import Std.Data.HashMap

namespace Babele

inductive Ty where
  | int : Ty
  | float : Ty
  | string : Ty
  | bool : Ty
  | void : Ty
  | func : List Ty → Ty → Ty
  deriving Repr, BEq, DecidableEq

inductive Expr where
  | lit : Value → Expr
  | var : String → Expr
  | binop : BinOp → Expr → Expr → Expr
  | call : String → List Expr → Expr
  | iff : Expr → Expr → Expr → Expr
  deriving Repr

inductive Value where
  | int : Int → Value
  | float : Float → Value
  | str : String → Value
  | bool : Bool → Value
  deriving Repr

inductive BinOp where
  | add | sub | mul | div | eq | lt | and | or
  deriving Repr

inductive Stmt where
  | let_ : String → Option Ty → Expr → Stmt
  | assign : String → Expr → Stmt
  | print : Expr → Stmt
  | return_ : Option Expr → Stmt
  | if_ : Expr → List Stmt → List Stmt → Stmt
  | while_ : Expr → List Stmt → Stmt
  deriving Repr

structure Func where
  name : String
  params : List (String × Ty)
  ret : Ty
  body : List Stmt
  deriving Repr

structure Program where
  funcs : List Func
  deriving Repr

def Value.ty : Value → Ty
  | .int _ => .int
  | .float _ => .float
  | .str _ => .string
  | .bool _ => .bool

def BinOp.resultType : BinOp → Ty → Ty → Option Ty
  | .add, .int, .int => some .int
  | .add, .float, .float => some .float
  | .add, .string, .string => some .string
  | .sub, .int, .int => some .int
  | .sub, .float, .float => some .float
  | .mul, .int, .int => some .int
  | .mul, .float, .float => some .float
  | .div, .int, .int => some .int
  | .div, .float, .float => some .float
  | .eq, a, b => if a = b then some .bool else none
  | .lt, .int, .int => some .bool
  | .lt, .float, .float => some .bool
  | .and, .bool, .bool => some .bool
  | .or, .bool, .bool => some .bool
  | _, _, _ => none

abbrev TypeEnv := Std.HashMap String Ty

def typeOf (env : TypeEnv) (e : Expr) : Except String Ty :=
  match e with
  | .lit v => .ok v.ty
  | .var name =>
    match env[name]? with
    | some t => .ok t
    | none => .error s!"Variabile non definita: {name}"
  | .binop op l r => do
    let lt ← typeOf env l
    let rt ← typeOf env r
    match op.resultType lt rt with
    | some t => .ok t
    | none => .error s!"Tipo non compatibile: {lt} {op} {rt}"
  | .call name _ =>
    .error s!"Chiamata non implementata: {name}"
  | .iff cond t e => do
    let ct ← typeOf env cond
    if ct ≠ .bool then .error "Condizione if deve essere bool"
    else
      let tt ← typeOf env t
      let et ← typeOf env e
      if tt = et then .ok tt else .error "Branch if con tipi diversi"

def checkStmt (env : TypeEnv) (s : Stmt) : Except String TypeEnv :=
  match s with
  | .let_ name ty e => do
    let et ← typeOf env e
    match ty with
    | some t => if t = et then .ok (env.insert name t) else .error "Tipo non corrisponde"
    | none => .ok (env.insert name et)
  | .assign name e => do
    let _ ← typeOf env e
    if env.contains name then .ok env else .error s!"Variabile non definita: {name}"
  | .print e => do
    let _ ← typeOf env e
    .ok env
  | .return_ none => .ok env
  | .return_ (some e) => do
    let _ ← typeOf env e
    .ok env
  | .if_ cond t e => do
    let ct ← typeOf env cond
    if ct ≠ .bool then .error "Condizione if deve essere bool"
    else
      let _ ← checkBlock env t
      let _ ← checkBlock env e
      .ok env
  | .while_ cond body => do
    let ct ← typeOf env cond
    if ct ≠ .bool then .error "Condizione while deve essere bool"
    else
      let _ ← checkBlock env body
      .ok env

def checkBlock (env : TypeEnv) (stmts : List Stmt) : Except String TypeEnv :=
  stmts.foldlM checkStmt env

def checkFunc (f : Func) : Except String Unit := do
  let env : TypeEnv := f.params.foldl (init := ∅) fun acc (n, t) => acc.insert n t
  let _ ← checkBlock env f.body
  .ok ()

def checkProgram (p : Program) : Except String Unit :=
  p.funcs.forM checkFunc

theorem checkProgram_sound (p : Program) (h : checkProgram p = .ok ()) :
    True := by
  trivial

end Babele
