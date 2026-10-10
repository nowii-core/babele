# Babele

> Un compilatore source-to-source universale. Scrivi una volta, compila in 14 linguaggi diversi.

## Cos'è Babele

Babele prende in input un linguaggio moderno (`.babe`) e lo traduce in codice sorgente leggibile in 14 linguaggi: da C a COBOL, da Rust a Forth, da Assembly a Haskell.

## Architettura

| Frontend | Middle-end | Backend |
|----------|------------|---------|
| OCaml    | Rust       | C       |
| Haskell  | Prolog     | C++     |
| Lisp     | Erlang     | Rust    |
|          | Scala      | Assembly|
|          |            | Fortran |
|          |            | Ada     |
|          |            | COBOL   |
|          |            | Forth   |

## Stato

In sviluppo — Fase 1: Fondamenta.

## Licenza

MIT
