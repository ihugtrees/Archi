macros:
	%macro stackCheck 1
		xor eax,eax
		xor edi,edi
		mov eax, %1
		dec eax
		mov edi,4
		mul edi
	%endmacro

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

section .data
	format_string: db "%s", 0	; format string
	errMsgOver: db 'Error: Operand Stack Overflow', 10,0	;string in case of too many arguments
	errMsgIns: db 'Error: Insufficient Number of Arguments on Stack', 10,0	;string in case of Insufficient number of arguments in Stack
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
	isMoreFirst: resb 1
	isMoreSecond: resb 1
	firstLastLinkAddress: resd 1
	secondLastLinkAddress: resd 1
	newLinkToPushAddress: resd 1
	firstLastLinkAddressToDelete: resd 1
	secondLastLinkAddressToDelete: resd 1
	isFirstToDup: resb 1
	numofhex: resd 5
	toBeDeleted: resd 1
	numOfOperation: resd 1	

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
	xor esi, esi ; char
	mov eax, 0
	mov ecx, 16
	mov ebx, [esp+8]
	mov ebx, [ebx+4]
	hexLoop:
		mov dl, byte [ebx]
		mov esi, edx
		xor edx,edx
		inc ebx
		cmp esi, 0
		je finishedHex
		mul ecx
		cmp esi, 'A'
		jge hexLetter
		sub esi, '0'
		jmp addSum
		hexLetter:
		sub esi, 55
		addSum:
		add eax, esi
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
		mov	eax, [stackSize] 
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
			je jmpBWand
			cmp byte [buffer], '|'
			je jmpbtor
			cmp byte [buffer], 'n'
			je jmpNumberOfhex
			cmp byte [buffer], 0x00
			je printCalc
			
			xor ecx ,ecx
			mov ecx, [stackSize]
			stackCheck ecx
			cmp dword [operandStackPointer], eax
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
			mov dword ebx, [operandStack] 				; first cell of operand stack
            add ebx, eax
			push dword [ebx]
			sub eax, 4
			mov dword ecx, [operandStack]
            add ecx, eax
			push dword [ecx]
			mov dword [operandStackPointer], eax

			call Addition
			xor ebx, ebx
			xor ecx, ecx
			xor edx, edx
			mov dword ebx, [operandStack]
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
			xor ecx,ecx
			mov ecx, [stackSize]
			stackCheck ecx
			cmp dword [operandStackPointer], eax
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
			mov ebx, [operandStack]
			add ebx,eax
			push dword [ebx]
			call Duplicate
			add esp, 4
			mov ecx, [operandStackPointer]
			add ecx, [operandStack]
			mov dword [ecx], eax
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
			xor ebx, ebx
			xor ecx, ecx
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_BWand
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_BWand:
			cmp dword [operandStackPointer], 8
			jl Insufficient
			xor eax, eax
			xor ebx, ebx
			mov dword eax, [operandStackPointer]
			sub eax, 4
			mov dword ebx, [operandStack] 				; first cell of operand stack
            add ebx, eax
			push dword [ebx]
			sub eax, 4
			mov dword ecx, [operandStack]
            add ecx, eax
			push dword [ecx]
			mov dword [operandStackPointer], eax
													
			call BWand
			xor ebx, ebx
			xor ecx, ecx
			xor edx, edx
			mov dword ebx, [operandStack]
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
			jne regular_btand_res
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			mov byte [flag2],1
			cmp [flag1],byte 1
			jne regular_dup
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			regular_btand_res:
			mov byte [flag2],0
			jmp printCalc		

	jmpbtor:
			xor ebx, ebx
			xor ecx, ecx
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_BWor
			debug_print opartion_seleced
			debug_print buffer
			jdown
			regular_BWor:
			cmp dword [operandStackPointer], 8
			jl Insufficient
			xor eax, eax
			xor ebx, ebx
			mov dword eax, [operandStackPointer]
			sub eax, 4
			mov dword ebx, [operandStack] 				; first cell of operand stack
            add ebx, eax
			push dword [ebx]
			sub eax, 4
			mov dword ecx, [operandStack]
            add ecx, eax
			push dword [ecx]
			mov dword [operandStackPointer], eax
													
			call btor
			xor ebx, ebx
			xor ecx, ecx
			xor edx, edx
			mov dword ebx, [operandStack]
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
			jne regular_btor_res
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			mov byte [flag2],1
			cmp [flag1],byte 1
			jne regular_dup
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			regular_btor_res:
			mov byte [flag2],0
			jmp printCalc

		jmpNumberOfhex:
			add dword [numOfOperation],1
			cmp [debug_mode],byte 1
			jne regular_hex
			debug_print opartion_seleced
			debug_print buffer
			jdown
			
			regular_hex:
			xor ebx,ebx
			xor ecx,ecx
			cmp dword [operandStackPointer], 4
			jl Insufficient
			sub dword [operandStackPointer],4

			call NumberOfhex
			cmp [debug_mode],byte 1
			jne regular_hex_res
			mov byte [isFirstLink], 0
			mov byte [isFirstToDup], 0
			mov byte [tempOdd], 0
			mov byte [flag2],1
			cmp [flag1],byte 1
			jne legalDup
			debug_print pushed
			sub dword [operandStackPointer], 4
			call PopAndPrint
			regular_hex_res:
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
			jmp printCalc

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
				xor esi, esi
				xor ecx, ecx
				mov [lastLink], eax
                mov esi, [operandStack]
				mov ecx, [operandStackPointer]			; if first tell the operand where to point
				mov [esi + ecx], eax
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
			xor ecx,ecx
			mov ecx, [stackSize]
			stackCheck ecx
			cmp dword [operandStackPointer], eax
			jg pOverflow
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
			jdown
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
			mov ebx, dword [operandStack]
			add ebx, edx
			mov ecx , [ebx]
			mov dword [toBeDeleted], ecx
			freeOperand toBeDeleted
			jmp endLoop
			
			AllDeleted:
			mov eax, [operandStack]
			push eax
			call free
			add esp, 4

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
	mov edx, dword [ebx + 1]
	mov dword [firstLastLinkAddress], edx

	jmp notFirstLinks2

	noMoreFirstLinks:
	mov byte [isMoreFirst], 1 					; mark by 1 if there are no more first
	jmp notFirstLinks2

	notFirstLinks2:
	cmp dword [ecx + 1], 0						; checks if there are more links of the second number
	je noMoreSecondLinks
	xor edx, edx
	mov edx, dword [ecx + 1]
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
	jmp onlyFirstLeft

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
	mov dword ebx, [operandStack]
	add ebx,edx
	mov ebx, [ebx]
	xor edx,edx

	runTotheEnd:
		inc edx
		push ebx
		mov ebx , dword [ebx+1]
		cmp ebx, 0
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
	startFunctionTwoParams

	andcheckFirst:
	xor eax, eax
	xor edx, edx

	mov dword [firstLastLinkAddressToDelete], ebx
	mov dword [secondLastLinkAddressToDelete], ecx
	mov dword [firstLastLinkAddress], ebx
	mov dword [secondLastLinkAddress], ecx
	cmp byte [isFirstLink], 0
	je andatLeastTwoFirst
	jmp andnotFirstLinks1

	andatLeastTwoFirst:
	mov byte al, [ebx] 							; put in al the value of the first link
	mov byte dl, [ecx]
	and al, dl									; al and ab
	cmp byte [isFirstLink], 0
	je andputNewLinkToPushAddress
	jmp andnotPutNewLinkToPushAddress

	andputNewLinkToPushAddress:					; update the last link pointers
	pushad
	createLinkMacro
	mov dword [newLinkToPushAddress], eax
	popad
	xor edx, edx
	mov dword edx ,[newLinkToPushAddress]
	mov byte [edx], al

	jmp andnotFirstLinks1

	andnotPutNewLinkToPushAddress:
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al

	andnotFirstLinks1:
	cmp dword [ebx + 1], 0						; check if there are more links of the first number
	je andnoMoreFirstLinks
	xor edx, edx
	mov edx, dword [ebx + 1]
	mov dword [firstLastLinkAddress], edx

	jmp andnotFirstLinks2

	andnoMoreFirstLinks:
	mov byte [isMoreFirst], 1 					; mark by 1 if there are no more first

	andnotFirstLinks2:
	cmp dword [ecx + 1], 0						; checks if there are more links of the second number
	je andnoMoreSecondLinks
	xor edx, edx
	mov edx, dword [ecx + 1]
	mov dword [secondLastLinkAddress], edx
	jmp andisBothOver

	andnoMoreSecondLinks:
	mov byte [isMoreSecond], 1 					; mark by 1 if there are no more second

	andisBothOver:
	xor edx, edx
	xor ebx, ebx
	mov bl, [isMoreFirst]
	mov dl, [isMoreSecond]

		andcompare1:
		cmp byte bl, 0
		je andcheckDl
		jmp BWandEnd
		andcheckDl:
		cmp byte dl, 0
		je andbothHaveCont
		jmp BWandEnd
		
	andbothHaveCont:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov dword ebx, [firstLastLinkAddress]
	mov dword ecx, [secondLastLinkAddress]
	jmp andatLeastTwoFirst
	
	BWandEnd:
	endFunctionParameter

