use crate::parser::{BinOp, Expr, Program, Stmt};

pub fn generate(program: &Program) -> String {
    let mut out = String::new();
    out.push_str("      * Generato da Babele\n");
    out.push_str("       IDENTIFICATION DIVISION.\n");
    out.push_str("       PROGRAM-ID. HELLO.\n");
    out.push_str("       DATA DIVISION.\n");
    out.push_str("       WORKING-STORAGE SECTION.\n");

    // Dichiara variabili
    let mut counter = 0;
    collect_vars(&program.main_body, &mut |name, value| {
        let len = match value {
            Expr::StrLit(s) => s.len().max(1),
            _ => 32,
        };
        out.push_str(&format!(
            "       01 {} PIC X({}) VALUE SPACES.\n",
            name.to_uppercase(),
            len
        ));
        counter += 1;
    });
    if counter == 0 {
        out.push_str("       01 DUMMY PIC X.\n");
    }

    out.push_str("       PROCEDURE DIVISION.\n");
    gen_body(&mut out, &program.main_body, 1);
    out.push_str("           STOP RUN.\n");
    out
}

fn collect_vars<F: FnMut(&str, &Expr)>(stmts: &[Stmt], f: &mut F) {
    for s in stmts {
        match s {
            Stmt::Let { name, value } => f(name, value),
            Stmt::If { then_body, else_body, .. } => {
                collect_vars(then_body, f);
                collect_vars(else_body, f);
            }
            Stmt::While { body, .. } => collect_vars(body, f),
            _ => {}
        }
    }
}

fn indent(out: &mut String, level: usize) {
    for _ in 0..level { out.push_str("    "); }
}

fn gen_body(out: &mut String, stmts: &[Stmt], level: usize) {
    let pad = "    ".repeat(level + 3); // 4 + level per COBOL (area B)
    for stmt in stmts {
        match stmt {
            Stmt::Let { name, value } => {
                out.push_str(&format!(
                    "{}MOVE {} TO {}.\n",
                    pad,
                    expr_to_cobol(value),
                    name.to_uppercase()
                ));
            }
            Stmt::Assign { name, value } => {
                out.push_str(&format!(
                    "{}MOVE {} TO {}.\n",
                    pad,
                    expr_to_cobol(value),
                    name.to_uppercase()
                ));
            }
            Stmt::Print(e) => {
                out.push_str(&format!("{}DISPLAY {}.\n", pad, expr_to_cobol(e)));
            }
            Stmt::If { cond, then_body, else_body } => {
                out.push_str(&format!("{}IF {}\n", pad, expr_to_cobol(cond)));
                gen_body(out, then_body, level);
                if !else_body.is_empty() {
                    out.push_str(&format!("{}ELSE\n", pad));
                    gen_body(out, else_body, level);
                }
                out.push_str(&format!("{}END-IF.\n", pad));
            }
            Stmt::While { cond, body } => {
                out.push_str(&format!("{}PERFORM UNTIL {}\n", pad, expr_to_cobol(cond)));
                gen_body(out, body, level + 1);
                out.push_str(&format!("{}END-PERFORM.\n", pad));
            }
        }
    }
}

fn expr_to_cobol(e: &Expr) -> String {
    match e {
        Expr::IntLit(n) => n.to_string(),
        Expr::StrLit(s) => format!("\"{}\"", s),
        Expr::BoolLit(true) => "1".to_string(),
        Expr::BoolLit(false) => "0".to_string(),
        Expr::Ident(n) => n.to_uppercase(),
        Expr::BinOp(l, op, r) => {
            let op_str = match op {
                BinOp::Add => "+",
                BinOp::Sub => "-",
                BinOp::Mul => "*",
                BinOp::Div => "/",
                BinOp::Lt => "<",
                BinOp::Gt => ">",
                BinOp::Eq => "=",
                BinOp::Neq => "NOT =",
            };
            format!("({} {} {})", expr_to_cobol(l), op_str, expr_to_cobol(r))
        }
    }
}
