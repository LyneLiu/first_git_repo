%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 十一月 2014 18:06
%%%-------------------------------------------------------------------
-module(socket_server).
-author("Administrator").
-behaviour(gen_server).

%% API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/3]).
-export([accept_loop/1]).

-define(TCP_OPTION,[binary,{packet,2},{active,false},{reuseaddr,true}]).

-record(server_state,{
  port,
  loop,
  ip = any,
  lsocket = null}).
%% 启动gen_server服务器
%% Name：服务器的名称
%% Port：为TCP分配的端口
%% Loop：对套接字Socket接收数据的处理方式
start(Name,Port,Loop) ->
  State = #server_state{port = Port,loop = Loop},
  gen_server:start_link({local,Name},?MODULE,State,[]).

%% 初始化服务器监听Listen接口
init(State = #server_state{port = Port})  ->
  io:format("The State is:~p~n",[State]),
  case gen_tcp:listen(Port,?TCP_OPTION) of
    {ok,LSocket} ->
      io:format("are you all right?"),
      NewState = State#server_state{lsocket = LSocket},
      {ok,accept(NewState)};
    {error,Reason}  ->
      {error,Reason}
  end.

%% 为保证健壮性，我们需要使用proc_lib：spawn来创建进程
accept(State = #server_state{loop = Loop,lsocket = LSocket})  ->
  proc_lib:spawn(?MODULE,accept_loop,[{self(),LSocket,Loop}]),
  State.
%% 使用echo模块的loop函数实现对socket数据的管理
accept_loop({Server,LSocket,{M,F}}) ->
  {ok,Socket} = gen_tcp:accept(LSocket),
  gen_server:cast(Server,{accepted,self()}),
  M:F(Socket).

handle_call(_Msg,_Caller,State) -> {noreply,State}.
handle_cast({accepted,_Pid},State = #server_state{})  ->
  {noreply,State}.
handle_info(_Msg,Library) -> {noreply,Library}.
terminate(_Reason,_Library) -> ok.
code_change(_OldVersion,Library,_Extra) -> {ok,Library}.