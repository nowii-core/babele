/* Runtime di Babele in C */
#include <stdio.h>
#include <string.h>

void babele_print(const char* s) {
    printf("%s\n", s);
}

char* babele_concat(const char* a, const char* b) {
    static char buffer[1024];
    snprintf(buffer, sizeof(buffer), "%s%s", a, b);
    return buffer;
}

int babele_strlen(const char* s) {
    return (int)strlen(s);
}
