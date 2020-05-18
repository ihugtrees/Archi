
%macro debug_print 1
	pushad
	push %1
	push format_string
	call printf
	add esp,8
	popad
%endmacro

%macro jdown 0
	pushad
	push down
	push format_string
	call printf
	add esp ,8
	popad
%endmacro

%macro startFunction 0
	push 	ebp
	mov 	ebp, esp
	sub 	esp, 4
	pusha
	mov 	eax, dword[ebp + 8]
%endmacro

%macro startFunctionTwoParams 0
	push ebp
	mov ebp, esp
	sub esp, 4
	mov ebx, [ebp + 8]
	mov ecx, [ebp + 12]
%endmacro

%macro endFunction 0
	popa
	mov 	esp, ebp
	pop 	ebp
	ret
%endmacro

%macro endFunctionParameter 0
	mov 	eax, dword[ebp-4]
	mov 	esp, ebp
	pop 	ebp
	ret
%endmacro

%macro printError 1
	push %1
	push format_string
	call printf
	add esp, 8
%endmacro

%macro createLinkMacro 0
	xor ecx, ecx
	push dword [linkSize]
	push 1
	call calloc
	add esp, 8
	;mov byte [eax], %1
	cmp byte [isFirstLink], 0 			; create Link with the value in ebx
	jne %%notFirst1

	%%isFirst1:
	xor ecx, ecx
	mov [lastLink], eax
	add [isFirstLink], byte 1
	jmp %%endFirst

	%%notFirst1:
	xor ecx, ecx

	mov ecx, [lastLink] 					; if the number was not the first, update lastLink
	inc ecx
	mov dword [ecx], eax
	mov [lastLink], eax
	%%endFirst:
%endmacro

%macro freeOperand 1
	xor edx, edx
	xor eax, eax
	mov dword eax, [%1]
	mov dword edx, [eax + 1]
	cmp edx, 0
	je %%lastLink

	%%checkLast:
	xor ebx, ebx
	mov edx, [eax + 1]
	cmp dword edx, 0
	je %%lastLink
	mov ebx, eax
	jmp %%notLastLink

	%%lastLink:
	pushad
	push eax
	call free
	add esp, 4
	popad
	jmp %%end

	%%notLastLink:
	mov eax, [ebx + 1]
	pushad
	push ebx
	call free
	add esp, 4
	popad
	jmp %%checkLast
	%%end:
%endmacro

%macro removeZero 0
	push eax
	mov edx, 0
	mov esi , 0
	%%zeros:
	cmp byte[buffer+edx],'0'
	jne %%jump_left
	inc edx
	inc esi
	jmp %%zeros

	%%jump_left:
	cmp esi, 82
	je %%fin_app
	mov edi,esi
	sub edi,edx
	mov al ,[buffer+esi]
	mov [buffer+edi],al
	inc esi
	jmp %%jump_left
	%%fin_app:
	xor eax,eax
	mov al ,byte [buffer]
	cmp al , byte 0xA
	jne %%finish1
	mov [buffer],byte '0'
	mov [buffer+1],byte 0xA
	%%finish1:
	pop eax
%endmacro

%macro backtoString 1
	cmp %1 , 9
	jle %%lowernumbers
	add %1 , 55
	jmp %%finishloop
	%%lowernumbers:
	add %1 ,48
	%%finishloop:
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

%macro calculateNumberToPower 1					;TO CALCULATE
	xor eax, eax
	mov eax, 2
	xor ebx, ebx
	mov ecx, [%1]
	dec ecx
	%%Yloop:
	add eax, eax
	loop %%Yloop
%endmacro

%macro checkLegOperandStack 0
	cmp dword [operandStackPointer], 8
	jl %%printInsu
	jmp %%end
	%%printInsu:
	jmp Insufficient
	%%end:
%endmacro

%macro checkYvalue 1
	jne wrongYValue
	%%checkSize:
	xor edx, edx
	xor esi, esi
	mov byte dl, %1
	add edx, 0
	mov dword esi, 0xC8
	cmp dword edx, esi
	jg %%wrongYValue
	jmp %%end
	%%wrongYValue:
	debug_print errMsgY
	jmp printCalc
	%%end:
