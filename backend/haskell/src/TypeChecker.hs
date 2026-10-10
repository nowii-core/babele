module TypeChecker where

import qualified Data.Map as Map

type Env = Map.Map String Type

data Type = TInt | TFloat | TString | TBool | TVoid
  deriving (Eq, Show)

data Expr
  = IntLit Integer
  | FloatLit Double
  | StringLit String
  | BoolLit Bool
  | Ident String
  | BinOp String Expr Expr
  | Call String [Expr]
  deriving (Show)

infer :: Env -> Expr -> Either String Type
infer _ (IntLit _) = Right TInt
infer _ (FloatLit _) = Right TFloat
infer _ (StringLit _) = Right TString
infer _ (BoolLit _) = Right TBool
infer env (Ident name) =
  case Map.lookup name env of
    Just t -> Right t
    Nothing -> Left ("Variabile non definita: " ++ name)
infer env (BinOp "+" l r) = do
  lt <- infer env l
  rt <- infer env r
  case (lt, rt) of
    (TInt, TInt) -> Right TInt
    (TFloat, TFloat) -> Right TFloat
    (TString, TString) -> Right TString
    _ -> Left "Tipo non compatibile per +"
infer env (BinOp _ l r) = do
  _ <- infer env l
  _ <- infer env r
  Right TBool
infer _ (Call _ _) = Right TVoid
