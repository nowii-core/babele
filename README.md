# Babele

<p align="center">
  <b>A Universal Source-to-Source Compiler: Write Once, Compile to 30+ Languages</b>
</p>

<p align="center">
  <a href="https://github.com/nowii-core/babele/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-007ec6?style=for-the-badge" alt="License">
  </a>
  <a href="https://github.com/nowii-core/babele/releases">
    <img src="https://img.shields.io/github/v/release/nowii-core/babele?style=for-the-badge&color=blue" alt="Release">
  </a>
  <img src="https://img.shields.io/badge/Languages-30%2B-blueviolet?style=for-the-badge" alt="Languages">
  <img src="https://img.shields.io/badge/Working_Backends-6-success?style=for-the-badge" alt="Backends">
  <img src="https://img.shields.io/badge/Status-Alpha-orange?style=for-the-badge" alt="Status">
</p>

<p align="center">
  <a href="#-overview">Overview</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-project-architecture">Architecture</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-contact">Contact</a>
</p>

---

</div>

## Overview

**Babele** is a universal source-to-source compiler designed to bridge the gap between modern software development and legacy systems. Millions of lines of COBOL, Fortran, and Ada run in production in banks, airlines, and governments, yet the developers who wrote them are retiring, and rewriting them by hand costs millions. 

Babele solves this. You write modern code once, and Babele automatically generates idiomatic, readable, and maintainable legacy code. While most compilers support only 2-3 backends, Babele targets over 30 languages, spanning 72 years of computer science history—from 1949 to 2021. It is not just a compiler; it is a bridge between worlds that never spoke to each other.

---

## Preview

![Babele Demo](docs/images/demo.png)

---

## Key Features

- **Universal Compilation:** Write in a single `.babe` file and compile it to multiple completely different ecosystems.
- **6 Working Backends:** Production-ready code generation for C, Python, JavaScript, Rust, Swift, and COBOL.
- **Extensive Language Support:** Supports variables (`let`), arithmetic, comparison, booleans, strings, integers, `print(...)`, `if / else`, and `while` loops.
- **30+ Planned Backends:** A massive roadmap covering Systems (C++, Zig, Assembly), Legacy Enterprise (Fortran, Ada, Forth), Functional (Haskell, OCaml, Erlang), Formal Research (Lean 4, Coq, Agda), and Historical (Smalltalk, Algol 68, APL) languages.
- **Clean Architecture:** A robust Lexer and Parser written in Rust generates an Abstract Syntax Tree (AST) before passing it to independent code generators.

---

## Tech Stack

### Compiler Core
- **Rust:** The primary language used for the Lexer, Parser, and AST generation, ensuring memory safety and lightning-fast execution.

### Backends (Code Generators)
- Modular architecture where each target language (C, COBOL, Python, JS, Rust, Swift) has its own independent generator.

---

## Project Architecture

```
source.babe
     |
     v
Lexer / Parser       (Rust)    -> AST
     |
     v
Code Generators      -> C, COBOL, Python, JS, Rust, Swift, ...
(per-target)
```

---

## Quick Start

### Prerequisites
- **Rust and Cargo** installed on your system.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nowii-core/babele.git
   cd babele
   ```

2. **Build the compiler:**
   ```bash
   cargo build --release
   ```

3. **Compile to any target:**
   ```bash
   ./target/release/babele examples/hello.babe --target=c
   ./target/release/babele examples/hello.babe --target=cobol
   ./target/release/babele examples/hello.babe --target=python
   ./target/release/babele examples/hello.babe --target=js
   ./target/release/babele examples/hello.babe --target=rust
   ./target/release/babele examples/hello.babe --target=swift
   ```

---

## Contributing

Every backend is independent. If you are an expert in COBOL, Fortran, Ada, or Forth, or if you want to help build the future of source-to-source compilation, there is a place for you. 

Open an [Issue](https://github.com/nowii-core/babele/issues) to discuss which backend or feature you would like to work on.

---

## License

This project is distributed under the **MIT** license. See the [`LICENSE`](./LICENSE) file for more information.

---

## Contact & Support

- **Maintainer:** [@nowii-core](https://github.com/nowii-core)
- **Bug Reports & Feature Requests:** If you encounter an issue or would like to suggest an improvement, open an [Issue](https://github.com/nowii-core/babele/issues) or submit a [Pull Request](https://github.com/nowii-core/babele/pulls).

---

<div align="center">
  <sub>Developed by <b>nowii-core</b></sub>
</div>
