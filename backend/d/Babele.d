// Babele D Compiler

import std.stdio;
import std.string;
import std.algorithm;
import std.conv;

enum Ty {
    int_, float_, string_, bool_, void_
}

enum BinOp {
    add = "+", sub = "-", mul = "*", div = "/"
}

abstract class Expr {
    abstract Ty typeOf(ref Ty[string] env);
    abstract string toC();
}

class IntLit : Expr {
    long value;
    this(long v) { value = v; }
    override Ty typeOf(ref Ty[string] env) { return Ty.int_; }
    override string toC() { return to!string(value); }
}

class StringLit : Expr {
    string value;
    this(string v) { value = v; }
    override Ty typeOf(ref Ty[string] env) { return Ty.string_; }
    override string toC() { return "\"" ~ value ~ "\""; }
}

class Ident : Expr {
    string name;
    this(string n) { name = n; }
    override Ty typeOf(ref Ty[string] env) {
        if (name in env) return env[name];
        throw new Exception("Variabile non definita: " ~ name);
    }
    override string toC() { return name; }
}

class BinOpExpr : Expr {
    BinOp op;
    Expr left, right;
    this(BinOp o, Expr l, Expr r) {
        op = o; left = l; right = r;
    }
    override Ty typeOf(ref Ty[string] env) {
        auto lt = left.typeOf(env);
        auto rt = right.typeOf(env);
        if (lt == Ty.int_ && rt == Ty.int_) return Ty.int_;
        if (lt == Ty.string_ && rt == Ty.string_) return Ty.string_;
        throw new Exception("Tipi non compatibili");
    }
    override string toC() {
        return "(" ~ left.toC() ~ " " ~ to!string(op) ~ " " ~ right.toC() ~ ")";
    }
}

abstract class Stmt {
    abstract void check(ref Ty[string] env);
    abstract string toC();
}

class LetStmt : Stmt {
    string name;
    Expr value;
    this(string n, Expr v) { name = n; value = v; }
    override void check(ref Ty[string] env) {
        env[name] = value.typeOf(env);
    }
    override string toC() {
        return "    const char* " ~ name ~ " = " ~ value.toC() ~ ";";
    }
}

class PrintStmt : Stmt {
    Expr value;
    this(Expr v) { value = v; }
    override void check(ref Ty[string] env) {
        value.typeOf(env);
    }
    override string toC() {
        return "    printf(\"%s\\n\", " ~ value.toC() ~ ");";
    }
}

string generateC(Stmt[] stmts) {
    string result = "/* Generato da Babele */\n#include <stdio.h>\n\nint main(void) {\n";
    foreach (s; stmts) {
        result ~= s.toC() ~ "\n";
    }
    result ~= "    return 0;\n}\n";
    return result;
}

void main() {
    Ty[string] env;
    Stmt[] program = [
        new LetStmt("saluto", new StringLit("Ciao, mondo!")),
        new PrintStmt(new Ident("saluto"))
    ];
    foreach (s; program) s.check(env);
    writeln(generateC(program));
}
