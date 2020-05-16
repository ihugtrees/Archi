
section	.rodata
	print_hexa: db "%X", 10, 0
	print_calc: db "calc: ", 10, 0
	print_stackOverflow: db "Error: Operand Stack Overflow", 10, 0
	print_stackLowOperands: db "Error: Insufficient Number of Arguments on Stack", 10, 0

section .bss
	;stack_max: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
	userInput: resb 50
	;stack: resb 4

section .data
	stack_size: db 5
	stack_count: db 0
	operations: dd 0
	stackPointer: dd 0
	lastItem: dd 0
	debug: db 0

%macro startFunc 0
	push	ebp
	mov 	ebp, esp
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
	cmp     ecx,1
	je      start_myCalc
	mov 	ecx, [esi + 4]
	call 	convertStringToInt
	mov     [stack_size], eax

start_myCalc:
	mov 	eax, [stack_size]
	mov 	ebx, 4	; 4 bytes pointer
	mul 	ebx
	push 	eax
	call 	malloc
	add     esp, 4
	mov 	[stackPointer], eax	;stack points to our operand stack
	mov     [lastItem], [stackPointer]
	jmp     myCalc

end_myCalc:
	calcPrintHexa [operations]
	mov     eax, 1
	mov     ebx, 0
	int     0x80
	nop

myCalc:
	startFunc

	calcLoop:
		push	print_calc
		call    printf
		add     esp, 4

		push    userInput
		call    gets
		add		esp, 4
		
		cmp 	[userInput], '+'
		je 		addition
		cmp 	[userInput], 'p'
		je 		popAndPrint
		cmp 	[userInput], 'd'
		je 		duplicate
		cmp 	[userInput], '&'
		je 		andOperation
		cmp 	[userInput], '|'
		je 		orOperation
		cmp 	[userInput], 'n'
		je 		numberOfHexa
		cmp 	[userInput], 'q'
		je 		quit
		cmp 	[stack_count], [stack_size]
		jge 	stackOverflow
		call 	addNumToStack
		jmp 	calcLoop

addNumToStack:
	startFunc
	
	push 5
	push 1
	call calloc
	

convertStringToInt:
	;ecx->pointer to string
	;eax returns the int
	startFunc
	xor eax,eax
	loop_number:
		xor ebx,ebx
		mov bl, byte [ecx]
		inc ecx
		cmp ebx , 0x0A
		je finished_number
		cmp ebx, 'A'
		jge subCharacter
		sub ebx, 48
		
		addInt:
		mov esi, 16
		mul esi
		add eax, ebx
		jmp loop_number

		subCharacter:
			sub ebx, 55
			jmp addInt

	finished_number:
	endFunc


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