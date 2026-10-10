// Runtime di Babele in C++
#include <iostream>
#include <string>

namespace babele {

void print(const std::string& s) {
    std::cout << s << std::endl;
}

std::string concat(const std::string& a, const std::string& b) {
    return a + b;
}

class Value {
public:
    virtual ~Value() = default;
    virtual std::string repr() const = 0;
};

class StringValue : public Value {
    std::string data_;
public:
    explicit StringValue(std::string d) : data_(std::move(d)) {}
    std::string repr() const override { return data_; }
};

}
