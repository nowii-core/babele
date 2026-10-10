; Babele full runtime - x86-64 Linux
; System calls, string handling, integer arithmetic

.section .data
    newline: .byte 10

.section .bss
    num_buffer: .skip 32

.section .text

; void babele_print_string(const char* s, size_t len)
.globl babele_print_string
.type babele_print_string, @function
babele_print_string:
    movq %rsi, %rdx
    movq %rdi, %rsi
    movq $1, %rax
    movq $1, %rdi
    syscall
    ret

; void babele_print_newline(void)
.globl babele_print_newline
.type babele_print_newline, @function
babele_print_newline:
    movq $1, %rax
    movq $1, %rdi
    leaq newline(%rip), %rsi
    movq $1, %rdx
    syscall
    ret

; void babele_exit(int code)
.globl babele_exit
.type babele_exit, @function
babele_exit:
    movq $60, %rax
    syscall

; size_t babele_strlen(const char* s)
.globl babele_strlen
.type babele_strlen, @function
babele_strlen:
    xorq %rax, %rax
.Lstrlen_loop:
    cmpb $0, (%rdi,%rax)
    je .Lstrlen_done
    incq %rax
    jmp .Lstrlen_loop
.Lstrlen_done:
    ret

; void babele_print_int(int64_t n)
.globl babele_print_int
.type babele_print_int, @function
babele_print_int:
    pushq %rbp
    movq %rsp, %rbp
    movq %rdi, %rax
    leaq num_buffer+31(%rip), %rsi
    movb $10, (%rsi)
    movq $1, %rcx

    testq %rax, %rax
    jns .Lpositive
    negq %rax
    movq $1, %r8
    jmp .Lconvert
.Lpositive:
    xorq %r8, %r8

.Lconvert:
    movq $10, %r9
.Lconvert_loop:
    xorq %rdx, %rdx
    divq %r9
    addb $48, %dl
    decq %rsi
    movb %dl, (%rsi)
    incq %rcx
    testq %rax, %rax
    jnz .Lconvert_loop

    testq %r8, %r8
    jz .Lprint_num
    decq %rsi
    movb $45, (%rsi)
    incq %rcx

.Lprint_num:
    decq %rcx
    movq $1, %rax
    movq $1, %rdi
    movq %rcx, %rdx
    syscall
    popq %rbp
    ret

; int64_t babele_add(int64_t a, int64_t b)
.globl babele_add
.type babele_add, @function
babele_add:
    movq %rdi, %rax
    addq %rsi, %rax
    ret

; int64_t babele_sub(int64_t a, int64_t b)
.globl babele_sub
.type babele_sub, @function
babele_sub:
    movq %rdi, %rax
    subq %rsi, %rax
    ret

; int64_t babele_mul(int64_t a, int64_t b)
.globl babele_mul
.type babele_mul, @function
babele_mul:
    movq %rdi, %rax
    imulq %rsi, %rax
    ret

; int64_t babele_div(int64_t a, int64_t b)
.globl babele_div
.type babele_div, @function
babele_div:
    movq %rdi, %rax
    cqto
    idivq %rsi
    ret

.globl _start
_start:
    ; print "Ciao, mondo!" e newline
    leaq hello(%rip), %rdi
    movq $12, %rsi
    call babele_print_string
    call babele_print_newline

    ; print 42
    movq $42, %rdi
    call babele_print_int

    ; exit(0)
    xorq %rdi, %rdi
    call babele_exit

.section .rodata
hello: .ascii "Ciao, mondo!"
