(* Babele Standard ML Compiler *)

signature BABELE_TYPES =
sig
  datatype ty = TInt | TFloat | TString | TBool | TVoid
              | TFunc of ty list * ty
  datatype value = VInt of int
                 | VFloat of real
                 | VString of string
                 | VBool of bool
  datatype binop = Add | Sub | Mul | Div | Eq | Lt
  datatype expr = ELit of value
                | EVar of string
                | EBinOp of binop * expr * expr
                | ECall of string * expr list
  datatype stmt = SLet of string * ty option * expr
                | SExpr of expr
                | SReturn of expr option
                | SIf of expr * stmt list * stmt list
                | SWhile of expr * stmt list
end

structure BabeleTypes : BABELE_TYPES =
struct
  datatype ty = TInt | TFloat | TString | TBool | TVoid
              | TFunc of ty list * ty
  datatype value = VInt of int
                 | VFloat of real
                 | VString of string
                 | VBool of bool
  datatype binop = Add | Sub | Mul | Div | Eq | Lt
  datatype expr = ELit of value
                | EVar of string
                | EBinOp of binop * expr * expr
                | ECall of string * expr list
  datatype stmt = SLet of string * ty option * expr
                | SExpr of expr
                | SReturn of expr option
                | SIf of expr * stmt list * stmt list
                | SWhile of expr * stmt list
end

structure TypeChecker : sig
  val infer : (string * BabeleTypes.ty) list
              -> BabeleTypes.expr
              -> BabeleTypes.ty option
  val checkStmt : (string * BabeleTypes.ty) list
                  -> BabeleTypes.stmt
                  -> (string * BabeleTypes.ty) list option
end =
struct
  open BabeleTypes

  fun lookup (x : string) [] = NONE
    | lookup x ((y, t) :: rest) =
        if x = y then SOME t else lookup x rest

  fun valueTy (VInt _) = TInt
    | valueTy (VFloat _) = TFloat
    | valueTy (VString _) = TString
    | valueTy (VBool _) = TBool

  fun infer env (ELit v) = SOME (valueTy v)
    | infer env (EVar x) = lookup x env
    | infer env (EBinOp (op', l, r)) =
        (case (infer env l, infer env r, op') of
             (SOME TInt, SOME TInt, _) => SOME TInt
           | (SOME TFloat, SOME TFloat, _) => SOME TFloat
           | (SOME TString, SOME TString, Add) => SOME TString
           | (SOME TBool, SOME TBool, Eq) => SOME TBool
           | _ => NONE)
    | infer env (ECall (_, _)) = SOME TVoid

  fun checkStmt env (SLet (name, tyOpt, e)) =
        (case (infer env e, tyOpt) of
             (SOME t, SOME t') => if t = t' then SOME ((name, t) :: env) else NONE
           | (SOME t, NONE) => SOME ((name, t) :: env)
           | _ => NONE)
    | checkStmt env (SExpr e) =
        (case infer env e of SOME _ => SOME env | NONE => NONE)
    | checkStmt env (SReturn NONE) = SOME env
    | checkStmt env (SReturn (SOME e)) =
        (case infer env e of SOME _ => SOME env | NONE => NONE)
    | checkStmt env (SIf (cond, t, e)) =
        (case infer env cond of
             SOME TBool => env
           | _ => NONE)
    | checkStmt env (SWhile (cond, _)) =
        (case infer env cond of SOME TBool => SOME env | _ => NONE)

  val _ = lookup "x" [("x", TInt)]
  val _ = infer [] (ELit (VInt 42))
end

structure CodegenC : sig
  val generate : BabeleTypes.stmt list -> string
end =
struct
  open BabeleTypes

  fun exprToC (ELit (VInt n)) = Int.toString n
    | exprToC (ELit (VString s)) = "\"" ^ s ^ "\""
    | exprToC (ELit (VBool b)) = if b then "1" else "0"
    | exprToC (EVar x) = x
    | exprToC (EBinOp (op', l, r)) =
        let val opStr = case op' of
                            Add => "+" | Sub => "-" | Mul => "*"
                          | Div => "/" | Eq => "==" | Lt => "<"
        in "(" ^ exprToC l ^ " " ^ opStr ^ " " ^ exprToC r ^ ")"
        end
    | exprToC (ECall (name, args)) =
        name ^ "(" ^ String.concatWith ", " (map exprToC args) ^ ")"

  fun stmtToC (SLet (name, _, e)) = "    const char* " ^ name ^ " = " ^ exprToC e ^ ";"
    | stmtToC (SExpr e) = "    " ^ exprToC e ^ ";"
    | stmtToC (SReturn NONE) = "    return;"
    | stmtToC (SReturn (SOME e)) = "    return " ^ exprToC e ^ ";"
    | stmtToC (SIf (c, t, e)) = "    if (" ^ exprToC c ^ ") { /* ... */ }"
    | stmtToC (SWhile (c, _)) = "    while (" ^ exprToC c ^ ") { /* ... */ }"

  fun generate stmts =
    "/* Generato da Babele */\n"
    ^ "#include <stdio.h>\n\n"
    ^ "int main(void) {\n"
    ^ String.concatWith "\n" (map stmtToC stmts) ^ "\n"
    ^ "    return 0;\n}\n"
end

val _ = print (CodegenC.generate [SLet ("saluto", NONE, ELit (VString "Ciao, mondo!"))])
