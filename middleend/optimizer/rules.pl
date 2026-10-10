% Regole di ottimizzazione
optimize(add(X, 0), X) :- !.
optimize(add(0, X), X) :- !.
optimize(mul(X, 1), X) :- !.
optimize(mul(1, X), X) :- !.
optimize(mul(_, 0), 0) :- !.
optimize(sub(X, X), 0) :- !.
