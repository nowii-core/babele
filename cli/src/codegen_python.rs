use crate::parser::{BinOp, Expr, Program, Stmt};

pub fn generate(program: &Program) -> String {
    let mut out = String::new();
    out.push_str("# Generato da Babele\n\n");
    out.push_str("def main():\n");
    if program.main_body.is_empty() {
        out.push_str("    pass\n");
    } else {
        gen_body(&mut out, &program.main_body, 1);
    }
    out.push_str("\nif __name__ == \"__main__\":\n");
    out.push_str("    main()\n");
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
                out.push_str(&format!("{} = {}\n", name, expr_to_py(value)));
            }
            Stmt::Assign { name, value } => {
                indent(out, level);
                out.push_str(&format!("{} = {}\n", name, expr_to_py(value)));
            }
            Stmt::Print(e) => {
                indent(out, level);
                out.push_str(&format!("print({})\n", expr_to_py(e)));
            }
            Stmt::If { cond, then_body, else_body } => {
                indent(out, level);
                out.push_str(&format!("if {}:\n", expr_to_py(cond)));
                if then_body.is_empty() {
                    indent(out, level + 1);
                    out.push_str("pass\n");
                } else {
                    gen_body(out, then_body, level + 1);
                }
                if !else_body.is_empty() {
                    indent(out, level);
                    out.push_str("else:\n");
                    gen_body(out, else_body, level + 1);
                }
            }
            Stmt::While { cond, body } => {
                indent(out, level);
                out.push_str(&format!("while {}:\n", expr_to_py(cond)));
                if body.is_empty() {
                    indent(out, level + 1);
                    out.push_str("pass\n");
                } else {
                    gen_body(out, body, level + 1);
                }
            }
        }
    }
}

fn expr_to_py(e: &Expr) -> String {
    match e {
        Expr::IntLit(n) => n.to_string(),
        Expr::StrLit(s) => format!("\"{}\"", s),
        Expr::BoolLit(true) => "True".to_string(),
        Expr::BoolLit(false) => "False".to_string(),
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
            format!("({} {} {})", expr_to_py(l), op_str, expr_to_py(r))
        }
    }
}
