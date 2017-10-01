-module(sample_common).
-include_lib("n2o/include/wf.hrl").
-include("sample.hrl").

%% API
-export([reg/2, resend/1, verify/2]).

reg(Token, Phone) ->
  io:format("Phone: ~p~n", [Phone]),
  wf:user(Phone),
  Code = rand:uniform(99999),

  kvs:put(#'Auth'{
    token     = Token,
    services  = [],
    type      = reg,
    phone     = Phone,
    sms_code  = wf:to_binary(Code),
    attempts  = 3
  }),

  io:format("AUTH REG SMS: ~p~n", [{Token, Code}]),

  {ok,sms_sent}.

resend(Token) ->
  case kvs:get('Auth', Token) of
    {ok, #'Auth'{}=Auth} ->
      Auth1 = Auth#'Auth'{type=resend},
      kvs:put(Auth1),
      io:format("AUTH  RESEND  OK:  ~p~n", [Auth1]),
      {ok,sms_sent};
    {error, _} ->
      io:format("AUTH  RESEND  SESSION  NOT  FOUND"),
      {error,session_not_found}
  end.

verify(Token, Code) ->
  case kvs:get('Auth', Token) of
    {ok, #'Auth'{sms_code=Code1, attempts=Attempts}=Auth} when Attempts > 0 ->
      case Code1 =:= Code of
        true  ->
          kvs:put(Auth#'Auth'{type=verify}),
          io:format("AUTH  VERIFY  SMS:  ~p~n", [Auth]),
          {ok,verifyed};
        false ->
          update_attempts(Auth),
          {error,invalid_code}
      end;
    _ -> {error,session_not_found}
  end.

update_attempts(#'Auth'{attempts=Attempts}=Auth) when Attempts > 0 ->
  Attempts1 = Attempts - 1,
  kvs:put(Auth#'Auth'{attempts=Attempts1}),
  n2o_async:send("looper", Attempts1);
update_attempts(#'Auth'{token = Token}) ->
  kvs:delete('Auth', Token),
  wf:redirect("/").
