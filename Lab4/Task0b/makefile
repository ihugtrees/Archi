all: run

run: patch.o start.o util.o 
	ld -m elf_i386  start.o patch.o util.o -o run

patch.o: patch.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector patch.c -o patch.o
	
util.o: util.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector util.c -o util.o
	
start.o: start.s
	nasm -f elf start.s -g -o start.o

.PHONY: clean

clean: 
	rm -f *.o run