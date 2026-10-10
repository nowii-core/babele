; Runtime di Babele - x86-64 Linux
.section .text
.globl babele_print
babele_print:
    mov %rdi, %rsi
    mov $1, %rax
    mov $1, %rdi
    mov $32, %rdx
    syscall
    ret

.globl babele_exit
babele_exit:
    mov $60, %rax
    xor %rdi, %rdi
    syscall
