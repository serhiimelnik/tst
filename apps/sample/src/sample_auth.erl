-module(sample_auth).
-compile(export_all).

info(Message,Req,State) ->
  wf:info(?MODULE, "Msg: ~p~n", [Message]),

  {unknown,Message,Req,State}.
