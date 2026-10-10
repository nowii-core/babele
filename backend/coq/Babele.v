Require Import String List Bool Arith.
Import ListNotations.
Open Scope string_scope.

Inductive ty : Type :=
  | TInt : ty
  | TFloat : ty
  | TString : ty
  | TBool : ty
  | TVoid : ty
  | TFunc : list ty -> ty -> ty.

Inductive value : Type :=
  | VInt : Z -> value
  | VFloat : Q -> value
  | VString : string -> value
  | VBool : bool -> value.

Inductive expr : Type :=
  | ELit : value -> expr
  | EVar : string -> expr
  | EBinOp : string -> expr -> expr -> expr
  | ECall : string -> list expr -> expr.

Inductive stmt : Type :=
  | SLet : string -> option ty -> expr -> stmt
  | SAssign : string -> expr -> stmt
  | SPrint : expr -> stmt
  | SReturn : option expr -> stmt
  | SIf : expr -> list stmt -> list stmt -> stmt
  | SWhile : expr -> list stmt -> stmt.

Record func : Type := mkFunc {
  fname : string;
  fparams : list (string * ty);
  fret : ty;
  fbody : list stmt
}.

Record program : Type := mkProgram {
  pfuncs : list func
}.

Definition type_env := list (string * ty).

Fixpoint lookup (x : string) (env : type_env) : option ty :=
  match env with
  | [] => None
  | (y, t) :: rest => if String.eqb x y then Some t else lookup x rest
  end.

Definition value_ty (v : value) : ty :=
  match v with
  | VInt _ => TInt
  | VFloat _ => TFloat
  | VString _ => TString
  | VBool _ => TBool
  end.

Fixpoint infer (env : type_env) (e : expr) : option ty :=
  match e with
  | ELit v => Some (value_ty v)
  | EVar x => lookup x env
  | EBinOp op l r =>
      match infer env l, infer env r with
      | Some TInt, Some TInt =>
          if String.eqb op "+" || String.eqb op "-" ||
             String.eqb op "*" || String.eqb op "/"
          then Some TInt else None
      | Some TString, Some TString =>
          if String.eqb op "+" then Some TString else None
      | _, _ => None
      end
  | ECall _ _ => Some TVoid
  end.

Definition extend (env : type_env) (x : string) (t : ty) : type_env :=
  (x, t) :: env.

Fixpoint check_stmts (env : type_env) (ss : list stmt) : option type_env :=
  match ss with
  | [] => Some env
  | s :: rest =>
      match s with
      | SLet x ty_opt e =>
          match infer env e with
          | Some t =>
              match ty_opt with
              | Some t' => if ty_eq_dec t t'
                           then check_stmts (extend env x t) rest
                           else None
              | None => check_stmts (extend env x t) rest
              end
          | None => None
          end
      | SPrint e =>
          match infer env e with
          | Some _ => check_stmts env rest
          | None => None
          end
      | _ => check_stmts env rest
      end
  end
with ty_eq_dec (a b : ty) : {a = b} + {a <> b}.
Proof.
  decide equality; decide equality.
Defined.

Theorem check_let_preserves :
  forall env x e t rest,
    infer env e = Some t ->
    check_stmts (extend env x t) rest = Some env ->
    check_stmts env (SLet x None e :: rest) = Some env.
Proof.
  intros. simpl. rewrite H. reflexivity.
Qed.

Lemma lookup_extend_same :
  forall env x t,
    lookup x (extend env x t) = Some t.
Proof.
  intros. simpl. rewrite String.eqb_refl. reflexivity.
Qed.
