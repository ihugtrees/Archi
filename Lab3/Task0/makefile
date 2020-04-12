all: bubble hexa

bubble: bubblesort.o
	gcc -m32 -g -Wall -o bubble bubblesort.o 

bubblesort.o: bubblesort.c 
	gcc -m32 -g -Wall -c -o bubblesort.o bubblesort.c

hexa: hexaPrint.o
	gcc -m32 -g -Wall -o hexa hexaPrint.o

hexaPrint.o: hexaPrint.c
	gcc -m32 -g -Wall -c -o hexaPrint.o hexaPrint.c

.PHONY: clean

clean: 
	rm -f *.o bubble hexa