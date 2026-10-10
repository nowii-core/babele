#[derive(Debug, Clone, PartialEq)]
pub enum Token {
    Fn, Let, Print, If, Else, While,
    Ident(String),
    IntLit(i64),
    StrLit(String),
    BoolLit(bool),
    Plus, Minus, Star, Slash,
    Lt, Gt, EqEq, NotEq,
    Assign,
    LParen, RParen, LBrace, RBrace,
    Semicolon,
    Eof,
}

pub fn tokenize(source: &str) -> Vec<Token> {
    let mut tokens = Vec::new();
    let chars: Vec<char> = source.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i];
        if c == '/' && i + 1 < chars.len() && chars[i + 1] == '/' {
            while i < chars.len() && chars[i] != '\n' { i += 1; }
            continue;
        }
        match c {
            ' ' | '\t' | '\n' | '\r' => i += 1,
            '(' => { tokens.push(Token::LParen); i += 1; }
            ')' => { tokens.push(Token::RParen); i += 1; }
            '{' => { tokens.push(Token::LBrace); i += 1; }
            '}' => { tokens.push(Token::RBrace); i += 1; }
            ';' => { tokens.push(Token::Semicolon); i += 1; }
            '+' => { tokens.push(Token::Plus); i += 1; }
            '-' => { tokens.push(Token::Minus); i += 1; }
            '*' => { tokens.push(Token::Star); i += 1; }
            '/' => { tokens.push(Token::Slash); i += 1; }
            '=' => {
                if i + 1 < chars.len() && chars[i + 1] == '=' {
                    tokens.push(Token::EqEq); i += 2;
                } else {
                    tokens.push(Token::Assign); i += 1;
                }
            }
            '!' => {
                if i + 1 < chars.len() && chars[i + 1] == '=' {
                    tokens.push(Token::NotEq); i += 2;
                } else { i += 1; }
            }
            '<' => { tokens.push(Token::Lt); i += 1; }
            '>' => { tokens.push(Token::Gt); i += 1; }
            '"' => {
                i += 1;
                let mut s = String::new();
                while i < chars.len() && chars[i] != '"' {
                    s.push(chars[i]); i += 1;
                }
                i += 1;
                tokens.push(Token::StrLit(s));
            }
            c if c.is_ascii_digit() => {
                let mut n: i64 = 0;
                while i < chars.len() && chars[i].is_ascii_digit() {
                    n = n * 10 + (chars[i] as i64 - '0' as i64);
                    i += 1;
                }
                tokens.push(Token::IntLit(n));
            }
            c if c.is_alphabetic() || c == '_' => {
                let mut s = String::new();
                while i < chars.len() && (chars[i].is_alphanumeric() || chars[i] == '_') {
                    s.push(chars[i]); i += 1;
                }
                let t = match s.as_str() {
                    "fn" => Token::Fn,
                    "let" => Token::Let,
                    "print" => Token::Print,
                    "if" => Token::If,
                    "else" => Token::Else,
                    "while" => Token::While,
                    "true" => Token::BoolLit(true),
                    "false" => Token::BoolLit(false),
                    _ => Token::Ident(s),
                };
                tokens.push(t);
            }
            _ => i += 1,
        }
    }
    tokens.push(Token::Eof);
    tokens
}
