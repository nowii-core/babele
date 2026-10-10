#[derive(Debug, Clone, PartialEq)]
pub enum Token {
    Fn, Let, Print,
    Ident(String), StringLit(String),
    LParen, RParen, LBrace, RBrace,
    Semicolon, Assign, Eof,
}

pub fn tokenize(source: &str) -> Vec<Token> {
    let mut tokens = Vec::new();
    let chars: Vec<char> = source.chars().collect();
    let mut i = 0;

    while i < chars.len() {
        let c = chars[i];
        match c {
            ' ' | '\t' | '\n' | '\r' => i += 1,
            '/' if i + 1 < chars.len() && chars[i + 1] == '/' => {
                while i < chars.len() && chars[i] != '\n' { i += 1; }
            }
            '(' => { tokens.push(Token::LParen); i += 1; }
            ')' => { tokens.push(Token::RParen); i += 1; }
            '{' => { tokens.push(Token::LBrace); i += 1; }
            '}' => { tokens.push(Token::RBrace); i += 1; }
            ';' => { tokens.push(Token::Semicolon); i += 1; }
            '=' => { tokens.push(Token::Assign); i += 1; }
            '"' => {
                i += 1;
                let mut s = String::new();
                while i < chars.len() && chars[i] != '"' {
                    s.push(chars[i]);
                    i += 1;
                }
                i += 1;
                tokens.push(Token::StringLit(s));
            }
            c if c.is_alphabetic() || c == '_' => {
                let mut s = String::new();
                while i < chars.len() && (chars[i].is_alphanumeric() || chars[i] == '_') {
                    s.push(chars[i]);
                    i += 1;
                }
                let tok = match s.as_str() {
                    "fn" => Token::Fn,
                    "let" => Token::Let,
                    "print" => Token::Print,
                    _ => Token::Ident(s),
                };
                tokens.push(tok);
            }
            _ => i += 1,
        }
    }
    tokens.push(Token::Eof);
    tokens
}
