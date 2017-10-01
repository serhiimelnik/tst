-module(login).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include("sample.hrl").

main()  ->
  #dtl{file="index",app=sample,bindings=[{body,body()}]}.

body() ->
  [ #span   { id=display },    #br{},
    #button { id=loginButton, body="Login",postback=login} ].

event(init) ->
  case wf:user() of
    undefined -> wf:redirect("/");
    _         -> ok
  end;
event(login) ->
  {ok, Auth} = kvs:get('Auth', n2o_session:session_id()),
  kvs:put(Auth#'Auth'{type=verify}),
  io:format("AUTH  LOGIN:  ~p~n", [Auth]),
  wf:redirect("/index");
event(E) -> wf:info(?MODULE,"Unknown Event: ~p~n",[E]).
