% Babele Prolog advanced runtime
fib(0, 0).
fib(1, 1).
fib(N, R) :- N > 1, N1 is N - 1, N2 is N - 2,
            fib(N1, R1), fib(N2, R2), R is R1 + R2.

fattoriale(0, 1).
fattoriale(N, R) :- N > 0, N1 is N - 1,
                    fattoriale(N1, R1), R is N * R1.

is_primo(2).
is_primo(N) :- N > 2, N mod 2 =\= 0, \+ divisibile(N, 3).
divisibile(N, I) :- I * I =< N, (N mod I =:= 0 ; I2 is I + 2, divisibile(N, I2)).

mcd(A, 0, A).
mcd(A, B, R) :- B > 0, A1 is A mod B, mcd(B, A1, R).

opt(add(X, 0), X).
opt(add(0, X), X).
opt(mul(X, 1), X).
opt(mul(1, X), X).
opt(mul(_, 0), 0).
opt(mul(0, _), 0).
opt(sub(X, 0), X).
opt(sub(X, X), 0).
opt(div(X, 1), X).
opt(add(A, B), R) :- integer(A), integer(B), R is A + B.
opt(mul(A, B), R) :- integer(A), integer(B), R is A * B.
