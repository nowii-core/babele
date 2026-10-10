NB. Babele J Compiler - array programming backend
NB. J e' un dialetto di APL sviluppato da Ken Iverson

NB. Definizione dei tipi primitivi
types =: 'Int';'Float';'String';'Bool';'Void'

NB. Parser combinator in stile J
NB. Ogni parser e' una funzione che prende input e ritorna (resto; risultato)

NB. Parse un intero
parseInt =: 3 : 0
  txt =. y
  num =. 0". txt
  if. num = _ do.
    _1
  else.
    (}.txt);num
  end.
)

NB. Parse un identificatore
parseIdent =: 3 : 0
  valid =. (#~ (e.&('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_')) y
  first =. {.valid
  if. first e. 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_' do.
    (}.y);valid
  else.
    _1
  end.
)

NB. Trasposta di matrice
transpose =: |:

NB. Somma cumulativa
scanPlus =: +/\

NB. Prodotto cumulativo
scanTimes =: */\

NB. Filtro positivi
filterPos =: #~ 0&<

NB. Tabella di moltiplicazione
multiplicationTable =: */~ 1 + i.

NB. Fibonacci tramite ricorsione
fib =: 3 : 0
  if. y < 2 do. y
  else. (fib y-1) + fib y-2
  end.
)

NB. Primi N numeri di Fibonacci
fibs =: fib"0 @: i.

NB. Test
main =: 3 : 0
  v =. 1 + i. 10
  s =. +/v
  p =. */v
  m =. s % #v
  fib10 =. fibs 10
  s;p;m;fib10
)

main 0