%endmacro

%macro popTwoOperands 0
	xor esi, esi
	mov esi, [operandStackPointer]
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	%%firstOperand:
	sub dword esi, 4
	mov ebx, [operandStack + esi]
	%%secondOperand:
	sub dword esi, 4
	mov ecx, [operandStack + esi]
	sub dword [operandStackPointer], 8
%endmacro

section .data
	format_string: db "%s", 0	; format string
	errMsgOver: db 'Error: Operand Stack Overflow', 10,0	;string in case of too many arguments
	errMsgIns: db 'Error: Insufficient Number of Arguments on Stack', 10,0	;string in case of Insufficient number of arguments in Stack
	errMsgY: db 'wrong Y value', 10,0	;string in case of wrong Y value
	lenOver: equ $ - errMsgOver		; length of the message
	lenIns: equ $ - errMsgIns		; length of the message
	calc: db "calc: ", 0
	down: db '',10,0
	linkSize: DD 5
	debug_mode: db 0
	flag2: db 0
	flag1:db 0
	q_debug: db 'Number of opartions was selected: ',0
	debug_mode_msg: db 'Debug mode',10,0
	input_msg: db 'input: ',0
	opartion_seleced: db 'opartion seleced: ',0
	pushed: db 'pushed to the stack: ',0
	stackSize: db 5

section .bss
	buffer: resb 83					; store my input
	operandStack: resb 4			; store the pointer to stack of the operands
	counter: resb 20
	count: resb 4                   ; input length
	operandStackPointer: resd 1		; pointer to the head of the stack
	temp: resd 1
	lastLink: resd 1
	isFirstLink: resb 1
	tempOdd: resb 1
	firstLinkOperation: resd 1
	carry: resb 1
	carry1: resb 1
	carry2: resb 1
	isMoreFirst: resb 1
	isMoreSecond: resb 1
	incPointer: resb 1
	firstLastLinkAddress: resd 1
	secondLastLinkAddress: resd 1
	newLinkToPushAddress: resd 1
	firstLastLinkAddressToDelete: resd 1
	secondLastLinkAddressToDelete: resd 1
	isFirstToDup: resb 1
	numofOnes: resd 2
	powerNumber: resd 1
	toBeDeleted: resd 1
	numOfOperation: resd 1
	XnumberPower: resb 1

section .text
	align 16
	global main
	extern printf
	extern fflush
	extern malloc
	extern calloc
	extern free
	extern fgets
	extern stdin
	extern stdout

main:
	cmp [esp+4], byte 1 ; no arguments
	je regular_mode

	xor ebx,ebx
	mov ebx, [esp+8] ; check if -d is first argument if not well have size
	mov ebx, [ebx+4]
	xor ecx,ecx
	cmp byte [ebx+ecx], '-'
	jne size_mode
	inc ecx
	cmp byte [ebx+ecx], 'd'
	jne regular_mode
	mov byte [debug_mode],1
	jmp regular_mode
	debug_print debug_mode_msg

	size_mode: ; we have size in argument
	xor eax, eax ; sum
	xor ebx, ebx ; pointer to size of stack in hex
	xor ecx, ecx ; constant 16
	xor edx, edx ; char

	mov eax, 0
	mov ecx, 16
	mov ebx, [esp+8]
	mov ebx, [ebx+4]
	hexLoop:
		xor edx, edx
		mov dl, byte [ebx]
		inc ebx
		cmp byte [edx], 0xa
		je finishedHex
		mul ecx
		cmp edx, 'A'
		jge hexLetter
		sub edx, '0'
		jmp addSum
		hexLetter:
		sub edx, 'A'
		addSum:
		add eax, edx
		jmp hexLoop
	finishedHex:
	mov dword [stackSize], eax

	cmp [esp+4], byte 3 ; 3 size without debug
	jl regular_mode
	mov byte [debug_mode], 1

	regular_mode:
		mov dword [numOfOperation], 0
		mov dword [counter], 0
		mov dword [operandStackPointer], 0
		call myCalc						; call to myCalc function

	mov eax, 1
	int 0x80

	myCalc:							; myCalc function
		push ebp					; beckup ebp
		mov ebp, esp				; set ebp to Func activation frame
		pushad

		xor eax, eax
		xor ebx, ebx
		mov	eax, [stack_size] ; 5 default
		mov	ebx, 4	; 4 bytes pointer
		mul	ebx
		push eax
		call malloc
		add esp, 4
		mov dword [operandStack], eax
		mov ebx, eax
		mov dword [lastLink], ebx

		printCalc:
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			push dword calc 				; push calc string to the stack
			push format_string
			call printf						; call tofgets printf func to print "calc:"
			add esp, 8
			jmp getInput

		getInput:
			push dword [stdin]			; first parameter
			push dword 82				; second parameter
			push dword buffer			; third parameter
			call fgets					; call fgets, using the three parameters
			add esp, 12					; clear the parameters from the stack
			push buffer
			call cDeleteLine
			add esp, 4

		checkInput:
			mov dword[ebp-4], 0
			mov ecx, [buffer]

		lable1:
			mov edx,[count]
			cmp byte [buffer], 0x71
			je end
			cmp byte [buffer], '+'
			je jmpAddition
			cmp byte [buffer], 'p'
			je jmpPopAndPrint
			cmp byte [buffer], 'd'
			je jmpDuplicate
			cmp byte [buffer], '&'
			je jmpPower
			cmp byte [buffer], 'v'
			je jmpSqrtPower
			cmp byte [buffer], 'n'
			je jmpNumberOfOnes
			cmp byte [buffer], 0x00
			je printCalc
			cmp dword [operandStackPointer], 16
			jg pOverflow
			jmp cont

