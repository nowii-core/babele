## Babele Nim Compiler

import std/[strutils, tables, sequtils, options]

type
  Ty* = enum
    tInt, tFloat, tString, tBool, tVoid

  BinOp* = enum
    opAdd = "+"
    opSub = "-"
    opMul = "*"
    opDiv = "/"
    opEq = "=="
    opLt = "<"

  ExprKind* = enum
    ekInt, ekFloat, ekString, ekBool, ekIdent, ekBinOp, ekCall

  Expr* = ref object
    case kind*: ExprKind
    of ekInt: intVal*: int
    of ekFloat: floatVal*: float
    of ekString: strVal*: string
    of ekBool: boolVal*: bool
    of ekIdent: name*: string
    of ekBinOp:
      op*: BinOp
      left*, right*: Expr
    of ekCall:
      funcName*: string
      args*: seq[Expr]

  StmtKind* = enum
    skLet, skExpr, skPrint, skReturn, skIf, skWhile

  Stmt* = ref object
    case kind*: StmtKind
    of skLet:
      letName*: string
      letType*: Option[Ty]
      letValue*: Expr
    of skExpr:
      expr*: Expr
    of skPrint:
      printExpr*: Expr
    of skReturn:
      returnExpr*: Option[Expr]
    of skIf:
      cond*: Expr
      thenBody*, elseBody*: seq[Stmt]
    of skWhile:
      whileCond*: Expr
      whileBody*: seq[Stmt]

  Env* = Table[string, Ty]

proc infer*(env: Env, e: Expr): Option[Ty] =
  case e.kind
  of ekInt: some(tInt)
  of ekFloat: some(tFloat)
  of ekString: some(tString)
  of ekBool: some(tBool)
  of ekIdent:
    if e.name in env: some(env[e.name])
    else: none(Ty)
  of ekBinOp:
    let lt = infer(env, e.left)
    let rt = infer(env, e.right)
    if lt.isSome and rt.isSome:
      let l = lt.get
      let r = rt.get
      case e.op
      of opAdd, opSub, opMul, opDiv:
        if l == tInt and r == tInt: some(tInt)
        elif l == tFloat and r == tFloat: some(tFloat)
        elif l == tString and r == tString and e.op == opAdd: some(tString)
        else: none(Ty)
      of opEq, opLt:
        if l == r: some(tBool)
        else: none(Ty)
    else: none(Ty)
  of ekCall:
    some(tVoid)

proc checkStmt*(env: var Env, s: Stmt): bool =
  case s.kind
  of skLet:
    let t = infer(env, s.letValue)
    if t.isSome:
      env[s.letName] = t.get
      true
    else: false
  of skExpr:
    infer(env, s.expr).isSome
  of skPrint:
    infer(env, s.printExpr).isSome
  of skReturn:
    if s.returnExpr.isSome: infer(env, s.returnExpr.get).isSome
    else: true
  of skIf:
    if infer(env, s.cond).get(tVoid) == tBool:
      s.thenBody.allIt(checkStmt(env, it)) and
        s.elseBody.allIt(checkStmt(env, it))
    else: false
  of skWhile:
    if infer(env, s.whileCond).get(tVoid) == tBool:
      s.whileBody.allIt(checkStmt(env, it))
    else: false

proc exprToC*(e: Expr): string =
  case e.kind
  of ekInt: $e.intVal
  of ekFloat: $e.floatVal
  of ekString: "\"" & e.strVal & "\""
  of ekBool: (if e.boolVal: "1" else: "0")
  of ekIdent: e.name
  of ekBinOp: "(" & exprToC(e.left) & " " & $e.op & " " & exprToC(e.right) & ")"
  of ekCall: e.funcName & "(" & e.args.map(exprToC).join(", ") & ")"

proc generateC*(stmts: seq[Stmt]): string =
  result = "/* Generato da Babele */\n#include <stdio.h>\n\nint main(void) {\n"
  for s in stmts:
    case s.kind
    of skLet:
      result.add("    const char* " & s.letName & " = " & exprToC(s.letValue) & ";\n")
    of skPrint:
      result.add("    printf(\"%s\\n\", " & exprToC(s.printExpr) & ");\n")
    else: discard
  result.add("    return 0;\n}\n")

when isMainModule:
  var env = initTable[string, Ty]()
  let program = @[
    Stmt(kind: skLet, letName: "saluto", letType: none(Ty),
         letValue: Expr(kind: ekString, strVal: "Ciao, mondo!")),
    Stmt(kind: skPrint, printExpr: Expr(kind: ekIdent, name: "saluto"))
  ]
  for s in program:
    discard checkStmt(env, s)
  echo generateC(program)
