/* Generato da Babele */
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

static inline void babele_print_int(int x) { printf("%d\n", x); }
static inline void babele_print_long(long x) { printf("%ld\n", x); }
static inline void babele_print_llong(long long x) { printf("%lld\n", x); }
static inline void babele_print_double(double x) { printf("%g\n", x); }
static inline void babele_print_str(const char* x) { printf("%s\n", x); }

#define BABELE_PRINT(x) _Generic((x), \
    int: babele_print_int, \
    long: babele_print_long, \
    long long: babele_print_llong, \
    double: babele_print_double, \
    float: babele_print_double, \
    char*: babele_print_str, \
    const char*: babele_print_str \
)(x)

int main(void) {
    __auto_type saluto = "Ciao, mondo!";
    BABELE_PRINT(saluto);
    __auto_type x = (40 + 2);
    BABELE_PRINT(x);
    __auto_type n = 10;
    __auto_type somma = 0;
    __auto_type i = 1;
    while ((i < n)) {
        somma = (somma + i);
        i = (i + 1);
    }
    BABELE_PRINT(somma);
    if ((somma > 50)) {
        BABELE_PRINT("Maggiore di 50");
    } else {
        BABELE_PRINT("Minore o uguale a 50");
    }
    return 0;
}
