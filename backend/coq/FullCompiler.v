Require Import String List ZArith Bool.
Import ListNotations.
Open Scope string_scope.
Open Scope Z_scope.

Inductive ty : Type :=
  | TInt | TFloat | TString | TBool | TVoid
  | TFunc : list ty -> ty -> ty.

Inductive binop : Type :=
  | OpAdd | OpSub | OpMul | OpDiv
  | OpEq | OpNeq | OpLt | OpGt | OpLe | OpGe
  | OpAnd | OpOr.

Inductive unop : Type := UNeg | UNot.

Inductive expr : Type :=
  | ELitInt : Z -> expr
  | ELitStr : string -> expr
  | ELitBool : bool -> expr
  | EVar : string -> expr
  | EBin : binop -> expr -> expr -> expr
  | EUn : unop -> expr -> expr
  | ECall : string -> list expr -> expr
  | EIf : expr -> expr -> expr -> expr.

Inductive stmt : Type :=
  | SLet : string -> option ty -> expr -> stmt
  | SAssign : string -> expr -> stmt
  | SPrint : expr -> stmt
  | SReturn : option expr -> stmt
  | SIf : expr -> list stmt -> list stmt -> stmt
  | SWhile : expr -> list stmt -> stmt
  | SBlock : list stmt -> stmt.

Record func : Type := mkFunc {
  fn_name : string;
  fn_params : list (string * ty);
  fn_ret : ty;
  fn_body : list stmt
}.

Record program : Type := mkProg {
  prog_funcs : list func
}.

Definition tenv := list (string * ty).

Fixpoint lookup (x : string) (e : tenv) : option ty :=
  match e with
  | [] => None
  | (y, t) :: rest => if String.eqb x y then Some t else lookup x rest
  end.

Definition binop_ty (op : binop) (l r : ty) : option ty :=
  match op, l, r with
  | OpAdd, TInt, TInt => Some TInt
  | OpAdd, TFloat, TFloat => Some TFloat
  | OpAdd, TString, TString => Some TString
  | OpSub, TInt, TInt => Some TInt
  | OpMul, TInt, TInt => Some TInt
  | OpDiv, TInt, TInt => Some TInt
  | OpEq, a, b => if ty_eq a b then Some TBool else None
  | OpLt, TInt, TInt => Some TBool
  | OpGt, TInt, TInt => Some TBool
  | OpAnd, TBool, TBool => Some TBool
  | OpOr, TBool, TBool => Some TBool
  | _, _, _ => None
  end
with ty_eq (a b : ty) : bool :=
  match a, b with
  | TInt, TInt => true
  | TFloat, TFloat => true
  | TString, TString => true
  | TBool, TBool => true
  | TVoid, TVoid => true
  | TFunc ps1 r1, TFunc ps2 r2 =>
      andb (forallb2 ty_eq ps1 ps2) (ty_eq r1 r2)
  | _, _ => false
  end.

Fixpoint infer (env : tenv) (e : expr) : option ty :=
  match e with
  | ELitInt _ => Some TInt
  | ELitStr _ => Some TString
  | ELitBool _ => Some TBool
  | EVar x => lookup x env
  | EBin op l r =>
      match infer env l, infer env r with
      | Some lt, Some rt => binop_ty op lt rt
      | _, _ => None
      end
  | EUn UNeg e => match infer env e with
                  | Some TInt => Some TInt
                  | Some TFloat => Some TFloat
                  | _ => None
                  end
  | EUn UNot e => match infer env e with
                  | Some TBool => Some TBool
                  | _ => None
                  end
  | ECall _ _ => Some TVoid
  | EIf c t e =>
      match infer env c, infer env t, infer env e with
      | Some TBool, Some tt, Some te => if ty_eq tt te then Some tt else None
      | _, _, _ => None
      end
  end.

Definition extend (env : tenv) (x : string) (t : ty) : tenv :=
  (x, t) :: env.

Fixpoint check_stmts (env : tenv) (ss : list stmt) : option tenv :=
  match ss with
  | [] => Some env
  | s :: rest =>
      match s with
      | SLet x ty_opt e =>
          match infer env e with
          | Some t =>
              match ty_opt with
              | Some declared =>
                  if ty_eq declared t
                  then check_stmts (extend env x declared) rest
                  else None
              | None => check_stmts (extend env x t) rest
              end
          | None => None
          end
      | SAssign x e =>
          match infer env e with
          | Some _ =>
              match lookup x env with
              | Some _ => check_stmts env rest
              | None => None
              end
          | None => None
          end
      | SPrint e =>
          match infer env e with
          | Some _ => check_stmts env rest
          | None => None
          end
      | SReturn None => check_stmts env rest
      | SReturn (Some e) =>
          match infer env e with
          | Some _ => check_stmts env rest
          | None => None
          end
      | SIf c t e =>
          match infer env c with
          | Some TBool =>
              match check_stmts env t with
              | Some _ =>
                  match check_stmts env e with
                  | Some _ => check_stmts env rest
                  | None => None
                  end
              | None => None
              end
          | _ => None
          end
      | SWhile c body =>
          match infer env c with
          | Some TBool =>
              match check_stmts env body with
              | Some _ => check_stmts env rest
              | None => None
              end
          | _ => None
          end
      | SBlock body =>
          match check_stmts env body with
          | Some _ => check_stmts env rest
          | None => None
          end
      end
  end.

Theorem type_safety_let :
  forall env x e t rest,
    infer env e = Some t ->
    check_stmts (extend env x t) rest = Some env ->
    check_stmts env (SLet x None e :: rest) = Some env.
Proof.
  intros. simpl. rewrite H. reflexivity.
Qed.

Lemma lookup_shadow :
  forall env x t,
    lookup x (extend env x t) = Some t.
Proof.
  intros. simpl. rewrite String.eqb_refl. reflexivity.
Qed.
