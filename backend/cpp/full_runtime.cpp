// Babele full runtime in C++
#include <iostream>
#include <string>
#include <memory>
#include <variant>
#include <vector>
#include <unordered_map>
#include <functional>
#include <sstream>

namespace babele {

using Value = std::variant<
    std::monostate,
    int64_t,
    double,
    std::string,
    bool
>;

std::string to_string(const Value& v) {
    return std::visit([](auto&& arg) -> std::string {
        using T = std::decay_t<decltype(arg)>;
        if constexpr (std::is_same_v<T, std::monostate>) return "null";
        else if constexpr (std::is_same_v<T, int64_t>) return std::to_string(arg);
        else if constexpr (std::is_same_v<T, double>) {
            std::ostringstream oss;
            oss << arg;
            return oss.str();
        }
        else if constexpr (std::is_same_v<T, std::string>) return arg;
        else if constexpr (std::is_same_v<T, bool>) return arg ? "true" : "false";
        return "";
    }, v);
}

class Environment {
    std::unordered_map<std::string, Value> vars_;
    std::shared_ptr<Environment> parent_;

public:
    Environment() = default;
    explicit Environment(std::shared_ptr<Environment> parent) : parent_(std::move(parent)) {}

    void set(const std::string& name, Value v) {
        vars_[name] = std::move(v);
    }

    std::optional<Value> get(const std::string& name) const {
        auto it = vars_.find(name);
        if (it != vars_.end()) return it->second;
        if (parent_) return parent_->get(name);
        return std::nullopt;
    }

    size_t size() const noexcept { return vars_.size(); }
};

class Expr {
public:
    virtual ~Expr() = default;
    virtual Value eval(Environment& env) const = 0;
};

using ExprPtr = std::unique_ptr<Expr>;

class IntLit : public Expr {
    int64_t value_;
public:
    explicit IntLit(int64_t v) : value_(v) {}
    Value eval(Environment&) const override { return value_; }
};

class StringLit : public Expr {
    std::string value_;
public:
    explicit StringLit(std::string v) : value_(std::move(v)) {}
    Value eval(Environment&) const override { return value_; }
};

class BoolLit : public Expr {
    bool value_;
public:
    explicit BoolLit(bool v) : value_(v) {}
    Value eval(Environment&) const override { return value_; }
};

class VarRef : public Expr {
    std::string name_;
public:
    explicit VarRef(std::string n) : name_(std::move(n)) {}
    Value eval(Environment& env) const override {
        auto v = env.get(name_);
        if (!v) throw std::runtime_error("Undefined variable: " + name_);
        return *v;
    }
};

class BinaryOp : public Expr {
public:
    enum class Op { Add, Sub, Mul, Div, Eq, Lt };
private:
    Op op_;
    ExprPtr left_, right_;
public:
    BinaryOp(Op op, ExprPtr l, ExprPtr r)
        : op_(op), left_(std::move(l)), right_(std::move(r)) {}

    Value eval(Environment& env) const override {
        Value lv = left_->eval(env);
        Value rv = right_->eval(env);
        return std::visit([this](auto&& l, auto&& r) -> Value {
            using L = std::decay_t<decltype(l)>;
            using R = std::decay_t<decltype(r)>;
            if constexpr (std::is_same_v<L, int64_t> && std::is_same_v<R, int64_t>) {
                switch (op_) {
                    case Op::Add: return l + r;
                    case Op::Sub: return l - r;
                    case Op::Mul: return l * r;
                    case Op::Div: return r != 0 ? Value{l / r} : Value{int64_t{0}};
                    case Op::Eq: return l == r;
                    case Op::Lt: return l < r;
                }
            } else if constexpr (std::is_same_v<L, std::string> && std::is_same_v<R, std::string>) {
                if (op_ == Op::Add) return l + r;
                if (op_ == Op::Eq) return l == r;
            } else if constexpr (std::is_same_v<L, double> && std::is_same_v<R, double>) {
                switch (op_) {
                    case Op::Add: return l + r;
                    case Op::Sub: return l - r;
                    case Op::Mul: return l * r;
                    case Op::Div: return r != 0.0 ? Value{l / r} : Value{0.0};
                    case Op::Eq: return l == r;
                    case Op::Lt: return l < r;
                }
            }
            return std::monostate{};
        }, lv, rv);
    }
};

class Stmt {
public:
    virtual ~Stmt() = default;
    virtual void exec(Environment& env) const = 0;
};

using StmtPtr = std::unique_ptr<Stmt>;

class LetStmt : public Stmt {
    std::string name_;
    ExprPtr value_;
public:
    LetStmt(std::string n, ExprPtr v) : name_(std::move(n)), value_(std::move(v)) {}
    void exec(Environment& env) const override {
        env.set(name_, value_->eval(env));
    }
};

class PrintStmt : public Stmt {
    ExprPtr value_;
public:
    explicit PrintStmt(ExprPtr v) : value_(std::move(v)) {}
    void exec(Environment& env) const override {
        std::cout << to_string(value_->eval(env)) << '\n';
    }
};

class Program {
    std::vector<StmtPtr> stmts_;
public:
    void add(StmtPtr s) { stmts_.push_back(std::move(s)); }
    void run() {
        Environment env;
        for (const auto& s : stmts_) s->exec(env);
    }
};

} // namespace babele

int main() {
    using namespace babele;
    Program p;
    p.add(std::make_unique<LetStmt>("saluto",
        std::make_unique<StringLit>("Ciao, mondo!")));
    p.add(std::make_unique<PrintStmt>(
        std::make_unique<VarRef>("saluto")));
    p.add(std::make_unique<LetStmt>("x",
        std::make_unique<BinaryOp>(BinaryOp::Op::Add,
            std::make_unique<IntLit>(40),
            std::make_unique<IntLit>(2))));
    p.add(std::make_unique<PrintStmt>(
        std::make_unique<VarRef>("x")));
    p.run();
    return 0;
}
