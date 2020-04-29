all: flame2

flame2: flame2.o start.o util.o 
	ld -m elf_i386  start.o flame2.o util.o -o flame2

flame2.o: flame2.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector flame2.c -o flame2.o
	
util.o: util.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector util.c -o util.o
	
start.o: start.s
	nasm -f elf start.s -g -o start.o

.PHONY: clean

clean: 
	rm -f *.o flame2