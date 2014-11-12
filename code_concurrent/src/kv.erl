%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 十一月 2014 11:26
%%%-------------------------------------------------------------------
-module(kv).
-author("Administrator").

%% API
-export([start/0, stop/0, store/2, lookup/1]).
-export([init/1,handle_call/3,handle_cast/2,terminate/2]).
-behaviour(gen_server).

%% Key_Value server exercise
start() ->
  gen_server:start_link({local,kv},kv,arg1,[]).

stop()  ->
  gen_server:cast(kv,stop).

store(Key,Val)  ->
  gen_server:call(kv,{store,Key,Val}).

lookup(Key) ->
  gen_server:call(kv,{lookup,Key}).

init(args1)  ->
  io:format("Key-Value server string ~n"),
  {ok,dict:new()}.

handle_call({store,Key,Value},_From,Dict)  ->
  Dict1 = dict:store(Key,Value,Dict),
  {reply,succeed,Dict1};
handle_call({lookup,Key},_From,Dict) ->
  {reply,dict:find(Key,Dict)}.

handle_cast(stop,_Dict)  ->
  {stop,normal}.

terminate(Reason,_Dict)  ->
  io:format("K-V server terminating with reason:~p~n",[Reason]).

