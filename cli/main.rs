use std::env;
use std::fs;
use std::process;

mod codegen_c;
mod lexer;
mod parser;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Uso: babele <file.babe>");
        process::exit(1);
    }

    let input_path = &args[1];
    let source = fs::read_to_string(input_path).unwrap_or_else(|e| {
        eprintln!("Errore lettura {}: {}", input_path, e);
        process::exit(1);
    });

    let tokens = lexer::tokenize(&source);
    let program = parser::parse(&tokens).unwrap_or_else(|e| {
        eprintln!("Errore parsing: {}", e);
        process::exit(1);
    });

    let c_code = codegen_c::generate(&program);
    let output_path = input_path.replace(".babe", ".c");
    fs::write(&output_path, &c_code).unwrap_or_else(|e| {
        eprintln!("Errore scrittura {}: {}", output_path, e);
        process::exit(1);
    });

    println!("✓ Generato: {}", output_path);
    println!("  Compila con: gcc {} -o hello", output_path);
    println!("  Esegui con:  ./hello");
}