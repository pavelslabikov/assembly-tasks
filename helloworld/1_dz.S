.global main

.data
STD_OUT = 1
WRITE_FN = 1

ZERO_CHAR = 0x30
MAX_LENGTH = 4

prolog: .ascii "\n", "Number in ASCII: "
.org . + MAX_LENGTH
result: .ascii " \n", "Digit count: "
length: .ascii " ", "\n"
end = . - prolog

.text
to_ascii: # int to_ascii(rsi number,rdi buf)
	push	%rbp
	mov	%rsp, %rbp
	
	std
	xchg	%rax, %rsi
	mov	$10, %rsi
	mov	$MAX_LENGTH, %rcx
1:
	xor	%rdx, %rdx
	div	%rsi
	add	$ZERO_CHAR, %rdx
	xchg	%rdx, %rax	 
	stosb
	xchg	%rdx, %rax 	
	test	%rax, %rax
	loopnz	1b	
2:	
	# return amount of written symbols
	mov	$MAX_LENGTH, %rax
	sub	%rcx, %rax	
	leave
	ret

main:
	mov $result, %rdi	
	mov $0, %rsi
	call to_ascii	

	# concat digit count
	mov	$length, %rdi
	add	$ZERO_CHAR, %rax
	stosb
	# print result
	mov	$prolog, %rsi
	mov	$end, %rdx	
	mov	$WRITE_FN, %rax
	mov	$STD_OUT, %rdi
	syscall
