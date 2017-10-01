-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include("sample.hrl").

main()  ->
  #dtl{file="index",app=sample,bindings=[{body,body()}]}.

body() ->
  [ #span   { id=display },    #br{},
    #button { id=loginButton, body="Logout",postback=logout} ].

event(init) ->
  case wf:user() of
    undefined -> wf:redirect("/");
    _         -> ok
  end;
event(logout) ->
  {ok, Auth} = kvs:get('Auth', n2o_session:session_id()),
  io:format("AUTH  LOGOUT:  ~p~n", [Auth]),
  kvs:delete('Auth', Auth#'Auth'.token),
  wf:redirect("/");
event(E) -> wf:info(?MODULE,"Unknown Event: ~p~n",[E]).
