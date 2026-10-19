# Babele

> A universal source-to-source compiler. Write once, compile to 30+ languages.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/nowii-core/babele)](https://github.com/nowii-core/babele/releases)
[![Languages](https://img.shields.io/badge/languages-30%2B-blueviolet)](LANGUAGES.md)
[![Backends](https://img.shields.io/badge/working_backends-6-success)]()
[![Status](https://img.shields.io/badge/status-alpha-orange)]()

![Babele demo](docs/images/demo.png)

## The Problem

Millions of lines of COBOL, Fortran and Ada run in production in banks, airlines and governments. The developers who wrote them are retiring. Rewriting them by hand costs millions of euros.

Babele solves this. You write modern code once, and Babele generates legacy code automatically - idiomatic, readable, and maintainable.

## One Input, Six Languages

The same .babe file compiles to C, Python, JavaScript, Rust, Swift and COBOL.

Input - examples/hello.babe:

    fn main() {
        let saluto = "Ciao, mondo!";
        print(saluto);
        let x = 40 + 2;
        print(x);
        let n = 10;
        let somma = 0;
        let i = 1;
        while i < n {
            somma = somma + i;
            i = i + 1;
        }
        print(somma);
        if somma > 50 {
            print("Maggiore di 50");
        } else {
            print("Minore o uguale a 50");
        }
    }

Output C - hello.c:

    #include <stdio.h>
    #include <stdbool.h>

    static inline void babele_print_int(int x) { printf("%d\n", x); }
    static inline void babele_print_str(const char* x) { printf("%s\n", x); }

    #define BABELE_PRINT(x) _Generic((x), \
        int: babele_print_int, \
        const char*: babele_print_str \
    )(x)

    int main(void) {
        __auto_type saluto = "Ciao, mondo!";
        BABELE_PRINT(saluto);
        __auto_type x = (40 + 2);
        BABELE_PRINT(x);
        return 0;
    }

Output Python - hello.py:

    def main():
        saluto = "Ciao, mondo!"
        print(saluto)
        x = (40 + 2)
        print(x)

    if __name__ == "__main__":
        main()

Output COBOL - hello.cob:

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

Same input. Six completely different worlds.

## Quick Start

    git clone https://github.com/nowii-core/babele.git
    cd babele
    cargo build --release

Compile to any target:

    ./target/release/babele examples/hello.babe --target=c
    ./target/release/babele examples/hello.babe --target=cobol
    ./target/release/babele examples/hello.babe --target=python
    ./target/release/babele examples/hello.babe --target=js
    ./target/release/babele examples/hello.babe --target=rust
    ./target/release/babele examples/hello.babe --target=swift

## Language Features

- Variables (let) and assignment
- Arithmetic: +, -, *, /
- Comparison: <, >, ==, !=
- Booleans: true, false
- Strings and integers
- print(...)
- if / else
- while

## Working Backends

- C (.c)
- COBOL (.cob)
- Python (.py)
- JavaScript (.js)
- Rust (.rs)
- Swift (.swift)

## Planned Backends

30+ languages in the full roadmap, spanning 72 years of computer science history - from 1949 to 2021.

- Systems: C, C++, Rust, Assembly, Zig, Nim, D
- Legacy Enterprise: COBOL, Fortran, Ada, Forth
- Functional: Haskell, OCaml, Erlang, Elixir, Scala, F#, Standard ML
- Formal Research: Lean 4, Coq (Rocq), Agda, Idris
- Historical: Simula 67, Smalltalk, Algol 68, APL, J, Common Lisp, Prolog

See LANGUAGES.md for the complete list.

## Architecture

    source.babe
         |
         v
    Lexer / Parser       (Rust)    -> AST
         |
         v
    Code Generators      -> C, COBOL, Python, JS, Rust, Swift, ...
    (per-target)

See ARCHITECTURE.md for the full architecture including the future pipeline with OCaml, Haskell, Prolog and Erlang.

## Why So Many Languages

Because no one has ever done it. Every other compiler supports 2-3 backends. Babele targets 30+.

Each backend attracts a different community: COBOL for banking, Fortran for science, Ada for avionics, Haskell and OCaml for compiler research, Coq and Agda for formal verification.

Babele is not just a compiler - it is a bridge between worlds that never spoke to each other.

## Contributing

Every backend is independent. If you know COBOL, Fortran, Ada, or Forth - there is a place for you.

Open an issue to discuss which backend or feature you would like to work on.

## License

MIT - see LICENSE.
