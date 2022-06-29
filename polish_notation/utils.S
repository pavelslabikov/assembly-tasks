.data
ZERO_CHAR = 0x30
A_OFFSET = 0x7
error_msg:	.asciz "Некорректный аргумент %d\n"

.text
.globl 	from_ascii
.globl	to_ascii
.globl	validate_arg

validate_arg: # (rsi str, rcx narg)
	mov	$40, %rbx
	mov	$47, %rdx
	cmpb	$ZERO_CHAR, (%rsi)
	jl	1f
	mov	$48, %rbx
	mov	$57, %rdx
1:
	lodsb
	cmp	%rbx, %rax
	jl	2f
	cmp	%rdx, %rax
	jg	2f
	movb	(%rsi),	%al
	testb	%al, %al
	jnz	1b
	ret
2:
	xor     %eax, %eax
	inc	%rcx
        mov	%rcx, %rsi
	mov     $error_msg, %rdi
        call    printf

	mov     $60, %eax
        mov     $1, %edi
        syscall

		 

from_ascii: # int (rsi buf)
        xor     %eax, %eax
        xor     %r8, %r8 #store result
        mov     $10, %rcx
1:
        lodsb
        test    %al, %al
        jz      2f
        sub     $ZERO_CHAR, %rax
        xchg    %rax, %r8
        mul     %rcx
        xchg    %rax, %r8
        add     %rax, %r8
        jmp     1b
2:
        xchg    %r8, %rax
        ret


to_ascii: #  (rdi buf, rsi number, rdx radix)
        xchg    %rcx, %rdx
        mov     %rsi, %rax
        std
        test    %rax, %rax
        jns     1f
        neg     %rax
1:
        xor     %rdx, %rdx
        div     %rcx
        cmp     $10, %rdx
        jb      2f
        add     $A_OFFSET, %rdx
2:
        add     $ZERO_CHAR, %rdx
        xchg    %rdx, %rax
        stosb
        xchg    %rdx, %rax
        test    %rax, %rax
        jnz     1b

        test    %rsi, %rsi
        jns     3f
        mov     $45, %rax
        stosb
3:
        ret

