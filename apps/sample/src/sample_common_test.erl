-module(sample_common_test).

-include_lib("eunit/include/eunit.hrl").
-include("sample.hrl").

%% API
reg_test() ->
  ?assertEqual({ok,sms_sent}, sample_common:reg(<<"1">>, 123)),
  ?assertEqual({ok,sms_sent}, sample_common:reg(<<"2">>, 1234)),
  ?assertEqual({ok,sms_sent}, sample_common:reg(<<"3">>, 12345)),
  ?assertEqual({ok,sms_sent}, sample_common:reg(<<"4">>, 123456)),
  ok.
