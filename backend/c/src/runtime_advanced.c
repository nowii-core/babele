/* Babele C advanced runtime */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

int64_t fibonacci(int64_t n) {
    if (n < 2) return n;
    int64_t a = 0, b = 1, tmp;
    for (int64_t i = 2; i <= n; i++) {
        tmp = a + b;
        a = b;
        b = tmp;
    }
    return b;
}

int64_t fattoriale(int64_t n) {
    int64_t r = 1;
    for (int64_t i = 2; i <= n; i++) r *= i;
    return r;
}

int is_primo(int64_t n) {
    if (n < 2) return 0;
    for (int64_t i = 2; i * i <= n; i++) {
        if (n % i == 0) return 0;
    }
    return 1;
}

int64_t mcd(int64_t a, int64_t b) {
    while (b != 0) {
        int64_t t = b;
        b = a % b;
        a = t;
    }
    return a;
}

int main(void) {
    const char *msg = "Ciao, mondo!";
    printf("%s\n", msg);
    printf("Fibonacci(10) = %lld\n", (long long)fibonacci(10));
    printf("Fattoriale(5) = %lld\n", (long long)fattoriale(5));
    printf("Is primo(17) = %d\n", is_primo(17));
    printf("MCD(48, 18) = %lld\n", (long long)mcd(48, 18));
    return 0;
}
