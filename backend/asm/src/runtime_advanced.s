; Babele Assembly advanced runtime - x86-64
.section .data
msg: .ascii "Ciao, mondo!\n"
msg_len = . - msg

.section .text
.globl _start

; Stampa stringa
print_string:
    mov $1, %rax
    mov $1, %rdi
    lea msg(%rip), %rsi
    mov $msg_len, %rdx
    syscall
    ret

; Calcola fibonacci iterativo
; Input: rdi = n, Output: rax = fib(n)
fibonacci:
    mov $0, %rax
    mov $1, %rbx
    mov $0, %rcx
.loop:
    cmp %rdi, %rcx
    jge .done
    mov %rax, %rdx
    add %rbx, %rax
    mov %rdx, %rbx
    inc %rcx
    jmp .loop
.done:
    ret

; Fattoriale
; Input: rdi = n, Output: rax = n!
fattoriale:
    mov $1, %rax
    mov $2, %rcx
.loop:
    cmp %rdi, %rcx
    jg .done
    imul %rcx, %rax
    inc %rcx
    jmp .loop
.done:
    ret

_start:
    call print_string
    mov $10, %rdi
    call fibonacci
    mov $5, %rdi
    call fattoriale
    mov $60, %rax
    xor %rdi, %rdi
    syscall
