all: arrays

arrays: arrays.o 
	gcc -g -m32 -Wall -o arrays arrays.o 

arrays.o: arrays.c 
	gcc -m32 -g -Wall -c -o arrays.o arrays.c

.PHONY: clean

clean: 
	rm -f *.o arrays