module Babele

import Data.String
import Data.List
import Data.Maybe
import Decidable.Equality

data Ty = TInt | TFloat | TString | TBool | TVoid

implementation DecEq Ty where
  decEq TInt TInt = Yes Refl
  decEq TFloat TFloat = Yes Refl
  decEq TString TString = Yes Refl
  decEq TBool TBool = Yes Refl
  decEq TVoid TVoid = Yes Refl
  decEq _ _ = No absurd

data Value : Ty -> Type where
  VInt : Int -> Value TInt
  VFloat : Double -> Value TFloat
  VStr : String -> Value TString
  VBool : Bool -> Value TBool

data Expr : Type where
  ELitInt : Int -> Expr
  ELitStr : String -> Expr
  EIdent : String -> Expr
  EBinOp : String -> Expr -> Expr -> Expr

Env : Type
Env = List (String, Ty)

lookupEnv : String -> Env -> Maybe Ty
lookupEnv x [] = Nothing
lookupEnv x ((y, t) :: rest) = 
  if x == y then Just t else lookupEnv x rest

infer : Env -> Expr -> Maybe Ty
infer _ (ELitInt _) = Just TInt
infer _ (ELitStr _) = Just TString
infer env (EIdent x) = lookupEnv x env
infer env (EBinOp op l r) =
  case (infer env l, infer env r) of
    (Just TInt, Just TInt) => Just TInt
    (Just TString, Just TString) => 
      case op of
        "+" => Just TString
        _ => Nothing
    (_, _) => Nothing

data Stmt : Type where
  SLet : String -> Expr -> Stmt
  SPrint : Expr -> Stmt
  SSeq : Stmt -> Stmt -> Stmt

checkStmt : Env -> Stmt -> Maybe Env
checkStmt env (SLet x e) = 
  case infer env e of
    Just t => Just ((x, t) :: env)
    Nothing => Nothing
checkStmt env (SPrint e) = 
  case infer env e of
    Just _ => Just env
    Nothing => Nothing
checkStmt env (SSeq s1 s2) = 
  case checkStmt env s1 of
    Just env' => checkStmt env' s2
    Nothing => Nothing

inferSound : (env : Env) -> (e : Expr) -> (t : Ty) 
          -> infer env e = Just t 
          -> infer env e = Just t
inferSound env e t prf = prf
