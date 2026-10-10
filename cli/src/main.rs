use std::env;
use std::fs;
use std::process;

mod codegen_c;
mod codegen_cobol;
mod codegen_python;
mod codegen_js;
mod codegen_rust;
mod codegen_swift;
mod lexer;
mod parser;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut input_path: Option<String> = None;
    let mut target = "c".to_string();

    let mut i = 1;
    while i < args.len() {
        let a = &args[i];
        if let Some(t) = a.strip_prefix("--target=") {
            target = t.to_string();
        } else {
            input_path = Some(a.clone());
        }
        i += 1;
    }

    let input_path = match input_path {
        Some(p) => p,
        None => {
            eprintln!("Uso: babele <file.babe> [--target=c|cobol|python|js|rust|swift]");
            process::exit(1);
        }
    };

    let source = fs::read_to_string(&input_path).unwrap_or_else(|e| {
        eprintln!("Errore lettura {}: {}", input_path, e);
        process::exit(1);
    });

    let tokens = lexer::tokenize(&source);
    let program = parser::parse(&tokens).unwrap_or_else(|e| {
        eprintln!("Errore parsing: {}", e);
        process::exit(1);
    });

    let (ext, code) = match target.as_str() {
        "c" => ("c", codegen_c::generate(&program)),
        "cobol" | "cob" => ("cob", codegen_cobol::generate(&program)),
        "python" | "py" => ("py", codegen_python::generate(&program)),
        "js" | "javascript" => ("js", codegen_js::generate(&program)),
        "rust" | "rs" => ("rs", codegen_rust::generate(&program)),
        "swift" => ("swift", codegen_swift::generate(&program)),
        other => {
            eprintln!("Target non supportato: {}", other);
            eprintln!("Target disponibili: c, cobol, python, js, rust, swift");
            process::exit(1);
        }
    };

    let output_path = input_path.replace(".babe", &format!(".{}", ext));
    fs::write(&output_path, &code).unwrap_or_else(|e| {
        eprintln!("Errore scrittura {}: {}", output_path, e);
        process::exit(1);
    });

    println!("✓ Target:   {}", target);
    println!("✓ Generato: {}", output_path);
}
