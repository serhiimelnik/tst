-module(verify).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include("sample.hrl").

main()  ->
  #dtl{file="index",app=sample,bindings=[{body,body()}]}.

body() ->
  [ #span   { id=display },    #br{},
    #span   { id=attempts, body="Attempts: "}, #br{},
    #span   { body="Code: "},  #number{id=code,autofocus=true},
    #button { id=verifyButton, body="Verify",postback=verify,source=[code]}, #br{},
    #span   { id=error, body=""}, #br{},
    #button { id=resendButton, body="Resend",postback=resend} ].

event(init) ->
  case wf:user() of
    undefined -> wf:redirect("/");
    _         ->
      wf:async("looper",fun verify:loop/1),
      wf:async("errorLoop",fun verify:error_loop/1),
      {ok, Auth} = kvs:get('Auth', n2o_session:session_id()),
      n2o_async:send("looper", Auth#'Auth'.attempts),
      ok
  end;
event(resend) ->
  case sample_common:resend(n2o_session:session_id()) of
    {ok,sms_sent}             ->
      n2o_async:send("errorLoop", "Resended");
    {error,session_not_found} -> wf:redirect("/")
  end;
event(verify) ->
  Code = wf:q(code),
  case sample_common:verify(n2o_session:session_id(), Code) of
    {ok,verifyed}             -> wf:redirect("/login");
    {error,invalid_code}      -> n2o_async:send("errorLoop", "Error: Invalid code");
    {error,session_not_found} -> wf:redirect("/")
  end;
event(E) -> wf:info(?MODULE,"Unknown Event: ~p~n",[E]).

loop(M) ->
  DTL = #dtl{file="attempts",app=sample,bindings=[{attempts,M}]},
  wf:update(attempts, wf:jse(wf:render(DTL))),
  wf:flush().

error_loop(M) ->
  DTL = #dtl{file="errors",app=sample,bindings=[{error_msg,M}]},
  wf:update(error, wf:jse(wf:render(DTL))),
  wf:flush().
