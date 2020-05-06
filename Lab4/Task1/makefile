all: task1b

task1b: task1b.o start.o util.o 
	ld -m elf_i386  start.o task1b.o util.o -o task1b

task1b.o: task1b.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector task1b.c -o task1b.o
	
util.o: util.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector util.c -o util.o
	
start.o: start.s
	nasm -f elf start.s -g -o start.o

.PHONY: clean

clean: 
	rm -f *.o task1b