.globl _start
.data
.org    . + 20
msg:     .asciz " \0"
res:     .asciz "%llu"

.macro get_time
    mfence
    rdtscp
    shl     $32, %rdx
    add     %rdx, %rax
.endm

.text

_start:
    get_time
    push    %rax

    xor     %r11, %r11
lp:  
    inc     %r11

    mov	    $msg, %rdi
	mov	    %r11, %rsi
	mov	    $10, %rdx
	call	to_ascii
    
    inc     %rdi
	xor	%eax, %eax
	call 	from_ascii

    cmp     $1234, %r11
    jnz     lp

    get_time

    pop     %rdx
    sub     %rdx, %rax
    
    mov     $res, %rdi
    mov     %rax, %rsi
    xor     %eax, %eax
    call    printf

    xor     %eax, %eax
    xor     %rdi, %rdi
    call    fflush

    mov     $60, %eax
    xor     %edi, %edi
    syscall

fact:
    push    %rbp
    mov     %rsp, %rbp
    cmp     $1, %rbx
    je      based
    dec     %rbx
    mul     %rbx
    call    fact
based:
    leave
    ret
