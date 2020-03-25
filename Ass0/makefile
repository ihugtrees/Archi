all: run

run: asmAssignment0.o mainAssignment0.o
	gcc -m32 -g -Wall -o run asmAssignment0.o mainAssignment0.o
	
mainAssignment0.o: mainAssignment0.c
	gcc -g -Wall -m32 -c -o mainAssignment0.o mainAssignment0.c

asmAssignment0.o: asmAssignment0.s
	nasm -g -f elf -w+all -o asmAssignment0.o asmAssignment0.s

.PHONY: clean

clean: 
	rm -f *.o run
