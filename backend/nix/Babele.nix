# Babele Nix Compiler - pure functional
{ pkgs ? import <nixpkgs> {} }:

let
  types = {
    int = { };
    float = { };
    string = { };
    bool = { };
    void = { };
  };

  # Espressioni AST
  Expr = rec {
    intLit = n: { kind = "int"; value = n; };
    stringLit = s: { kind = "string"; value = s; };
    var = name: { kind = "var"; name = name; };
    binOp = op: l: r: { kind = "binOp"; inherit op l r; };
  };

  # Statement AST
  Stmt = rec {
    letStmt = name: value: { kind = "let"; inherit name value; };
    print = value: { kind = "print"; inherit value; };
  };

  # Type inference
  inferType = env: expr:
    if expr.kind == "int" then "int"
    else if expr.kind == "string" then "string"
    else if expr.kind == "var" then
      (if env ? ${expr.name} then env.${expr.name} else throw "Variable undefined: ${expr.name}")
    else if expr.kind == "binOp" then
      let
        lt = inferType env expr.l;
        rt = inferType env expr.r;
      in
        if lt == "int" && rt == "int" then "int"
        else if lt == "string" && rt == "string" then "string"
        else throw "Type mismatch: ${lt} vs ${rt}"
    else throw "Unknown expression";

  # Code generation C
  exprToC = expr:
    if expr.kind == "int" then toString expr.value
    else if expr.kind == "string" then "\"${expr.value}\""
    else if expr.kind == "var" then expr.name
    else if expr.kind == "binOp" then
      "(${exprToC expr.l} ${expr.op} ${exprToC expr.r})"
    else "0";

  generateC = stmts: ''
    /* Generato da Babele */
    #include <stdio.h>

    int main(void) {
    ${builtins.concatStringsSep "\n" (map stmtToC stmts)}
        return 0;
    }
  '';

  stmtToC = stmt:
    if stmt.kind == "let" then
      "    const char* ${stmt.name} = ${exprToC stmt.value};"
    else if stmt.kind == "print" then
      "    printf(\"%s\\n\", ${exprToC stmt.value});"
    else "";

  program = [
    (Stmt.letStmt "saluto" (Expr.stringLit "Ciao, mondo!"))
    (Stmt.print (Expr.var "saluto"))
  ];

in
{
  inherit types Expr Stmt inferType generateC program;
  output = generateC program;
}
