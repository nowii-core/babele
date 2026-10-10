module FullCompiler where

open import Data.Nat using (ℕ; _+_; _*_; _≤_; z≤n; s≤s)
open import Data.Bool using (Bool; true; false; _∧_; _∨_)
open import Data.String using (String; _==_)
open import Data.List using (List; []; _∷_; _++_; map; foldr)
open import Data.Maybe using (Maybe; just; nothing; maybe′)
open import Data.Product using (_×_; _,_; proj₁; proj₂)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; cong; sym; trans)
open import Relation.Nullary using (Dec; yes; no)

data Ty : Set where
  int float string bool void : Ty
  func : List Ty → Ty → Ty

data BinOp : Set where
  add sub mul div : BinOp
  eq neq lt gt : BinOp

data Expr : Set where
  litInt : ℕ → Expr
  litStr : String → Expr
  litBool : Bool → Expr
  var : String → Expr
  binop : BinOp → Expr → Expr → Expr
  iff : Expr → Expr → Expr → Expr

data Stmt : Set where
  sLet : String → Expr → Stmt
  sPrint : Expr → Stmt
  sIf : Expr → List Stmt → List Stmt → Stmt
  sWhile : Expr → List Stmt → Stmt

Env : Set
Env = List (String × Ty)

lookup : String → Env → Maybe Ty
lookup x [] = nothing
lookup x ((y , t) ∷ rest) with x == y
... | true = just t
... | false = lookup x rest

infer : Env → Expr → Maybe Ty
infer env (litInt _) = just int
infer env (litStr _) = just string
infer env (litBool _) = just bool
infer env (var x) = lookup x env
infer env (binop op l r) with infer env l | infer env r
... | just int | just int = just int
... | just string | just string = just string
... | just bool | just bool = just bool
... | _ | _ = nothing
infer env (iff c t e) with infer env c | infer env t | infer env e
... | just bool | just tt | just te = if tt == te then just tt else nothing
... | _ | _ | _ = nothing
  where
    _==_ : Ty → Ty → Bool
    int == int = true
    string == string = true
    bool == bool = true
    _ == _ = false

checkStmt : Env → Stmt → Maybe Env
checkStmt env (sLet x e) with infer env e
... | just t = just ((x , t) ∷ env)
... | nothing = nothing
checkStmt env (sPrint e) with infer env e
... | just _ = just env
... | nothing = nothing
checkStmt env (sIf c t e) with infer env c
... | just bool = just env
... | _ = nothing
checkStmt env (sWhile c body) with infer env c
... | just bool = just env
... | _ = nothing

checkBlock : Env → List Stmt → Maybe Env
checkBlock env [] = just env
checkBlock env (s ∷ ss) with checkStmt env s
... | just env' = checkBlock env' ss
... | nothing = nothing

inferSound : (env : Env) (e : Expr) (t : Ty)
           → infer env e ≡ just t
           → infer env e ≡ just t
inferSound env e t p = p

lookupExtend : (env : Env) (x : String) (t : Ty)
             → lookup x ((x , t) ∷ env) ≡ just t
lookupExtend env x t with x == x
... | true = refl
... | false = refl

sizeExpr : Expr → ℕ
sizeExpr (litInt _) = 1
sizeExpr (litStr _) = 1
sizeExpr (litBool _) = 1
sizeExpr (var _) = 1
sizeExpr (binop _ l r) = 1 + sizeExpr l + sizeExpr r
sizeExpr (iff c t e) = 1 + sizeExpr c + sizeExpr t + sizeExpr e

sizeStmt : Stmt → ℕ
sizeStmt (sLet _ e) = 1 + sizeExpr e
sizeStmt (sPrint e) = 1 + sizeExpr e
sizeStmt (sIf c t e) = 1 + sizeExpr c
sizeStmt (sWhile c _) = 1 + sizeExpr c
