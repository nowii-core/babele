\ Runtime di Babele in Forth
: babele-print ( c-addr u -- )
  type cr ;

: babele-newline ( -- )
  cr ;

: babele-space ( -- )
  space ;

: babele-dup ( n -- n n )
  dup ;
