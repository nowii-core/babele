(* Parser OCaml completo di Babele *)

type token =
  | INT of int
  | FLOAT of float
  | STRING of string
  | IDENT of string
  | FN | LET | PRINT | RETURN
  | IF | ELSE | WHILE
  | PLUS | MINUS | STAR | SLASH
  | EQ | NEQ | LT | GT | LTE | GTE
  | ASSIGN
  | LPAREN | RPAREN | LBRACE | RBRACE
  | SEMICOLON | COMMA | ARROW
  | EOF

type ty =
  | TInt
  | TFloat
  | TString
  | TBool
  | TVoid
  | TFunc of ty list * ty

type expr =
  | EInt of int
  | EFloat of float
  | EString of string
  | EIdent of string
  | EBinOp of binop * expr * expr
  | EUnOp of unop * expr
  | ECall of string * expr list
  | EIf of expr * expr * expr option

and binop = Add | Sub | Mul | Div | Eq | Neq | Lt | Gt | Lte | Gte | And | Or
and unop = Neg | Not

type stmt =
  | SLet of string * ty option * expr
  | SExpr of expr
  | SReturn of expr option
  | SIf of expr * stmt list * stmt list
  | SWhile of expr * stmt list
  | SBlock of stmt list

type func = {
  name : string;
  params : (string * ty) list;
  return_ty : ty;
  body : stmt list;
}

type program = { functions : func list }

let tokenize (source : string) : token list =
  let tokens = ref [] in
  let buf = Buffer.create 16 in
  let line = ref 1 in
  let flush_ident () =
    if Buffer.length buf > 0 then begin
      let s = Buffer.contents buf in
      Buffer.clear buf;
      let tok = match s with
        | "fn" -> FN
        | "let" -> LET
        | "print" -> PRINT
        | "return" -> RETURN
        | "if" -> IF
        | "else" -> ELSE
        | "while" -> WHILE
        | "int" -> IDENT "int"
        | "string" -> IDENT "string"
        | "float" -> IDENT "float"
        | "bool" -> IDENT "bool"
        | _ -> IDENT s
      in
      tokens := tok :: !tokens
    end
  in
  String.iter (fun c ->
    match c with
    | 'a'..'z' | 'A'..'Z' | '0'..'9' | '_' -> Buffer.add_char buf c
    | ' ' | '\t' | '\r' -> flush_ident ()
    | '\n' -> flush_ident (); incr line
    | '+' -> flush_ident (); tokens := PLUS :: !tokens
    | '-' -> flush_ident (); tokens := MINUS :: !tokens
    | '*' -> flush_ident (); tokens := STAR :: !tokens
    | '/' -> flush_ident (); tokens := SLASH :: !tokens
    | '=' -> flush_ident (); tokens := ASSIGN :: !tokens
    | '(' -> flush_ident (); tokens := LPAREN :: !tokens
    | ')' -> flush_ident (); tokens := RPAREN :: !tokens
    | '{' -> flush_ident (); tokens := LBRACE :: !tokens
    | '}' -> flush_ident (); tokens := RBRACE :: !tokens
    | ';' -> flush_ident (); tokens := SEMICOLON :: !tokens
    | ',' -> flush_ident (); tokens := COMMA :: !tokens
    | _ -> ()
  ) source;
  flush_ident ();
  List.rev (EOF :: !tokens)

type parser_state = { mutable tokens : token list }

let peek p = match p.tokens with [] -> EOF | t :: _ -> t

let advance p =
  match p.tokens with
  | [] -> EOF
  | t :: rest -> p.tokens <- rest; t

let expect p expected =
  let got = advance p in
  if got <> expected then
    failwith (Printf.sprintf "Expected token, got different")

let rec parse_expr p = parse_or p

and parse_or p =
  let left = parse_and p in
  let rec loop acc =
    match peek p with
    | _ -> acc
  in loop left

and parse_and p =
  let left = parse_cmp p in
  left