preJumps:
	preAdd:
			jmpAddition:
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_add
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_add:
			mov dword [carry], 0
			cmp dword [operandStackPointer], 8
			jl Insufficient

			legalAdd:
			xor eax, eax
			xor ebx, ebx
			mov dword eax, [operandStackPointer]
			sub eax, 4
			mov dword ebx, [operandStack + eax] 				; first cell of operand stack
			push ebx
			sub eax, 4
			mov dword ecx, [operandStack + eax]
			push ecx
			mov dword [operandStackPointer], eax

			call Addition
			xor ebx, ebx
			xor ecx, ecx
			xor edx, edx
			mov dword ebx, operandStack
			mov dword edx, [operandStackPointer]
			mov dword ecx, [newLinkToPushAddress]
			mov dword [ebx + edx], ecx
			add dword [operandStackPointer], 4

			pushad
			freeOperand dword firstLastLinkAddressToDelete
			popad
			pushad
			freeOperand dword secondLastLinkAddressToDelete
			popad
			cmp [debug_mode],byte 1
			jne regular_add_res
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			mov byte [flag2],1
			cmp [flag1],byte 1
			jne regular_dup
			reular_add1:
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			regular_add_res:
			mov byte [flag2],0
			jmp printCalc

	prePAP:

			jmpPopAndPrint:
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_pap
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_pap:
			xor ebx,ebx
			xor ecx,ecx
			cmp dword [operandStackPointer], 4
			jl Insufficient
			sub dword [operandStackPointer],4

			call PopAndPrint
			jmp printCalc

	preDUP:

			jmpDuplicate:
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_dup
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_dup:
			mov byte [isFirstToDup], 0
			cmp dword [operandStackPointer], 16
			jle checkNotEmpty
			sub dword [numOfOperation],1
			jmp pOverflow
			checkNotEmpty:
			cmp dword [operandStackPointer], 4
			jge legalDup
			sub dword [numOfOperation],1
			jmp Insufficient

			legalDup:
			mov eax, [operandStackPointer]
			sub eax, 4 										;get the last operand that was inserted to the operand stack
			mov ebx, [operandStack + eax]
			push ebx
			call Duplicate
			add esp, 4
			mov ecx, [operandStackPointer]
			mov dword [operandStack + ecx], eax
			add dword[operandStackPointer], 4
			cmp [debug_mode],byte 1
			jne regular_dup_res
			pushad
			cmp byte [flag2],1
			je reular_add1
			cmp byte [flag1],1
			je regular_dup_res
			mov byte [flag1],1
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			jmp regular_dup
			popad
			regular_dup_res:
			mov byte [flag1],0
			jmp printCalc


	jmpBWand:
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_BWand
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_BWand:
			cmp dword [operandStackPointer], 8
			jl Insufficient

			mov dword eax, [operandStackPointer]
			sub eax, 4
			mov dword ebx, [operandStack + eax] 				; X
			;push ebx
			sub eax, 4
			mov dword ecx, [operandStack + eax]					; Y


			xor edx, ed
			mov dword [operandStackPointer], eax
			push ebx 											; push X
			push ecx											; push Y
			call BWand
			cmp [debug_mode],byte 1
			jne regular_pow_res
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			mov byte [flag2],1
			cmp [flag1],byte 1
			jne regular_dup
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			regular_pow_res:
			mov byte [flag2],0

			jmp printCalc

			jmpSqrtPower:
			add dword [numOfOperation],1
			checkLegOperandStack
			cmp [debug_mode],byte 1
			jne regular_spwr
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_spwr:

			popTwoOperands
			checkYvalue byte [ecx]
			xor esi, esi
			mov esi, [ecx]
			mov [powerNumber], esi
			push ebx 											; push x
			push ecx											; push y
			call SqrtPower
			cmp [debug_mode],byte 1
			jne regular_spow_res
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			mov byte [flag2],1
			cmp [flag1],byte 1
			jne regular_dup
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			regular_spow_res:
			mov byte [flag2],0
			jmp printCalc


			jmpNumberOfOnes:
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_ones
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_ones:
			xor ebx,ebx
			xor ecx,ecx
			cmp dword [operandStackPointer], 4
			jl Insufficient
			sub dword [operandStackPointer],4

			call NumberOfOnes
			cmp [debug_mode],byte 1
			jne regular_ones_res
			mov byte [isFirstLink], 0
			mov byte [isFirstToDup], 0
			mov byte [tempOdd], 0
			mov byte [flag2],1
			cmp [flag1],byte 1
			jne legalDup
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			regular_ones_res:
			mov byte [flag2],0
			jmp printCalc

			pOverflow:
			push dword errMsgOver
			push format_string
			call printf
			add esp,8
			jmp printCalc


			Insufficient:
			push dword errMsgIns
			push format_string
			call printf
			add esp, 8
			jmp

			cont:
			cmp [debug_mode],byte 1
			jne regular_input
			debug_print input_msg
			debug_print buffer
			jdown
			regular_input:
			call cInsertNumberToStack
			jmp printCalc

		 cDeleteLine:
		 	startFunction
		 	mov dword [count],0         ; intiate counter to count length of checkInput
			mov ecx,82					; buffer size
			mov edx, buffer				; buffer address

			deleteLoop:					; serch for new line in the buffer, and delete it
			cmp byte [edx],0xa
			je l1 					; if finds a new line, replace him with 0
			add byte [count],1
			inc edx
			loop deleteLoop

			l1:
			mov byte [edx],0
			inc edx
			endFunctionParameter


		cInsertNumberToStack:
			startFunction
			and ecx,0

			CheckIfOver:
				cmp dword [count], 0
				je numberWasAdded
				call cCreateLink
				sub dword [count], 2
				jmp CheckIfOver

				numberWasAdded:
				add dword [operandStackPointer], 4
				jmp finish

		cCreateLink:					; Creates link
			startFunction
			xor ebx, ebx
			xor ecx, ecx

			cmp dword [count], 1
			je addZero
			jmp getNumber

			addZero:
			mov al, [buffer]
			mov [buffer],byte  '0'
			mov [buffer + 1], al
			add byte [count],1

			getNumber:
				xor edx, edx
				xor ecx, ecx
				add ecx, [count]
				dec ecx
				add edx, [buffer + ecx]		; Extract the first number to be convert
				mov dword [ebp-4], eax
				push edx
				call makeInt
				add esp, 4

				mov byte [buffer+ecx], 0
											; move the the next char at the buffer
				add ebx, eax

				dec ecx
				xor edx, edx
				add edx, [buffer + ecx]			;
				push edx
				mov dword [ebp-4], eax
				call makeInt
				add esp, 4
				shl eax, 4
				add ebx, eax
				mov byte [buffer+ecx], 0		; convert the last digit in the buffer to null (0)

			createLink:
				xor edx, edx
				xor ecx, ecx

				pusha
				push dword [linkSize]
				push 1
				call calloc
				add esp, 8
				mov dword [eax], ebx
				cmp byte [isFirstLink], 0 			; create Link with the value in ebx
				jne notFirst

				isFirst:
				xor ecx, ecx
				mov [lastLink], eax
				mov ecx, [operandStackPointer]			; if first tell the operand where to point
				mov [operandStack + ecx], eax
				add [isFirstLink], byte 1
				jmp endFirst

				notFirst:
				xor ecx, ecx
				xor ebx, ebx
				mov ecx, [lastLink] 					; if the number was not the first, update lastLink
				inc ecx
				mov dword [ecx], eax
				mov [lastLink], eax

				endFirst:
				endFunction

			cmp dword [operandStackPointer], 16
			jg Insufficient
			jmp cont

				makeInt:
					startFunction
					makeNum:
						cmp eax, 57
						jg changeUpper
						cmp eax, 48
						jl endInt
						sub eax, 48
						jmp endInt


					changeUpper:
						cmp eax, 65
						jl endInt
						cmp eax, 70
						jg changeLower
						sub eax, 55
						jmp endInt

					changeLower:
						cmp eax, 97
						jl endInt
						cmp eax, 102
						jg endInt
						sub eax, 87

					endInt:

			finish:
				mov dword [temp], eax
				popa
				mov eax, dword [temp]
				mov esp, ebp
				pop ebp
				ret


		end:
			cmp [debug_mode],byte 1
			jne regular_end
			debug_print opartion_seleced
			debug_print buffer
			jdown
			debug_print q_debug

			regular_end:
			clearBuff buffer
			xor ecx,ecx
			xor edi,edi
			mov ecx,[numOfOperation]
			mov dword [buffer],ecx
			push dword buffer
			call cInsertNumberToStack
			add esp,4
			sub dword [operandStackPointer],4
			call PopAndPrint
			mov dword [toBeDeleted],0
			xor ebx,ebx
			xor edx,edx

			endLoop:
			cmp dword [operandStackPointer],0
			je AllDeleted
			sub dword [operandStackPointer],4
			mov edx,dword [operandStackPointer]
			mov ebx, dword [operandStack+edx]
			mov dword [toBeDeleted],ebx
			freeOperand toBeDeleted
			jmp endLoop
			AllDeleted:
			mov esp, ebp
			pop ebp
			ret