btor:
	startFunctionTwoParams

	orcheckFirst:
	xor eax, eax
	xor edx, edx

	mov dword [firstLastLinkAddressToDelete], ebx
	mov dword [secondLastLinkAddressToDelete], ecx
	mov dword [firstLastLinkAddress], ebx
	mov dword [secondLastLinkAddress], ecx
	cmp byte [isFirstLink], 0
	je oratLeastTwoFirst
	jmp ornotFirstLinks1

	oratLeastTwoFirst:
	mov byte al, [ebx] 							; put in al the value of the first link
	mov byte dl, [ecx] 
	or al, dl									
	cmp byte [isFirstLink], 0
	je orputNewLinkToPushAddress
	jmp ornotPutNewLinkToPushAddress

	orputNewLinkToPushAddress:					; update the last link pointers
	pushad
	createLinkMacro
	mov dword [newLinkToPushAddress], eax
	popad
	xor edx, edx
	mov dword edx ,[newLinkToPushAddress]
	mov byte [edx], al

	jmp ornotFirstLinks1

	ornotPutNewLinkToPushAddress:
	
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al
	ornotFirstLinks1:
	cmp dword [ebx + 1], 0						; check if there are more links of the first number
	je ornoMoreFirstLinks
	xor edx, edx
	mov edx, dword [ebx + 1]
	mov dword [firstLastLinkAddress], edx

	jmp ornotFirstLinks2

	ornoMoreFirstLinks:
	mov byte [isMoreFirst], 1 					; mark by 1 if there are no more first
	
	ornotFirstLinks2:
	cmp dword [ecx + 1], 0						; checks if there are more links of the second number
	je ornoMoreSecondLinks
	xor edx, edx
	mov edx, dword [ecx + 1]
	mov dword [secondLastLinkAddress], edx
	jmp orisBothOver

	ornoMoreSecondLinks:
	mov byte [isMoreSecond], 1 					; mark by 1 if there are no more second
	
	orisBothOver:
	xor edx, edx
	xor ebx, ebx
	mov bl, [isMoreFirst]
	mov dl, [isMoreSecond]

		orcompare1:
		cmp byte bl, 0
		je orcheckDl
		jmp orcompare2
		orcheckDl:
		cmp byte dl, 0
		je orbothHaveCont

		orcompare2:
		cmp byte bl, 1
		je orcheckDl2
		jmp orcompare3
		orcheckDl2:
		cmp byte dl, 0
		je oronlySecondLeft		

		orcompare3:
		cmp byte bl, 0
		je orcheckDl3
		jmp btorEnd
		orcheckDl3:
		cmp byte dl, 1
		je oronlyFirstLeft
		
	orbothHaveCont:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov dword ebx, [firstLastLinkAddress]
	mov dword ecx, [secondLastLinkAddress]
	jmp oratLeastTwoFirst

	oronlySecondLeft:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	mov dword ebx, [firstLastLinkAddress]
	mov dword ecx, [secondLastLinkAddress]
	mov byte al, [ecx]
	jmp ornotPutNewLinkToPushAddress

	oronlyFirstLeft:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	mov dword ebx, [firstLastLinkAddress]
	mov dword ecx, [secondLastLinkAddress]
	mov byte al, [ebx]
	jmp ornotPutNewLinkToPushAddress
	
	btorEnd:
	endFunctionParameter