and parse_cmp p =
  let left = parse_add p in
  let rec loop acc =
    match peek p with
    | EQ -> ignore (advance p); loop (EBinOp (Eq, acc, parse_add p))
    | NEQ -> ignore (advance p); loop (EBinOp (Neq, acc, parse_add p))
    | LT -> ignore (advance p); loop (EBinOp (Lt, acc, parse_add p))
    | GT -> ignore (advance p); loop (EBinOp (Gt, acc, parse_add p))
    | _ -> acc
  in loop left

and parse_add p =
  let left = parse_mul p in
  let rec loop acc =
    match peek p with
    | PLUS -> ignore (advance p); loop (EBinOp (Add, acc, parse_mul p))
    | MINUS -> ignore (advance p); loop (EBinOp (Sub, acc, parse_mul p))
    | _ -> acc
  in loop left

and parse_mul p =
  let left = parse_primary p in
  let rec loop acc =
    match peek p with
    | STAR -> ignore (advance p); loop (EBinOp (Mul, acc, parse_primary p))
    | SLASH -> ignore (advance p); loop (EBinOp (Div, acc, parse_primary p))
    | _ -> acc
  in loop left

and parse_primary p =
  match peek p with
  | INT n -> ignore (advance p); EInt n
  | FLOAT f -> ignore (advance p); EFloat f
  | STRING s -> ignore (advance p); EString s
  | IDENT name ->
      ignore (advance p);
      (match peek p with
       | LPAREN ->
           ignore (advance p);
           let rec parse_args acc =
             match peek p with
             | RPAREN -> ignore (advance p); List.rev acc
             | _ ->
                 let e = parse_expr p in
                 (match peek p with
                  | COMMA -> ignore (advance p); parse_args (e :: acc)
                  | _ -> List.rev (e :: acc))
           in
           let args = parse_args [] in
           ECall (name, args)
       | _ -> EIdent name)
  | LPAREN ->
      ignore (advance p);
      let e = parse_expr p in
      expect p RPAREN;
      e
  | _ -> failwith "Unexpected token"

let rec parse_stmt p =
  match peek p with
  | LET ->
      ignore (advance p);
      let name = match advance p with
        | IDENT n -> n
        | _ -> failwith "Expected identifier"
      in
      expect p ASSIGN;
      let e = parse_expr p in
      expect p SEMICOLON;
      SLet (name, None, e)
  | PRINT ->
      ignore (advance p);
      expect p LPAREN;
      let e = parse_expr p in
      expect p RPAREN;
      expect p SEMICOLON;
      SExpr e
  | RETURN ->
      ignore (advance p);
      (match peek p with
       | SEMICOLON -> ignore (advance p); SReturn None
       | _ ->
           let e = parse_expr p in
           expect p SEMICOLON;
           SReturn (Some e))
  | LBRACE -> SBlock (parse_block p)
  | _ ->
      let e = parse_expr p in
      expect p SEMICOLON;
      SExpr e

and parse_block p =
  expect p LBRACE;
  let rec loop acc =
    match peek p with
    | RBRACE -> ignore (advance p); List.rev acc
    | EOF -> List.rev acc
    | _ -> loop (parse_stmt p :: acc)
  in loop []

let parse_program (source : string) : program =
  let tokens = tokenize source in
  let p = { tokens } in
  let rec loop acc =
    match peek p with
    | EOF -> List.rev acc
    | FN ->
        ignore (advance p);
        let name = match advance p with
          | IDENT n -> n
          | _ -> failwith "Expected function name"
        in
        expect p LPAREN;
        expect p RPAREN;
        let body = parse_block p in
        let f = { name; params = []; return_ty = TVoid; body } in
        loop (f :: acc)
    | _ -> loop acc
  in
  { functions = loop [] }

let () =
  let source = "fn main() { let saluto = \"Ciao, mondo!\"; print(saluto); }" in
  let prog = parse_program source in
  Printf.printf "Parsed %d functions\n" (List.length prog.functions)
