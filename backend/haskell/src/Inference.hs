{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TupleSections #-}

module Inference where

import Control.Monad.Except
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map

data Type
  = TVar Int
  | TInt
  | TFloat
  | TString
  | TBool
  | TVoid
  | TFunc [Type] Type
  deriving (Eq, Show)

data Expr
  = EInt Integer
  | EFloat Double
  | EString String
  | EBool Bool
  | EVar String
  | EApp Expr [Expr]
  | ELam [String] Expr
  | EIf Expr Expr Expr
  | EBin String Expr Expr
  deriving (Show)

data Scheme = Scheme [Int] Type
  deriving (Show)

type TypeEnv = Map String Scheme

newtype Infer a = Infer { runInfer :: Int -> Either String (a, Int) }

instance Functor Infer where
  fmap f (Infer g) = Infer $ \n -> fmap (\(a, n') -> (f a, n')) (g n)

instance Applicative Infer where
  pure a = Infer $ \n -> Right (a, n)
  Infer f <*> Infer g = Infer $ \n -> do
    (f', n1) <- f n
    (a, n2) <- g n1
    Right (f' a, n2)

instance Monad Infer where
  return = pure
  Infer g >>= f = Infer $ \n -> do
    (a, n1) <- g n
    runInfer (f a) n1

instance MonadError String Infer where
  throwError msg = Infer $ \_ -> Left msg
  catchError (Infer g) handler = Infer $ \n ->
    case g n of
      Left err -> runInfer (handler err) n
      Right ok -> Right ok

fresh :: Infer Type
fresh = Infer $ \n -> Right (TVar n, n + 1)

instantiate :: Scheme -> Infer Type
instantiate (Scheme vars t) = do
  let go (TVar v)
        | v `elem` vars = fresh
        | otherwise = return (TVar v)
      go (TFunc args ret) = do
        args' <- mapM go args
        ret' <- go ret
        return (TFunc args' ret')
      go other = return other
  go t

generalize :: TypeEnv -> Type -> Scheme
generalize env t = Scheme freeVars t
  where
    envFree = Map.foldr (unionFree . schemeFree) [] env
    freeVars = filter (`notElem` envFree) (freeVarsOf t)
    schemeFree (Scheme vs t') = filter (`notElem` vs) (freeVarsOf t')

freeVarsOf :: Type -> [Int]
freeVarsOf = \case
  TVar n -> [n]
  TFunc args ret -> concatMap freeVarsOf args ++ freeVarsOf ret
  _ -> []

unionFree :: [Int] -> [Int] -> [Int]
unionFree xs ys = xs ++ filter (`notElem` xs) ys

occursCheck :: Int -> Type -> Infer ()
occursCheck n (TVar m)
  | n == m = return ()
  | otherwise = return ()
occursCheck n t
  | n `elem` freeVarsOf t = throwError $ "Occurs check failed: " ++ show n
  | otherwise = return ()

unify :: Type -> Type -> Infer ()
unify (TVar n) t = occursCheck n t >> return ()
unify t (TVar n) = occursCheck n t >> return ()
unify TInt TInt = return ()
unify TFloat TFloat = return ()
unify TString TString = return ()
unify TBool TBool = return ()
unify TVoid TVoid = return ()
unify (TFunc a1 r1) (TFunc a2 r2) = do
  zipWithM_ unify a1 a2
  unify r1 r2
unify t1 t2 = throwError $ "Cannot unify " ++ show t1 ++ " with " ++ show t2

infer :: TypeEnv -> Expr -> Infer Type
infer env (EInt _) = return TInt
infer env (EFloat _) = return TFloat
infer env (EString _) = return TString
infer env (EBool _) = return TBool
infer env (EVar name) =
  case Map.lookup name env of
    Just scheme -> instantiate scheme
    Nothing -> throwError $ "Unbound variable: " ++ name
infer env (EApp f args) = do
  ft <- infer env f
  argTs <- mapM (infer env) args
  ret <- fresh
  unify ft (TFunc argTs ret)
  return ret
infer env (ELam params body) = do
  paramTs <- mapM (const fresh) params
  let env' = Map.fromList (zip params (map (Scheme []) paramTs)) `Map.union` env
  bodyT <- infer env' body
  return (TFunc paramTs bodyT)
infer env (EIf cond t e) = do
  condT <- infer env cond
  unify condT TBool
  tT <- infer env t
  eT <- infer env e
  unify tT eT
  return tT
infer env (EBin op l r) = do
  lt <- infer env l
  rt <- infer env r
  case op of
    "+" -> do
      unify lt rt
      return lt
    "==" -> do
      unify lt rt
      return TBool
    "<" -> do
      unify lt TInt
      unify rt TInt
      return TBool
    _ -> throwError $ "Unknown operator: " ++ op

inferTop :: TypeEnv -> Expr -> Either String Type
inferTop env e = fst <$> runInfer (infer env e) 0

test :: Either String Type
test = inferTop Map.empty (EBin "+" (EInt 1) (EInt 2))
