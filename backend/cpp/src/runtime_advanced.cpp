// Babele C++ advanced runtime
#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <optional>
#include <variant>
#include <cstdint>

namespace babele {

std::int64_t fibonacci(std::int64_t n) {
    if (n < 2) return n;
    std::int64_t a = 0, b = 1;
    for (std::int64_t i = 2; i <= n; ++i) {
        auto tmp = a + b;
        a = b;
        b = tmp;
    }
    return b;
}

std::int64_t fattoriale(std::int64_t n) {
    std::int64_t r = 1;
    for (std::int64_t i = 2; i <= n; ++i) r *= i;
    return r;
}

bool is_primo(std::int64_t n) {
    if (n < 2) return false;
    for (std::int64_t i = 2; i * i <= n; ++i) {
        if (n % i == 0) return false;
    }
    return true;
}

std::int64_t mcd(std::int64_t a, std::int64_t b) {
    while (b != 0) {
        auto t = b;
        b = a % b;
        a = t;
    }
    return a;
}

template <typename T>
class Stack {
    std::vector<T> data_;
public:
    void push(T v) { data_.push_back(std::move(v)); }
    std::optional<T> pop() {
        if (data_.empty()) return std::nullopt;
        auto v = data_.back();
        data_.pop_back();
        return v;
    }
    std::size_t size() const { return data_.size(); }
};

using Value = std::variant<std::monostate, std::int64_t, double, std::string, bool>;

std::string to_string(const Value& v) {
    return std::visit([](auto&& arg) -> std::string {
        using T = std::decay_t<decltype(arg)>;
        if constexpr (std::is_same_v<T, std::monostate>) return "null";
        else if constexpr (std::is_same_v<T, std::int64_t>) return std::to_string(arg);
        else if constexpr (std::is_same_v<T, double>) return std::to_string(arg);
        else if constexpr (std::is_same_v<T, std::string>) return arg;
        else if constexpr (std::is_same_v<T, bool>) return arg ? "true" : "false";
        return "";
    }, v);
}

}

int main() {
    using namespace babele;
    std::cout << "Ciao, mondo!\n";
    std::cout << "Fibonacci(10) = " << fibonacci(10) << '\n';
    std::cout << "Fattoriale(5) = " << fattoriale(5) << '\n';
    std::cout << "Is primo(17) = " << is_primo(17) << '\n';
    std::cout << "MCD(48, 18) = " << mcd(48, 18) << '\n';
    return 0;
}
