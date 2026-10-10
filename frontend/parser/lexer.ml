(* Lexer di Babele *)

type token =
  | INT of int
  | STRING of string
  | IDENT of string
  | FN | LET | PRINT
  | PLUS | ASSIGN
  | LPAREN | RPAREN | LBRACE | RBRACE
  | SEMICOLON | EOF

let tokenize (input : string) : token list =
  let tokens = ref [] in
  let buf = Buffer.create 16 in
  let flush_ident () =
    if Buffer.length buf > 0 then begin
      let s = Buffer.contents buf in
      Buffer.clear buf;
      let tok = match s with
        | "fn" -> FN
        | "let" -> LET
        | "print" -> PRINT
        | _ -> IDENT s
      in
      tokens := tok :: !tokens
    end
  in
  String.iter (fun c ->
    match c with
    | 'a'..'z' | 'A'..'Z' | '0'..'9' | '_' ->
        Buffer.add_char buf c
    | '+' -> flush_ident (); tokens := PLUS :: !tokens
    | '=' -> flush_ident (); tokens := ASSIGN :: !tokens
    | '(' -> flush_ident (); tokens := LPAREN :: !tokens
    | ')' -> flush_ident (); tokens := RPAREN :: !tokens
    | '{' -> flush_ident (); tokens := LBRACE :: !tokens
    | '}' -> flush_ident (); tokens := RBRACE :: !tokens
    | ';' -> flush_ident (); tokens := SEMICOLON :: !tokens
    | _ -> ()
  ) input;
  flush_ident ();
  List.rev (EOF :: !tokens)
