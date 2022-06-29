all: link

compile:
	as -o 3_dz.o 3_dz.S && as -o utils.o utils.S

link: compile
	ld -o 3_dz.out 3_dz.o utils.o  -I /lib64/ld-linux-x86-64.so.2 -lc

