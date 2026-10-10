# Architettura di Babele

## Pipeline

source.babe -> LEXER (OCaml) -> PARSER (OCaml) -> AST (OCaml)
           -> TYPECHECKER (Haskell) -> IR (Rust) -> OPTIMIZER (Rust+Prolog)
           -> CODEGEN (C, C++, Rust, ASM, Fortran, Ada, COBOL, Forth)

## Componenti

### Frontend
- parser/ (OCaml)
- typechecker/ (Haskell)
- macros/ (Lisp)

### Middle-end
- ir/ (Rust)
- optimizer/ (Rust + Prolog)
- distributed/ (Erlang + Scala)

### Backend
- c/, cpp/, rust/, asm/, fortran/, ada/, cobol/, forth/

### Runtime
- jit/ (C++)
- embedded/ (Forth)
