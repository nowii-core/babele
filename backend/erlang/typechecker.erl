-module(babele_typechecker).
-export([infer/2, check_program/1, check_stmt/2, check_block/2]).
-export([value_type/1, binop_type/3, lookup/2, extend/3]).

-type ty() :: int | float | string | bool | void | {func, [ty()], ty()}.
-type value() :: {int, integer()}
               | {float, float()}
               | {string, binary()}
               | {bool, boolean()}.
-type expr() :: {lit, value()}
              | {var, binary()}
              | {binop, atom(), expr(), expr()}
              | {call, binary(), [expr()]}
              | {if_expr, expr(), expr(), expr()}.
-type stmt() :: {let_stmt, binary(), ty() | undefined, expr()}
              | {assign, binary(), expr()}
              | {print, expr()}
              | {return_stmt, expr() | none}
              | {if_stmt, expr(), [stmt()], [stmt()]}
              | {while_stmt, expr(), [stmt()]}
              | {block, [stmt()]}.
-type env() :: [{binary(), ty()}].

-spec value_type(value()) -> ty().
value_type({int, _}) -> int;
value_type({float, _}) -> float;
value_type({string, _}) -> string;
value_type({bool, _}) -> bool.

-spec lookup(binary(), env()) -> {ok, ty()} | error.
lookup(_Name, []) -> error;
lookup(Name, [{Name, T} | _]) -> {ok, T};
lookup(Name, [_ | Rest]) -> lookup(Name, Rest).

-spec extend(env(), binary(), ty()) -> env().
extend(Env, Name, Ty) -> [{Name, Ty} | Env].

-spec binop_type(atom(), ty(), ty()) -> {ok, ty()} | error.
binop_type('+', int, int) -> {ok, int};
binop_type('+', float, float) -> {ok, float};
binop_type('+', string, string) -> {ok, string};
binop_type('-', int, int) -> {ok, int};
binop_type('-', float, float) -> {ok, float};
binop_type('*', int, int) -> {ok, int};
binop_type('*', float, float) -> {ok, float};
binop_type('/', int, int) -> {ok, int};
binop_type('/', float, float) -> {ok, float};
binop_type('==', T, T) -> {ok, bool};
binop_type('!=', T, T) -> {ok, bool};
binop_type('<', int, int) -> {ok, bool};
binop_type('>', int, int) -> {ok, bool};
binop_type('&&', bool, bool) -> {ok, bool};
binop_type('||', bool, bool) -> {ok, bool};
binop_type(_, _, _) -> error.

-spec infer(env(), expr()) -> {ok, ty()} | {error, binary()}.
infer(_Env, {lit, V}) -> {ok, value_type(V)};
infer(Env, {var, Name}) ->
    case lookup(Name, Env) of
        {ok, T} -> {ok, T};
        error -> {error, <<"Variable undefined: ", Name/binary>>}
    end;
infer(Env, {binop, Op, L, R}) ->
    case {infer(Env, L), infer(Env, R)} of
        {{ok, LT}, {ok, RT}} ->
            case binop_type(Op, LT, RT) of
                {ok, T} -> {ok, T};
                error -> {error, <<"Type mismatch">>}
            end;
        {{error, E}, _} -> {error, E};
        {_, {error, E}} -> {error, E}
    end;
infer(_Env, {call, _Name, _Args}) -> {ok, void};
infer(Env, {if_expr, Cond, Then, Else}) ->
    case infer(Env, Cond) of
        {ok, bool} ->
            case {infer(Env, Then), infer(Env, Else)} of
                {{ok, TT}, {ok, TE}} when TT =:= TE -> {ok, TT};
                {{ok, _}, {ok, _}} -> {error, <<"Branches have different types">>};
                {{error, E}, _} -> {error, E};
                {_, {error, E}} -> {error, E}
            end;
        {ok, _} -> {error, <<"If condition must be bool">>};
        {error, E} -> {error, E}
    end.

-spec check_stmt(env(), stmt()) -> {ok, env()} | {error, binary()}.
check_stmt(Env, {let_stmt, Name, undefined, E}) ->
    case infer(Env, E) of
        {ok, T} -> {ok, extend(Env, Name, T)};
        {error, Err} -> {error, Err}
    end;
check_stmt(Env, {let_stmt, Name, DeclaredTy, E}) ->
    case infer(Env, E) of
        {ok, DeclaredTy} -> {ok, extend(Env, Name, DeclaredTy)};
        {ok, _} -> {error, <<"Declared type mismatch">>};
        {error, Err} -> {error, Err}
    end;
check_stmt(Env, {assign, Name, E}) ->
    case {lookup(Name, Env), infer(Env, E)} of
        {{ok, _}, {ok, _}} -> {ok, Env};
        {error, _} -> {error, <<"Undefined variable">>};
        {_, {error, Err}} -> {error, Err}
    end;
check_stmt(Env, {print, E}) ->
    case infer(Env, E) of
        {ok, _} -> {ok, Env};
        {error, Err} -> {error, Err}
    end;
check_stmt(Env, {return_stmt, none}) -> {ok, Env};
check_stmt(Env, {return_stmt, E}) ->
    case infer(Env, E) of
        {ok, _} -> {ok, Env};
        {error, Err} -> {error, Err}
    end;
check_stmt(Env, {if_stmt, Cond, Then, Else}) ->
    case infer(Env, Cond) of
        {ok, bool} ->
            case {check_block(Env, Then), check_block(Env, Else)} of
                {{ok, _}, {ok, _}} -> {ok, Env};
                {{error, E}, _} -> {error, E};
                {_, {error, E}} -> {error, E}
            end;
        {ok, _} -> {error, <<"If condition must be bool">>};
        {error, E} -> {error, E}
    end;
check_stmt(Env, {while_stmt, Cond, Body}) ->
    case infer(Env, Cond) of
        {ok, bool} ->
            case check_block(Env, Body) of
                {ok, _} -> {ok, Env};
                {error, E} -> {error, E}
            end;
        {ok, _} -> {error, <<"While condition must be bool">>};
        {error, E} -> {error, E}
    end;
check_stmt(Env, {block, Body}) ->
    case check_block(Env, Body) of
        {ok, _} -> {ok, Env};
        {error, E} -> {error, E}
    end.

-spec check_block(env(), [stmt()]) -> {ok, env()} | {error, binary()}.
check_block(Env, []) -> {ok, Env};
check_block(Env, [S | Rest]) ->
    case check_stmt(Env, S) of
        {ok, Env1} -> check_block(Env1, Rest);
        {error, E} -> {error, E}
    end.

-spec check_program([{binary(), [stmt()]}]) -> ok | {error, binary()}.
check_program(Funcs) ->
    lists:foldl(
        fun({_Name, Body}, Acc) ->
            case Acc of
                ok ->
                    case check_block([], Body) of
                        {ok, _} -> ok;
                        {error, E} -> {error, E}
                    end;
                _ -> Acc
            end
        end,
        ok,
        Funcs
    ).
