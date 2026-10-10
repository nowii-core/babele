module Babele

type Ty =
    | TInt
    | TFloat
    | TString
    | TBool
    | TVoid

type Value =
    | VInt of int
    | VFloat of float
    | VString of string
    | VBool of bool

type BinOp = Add | Sub | Mul | Div | Eq | Lt

type Expr =
    | ELit of Value
    | EVar of string
    | EBinOp of BinOp * Expr * Expr
    | ECall of string * Expr list

type Stmt =
    | SLet of string * Ty option * Expr
    | SExpr of Expr
    | SPrint of Expr
    | SReturn of Expr option
    | SIf of Expr * Stmt list * Stmt list
    | SWhile of Expr * Stmt list

type Program = { Functions : (string * (string * Ty) list * Ty * Stmt list) list }

let valueTy = function
    | VInt _ -> TInt
    | VFloat _ -> TFloat
    | VString _ -> TString
    | VBool _ -> TBool

let rec infer (env : Map<string, Ty>) (e : Expr) : Result<Ty, string> =
    match e with
    | ELit v -> Ok (valueTy v)
    | EVar name ->
        match Map.tryFind name env with
        | Some t -> Ok t
        | None -> Error (sprintf "Variabile non definita: %s" name)
    | EBinOp (op, l, r) ->
        match infer env l, infer env r with
        | Ok TInt, Ok TInt -> Ok TInt
        | Ok TFloat, Ok TFloat -> Ok TFloat
        | Ok TString, Ok TString when op = Add -> Ok TString
        | Ok l, Ok r when l = r -> Ok TBool
        | Ok l, Ok r -> Error (sprintf "Tipi non compatibili: %A %A" l r)
        | Error e, _ -> Error e
        | _, Error e -> Error e
    | ECall (_, _) -> Ok TVoid

let checkStmt (env : Map<string, Ty>) (s : Stmt) : Result<Map<string, Ty>, string> =
    match s with
    | SLet (name, tyOpt, e) ->
        match infer env e with
        | Ok t ->
            match tyOpt with
            | Some t' when t' <> t -> Error "Tipo dichiarato non corrisponde"
            | _ -> Ok (Map.add name t env)
        | Error e -> Error e
    | SExpr e ->
        match infer env e with
        | Ok _ -> Ok env
        | Error e -> Error e
    | SPrint e ->
        match infer env e with
        | Ok _ -> Ok env
        | Error e -> Error e
    | SReturn None -> Ok env
    | SReturn (Some e) ->
        match infer env e with
        | Ok _ -> Ok env
        | Error e -> Error e
    | SIf (cond, t, e) ->
        match infer env cond with
        | Ok TBool ->
            match checkBlock env t with
            | Ok _ ->
                match checkBlock env e with
                | Ok _ -> Ok env
                | Error err -> Error err
            | Error err -> Error err
        | _ -> Error "Condizione if deve essere bool"
    | SWhile (cond, body) ->
        match infer env cond with
        | Ok TBool ->
            match checkBlock env body with
            | Ok _ -> Ok env
            | Error e -> Error e
        | _ -> Error "Condizione while deve essere bool"

and checkBlock env (stmts : Stmt list) : Result<Map<string, Ty>, string> =
    List.fold (fun acc s ->
        match acc with
        | Ok env' -> checkStmt env' s
        | Error e -> Error e) (Ok env) stmts

let rec exprToC = function
    | ELit (VInt n) -> string n
    | ELit (VFloat f) -> string f
    | ELit (VString s) -> sprintf "\"%s\"" s
    | ELit (VBool b) -> if b then "1" else "0"
    | EVar name -> name
    | EBinOp (op, l, r) ->
        let opStr = match op with
                   | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/"
                   | Eq -> "==" | Lt -> "<"
        sprintf "(%s %s %s)" (exprToC l) opStr (exprToC r)
    | ECall (name, args) ->
        sprintf "%s(%s)" name (String.concat ", " (List.map exprToC args))

let stmtToC = function
    | SLet (name, _, e) -> sprintf "    const char* %s = %s;" name (exprToC e)
    | SPrint e -> sprintf "    printf(\"%%s\\n\", %s);" (exprToC e)
    | _ -> "    /* non implementato */"

let generateC (stmts : Stmt list) : string =
    let sb = System.Text.StringBuilder()
    sb.AppendLine("/* Generato da Babele */") |> ignore
    sb.AppendLine("#include <stdio.h>") |> ignore
    sb.AppendLine() |> ignore
    sb.AppendLine("int main(void) {") |> ignore
    stmts |> List.iter (fun s -> sb.AppendLine(stmtToC s) |> ignore)
    sb.AppendLine("    return 0;") |> ignore
    sb.AppendLine("}") |> ignore
    sb.ToString()

[<EntryPoint>]
let main _ =
    let program = [
        SLet ("saluto", None, ELit (VString "Ciao, mondo!"))
        SPrint (EVar "saluto")
    ]
    printfn "%s" (generateC program)
    0
