all: encoder

encoder: encoder.o start.o util.o 
	ld -m elf_i386  start.o encoder.o util.o -o encoder

encoder.o: encoder.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector encoder.c -o encoder.o
	
util.o: util.c
	gcc -m32 -Wall -ansi -g -c -nostdlib -fno-stack-protector util.c -o util.o
	
start.o: start.s
	nasm -f elf start.s -g -o start.o

.PHONY: clean

clean: 
	rm -f *.o encoder