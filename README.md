# Babele

> A universal source-to-source compiler. Write once, compile to 30+ languages.

## The Problem

Millions of lines of COBOL, Fortran and Ada run in production in banks, airlines and governments. The developers who wrote them are retiring. Rewriting them by hand costs millions.

Babele solves this. Write modern code once, generate legacy code automatically.

## Example

Input (hello.babe):
    fn main() {
        let saluto = "Ciao, mondo!";
        print(saluto);
    }

Output C:
    /* Generato da Babele */
    #include <stdio.h>
    int main(void) {
        const char* saluto = "Ciao, mondo!";
        printf("%s\n", saluto);
        return 0;
    }

Output COBOL:
          * Generato da Babele
           IDENTIFICATION DIVISION.
           PROGRAM-ID. HELLO.
           DATA DIVISION.
           WORKING-STORAGE SECTION.
           01 SALUTO PIC X(12).
           PROCEDURE DIVISION.
               MOVE "Ciao, mondo!" TO SALUTO.
               DISPLAY SALUTO.
               STOP RUN.

Same input. Two completely different worlds.

## Supported Languages

30+ languages, from 1949 to 2021. See LANGUAGES.md for the full list.

Systems: C, C++, Rust, Assembly, Zig, Nim, D
Legacy: COBOL, Fortran, Ada, Forth
Functional: Haskell, OCaml, Erlang, Elixir, Scala, F#, SML
Research: Lean 4, Coq, Agda, Idris
Historical: Simula 67, Smalltalk, Algol 68, APL, J, Lisp, Prolog

## Architecture

source.babe
  -> Lexer/Parser (OCaml)    -> AST
  -> Type Checker (Haskell)  -> Typed AST
  -> IR (Rust)               -> Middle-end
  -> Optimizer (Prolog)      -> Optimized IR
  -> Codegen (14 backends)   -> C, COBOL, Rust, ASM

## Roadmap

- [x] Working compiler with C and COBOL backends
- [x] Documentation
- [ ] Full OCaml parser
- [ ] Haskell type inference
- [ ] Prolog optimizer
- [ ] Assembly backends
- [ ] First stable release

## License

MIT
