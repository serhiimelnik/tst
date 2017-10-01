-module(sample_common_test).

-include_lib("eunit/include/eunit.hrl").
-include("sample.hrl").

%% API
reg_test() ->
  Token = n2o_session:session_id(),
  Code = integer_to_binary(sample_common:reg(123)),
  {ok, Auth} = kvs:get('Auth', Token),

  ?assertEqual(Code, Auth#'Auth'.sms_code),
  ok.