Addition:
	startFunctionTwoParams
	mov dword [carry], 0
	mov dword [carry1], 0


	checkFirst:
	xor eax, eax
	xor edx, edx

	mov dword [firstLastLinkAddressToDelete], ebx
	mov dword [secondLastLinkAddressToDelete], ecx
	mov dword [firstLastLinkAddress], ebx
	mov dword [secondLastLinkAddress], ecx
	cmp byte [isFirstLink], 0
	je atLeastTwoFirst
	jmp notFirstLinks1

	atLeastTwoFirst:
	mov byte al, [ebx] 							; put in al the value of the first link
	mov byte dl, [ecx] 							; || second
	add al, [carry]
	setc [carry1]
	add al, dl										; al and ab
	setc [carry]
	cmp byte [isFirstLink], 0
	je putNewLinkToPushAddress
	jmp notPutNewLinkToPushAddress

	putNewLinkToPushAddress:					; update the last link pointers
	pushad
	createLinkMacro
	mov dword [newLinkToPushAddress], eax
	popad
	xor edx, edx
	mov dword edx ,[newLinkToPushAddress]
	mov byte [edx], al


	jmp notFirstLinks1

	notPutNewLinkToPushAddress:
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al




	notFirstLinks1:
	cmp dword [ebx + 1], 0						; check if there are more links of the first number
	je noMoreFirstLinks
	xor edx, edx
	mov edx, [ebx + 1]
	mov dword [firstLastLinkAddress], edx

	jmp notFirstLinks2

	noMoreFirstLinks:
	mov byte [isMoreFirst], 1 					; mark by 1 if there are no more first
	jmp notFirstLinks2

	notFirstLinks2:
	cmp dword [ecx + 1], 0						; checks if there are more links of the second number
	je noMoreSecondLinks
	xor edx, edx
	mov edx, [ecx + 1]
	mov dword [secondLastLinkAddress], edx
	jmp isBothOver

	noMoreSecondLinks:
	mov byte [isMoreSecond], 1 					; mark by 1 if there are no more second
	jmp isBothOver

	isBothOver:
	xor edx, edx
	xor ebx, ebx
	mov bl, [isMoreFirst]
	mov dl, [isMoreSecond]

		compare1:
		cmp byte bl, 0
		je checkDl
		jmp compare2
		checkDl:
		cmp byte dl, 0
		je bothHaveCont

		compare2:
		cmp byte bl, 1
		je checkDl2
		jmp compare3
		checkDl2:
		cmp byte dl, 0
		je onlySecondLeft

		compare3:
		cmp byte bl, 0
		je checkDl3
		jmp checkCarry
		checkDl3:
		cmp byte dl, 1
		je onlyFirstLeft
		jmp checkCarry

	bothHaveCont:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov dword ebx, [firstLastLinkAddress]
	mov dword ecx, [secondLastLinkAddress]
	jmp atLeastTwoFirst




	onlySecondLeft:
	cmp byte [isMoreSecond], 1
	je checkCarry
	xor edx, edx
	xor ebx, ebx
	xor eax, eax
	mov dword ebx, [secondLastLinkAddress]
	mov byte al, [ebx]
	add al, [carry]
	setc [carry]
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al
	cmp dword [ebx + 1], 0 						; NEED TO TAKE CARE TO CARRY CASE
	je checkCarry
	xor edx, edx
	mov edx, [ebx+1]
	mov dword [secondLastLinkAddress], edx
	jmp onlySecondLeft


	onlyFirstLeft:
	cmp byte [isMoreFirst], 1
	je checkCarry
	xor edx, edx
	xor ebx, ebx
	xor eax, eax
	mov dword ebx, [firstLastLinkAddress]
	mov byte al, [ebx]
	add al, [carry]
	setc [carry]
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al
	cmp dword [ebx + 1], 0						; NEED TO TAKE CARE TO CARRY CASE
	je checkCarry
	xor edx, edx
	mov edx, [ebx+1]
	mov dword [firstLastLinkAddress], edx
	JMP onlyFirstLeft

	checkCarry:
	cmp byte [carry], 1
	je createCarryLink
	cmp byte [carry1], 1
	je createCarryLink
	jmp endAddition

	createCarryLink:
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], 1

	endAddition:
	cmp byte [isFirstLink], 1
	je updateStack


	updateStack:
	xor ecx, ecx
	mov ecx, [newLinkToPushAddress]
	mov dword [ebp - 4], ecx

	endFunctionParameter

