-module(sample_common).
-include_lib("n2o/include/wf.hrl").
-include("sample.hrl").

%% API
-export([reg/1]).

reg(Phone) ->
  io:format("Phone: ~p~n", [Phone]),
  wf:user(Phone),
  Code = rand:uniform(99999),

  kvs:put(#'Auth'{
    token     = n2o_session:session_id(),
    services  = [],
    type      = reg,
    phone     = Phone,
    sms_code  = wf:to_binary(Code),
    attempts  = 3
  }),

  Code.