NumberOfhex:  ; just count the links, mul 2 and check last link > 16
	startFunction
	mov dword [carry],0
	mov dword [numofhex], 0
	mov dword [counter],0
	clearBuff buffer
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	mov edx,[operandStackPointer]
	mov dword ebx, [operandStack]
	add ebx, edx
	mov ebx, [ebx]
	xor edx,edx
	xor esi,esi

	runTotheEndHex:
		inc esi
		push ebx
		mov ebx, dword [ebx+1]
		cmp ebx,0
		jnz runTotheEndHex
		xor eax,eax ;; mul by 2 and check if need to decrese by 1
		mov eax, 2
		mul esi
		pop ecx
		push ecx
		mov edx, [ecx]
		cmp edx, 16
		jge addHexa
		sub eax, 1
		addHexa:
		mov [numofhex], eax

	freecounthex:
		cmp esi,0
		je endsession
		pop ecx
		pushad
		push ecx
		call free
		add esp,4
		popad
		xor ecx,ecx
		dec esi
		jmp freecounthex

	endsession:
			clearBuff buffer
			xor ecx,ecx
			xor edi,edi
			mov ecx,[numofhex]
			mov dword [buffer],ecx
			pushad
			push dword buffer
			call cInsertNumberToStack
			add esp,4
			popad
			endFunction