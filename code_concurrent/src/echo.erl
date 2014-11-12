%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 十一月 2014 9:52
%%%-------------------------------------------------------------------
-module(echo).
-author("Administrator").

%% API
-export([listen/1, loop/1]).

-define(TCP_OPTIONS,[binary,{packet,2},{active,false},{reuseaddr,true}]).

%% the parent process owns both the listen socket and the accept loop
listen(Port)  ->
  {ok,LSocket} = gen_tcp:listen(Port,?TCP_OPTIONS),
  accept(LSocket).

accept(LSocket) ->
  {ok,Socket} = gen_tcp:accept(LSocket),
  spawn(fun() -> loop(Socket) end),
  accept(LSocket).


loop(Socket)  ->
  case gen_tcp:recv(Socket,0) of
    {ok,Data} ->
      io:format("The Data is ~p~n",[Data]),
      gen_tcp:send(Socket,Data),
      io:format("test here 1~n"),
      loop(Socket);
    {error,closed}  ->
      io:format("it is wrong!!!~n"),
      ok
  end.