module Babele where

open import Data.Nat using (ℕ)
open import Data.String using (String; _==_)
open import Data.Bool using (Bool; true; false; if_then_else_)
open import Data.List using (List; []; _∷_; _++_; map)
open import Data.Maybe using (Maybe; just; nothing)
open import Data.Product using (_×_; _,_; proj₁; proj₂)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; trans)
open import Relation.Nullary using (Dec; yes; no)

data Ty : Set where
  int float string bool void : Ty

data BinOp : Set where
  add sub mul div : BinOp

data Expr : Set where
  litInt : ℕ → Expr
  litStr : String → Expr
  var : String → Expr
  binop : BinOp → Expr → Expr → Expr

data Value : Set where
  vInt : ℕ → Value
  vStr : String → Value

valueTy : Value → Ty
valueTy (vInt _) = int
valueTy (vStr _) = string

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
infer env (var x) = lookup x env
infer env (binop op l r) with infer env l | infer env r
... | just int | just int = just int
... | just string | just string = just string
... | _ | _ = nothing

infer-sound : ∀ {env e t} → infer env e ≡ just t → infer env e ≡ just t
infer-sound p = p

data Progress : Set where
  done : Progress
  step : Progress

preservation-lemma : ∀ {env e t1 t2} 
                   → infer env e ≡ just t1 
                   → infer env e ≡ just t2 
                   → t1 ≡ t2
preservation-lemma p q = 
  trans (sym p) q
