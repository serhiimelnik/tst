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

resend_test() ->
  reg_test(),

  ?assertEqual({ok,sms_sent}, sample_common:resend(<<"1">>)),
  ?assertEqual({ok,sms_sent}, sample_common:resend(<<"2">>)),
  ?assertEqual({error,session_not_found}, sample_common:resend(<<"5">>)),
  ?assertEqual({error,session_not_found}, sample_common:resend(<<"6">>)),
  ok.

verify_test() ->
  resend_test(),
  Token = <<"2">>,
  {ok, Auth} = kvs:get('Auth', Token),

  ?assertEqual({error,invalid_code}, sample_common:verify(Token, <<"asd">>)),
  ?assertEqual({error,session_not_found}, sample_common:verify(<<"asd">>, <<"asd">>)),
  ?assertEqual({ok,verifyed}, sample_common:verify(Token, Auth#'Auth'.sms_code)),
  ok.
