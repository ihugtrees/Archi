all: calc

calc: calc.o 
	gcc -m32 -g -Wall -o calc calc.o

calc.o: calc.s
	nasm -g -f elf -w+all -o calc.o calc.s

.PHONY: clean

clean: 
	rm -f *.o calc