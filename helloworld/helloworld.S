.global main
.data

.bss
.lcomm buf, 8

.text
main:
	mov $3, %eax
	mov $0, %ebx
	mov $buf, %rcx
	mov $8, %edx
	int $0x80
	
	movq $buf, %rcx
	push %rcx
	call add_f

from_ascii: # int from_ascii(ascii str)
	push %rbp
	mov %rsp, %rbp
	
	mov $0, %rax
	mov $8, %rcx
	head:
	
	loop head
	16(%rbp)
add_f:
	push %rbp
	mov %rsp, %rbp
	
	mov $4, %rax
	mov $1, %rbx
	mov 16(%rbp), %rcx
	int $0x80
	leave 
	ret
