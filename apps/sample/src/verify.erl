-module(verify).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include("sample.hrl").

main()  ->
  #dtl{file="index",app=sample,bindings=[{body,body()}]}.

body() ->
  [ #span   { id=display },    #br{},
    #span   { body="Code: "},  #number{id=code,autofocus=true},
    #button { id=verifyButton, body="Verify",postback=verify,source=[code]}, #br{},
    #button { id=resendButton, body="Resend",postback=resend} ].

event(init) ->
  case wf:user() of
    undefined -> wf:redirect("/");
    _         -> ok
  end;
event(resend) ->
  case kvs:get('Auth', n2o_session:session_id()) of
    {ok, #'Auth'{}=Auth} ->
      Auth1 = Auth#'Auth'{type=resend},
      kvs:put(Auth1),
      io:format("AUTH  RESEND  OK:  ~p~n", [Auth1]);
    {error, _} ->
      io:format("AUTH  RESEND  SESSION  NOT  FOUND"),
      wf:redirect("/")
  end;
event(verify) ->
  Code = wf:q(code),
  case kvs:get('Auth', n2o_session:session_id()) of
    {ok, #'Auth'{sms_code=Code1, attempts=Attempts}=Auth} when Attempts > 0 ->
      case Code1 =:= Code of
        true  ->
          kvs:put(Auth#'Auth'{type=verify}),
          io:format("AUTH  VERIFY  SMS:  ~p~n", [Auth]),
          wf:redirect("/login");
        false ->
          update_attempts(Auth)
      end;
    _ -> wf:redirect("/")
  end;
event(E) -> wf:info(?MODULE,"Unknown Event: ~p~n",[E]).

update_attempts(#'Auth'{attempts=Attempts}=Auth) when Attempts > 0 ->
  kvs:put(Auth#'Auth'{attempts=Attempts - 1});
update_attempts(#'Auth'{token = Token}) ->
  kvs:delete('Auth', Token),
  wf:redirect("/").