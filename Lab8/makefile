all: task1 task2 task3 

task1: task1.o 
	gcc -m32 -g -Wall -o task1 task1.o

task1.o: task1.c
	gcc -g -Wall -m32  -c -o task1.o task1.c 
	
task2: task2.o 
	gcc -m32 -g -Wall -o task2 task2.o

task2.o: task2.c
	gcc -g -Wall -m32  -c -o task2.o task2.c 
	
task3: task3.o 
	gcc -m32 -g -Wall -o task3 task3.o

task3.o: task3.c
	gcc -g -Wall -m32  -c -o task3.o task3.c 
	
	
.PHONY: clean

clean: 
	rm -f *.o task1 task2 task3 