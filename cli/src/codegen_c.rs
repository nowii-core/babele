use crate::parser::{BinOp, Expr, Program, Stmt};

pub fn generate(program: &Program) -> String {
    let mut out = String::new();
    out.push_str("/* Generato da Babele */\n");
    out.push_str("#include <stdio.h>\n");
    out.push_str("#include <stdbool.h>\n");
    out.push_str("#include <string.h>\n\n");
    out.push_str("static inline void babele_print_int(int x) { printf(\"%d\\n\", x); }\n");
    out.push_str("static inline void babele_print_long(long x) { printf(\"%ld\\n\", x); }\n");
    out.push_str("static inline void babele_print_llong(long long x) { printf(\"%lld\\n\", x); }\n");
    out.push_str("static inline void babele_print_double(double x) { printf(\"%g\\n\", x); }\n");
    out.push_str("static inline void babele_print_str(const char* x) { printf(\"%s\\n\", x); }\n\n");
    out.push_str("#define BABELE_PRINT(x) _Generic((x), \\\n");
    out.push_str("    int: babele_print_int, \\\n");
    out.push_str("    long: babele_print_long, \\\n");
    out.push_str("    long long: babele_print_llong, \\\n");
    out.push_str("    double: babele_print_double, \\\n");
    out.push_str("    float: babele_print_double, \\\n");
    out.push_str("    char*: babele_print_str, \\\n");
    out.push_str("    const char*: babele_print_str \\\n");
    out.push_str(")(x)\n\n");
    out.push_str("int main(void) {\n");
    gen_body(&mut out, &program.main_body, 1);
    out.push_str("    return 0;\n");
    out.push_str("}\n");
    out
}

fn indent(out: &mut String, level: usize) {
    for _ in 0..level { out.push_str("    "); }
}

fn gen_body(out: &mut String, stmts: &[Stmt], level: usize) {
    for stmt in stmts {
        match stmt {
            Stmt::Let { name, value } => {
                indent(out, level);
                out.push_str(&format!("__auto_type {} = {};\n", name, expr_to_c(value)));
            }
            Stmt::Assign { name, value } => {
                indent(out, level);
                out.push_str(&format!("{} = {};\n", name, expr_to_c(value)));
            }
            Stmt::Print(e) => {
                indent(out, level);
                out.push_str(&format!("BABELE_PRINT({});\n", expr_to_c(e)));
            }
            Stmt::If { cond, then_body, else_body } => {
                indent(out, level);
                out.push_str(&format!("if ({}) {{\n", expr_to_c(cond)));
                gen_body(out, then_body, level + 1);
                indent(out, level);
                out.push_str("}");
                if !else_body.is_empty() {
                    out.push_str(" else {\n");
                    gen_body(out, else_body, level + 1);
                    indent(out, level);
                    out.push_str("}");
                }
                out.push('\n');
            }
            Stmt::While { cond, body } => {
                indent(out, level);
                out.push_str(&format!("while ({}) {{\n", expr_to_c(cond)));
                gen_body(out, body, level + 1);
                indent(out, level);
                out.push_str("}\n");
            }
        }
    }
}

fn expr_to_c(e: &Expr) -> String {
    match e {
        Expr::IntLit(n) => n.to_string(),
        Expr::StrLit(s) => format!("\"{}\"", s),
        Expr::BoolLit(true) => "true".to_string(),
        Expr::BoolLit(false) => "false".to_string(),
        Expr::Ident(n) => n.clone(),
        Expr::BinOp(l, op, r) => {
            let op_str = match op {
                BinOp::Add => "+",
                BinOp::Sub => "-",
                BinOp::Mul => "*",
                BinOp::Div => "/",
                BinOp::Lt => "<",
                BinOp::Gt => ">",
                BinOp::Eq => "==",
                BinOp::Neq => "!=",
            };
            format!("({} {} {})", expr_to_c(l), op_str, expr_to_c(r))
        }
    }
}