PopAndPrint:
	startFunction
	clearBuff buffer
	xor edi,edi
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	mov edx,[operandStackPointer]
	mov dword ebx, [operandStack+edx]
	xor edx,edx
	runTotheEnd:
		inc edx
		push ebx
		mov ebx , dword [ebx+1]
		cmp ebx,0
		jnz runTotheEnd
		xor esi,esi
	printTheStack:
		xor edi,edi
		xor eax,eax
		xor ebx,ebx
		cmp edx,0
		je endPopAndPrint
		xor ecx,ecx
		pop ecx
		mov al, [ecx]
		mov bl, [ecx]
		shr bl, 4
		pushad
		push ecx
		call free
		add esp,4
		popad
		backtoString ebx
		mov [buffer+esi], bl
		xor ebx, ebx
		mov ebx,eax
		shl bl, 4
		shr bl, 4
		backtoString ebx
		inc esi
		mov [buffer+esi], bl
		inc esi
		dec edx
		jmp printTheStack

	endPopAndPrint:
		removeZero
		push dword buffer
		push format_string
		call printf
		add esp, 8
		clearBuff buffer
		push down
		push format_string
		call printf
		add esp ,8
		endFunction

Duplicate:
	startFunction							;first, check if there is any operands, or too much
	startDup:
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	dupLink:
	pushad
	createLinkMacro
	cmp byte [isFirstToDup], 0
	je putNewLinkToPushAddressDup
	jmp notPutNewLinkToPushAddressDup
	putNewLinkToPushAddressDup:
	mov dword [newLinkToPushAddress], eax
	mov byte [isFirstToDup], 1
	notPutNewLinkToPushAddressDup:
	popad
	mov byte cl, [eax]
	mov edx, [lastLink]
	mov byte [edx], cl
	cmp dword [eax + 1], 0
	jne incSourceAddressPointer
	jmp doneDup
	incSourceAddressPointer:
	mov eax, [eax + 1]
	jmp dupLink
	doneDup:
	mov edx, [newLinkToPushAddress]
	endDuplicate:
	mov [ebp - 4], edx

	endFunctionParameter

