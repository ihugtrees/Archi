all: run

run: my_echo.o 
	gcc -m32 -g -Wall -o run my_echo.o 
	
my_echo.o: my_echo.c
	gcc -g -Wall -m32 -c -o my_echo.o my_echo.c

.PHONY: clean

clean: 
	rm -f *.o run
