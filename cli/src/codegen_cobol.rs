use crate::parser::{Expr, Program, Stmt};

pub fn generate(program: &Program) -> String {
    let mut out = String::new();
    out.push_str("      * Generato da Babele\n");
    out.push_str("       IDENTIFICATION DIVISION.\n");
    out.push_str("       PROGRAM-ID. HELLO.\n");
    out.push_str("       DATA DIVISION.\n");
    out.push_str("       WORKING-STORAGE SECTION.\n");

    let mut counter = 0;
    for stmt in &program.main_body {
        if let Stmt::Let { name, value } = stmt {
            let len = match value {
                Expr::StringLit(s) => s.len().max(1),
                _ => 32,
            };
            out.push_str(&format!("       01 {} PIC X({}).\n", name.to_uppercase(), len));
            counter += 1;
        }
    }
    if counter == 0 {
        out.push_str("       01 DUMMY PIC X.\n");
    }
    out.push_str("       PROCEDURE DIVISION.\n");
    for stmt in &program.main_body {
        match stmt {
            Stmt::Let { name, value } => {
                out.push_str(&format!("           MOVE {} TO {}.\n", expr_to_cobol(value), name.to_uppercase()));
            }
            Stmt::Print(e) => {
                out.push_str(&format!("           DISPLAY {}.\n", expr_to_cobol(e)));
            }
        }
    }
    out.push_str("           STOP RUN.\n");
    out
}

fn expr_to_cobol(e: &Expr) -> String {
    match e {
        Expr::StringLit(s) => format!("\"{}\"", s),
        Expr::Ident(n) => n.to_uppercase(),
    }
}
