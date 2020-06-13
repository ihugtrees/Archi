
all: virus

virus: skeleton.o
	ld -g -m elf_i386 skeleton.o -o virus

skeleton.o: skeleton.s
	nasm -g -f elf skeleton.s -o skeleton.o

.PHONY: clean

clean: 
	rm -f *.o virus