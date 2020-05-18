all: task3

task3: task3.o LineParser.o
	gcc -m32 -g -Wall -o task3 task3.o LineParser.o

task3.o: task3.c 
	gcc -m32 -g -Wall -c -o task3.o task3.c

LineParser.o: LineParser.c
	gcc -m32 -g -Wall -c -o LineParser.o LineParser.c

.PHONY: clean

clean: 
	rm -f *.o task3