all: task4

task4: task4.o LineParser.o
	gcc -m32 -g -Wall -o task4 task4.o LineParser.o

task4.o: task4.c 
	gcc -m32 -g -Wall -c -o task4.o task4.c

LineParser.o: LineParser.c
	gcc -m32 -g -Wall -c -o LineParser.o LineParser.c

.PHONY: clean

clean: 
	rm -f *.o task4