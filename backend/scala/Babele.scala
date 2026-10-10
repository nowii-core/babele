package babele

sealed trait Ty
object Ty {
  case object TInt extends Ty
  case object TFloat extends Ty
  case object TString extends Ty
  case object TBool extends Ty
  case object TVoid extends Ty
}

sealed trait Value
object Value {
  case class VInt(n: Long) extends Value
  case class VFloat(f: Double) extends Value
  case class VString(s: String) extends Value
  case class VBool(b: Boolean) extends Value
}

sealed trait BinOp
object BinOp {
  case object Add extends BinOp
  case object Sub extends BinOp
  case object Mul extends BinOp
  case object Div extends BinOp
  case object Eq extends BinOp
  case object Lt extends BinOp
}

sealed trait Expr
object Expr {
  case class Lit(v: Value) extends Expr
  case class Var(name: String) extends Expr
  case class BinOpExpr(op: BinOp, left: Expr, right: Expr) extends Expr
  case class Call(name: String, args: List[Expr]) extends Expr
}

sealed trait Stmt
object Stmt {
  case class Let(name: String, ty: Option[Ty], value: Expr) extends Stmt
  case class Print(value: Expr) extends Stmt
  case class Return(value: Option[Expr]) extends Stmt
  case class If(cond: Expr, thenBody: List[Stmt], elseBody: List[Stmt]) extends Stmt
  case class While(cond: Expr, body: List[Stmt]) extends Stmt
}

object TypeChecker {
  type Env = Map[String, Ty]

  def valueTy(v: Value): Ty = v match {
    case Value.VInt(_) => Ty.TInt
    case Value.VFloat(_) => Ty.TFloat
    case Value.VString(_) => Ty.TString
    case Value.VBool(_) => Ty.TBool
  }

  def infer(env: Env, e: Expr): Either[String, Ty] = e match {
    case Expr.Lit(v) => Right(valueTy(v))
    case Expr.Var(name) =>
      env.get(name).toRight(s"Variabile non definita: $name")
    case Expr.BinOpExpr(op, l, r) =>
      for {
        lt <- infer(env, l)
        rt <- infer(env, r)
        result <- (op, lt, rt) match {
          case (_, Ty.TInt, Ty.TInt) => Right(Ty.TInt)
          case (_, Ty.TFloat, Ty.TFloat) => Right(Ty.TFloat)
          case (BinOp.Add, Ty.TString, Ty.TString) => Right(Ty.TString)
          case (BinOp.Eq, a, b) if a == b => Right(Ty.TBool)
          case (BinOp.Lt, Ty.TInt, Ty.TInt) => Right(Ty.TBool)
          case _ => Left(s"Tipi non compatibili: $lt, $rt con $op")
        }
      } yield result
    case Expr.Call(_, _) => Right(Ty.TVoid)
  }

  def checkStmt(env: Env, s: Stmt): Either[String, Env] = s match {
    case Stmt.Let(name, tyOpt, value) =>
      infer(env, value).flatMap { t =>
        tyOpt match {
          case Some(t2) if t2 != t => Left("Tipo dichiarato non corrisponde")
          case _ => Right(env + (name -> t))
        }
      }
    case Stmt.Print(value) => infer(env, value).map(_ => env)
    case Stmt.Return(None) => Right(env)
    case Stmt.Return(Some(e)) => infer(env, e).map(_ => env)
    case Stmt.If(cond, thenBody, elseBody) =>
      infer(env, cond).flatMap {
        case Ty.TBool =>
          for {
            _ <- checkBlock(env, thenBody)
            _ <- checkBlock(env, elseBody)
          } yield env
        case _ => Left("Condizione if deve essere bool")
      }
    case Stmt.While(cond, body) =>
      infer(env, cond).flatMap {
        case Ty.TBool => checkBlock(env, body).map(_ => env)
        case _ => Left("Condizione while deve essere bool")
      }
  }

  def checkBlock(env: Env, stmts: List[Stmt]): Either[String, Env] =
    stmts.foldLeft[Either[String, Env]](Right(env)) {
      case (Right(e), s) => checkStmt(e, s)
      case (left, _) => left
    }
}

object CodegenC {
  import Expr._

  def exprToC(e: Expr): String = e match {
    case Lit(Value.VInt(n)) => n.toString
    case Lit(Value.VFloat(f)) => f.toString
    case Lit(Value.VString(s)) => s""""$s""""
    case Lit(Value.VBool(b)) => if (b) "1" else "0"
    case Var(name) => name
    case BinOpExpr(op, l, r) =>
      val opStr = op match {
        case BinOp.Add => "+"
        case BinOp.Sub => "-"
        case BinOp.Mul => "*"
        case BinOp.Div => "/"
        case BinOp.Eq => "=="
        case BinOp.Lt => "<"
      }
      s"(${exprToC(l)} $opStr ${exprToC(r)})"
    case Call(name, args) =>
      s"$name(${args.map(exprToC).mkString(", ")})"
  }

  def stmtToC(s: Stmt): String = s match {
    case Stmt.Let(name, _, value) =>
      s"""    const char* $name = ${exprToC(value)};"""
    case Stmt.Print(value) =>
      s"""    printf("%s\\n", ${exprToC(value)});"""
    case _ => "    /* non implementato */"
  }

  def generate(stmts: List[Stmt]): String = {
    val sb = new StringBuilder
    sb.append("/* Generato da Babele */\n")
    sb.append("#include <stdio.h>\n\n")
    sb.append("int main(void) {\n")
    stmts.foreach(s => sb.append(stmtToC(s)).append("\n"))
    sb.append("    return 0;\n}\n")
    sb.toString
  }
}

object Main {
  def main(args: Array[String]): Unit = {
    import Expr._
    import Stmt._
    val program = List(
      Let("saluto", None, Lit(Value.VString("Ciao, mondo!"))),
      Print(Var("saluto"))
    )
    println(CodegenC.generate(program))
  }
}
