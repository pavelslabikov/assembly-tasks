.data
ZERO_CHAR = 0x30
ASCII_STAR = 0x2a
ASCII_O_BRACKET = 0x28
ASCII_C_BRACKET = 0x29

polish:	.quad	0, 0, 0
result:	.asciz	" \n"
end = .	

.text
.globl	_start

_start:
	xor	%rcx, %rcx
	pop	%r12 # amount of ags
	dec	%r12
	add	$8, %rsp
	mov	%rsp, %rbp
	push	$0
	mov	$polish, %rdi

outer:
	xor	%rax, %rax
	mov	(%rbp,%rcx,8), %rsi # current arg
	push	%rsi
	call	validate_arg
	pop	%rsi
	movb	(%rsi), %al
	mov	$parsers, %rdx
	mov	%rax, %r8
	sub	$40, %r8
	jmp	*(%rdx, %r8, 8)
parse_operator:
	mov	(%rsp), %r8
	test	%r8, %r8
	jz	is_empty
	mov	$priorities, %rdx
	movb	-40(%rdx, %r8,1), %bl
	cmpb	-40(%rdx,%rax,1), %bl
	jge	lesser
is_empty: # дошли до дна стека	
	push	%rax
	jmp	continue_outer
lesser: # на стеке более приоритетная
	xchg	%rax,%rdx
	pop	%rax
	stosb
	xchg	%rax, %rdx
	jmp	parse_operator

parse_o_bracket:
	push	%rax
	jmp	continue_outer

parse_digit:
	lodsb
	stosb
	test	%rax, %rax
	jnz	parse_digit
	jmp	continue_outer

parse_c_bracket:
	pop	%rax
	cmp	$ASCII_O_BRACKET, %rax
	jz	continue_outer
	stosb
	jmp	parse_c_bracket		
continue_outer:	
	inc	%rcx
	cmp	%rcx, %r12
	jnz	outer

empty_stack:
	pop	%rax
	stosb
	test	%rax, %rax
	jnz	empty_stack
		
	mov	$polish, %rsi
	mov	$operators, %rbx
count_p:
	movb	(%rsi), %dl
	testb	%dl, %dl
	jz	print_res
	cmpb	$ZERO_CHAR, %dl
	jge	dg
	xor	%rax, %rax
	lodsb
	pop	%r9
	pop	%r8
	sub	$ASCII_STAR, %rax
	call	*(%rbx, %rax, 8)
	push	%rax
	jmp	count_p
dg:	
	call	from_ascii
	push	%rax
	jmp	count_p
print_res:
	pop	%rsi
	mov	$result, %rdi
	mov	$10, %rdx
	call	to_ascii
	
	mov	%rdi, %rdx	
	sub	$end, %rdx
	neg	%rdx
	mov     %rdi, %rsi
        mov     $1, %rax
        mov     $1, %rdi
	syscall
	mov     $60, %eax
        xor     %edi, %edi
        syscall
	
multiply: # r8, r9
	mov	%r8, %rax
	imul	%r9
	ret	
add:
	add	%r8, %r9
	mov	%r9, %rax
	ret
substract:
	sub	%r9, %r8
	mov	%r8, %rax
	ret
divide:
	xor	%rdx, %rdx
	mov	%r8, %rax
	idiv	%r9
	ret

.data
operators:
	.quad	multiply
	.quad	add
	.quad	0
	.quad	substract
	.quad	0
	.quad	divide
priorities:
	.byte	0
	.byte	0
	.byte	2
	.byte	1
	.byte	0
	.byte	1
	.byte	0
	.byte	2
parsers:
	.quad	parse_o_bracket
	.quad	parse_c_bracket
	.rept	2
	.quad	parse_operator
	.endr
	.quad	0
	.quad	parse_operator
	.quad	0
	.quad	parse_operator
	.rept	10
	.quad	parse_digit
	.endr
