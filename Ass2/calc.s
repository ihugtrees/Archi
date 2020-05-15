
section	.rodata
	print_hexa: db "%X", 10, 0
	print_calc: db "calc: ", 10, 0
	print_stackOverflow: db "Error: Operand Stack Overflow", 10, 0
	print_stackLowOperands: db "Error: Insufficient Number of Arguments on Stack", 10, 0

section .bss
	;stack_max: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
	userInput: resb 12
	stack: resb 4

section .data
	stack_size: db 5
	stack_count: db 0
	operations: db 0

%macro startFunc 1
	push	ebp
	mov 	ebp, esp
	sub		esp, %1
%endmacro

%macro endFunc 0	
	popad			
	mov esp, ebp
	pop ebp
	ret
%endmacro

%macro calcPrintHexa 1
	push 	%1
	push	print_hexa
	call    printf
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
	;push    dword esi   ; char* argv[]
	;push    dword ecx   ; int argc
	cmp     ecx,0
	je      start_myCalc
	mov     [stack_size], [esi+4]

start_myCalc:
	mov 	eax, [stack_size] 
	mov 	ebx, 5	;1 byte for data 4 for next pointer 
	mul 	ebx
	push 	eax
	call 	malloc
	mov 	[stack], eax	;stack points to our operand stack
	jmp     myCalc

end_myCalc:
	calcPrintHexa [operations]
	mov     eax,1
	mov     ebx,0
	int     0x80
	nop

myCalc:
	startFunc 0

	call malloc
	myCalc_Loop:		
		push	print_calc
		call    printf
		push 	ecx
		call 	gets
		cmp 	[ecx], '+'
		je 		addition
		cmp 	[ecx], 'p'
		je 		popAndPrint
		cmp 	[ecx], 'd'
		je 		duplicate
		cmp 	[ecx], '&'
		je 		andOperation
		cmp 	[ecx], '|'
		je 		orOperation
		cmp 	[ecx], 'n'
		je 		numberOfHexa
		cmp 	[ecx], 'q'
		je 		quit
		cmp 	[stack_count], [stack_size]
		jge 	stackOverflow
		; convert and add here
		;
		;
		;
		inc 	[stack_count]
		jmp 	myCalc_Loop

stackOverflow:
	push 	print_stackOverflow
	call 	printf
	jmp 	myCalc_Loop

stackLowOperands:
	push 	print_stackLowOperands
	call 	printf
	jmp 	myCalc_Loop

quit:
	;push 	[stack]
	;call 	free
	jmp 	end_myCalc

addition:
	inc 	[operations]
	cmp 	[stack_count], 2
	jl 		stackLowOperands
	;pop
	;pop
	;add
	;push
	jmp 	myCalc_Loop

popAndPrint:
	inc 	[operations]
	cmp 	[stack_count], 1
	jl 		stackLowOperands
	;pop
	;calcPrintHexa eax
	jmp 	myCalc_Loop

duplicate:
	inc 	[operations]
	cmp 	[stack_count], 1
	jl 		stackLowOperands
	;pop
	;push
	;push
	jmp 	myCalc_Loop

andOperation:
	inc 	[operations]
	cmp 	[stack_count], 2
	jl 		stackLowOperands
	;pop
	;pop
	;push
	jmp 	myCalc_Loop

orOperation:
	inc 	[operations]
	cmp 	[stack_count], 2
	jl 		stackLowOperands
	;pop
	;pop
	;push
	jmp 	myCalc_Loop

numberOfHexa:
	inc 	[operations]
	cmp 	[stack_count], 1
	jl 		stackLowOperands
	;pop
	;push
	jmp 	myCalc_Loop
















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