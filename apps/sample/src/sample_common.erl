-module(sample_common).
-include_lib("n2o/include/wf.hrl").
-include("sample.hrl").

%% API
-export([reg/2]).

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
