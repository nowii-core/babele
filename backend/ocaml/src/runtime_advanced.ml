(* Babele OCaml advanced runtime *)

let rec fibonacci n =
  if n < 2 then n
  else fibonacci (n - 1) + fibonacci (n - 2)

let fattoriale n =
  let rec aux acc i =
    if i > n then acc
    else aux (acc * i) (i + 1)
  in aux 1 1

let is_primo n =
  if n < 2 then false
  else
    let rec check i =
      if i * i > n then true
      else if n mod i = 0 then false
      else check (i + 1)
    in check 2

let rec mcd a b =
  if b = 0 then a
  else mcd b (a mod b)

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
  | EBool of bool
  | EVar of string
  | EBinOp of string * expr * expr
  | ECall of string * expr list

type env = (string * ty) list

let rec lookup x = function
  | [] -> None
  | (k, v) :: rest -> if k = x then Some v else lookup x rest

let rec infer env = function
  | EInt _ -> Some TInt
  | EFloat _ -> Some TFloat
  | EString _ -> Some TString
  | EBool _ -> Some TBool
  | EVar x -> lookup x env
  | EBinOp (op, l, r) ->
    (match infer env l, infer env r with
     | Some TInt, Some TInt ->
       (match op with
        | "+" | "-" | "*" | "/" -> Some TInt
        | "==" | "!=" | "<" | ">" -> Some TBool
        | _ -> None)
     | Some TString, Some TString when op = "+" -> Some TString
     | Some TFloat, Some TFloat when op = "+" -> Some TFloat
     | _ -> None)
  | ECall (_, _) -> Some TVoid

let expr_to_c = function
  | EInt n -> string_of_int n
  | EFloat f -> string_of_float f
  | EString s -> Printf.sprintf "\"%s\"" s
  | EBool true -> "1"
  | EBool false -> "0"
  | EVar x -> x
  | EBinOp (op, l, r) ->
    Printf.sprintf "(%s %s %s)" (expr_to_c l) op (expr_to_c r)
  | ECall (name, args) ->
    Printf.sprintf "%s(%s)" name
      (String.concat ", " (List.map expr_to_c args))

let generate_hello () =
  let buf = Buffer.create 256 in
  Buffer.add_string buf "/* Generato da Babele */\n";
  Buffer.add_string buf "#include <stdio.h>\n\n";
  Buffer.add_string buf "int main(void) {\n";
  Buffer.add_string buf "    const char* saluto = \"Ciao, mondo!\";\n";
  Buffer.add_string buf "    printf(\"%s\\n\", saluto);\n";
  Buffer.add_string buf "    return 0;\n";
  Buffer.add_string buf "}\n";
  Buffer.contents buf

let () =
  Printf.printf "Fibonacci(10) = %d\n" (fibonacci 10);
  Printf.printf "Fattoriale(5) = %d\n" (fattoriale 5);
  Printf.printf "Is primo(17) = %b\n" (is_primo 17);
  Printf.printf "MCD(48, 18) = %d\n" (mcd 48 18);
  print_string (generate_hello ())
