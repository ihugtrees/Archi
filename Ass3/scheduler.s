%macro printwinn 1
	pushad
	push %1
	push printwin
	call printf
	add esp,8
	popad
%endmacro

section .data
	SPP equ 4 							; offset of pointer to co-routine stack in co-routine struct
	rounds: dd 0
	droneSteps: dd 0
	minDestroyed: dd 65535
	alive: dd 0
	printwin: db "The winner is drone: %d", 10, 0

section .text                           ; functions from c libary
	align 16
	global scheduler:function
	extern N
	extern K
	extern R
	extern resume
	extern drone
	extern printer
	extern main
	extern printerCo
	extern CORS
	extern dronesArray
	extern printf
	extern endCo

scheduler:
	xor esi, esi ; drone offset
    mov eax, dword [N]
    mov dword [alive], eax

	schedulerLoop:
		mov eax, [N]
		shl eax, 2
		cmp eax, esi
		je roundComplete
		jmp next

	roundComplete: ; finished whole round
        xor esi, esi
        inc byte [rounds]
        mov edx, [rounds]
        cmp edx, [R]
        je checkIfGameOver

	next:
		mov eax, [CORS]
		add eax, esi
		mov ebx, [eax]

		mov ecx, [dronesArray] ; current drone pointer
		add ecx, esi
        mov ecx, [ecx]
		add esi, 4 ; next drone
		mov ecx, dword [ecx + 36] ; dead flag
		cmp ecx, 1 		; check if dead
		je schedulerLoop

		call resume
		inc byte [droneSteps]
		mov edi, [droneSteps]
		cmp edi, [K]
		je gotoPrinter
		jmp schedulerLoop

	gotoPrinter:
		mov eax, [CORS]
		mov ecx, dword [printerCo]
		add eax, ecx
		mov ebx, [eax]
		call resume
		mov dword [droneSteps], 0
		jmp schedulerLoop

	checkIfGameOver:
		xor eax, eax
		xor ecx, ecx ; counter
		xor edx, edx 
        mov dword [rounds], 0

        cmp dword [alive], 1
        je gameEnded
				
		mov dword [minDestroyed], 65535

		loserLoop:
			cmp ecx, [N]
			je endLoop
            mov edi, ecx
			shl edi, 2
			mov eax, [dronesArray] ; current drone
			add eax, edi
            mov eax, [eax]
            xor edx, edx
			mov edx, dword [eax + 36] ; if dead
			cmp edx, 1
			jge contLoop
            xor edx, edx
			mov edx, dword [eax + 32] ; how many targets destroyed
			cmp edx, dword [minDestroyed]
			jl loser

			contLoop:
			inc ecx
			jmp loserLoop

			loser:
			mov dword [minDestroyed], edx
			jmp contLoop

		endLoop:
			xor ecx, ecx
			eliminationLoop:
                mov edi, ecx
                shl edi, 2
                mov eax, [dronesArray] ; current drone
                add eax, edi
                mov eax, [eax]
				mov edx, dword [eax + 36] ; if dead
				cmp edx, 1
				jge contElimLoop
				mov edx, dword [eax + 32] ; how many targets destroyed
				cmp edx, dword [minDestroyed]
				je dieNoob

				contElimLoop:
				inc ecx
				jmp eliminationLoop

				dieNoob:
				mov dword [eax + 36], 1
                sub dword [alive], 1
                cmp dword [alive], 1
                je gameEnded
				jmp schedulerLoop

	gameEnded:
		xor ecx, ecx
		winnerLoop:
            mov edi, ecx
			shl edi, 2
			mov eax, [dronesArray] ; current drone
			add eax, edi
            mov eax, [eax]
			mov edx, dword [eax + 36] ; if dead
			cmp edx, 1
			jge contWinLoop
			jmp winner

			contWinLoop:
			inc ecx
			jmp winnerLoop
	winner:
        pushad
        jmp finalPrint
    printWinner:
        popad
		inc ecx
		printwinn ecx
		ffree
		call endCo

    finalPrint:
		mov eax, [CORS]
		mov ecx, dword [printerCo]
		add eax, ecx
		mov ebx, [eax]
		call resume
		mov dword [droneSteps], 0
		jmp printWinner