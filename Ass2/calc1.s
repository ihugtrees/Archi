

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

%macro clearBuff 1
	xor eax,eax
	%%loopbuff:
		cmp eax, 82
		je %%endmacrobuff
		mov [%1+eax], byte 0x00
		inc eax
		jmp %%loopbuff
	%%endmacrobuff:
%endmacro

section	.rodata
	print_hexa: db "%X", 10, 0
	print_calc: db "calc: ", 10, 0
	print_stackOverflow: db "Error: Operand Stack Overflow", 10, 0
	print_stackLowOperands: db "Error: Insufficient Number of Arguments on Stack", 10, 0

section .bss
	;stack_max: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
	buffer: resb 83
	operandStackPointer: resd 1
	lastLink: resd 1

section .data
	stack_size: db 5
	stack_count: db 0
	operations: db 0
	stackPointer: dd 0
	lastOperand: db 0
	debug: db 0
	isFirsLink: db 0
	inputLength: db 0

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
    
	cmp     ecx,1
	je      start_myCalc
	mov 	ecx, [esi + 4]
	;call 	convertHexToInt ;; TODO
	mov     [stack_size], eax

start_myCalc:
	mov 	eax, [stack_size] ; 5 default
	mov 	ebx, 4	; 4 bytes pointer
	mul 	ebx
	push 	eax
	call 	malloc
	add     esp, 4
	mov 	[operandStackPointer], eax	; pointer to operand stack
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
		mov byte [isFirsLink], 0 ; new input we zero the first link bool
		push	print_calc
		call    printf
		add     esp, 4

		push    buffer ; gets user input string
		call    gets
		add		esp, 4

		mov [inputLength], 0 ; gets user input length
		mov ecx, buffer

		lengthLoop:
			cmp [ecx], 0xa ; loop until newline
			je newLine
			inc ecx
			add byte [inputLength], 1
			jmp lengthLoop

		newLine:
			mov [ecx], 0

		cmp byte [buffer], '+'
		je 		preaddition
		cmp byte [buffer], 'p'
		je 		prepopAndPrint
		cmp byte [buffer], 'd'
		je 		preduplicate
		cmp byte [buffer], '&'
		je 		preandOperation
		cmp byte [buffer], '|'
		je 		preorOperation
		cmp byte [buffer], 'n'
		je 		prenumberOfHexa
		cmp byte [buffer], 'q'
		je 		quit
		xor ebx, ebx
		mov ebx, [stack_count]
		cmp 	ebx, [stack_size] ; check if stack is full
		jge 	stackOverflow
		call 	addNumToStack
		jmp 	calcLoop

addNumToStack:
	startFunc

	isEndOfInput:
		cmp [inputLength], 0
		je doneAddingNumberToStack
		call createLinkedList
		sub [inputLength], 2
		jmp isEndOfInput

	doneAddingNumberToStack:
		add byte [lastOperand], 4
		add byte [stack_count], 1
		;jmp finish

createLinkedList:
	startFunc

	createNumber:
		xor ebx, ebx ; sum
		xor ecx, ecx ; input pointer
		xor edx, edx ; the char
		add ecx, [inputLength]
		dec ecx
		add edx, [buffer + ecx]
		call createInt

		mov [buffer + ecx], 0
		add ebx, eax

		xor edx, edx
		dec ecx
		add edx, [buffer + ecx]
		call createInt
		shl eax, 4
		add ebx, eax
		mov [buffer + ecx], 0

	createSingleLink:
		push 5
		push 1
		call calloc
		add esp, 8
		mov dword [eax], ebx
		cmp byte [isFirsLink], 0
		jg notFirst

		isFirst:
		xor ecx, ecx
		xor edx, edx
		mov [lastLink], eax
		mov ecx, [lastOperand]
		mov edx, [operandStackPointer]
		mov [edx + ecx], eax
		add [isFirsLink], byte 1
		jmp endFirst

		notFirst:
		xor ecx, ecx
		mov ecx, [lastLink]
		inc ecx
		mov dword [ecx], eax
		mov [lastLink], eax

		endFirst:
		endFunc

createInt:
	startFunc
	cmp edx, 'A'
	jge upperCase
	sub edx, '0'
	jmp done

	upperCase:
	sub edx, 'A'

	done:
	mov eax, edx
	endFunc


convertHexToInt:
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
	endFunc

stackLowOperands:
	push 	print_stackLowOperands
	call 	printf
	endFunc

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
	startFunc
	inc [operations]
	cmp [stack_count], 1
	jl stackLowOperands
	sub [lastOperand], 4
	clearBuff buffer

	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	mov edx, stackPointer
	mov dword ebx, [lastOperand + edx]


	endPopAndPrint:
		removeZero
		push dword buffer
		push print_hexa
		call printf
		add esp, 8
		clearBuff buffer
		push down
		push format_string
		call printf
		add esp ,8
		endFunction
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