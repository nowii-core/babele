/* Generato da Babele */
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#define BABELE_PRINT(x) _Generic((x), \
    int: printf("%d\n", (int)(x)), \
    long: printf("%ld\n", (long)(x)), \
    long long: printf("%lld\n", (long long)(x)), \
    double: printf("%f\n", (double)(x)), \
    float: printf("%f\n", (double)(x)), \
    char*: printf("%s\n", (char*)(x)), \
    const char*: printf("%s\n", (const char*)(x)), \
    default: printf("(unknown)\n") \
)

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
