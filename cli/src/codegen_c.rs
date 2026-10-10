use crate::parser::{Expr, Program, Stmt};

pub fn generate(program: &Program) -> String {
    let mut out = String::new();
    out.push_str("/* Generato da Babele */\n");
    out.push_str("#include <stdio.h>\n\n");
    out.push_str("int main(void) {\n");
    for stmt in &program.main_body {
        match stmt {
            Stmt::Let { name, value } => {
                out.push_str(&format!("    const char* {} = {};\n", name, expr_to_c(value)));
            }
            Stmt::Print(e) => {
                out.push_str(&format!("    printf(\"%s\\n\", {});\n", expr_to_c(e)));
            }
        }
    }
    out.push_str("    return 0;\n}\n");
    out
}

fn expr_to_c(e: &Expr) -> String {
    match e {
        Expr::StringLit(s) => format!("\"{}\"", s),
        Expr::Ident(n) => n.clone(),
    }
}
