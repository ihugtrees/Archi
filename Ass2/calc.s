
section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string

section .bss			; we define (global) uninitialized variables in .bss section
	stack_max: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]

section .data
	stack_size: db 0
	operations: db 0

%macro startFunc 1
	push	ebp
	mov 	ebp, esp
	sub		esp, %1
%endmacro 


section .text
	align 16
	global main
	extern printf
	extern fprintf 
	extern fflush
	extern malloc 
	extern calloc 
	extern free 
	extern gets 
	extern getchar 
	extern fgets 

main:
	pop    dword ecx    ; ecx = argc
	mov    esi,esp      ; esi = argv
	;lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
	mov     eax,ecx     ; put the number of arguments into eax
	shl     eax,2       ; compute the size of argv in bytes
	add     eax,esi     ; add the size to the address of argv 
	add     eax,4       ; skip NULL at the end of argv
	;push    dword eax   ; char *envp[]
	push    dword esi   ; char* argv[]
	push    dword ecx   ; int argc

	call    main      

	mov     ebx,eax
	mov     eax,1
	int     0x80
	nop



















convertor:
	push ebp
	mov ebp, esp
	pushad

	mov ecx, dword [ebp+8]	; get function argument (pointer to string)
	mov dword [an] ,0
	mov dword [an+4], 0
	mov dword [an+8], 0		; and is a big number so it takes 3 iteration to zero it.
	mov edi,an
	xor eax,eax

loop_number:
	xor ebx,ebx
	mov bl, byte [ecx]
	inc ecx
	cmp ebx , 0x0A
	je finished_number

	mov esi, 10
	mul esi
	sub ebx,48
	add eax,ebx
	jmp loop_number

finished_number:
	xor ebx,ebx
	xor edx,edx
	cmp eax, 0
	je print_zero
	mov ebx, 16
	mov cl,0

pushJump:
	cmp eax,0
	je popStack
	div ebx
	inc cl
	push edx
	xor edx,edx
	jmp pushJump

popStack:
	xor eax,eax
	pop eax
	cmp eax,10
	jge to_char

to_num:
	add eax,48
	jmp done_converting

to_char:
	add eax,55

done_converting:
	mov [edi],  eax
	inc edi
	dec cl
	cmp cl,0
	jnz popStack
	jmp toPrint

print_zero:
	add eax,48
	mov [edi],  eax

toPrint:
	push an	    		; call printf with 2 arguments
	push format_string	; pointer to str and pointer to format string
	call printf
	add esp, 8      	; clean up stack after call
	popad			
	mov esp, ebp	
	pop ebp
	ret