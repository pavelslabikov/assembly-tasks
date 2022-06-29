.data
ZERO_CHAR = 0x30
A_OFFSET = 0x7 

test:	.asciz "\n"
msg:	.asciz "Result: %s\n"
.org	. + 8
result = .

.text
.globl from_ascii
.globl to_ascii

from_ascii: # int (rdi buf)
	push	%rbp
	mov	%rsp, %rbp

	xchg	%rdi, %rsi
	xor	%eax, %eax
	xor	%r8, %r8 #store result
	mov	$10, %rcx
1:	
	lodsb
	test	%al, %al
	jz	3f
	
    cmp	$0x41, %rax
	jb	2f
	sub	$A_OFFSET, %rax
2:	
	sub	$ZERO_CHAR, %rax
	xchg	%rax, %r8	
	mul	%rcx
	xchg	%rax, %r8
	add	%rax, %r8
	jmp	1b
3:
	xchg	%r8, %rax
	leave
	ret

to_ascii: #  (rdi buf, rsi number, rdx radix)
	push	%rbp
	mov	%rsp, %rbp
	
	xchg	%rcx, %rdx
	xchg	%rsi, %rax
	std
1:
	xor	%rdx, %rdx
	div	%rcx
	cmp	$10, %rdx
	jb	2f
	add	$A_OFFSET, %rdx
2:	
	add	$ZERO_CHAR, %rdx
	xchg	%rdx, %rax
	stosb
	xchg	%rdx, %rax
	test	%rax, %rax
	jnz	1b
    cld
	leave
	ret
