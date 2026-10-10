use crate::lexer::Token;

#[derive(Debug, Clone)]
pub enum BinOp { Add, Sub, Mul, Div, Lt, Gt, Eq, Neq }

#[derive(Debug, Clone)]
pub enum Expr {
    IntLit(i64),
    StrLit(String),
    BoolLit(bool),
    Ident(String),
    BinOp(Box<Expr>, BinOp, Box<Expr>),
}

#[derive(Debug, Clone)]
pub enum Stmt {
    Let { name: String, value: Expr },
    Assign { name: String, value: Expr },
    Print(Expr),
    If { cond: Expr, then_body: Vec<Stmt>, else_body: Vec<Stmt> },
    While { cond: Expr, body: Vec<Stmt> },
}

#[derive(Debug)]
pub struct Program { pub main_body: Vec<Stmt> }

pub fn parse(tokens: &[Token]) -> Result<Program, String> {
    let mut p = Parser { tokens: tokens.to_vec(), pos: 0 };
    p.parse_program()
}

struct Parser { tokens: Vec<Token>, pos: usize }

impl Parser {
    fn peek(&self) -> &Token {
        self.tokens.get(self.pos).unwrap_or(&Token::Eof)
    }
    fn advance(&mut self) -> Token {
        let t = self.tokens.get(self.pos).cloned().unwrap_or(Token::Eof);
        self.pos += 1;
        t
    }
    fn expect(&mut self, t: Token) -> Result<(), String> {
        let got = self.advance();
        if got == t { Ok(()) } else { Err(format!("Atteso {:?}, trovato {:?}", t, got)) }
    }
    fn parse_program(&mut self) -> Result<Program, String> {
        self.expect(Token::Fn)?;
        match self.advance() {
            Token::Ident(_) => {}
            t => return Err(format!("Atteso nome funzione, trovato {:?}", t)),
        }
        self.expect(Token::LParen)?;
        self.expect(Token::RParen)?;
        self.expect(Token::LBrace)?;
        let body = self.parse_body()?;
        Ok(Program { main_body: body })
    }
    fn parse_body(&mut self) -> Result<Vec<Stmt>, String> {
        let mut stmts = Vec::new();
        while self.peek() != &Token::RBrace && self.peek() != &Token::Eof {
            stmts.push(self.parse_stmt()?);
        }
        self.expect(Token::RBrace)?;
        Ok(stmts)
    }
    fn parse_stmt(&mut self) -> Result<Stmt, String> {
        match self.peek().clone() {
            Token::Let => {
                self.advance();
                let name = match self.advance() {
                    Token::Ident(n) => n,
                    t => return Err(format!("Atteso identificatore, trovato {:?}", t)),
                };
                self.expect(Token::Assign)?;
                let value = self.parse_expr()?;
                self.expect(Token::Semicolon)?;
                Ok(Stmt::Let { name, value })
            }
            Token::Print => {
                self.advance();
                self.expect(Token::LParen)?;
                let e = self.parse_expr()?;
                self.expect(Token::RParen)?;
                self.expect(Token::Semicolon)?;
                Ok(Stmt::Print(e))
            }
            Token::If => {
                self.advance();
                let cond = self.parse_expr()?;
                self.expect(Token::LBrace)?;
                let then_body = self.parse_body()?;
                let else_body = if self.peek() == &Token::Else {
                    self.advance();
                    self.expect(Token::LBrace)?;
                    self.parse_body()?
                } else { Vec::new() };
                Ok(Stmt::If { cond, then_body, else_body })
            }
            Token::While => {
                self.advance();
                let cond = self.parse_expr()?;
                self.expect(Token::LBrace)?;
                let body = self.parse_body()?;
                Ok(Stmt::While { cond, body })
            }
            Token::Ident(_) => {
                let name = match self.advance() {
                    Token::Ident(n) => n,
                    _ => unreachable!(),
                };
                self.expect(Token::Assign)?;
                let value = self.parse_expr()?;
                self.expect(Token::Semicolon)?;
                Ok(Stmt::Assign { name, value })
            }
            t => Err(format!("Statement non riconosciuto: {:?}", t)),
        }
    }
    fn parse_expr(&mut self) -> Result<Expr, String> {
        self.parse_cmp()
    }
    fn parse_cmp(&mut self) -> Result<Expr, String> {
        let mut left = self.parse_add()?;
        loop {
            let op = match self.peek() {
                Token::Lt => BinOp::Lt,
                Token::Gt => BinOp::Gt,
                Token::EqEq => BinOp::Eq,
                Token::NotEq => BinOp::Neq,
                _ => break,
            };
            self.advance();
            let right = self.parse_add()?;
            left = Expr::BinOp(Box::new(left), op, Box::new(right));
        }
        Ok(left)
    }
    fn parse_add(&mut self) -> Result<Expr, String> {
        let mut left = self.parse_mul()?;
        loop {
            let op = match self.peek() {
                Token::Plus => BinOp::Add,
                Token::Minus => BinOp::Sub,
                _ => break,
            };
            self.advance();
            let right = self.parse_mul()?;
            left = Expr::BinOp(Box::new(left), op, Box::new(right));
        }
        Ok(left)
    }
    fn parse_mul(&mut self) -> Result<Expr, String> {
        let mut left = self.parse_primary()?;
        loop {
            let op = match self.peek() {
                Token::Star => BinOp::Mul,
                Token::Slash => BinOp::Div,
                _ => break,
            };
            self.advance();
            let right = self.parse_primary()?;
            left = Expr::BinOp(Box::new(left), op, Box::new(right));
        }
        Ok(left)
    }
    fn parse_primary(&mut self) -> Result<Expr, String> {
        match self.advance() {
            Token::IntLit(n) => Ok(Expr::IntLit(n)),
            Token::StrLit(s) => Ok(Expr::StrLit(s)),
            Token::BoolLit(b) => Ok(Expr::BoolLit(b)),
            Token::Ident(n) => Ok(Expr::Ident(n)),
            Token::LParen => {
                let e = self.parse_expr()?;
                self.expect(Token::RParen)?;
                Ok(e)
            }
            t => Err(format!("Espressione non valida: {:?}", t)),
        }
    }
}