BWand:
	startFunction
	mov dword [carry], 0
	mov dword [carry1], 0


	checkFirst:
	xor eax, eax
	xor edx, edx

	mov dword [firstLastLinkAddressToDelete], ebx
	mov dword [secondLastLinkAddressToDelete], ecx
	mov dword [firstLastLinkAddress], ebx
	mov dword [secondLastLinkAddress], ecx
	cmp byte [isFirstLink], 0
	je atLeastTwoFirst
	jmp notFirstLinks1

	atLeastTwoFirst:
	mov byte al, [ebx] 							; put in al the value of the first link
	mov byte dl, [ecx] 							; || second
	and al, dl										; al and ab
	cmp byte [isFirstLink], 0
	je putNewLinkToPushAddress
	jmp notPutNewLinkToPushAddress

	putNewLinkToPushAddress:					; update the last link pointers
	pushad
	createLinkMacro
	mov dword [newLinkToPushAddress], eax
	popad
	xor edx, edx
	mov dword edx ,[newLinkToPushAddress]
	mov byte [edx], al


	jmp notFirstLinks1

	notPutNewLinkToPushAddress:
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al




	notFirstLinks1:
	cmp dword [ebx + 1], 0						; check if there are more links of the first number
	je noMoreFirstLinks
	xor edx, edx
	mov edx, [ebx + 1]
	mov dword [firstLastLinkAddress], edx

	jmp notFirstLinks2

	noMoreFirstLinks:
	pushad
	freeOperand dword secondLastLinkAddressToDelete
	popad
	mov byte [isMoreFirst], 1 					; mark by 1 if there are no more first
	jmp notFirstLinks2

	notFirstLinks2:
	cmp dword [ecx + 1], 0						; checks if there are more links of the second number
	je noMoreSecondLinks
	xor edx, edx
	mov edx, [ecx + 1]
	mov dword [secondLastLinkAddress], edx
	jmp isBothOver

	noMoreSecondLinks:
	pushad
	freeOperand dword firstLastLinkAddressToDelete
	popad
	mov byte [isMoreSecond], 1 					; mark by 1 if there are no more second
	jmp isBothOver

	isBothOver:
	xor edx, edx
	xor ebx, ebx
	mov bl, [isMoreFirst]
	mov dl, [isMoreSecond]

		compare1:
		cmp byte bl, 0
		je checkDl
		jmp compare2
		checkDl:
		cmp byte dl, 0
		je bothHaveCont

		compare2:
		cmp byte bl, 1
		je checkDl2
		jmp compare3
		checkDl2:
		cmp byte dl, 0
		je onlySecondLeft

		compare3:
		cmp byte bl, 0
		je checkDl3
		jmp checkCarry
		checkDl3:
		cmp byte dl, 1
		je onlyFirstLeft
		jmp checkCarry

	bothHaveCont:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov dword ebx, [firstLastLinkAddress]
	mov dword ecx, [secondLastLinkAddress]
	jmp atLeastTwoFirst




	onlySecondLeft:
	cmp byte [isMoreSecond], 1
	je checkCarry
	xor edx, edx
	xor ebx, ebx
	xor eax, eax
	mov dword ebx, [secondLastLinkAddress]
	mov byte al, [ebx]
	and al, [carry]
	setc [carry]
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al
	cmp dword [ebx + 1], 0 						; NEED TO TAKE CARE TO CARRY CASE
	je checkCarry
	xor edx, edx
	mov edx, [ebx+1]
	mov dword [secondLastLinkAddress], edx
	jmp onlySecondLeft


	onlyFirstLeft:
	cmp byte [isMoreFirst], 1
	je checkCarry
	xor edx, edx
	xor ebx, ebx
	xor eax, eax
	mov dword ebx, [firstLastLinkAddress]
	mov byte al, [ebx]
	and al, [carry]
	setc [carry]
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al
	cmp dword [ebx + 1], 0						; NEED TO TAKE CARE TO CARRY CASE
	je checkCarry
	xor edx, edx
	mov edx, [ebx+1]
	mov dword [firstLastLinkAddress], edx
	JMP onlyFirstLeft

	checkCarry:
	cmp byte [carry], 1
	je createCarryLink
	cmp byte [carry1], 1
	je createCarryLink
	jmp endAddition

	createCarryLink:
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], 1

	endAddition:
	cmp byte [isFirstLink], 1
	je updateStack


	updateStack:
	xor ecx, ecx
	mov ecx, [newLinkToPushAddress]
	mov dword [ebp - 4], ecx


	endFunctionParameter

