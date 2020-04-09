all: run

run: asm_task1Assignment1.o main_task1Assignment1.o
	gcc -m32 -g -Wall -o run asm_task1Assignment1.o main_task1Assignment1.o
	
main_task1Assignment1.o: main_task1Assignment1.c
	gcc -g -Wall -m32 -c -o main_task1Assignment1.o main_task1Assignment1.c

asm_task1Assignment1.o: asm_task1Assignment1.s
	nasm -g -f elf -w+all -o asm_task1Assignment1.o asm_task1Assignment1.s

.PHONY: clean

clean: 
	rm -f *.o run