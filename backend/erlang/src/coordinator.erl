%%% Coordinator di Babele in Erlang
-module(babele_coordinator).
-behaviour(gen_server).

-export([start_link/0, compile/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, code_change/3]).

-record(state, {workers = [] :: [pid()], pending = []}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

compile(Files) ->
    gen_server:call(?MODULE, {compile, Files}, infinity).

init([]) ->
    {ok, #state{}}.

handle_call({compile, Files}, _From, State) ->
    Results = lists:map(fun(F) -> {F, ok} end, Files),
    {reply, Results, State};
handle_call(_Req, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_Old, State, _Extra) ->
    {ok, State}.