SqrtPower:
	startFunctionTwoParams
	mov dword [isFirstLink], 0
	mov [firstLastLinkAddress], ebx
	pushad
	freeOperand firstLastLinkAddress
	popad
	mov dword [firstLastLinkAddress], 0 		; free the list that kept the y value
	xor eax, eax
	xor edx, edx
	mov eax, [operandStackPointer]
	mov [operandStack + eax], ecx

	negPowLoop:
	cmp dword [powerNumber], 0
	je endNegPower
	dec dword [powerNumber]
	mov eax, [operandStackPointer]
	mov ecx, [operandStack + eax]

	firstLink:
	xor ebx, ebx
	mov ebx, [ecx]
	mov edx, [ecx]
	shr byte dl, 1
	mov [ecx], edx
	cmp dword [ecx + 1] , 0
	je negPowLoop
	mov ebx, ecx
	mov dword ecx , [ecx + 1]

	subNegPowerLoop:
	xor eax, eax
	mov byte al, [ecx]
	and byte al, 1
	shl byte al, 7
	xor byte [ebx], al
	shr byte [ecx], 1
	cmp dword [ecx + 1] , 0
	je negPowLoop
	mov dword ecx, [ecx + 1]
	mov dword ebx, [ebx + 1]
	jmp subNegPowerLoop

	endNegPower:
	add dword [operandStackPointer], 4
	mov eax, [operandStackPointer]
	endFunctionParameter



