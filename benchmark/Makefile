all: link

compile:
	as -o 5_dz.o 5_dz.S && as -o utils.o utils.S

link: compile
	ld -o 5_dz.out 5_dz.o utils.o -I /lib64/ld-linux-x86-64.so.2 -lc

