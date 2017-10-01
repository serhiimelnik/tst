-module(reg).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include("sample.hrl").

main()  ->
  #dtl{file="index",app=sample,bindings=[{body,body()}]}.

body() ->
  [ #span   { id=display },    #br{},
    #span   { body="Phone: "}, #number{id=phone,autofocus=true},
    #button { id=reqButton, body="Req",postback=req,source=[phone]} ].

event(init) ->
  wf:reg(n2o_session:session_id());
event(req) ->
  case wf:q(phone) of
    <<>>      -> wf:redirect("/");
    undefined -> wf:redirect("/");
    E         ->
      {ok,sms_sent} = sample_common:reg(n2o_session:session_id(), E),
      wf:redirect("/verify")
  end,
  ok;
event(E) -> wf:info(?MODULE,"Unknown Event: ~p~n",[E]).