NumberOfOnes:
	startFunction
	mov dword [carry],0
	mov dword [numofOnes], 0
	mov dword [counter],0
	clearBuff buffer
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	mov edx,[operandStackPointer]
	mov dword ebx, [operandStack+edx]
	xor edx,edx
	xor esi,esi
	runTotheEndones:
		inc esi
		push ebx
		mov ebx , dword [ebx+1]
		cmp ebx,0
		jnz runTotheEndones
	countOnes:
		cmp esi,0
		je endsession
		xor edx,edx
		xor eax,eax
		xor eax,eax
		pop ecx
		mov edx,[ecx]
		pushad
		push ecx
		call free
		add esp,4
		popad
		xor ecx,ecx
		mov cl,8
		dec esi
	countloop:
		xor edi,edi
		cmp cl,0
		je countOnes
		mov al,dl
		and dl ,1
		add byte [numofOnes] , dl
		setc [carry]
		cmp byte [carry],1
		jne noCarrytoAdd1
		add byte [carry1],1
		noCarrytoAdd1:
		mov dl,al
		shr dl,1
		dec cl
		jmp countloop

	endsession:
			clearBuff buffer
			xor ecx,ecx
			xor edi,edi
			mov ecx,[numofOnes]
			mov dword [buffer],ecx
			pushad
			push dword buffer
			call cInsertNumberToStack
			add esp,4
			cmp byte [carry1],1
			jne NoCarryToAdd
			mov ebx,ecx
			pushad
			createLinkMacro
			mov dword [eax],ebx
			popad
			mov dword edx ,[lastLink]
			mov byte [edx], 1
			NoCarryToAdd:
			popad
			endFunction