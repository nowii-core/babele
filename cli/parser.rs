use crate::lexer::Token;

#[derive(Debug)]
pub struct Program {
    pub main_body: Vec<Stmt>,
}

#[derive(Debug)]
pub enum Stmt {
    Let { name: String, value: Expr },
    Print(Expr),
}

#[derive(Debug)]
pub enum Expr {
    StringLit(String),
    Ident(String),
}

pub fn parse(tokens: &[Token]) -> Result<Program, String> {
    let mut p = Parser {
        tokens: tokens.to_vec(),
        pos: 0,
    };
    p.parse_program()
}

struct Parser {
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    fn peek(&self) -> &Token {
        self.tokens.get(self.pos).unwrap_or(&Token::Eof)
    }

    fn advance(&mut self) -> Token {
        let t = self.tokens.get(self.pos).cloned().unwrap_or(Token::Eof);
        self.pos += 1;
        t
    }

    fn expect(&mut self, expected: Token) -> Result<(), String> {
        let got = self.advance();
        if got == expected {
            Ok(())
        } else {
            Err(format!("Atteso {:?}, trovato {:?}", expected, got))
        }
    }

    fn parse_program(&mut self) -> Result<Program, String> {
        self.expect(Token::Fn)?;
        let _name = match self.advance() {
            Token::Ident(n) => n,
            t => return Err(format!("Atteso nome funzione, trovato {:?}", t)),
        };
        self.expect(Token::LParen)?;
        self.expect(Token::RParen)?;
        self.expect(Token::LBrace)?;

        let mut body = Vec::new();
        while self.peek() != &Token::RBrace {
            body.push(self.parse_stmt()?);
        }
        self.expect(Token::RBrace)?;

        Ok(Program { main_body: body })
    }

    fn parse_stmt(&mut self) -> Result<Stmt, String> {
        match self.peek() {
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
            t => Err(format!("Statement non riconosciuto: {:?}", t)),
        }
    }

    fn parse_expr(&mut self) -> Result<Expr, String> {
        match self.advance() {
            Token::StringLit(s) => Ok(Expr::StringLit(s)),
            Token::Ident(n) => Ok(Expr::Ident(n)),
            t => Err(format!("Espressione non valida: {:?}", t)),
        }
    }
}