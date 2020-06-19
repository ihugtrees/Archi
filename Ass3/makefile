all: ass3

ass3: drone.o printer.o scheduler.o target.o ass3.o
	gcc -m32 -g -Wall -o ass3 drone.o printer.o  scheduler.o target.o ass3.o

drone.o: drone.s
	nasm -g -f elf -w+all -o drone.o drone.s

printer.o: printer.s
	nasm -g -f elf -w+all -o printer.o printer.s

scheduler.o: scheduler.s
	nasm -g -f elf -w+all -o scheduler.o scheduler.s

target.o: target.s
	nasm -g -f elf -w+all -o target.o target.s

ass3.o: ass3.s
	nasm -g -f elf -w+all -o ass3.o ass3.s


.PHONY: clean

clean: 
	rm -f *.o ass3