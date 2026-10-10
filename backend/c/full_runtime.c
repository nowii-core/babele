/* Babele full runtime in C */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

typedef enum {
    VAL_INT, VAL_FLOAT, VAL_STRING, VAL_BOOL, VAL_NULL
} val_type_t;

typedef struct value {
    val_type_t type;
    union {
        int64_t i;
        double f;
        char *s;
        bool b;
    } as;
} value_t;

value_t val_int(int64_t n) {
    value_t v = { .type = VAL_INT };
    v.as.i = n;
    return v;
}

value_t val_float(double f) {
    value_t v = { .type = VAL_FLOAT };
    v.as.f = f;
    return v;
}

value_t val_string(const char *s) {
    value_t v = { .type = VAL_STRING };
    v.as.s = strdup(s);
    return v;
}

value_t val_bool(bool b) {
    value_t v = { .type = VAL_BOOL };
    v.as.b = b;
    return v;
}

void val_free(value_t *v) {
    if (v->type == VAL_STRING && v->as.s) {
        free(v->as.s);
        v->as.s = NULL;
    }
}

void val_print(value_t v) {
    switch (v.type) {
        case VAL_INT:    printf("%lld\n", (long long)v.as.i); break;
        case VAL_FLOAT:  printf("%g\n", v.as.f); break;
        case VAL_STRING: printf("%s\n", v.as.s); break;
        case VAL_BOOL:   printf("%s\n", v.as.b ? "true" : "false"); break;
        case VAL_NULL:   printf("null\n"); break;
    }
}

value_t val_add(value_t a, value_t b) {
    if (a.type == VAL_INT && b.type == VAL_INT) return val_int(a.as.i + b.as.i);
    if (a.type == VAL_FLOAT && b.type == VAL_FLOAT) return val_float(a.as.f + b.as.f);
    if (a.type == VAL_STRING && b.type == VAL_STRING) {
        size_t la = strlen(a.as.s), lb = strlen(b.as.s);
        char *buf = malloc(la + lb + 1);
        memcpy(buf, a.as.s, la);
        memcpy(buf + la, b.as.s, lb);
        buf[la + lb] = '\0';
        value_t v = { .type = VAL_STRING, .as.s = buf };
        return v;
    }
    return val_int(0);
}

value_t val_sub(value_t a, value_t b) {
    if (a.type == VAL_INT && b.type == VAL_INT) return val_int(a.as.i - b.as.i);
    if (a.type == VAL_FLOAT && b.type == VAL_FLOAT) return val_float(a.as.f - b.as.f);
    return val_int(0);
}

value_t val_mul(value_t a, value_t b) {
    if (a.type == VAL_INT && b.type == VAL_INT) return val_int(a.as.i * b.as.i);
    if (a.type == VAL_FLOAT && b.type == VAL_FLOAT) return val_float(a.as.f * b.as.f);
    return val_int(0);
}

value_t val_div(value_t a, value_t b) {
    if (a.type == VAL_INT && b.type == VAL_INT && b.as.i != 0)
        return val_int(a.as.i / b.as.i);
    if (a.type == VAL_FLOAT && b.type == VAL_FLOAT && b.as.f != 0.0)
        return val_float(a.as.f / b.as.f);
    return val_int(0);
}

value_t val_eq(value_t a, value_t b) {
    if (a.type != b.type) return val_bool(false);
    switch (a.type) {
        case VAL_INT:    return val_bool(a.as.i == b.as.i);
        case VAL_FLOAT:  return val_bool(a.as.f == b.as.f);
        case VAL_STRING: return val_bool(strcmp(a.as.s, b.as.s) == 0);
        case VAL_BOOL:   return val_bool(a.as.b == b.as.b);
        default:         return val_bool(true);
    }
}

typedef struct {
    char **keys;
    value_t *vals;
    size_t size;
    size_t cap;
} env_t;

env_t *env_new(void) {
    env_t *e = malloc(sizeof(env_t));
    e->size = 0;
    e->cap = 16;
    e->keys = malloc(sizeof(char*) * e->cap);
    e->vals = malloc(sizeof(value_t) * e->cap);
    return e;
}

void env_set(env_t *e, const char *k, value_t v) {
    for (size_t i = 0; i < e->size; i++) {
        if (strcmp(e->keys[i], k) == 0) {
            val_free(&e->vals[i]);
            e->vals[i] = v;
            return;
        }
    }
    if (e->size >= e->cap) {
        e->cap *= 2;
        e->keys = realloc(e->keys, sizeof(char*) * e->cap);
        e->vals = realloc(e->vals, sizeof(value_t) * e->cap);
    }
    e->keys[e->size] = strdup(k);
    e->vals[e->size] = v;
    e->size++;
}

value_t *env_get(env_t *e, const char *k) {
    for (size_t i = 0; i < e->size; i++) {
        if (strcmp(e->keys[i], k) == 0) return &e->vals[i];
    }
    return NULL;
}

void env_free(env_t *e) {
    for (size_t i = 0; i < e->size; i++) {
        free(e->keys[i]);
        val_free(&e->vals[i]);
    }
    free(e->keys);
    free(e->vals);
    free(e);
}

int main(void) {
    env_t *env = env_new();
    env_set(env, "saluto", val_string("Ciao, mondo!"));
    value_t *v = env_get(env, "saluto");
    if (v) val_print(*v);
    env_free(env);
    return 0;
}
