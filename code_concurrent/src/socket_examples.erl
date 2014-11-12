%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 十一月 2014 17:05
%%%-------------------------------------------------------------------
-module(socket_examples).
-author("Administrator").

%% API
-export([error_test/0]).

error_test()  ->
  Pid = spawn(fun() -> error_test_server() end),
  register(error_test,Pid),
  timer:sleep(2000),
  {ok,Socket} = gen_tcp:connect("localhost",4321,[binary,{packet,2}]),
  io:format("Connected to :~p~n",[Socket]),
  gen_tcp:send(Socket,<<"123">>),
  receive
    Any ->
      io:format("Any = ~p~n",[Any])
  end.

error_test_server() ->
  {ok,Listen} = gen_tcp:listen(4321,[binary,{packet,2}]),
  {ok,Socket} = gen_tcp:accept(Listen),
  error_test_server_loop(Socket).

error_test_server_loop(Socket)  ->
  receive
    {tcp,Socket,Data} ->
      io:format("Receive the Data:~p~n",[Data]),
      _Msg = binary_to_list(Data),
      gen_tcp:send(Socket,<<"I have received the data!">>),
      error_test_server_loop(Socket)
  end.