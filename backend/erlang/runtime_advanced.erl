-module(babele_runtime_advanced).
-export([fib/1, fattoriale/1, is_primo/1, mcd/2, map_reduce/3]).
-export([start_worker_pool/1, distribute/2]).

fib(0) -> 0;
fib(1) -> 1;
fib(N) when N > 1 -> fib(N - 1) + fib(N - 2).

fattoriale(0) -> 1;
fattoriale(1) -> 1;
fattoriale(N) when N > 1 -> N * fattoriale(N - 1).

is_primo(N) when N < 2 -> false;
is_primo(2) -> true;
is_primo(N) when N rem 2 =:= 0 -> false;
is_primo(N) -> is_primo(N, 3).

is_primo(N, I) when I * I > N -> true;
is_primo(N, I) ->
    case N rem I of
        0 -> false;
        _ -> is_primo(N, I + 2)
    end.

mcd(A, 0) -> A;
mcd(A, B) -> mcd(B, A rem B).

map_reduce(MapFun, ReduceFun, List) ->
    Mapped = lists:map(MapFun, List),
    lists:foldl(ReduceFun, 0, Mapped).

start_worker_pool(N) ->
    [spawn(fun worker_loop/0) || _ <- lists:seq(1, N)].

worker_loop() ->
    receive
        {compile, From, Code} ->
            Result = compile_chunk(Code),
            From ! {result, Result},
            worker_loop();
        stop ->
            ok
    end.

compile_chunk(Code) ->
    {ok, byte_size(Code)}.

distribute(Workers, Tasks) ->
    lists:foreach(fun({Worker, Task}) ->
        Worker ! {compile, self(), Task}
    end, lists:zip(Workers, Tasks)),
    collect(length(Tasks), []).

collect(0, Acc) -> lists:reverse(Acc);
collect(N, Acc) ->
    receive
        {result, R} -> collect(N - 1, [R | Acc])
    after 5000 -> {error, timeout}
    end.
