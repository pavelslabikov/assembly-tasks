all: link

compile: 
	as -o $(file).o $(file).S

link: compile
	ld -o $(file).out $(file).o -I /lib64/ld-linux-x86-64.so.2 -lc

clean:
	rm -f *.o *.out
