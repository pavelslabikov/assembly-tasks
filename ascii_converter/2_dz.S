.data
ZERO_CHAR = 0x30
A_OFFSET = 0x7 

test:	.asciz "\n"
msg:	.asciz "Result: %s\n"
.org	. + 8
result = .

.text
.globl _start

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
	jz	2f
	sub	$ZERO_CHAR, %rax
	xchg	%rax, %r8	
	mul	%rcx
	xchg	%rax, %r8
	add	%rax, %r8
	jmp	1b
2:
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

	leave
	ret

_start:
	xor	%eax, %eax
	mov	$test, %rdi
	call printf

	add	$16, %rsp

	pop	%rdi # convert number
	xor	%eax, %eax
	call 	from_ascii
	xchg	%rax, %r12

	pop	%rdi # convert radix
	xor	%rax, %rax
	call	from_ascii

	mov	$result, %rdi
	xchg	%r12, %rsi
	xchg	%rax, %rdx
	call	to_ascii

	xor	%eax, %eax
	inc	%rdi
	xchg	%rdi, %rsi
	mov	$msg, %rdi
	call	printf
	
	mov	$60, %eax
	xor	%edi, %edi
	syscall	
