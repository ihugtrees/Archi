section .data
	targetCordinatesStr: db "x: %.2f, y: %.2f", 10, 0 ; float 2 numbers after dot
	droneDetailsStr: db "[%d] x: %.2f, y: %.2f, a: %.2f, spd: %.2f, kills: %d, dead: %d", 10, 0   ; format string int
	targetStr: db "%.2f,%.2f", 10, 0
	droneStr: db "%d,%.2f,%.2f,%.2f,%.2f,%d", 10, 0

section .text                           ; functions from c libary
	align 16
	global printer:function
	extern N
	extern drone
	extern target
	extern scheduler
	extern resume
	extern printf
	extern fprintf
	extern sscanf
	extern malloc
	extern dronesArray
	extern xt
	extern yt
	extern free
	extern printerCo
	extern schedulerCo
	extern CORS
	extern speed

printer:
	pushad			; print target
	fld qword [yt]
	fld qword [xt]
	sub esp, 16
	fstp qword [esp]
	fstp qword [esp + 8]
	push targetCordinatesStr
	call printf
	add esp, 20
	popad

	xor esi, esi
	mov ecx, dword [N]
	mov eax, dword [dronesArray]

	printDronesLoop:
		mov edi, dword [eax]
		inc esi
		pushad
		push dword [edi + 36]
		push dword [edi + 32]
   		fld qword [edi  + 24]
		fld qword [edi + 16]
		fld qword [edi + 8]
		fld qword [edi]
		sub esp, 32
		fstp qword [esp]
		fstp qword [esp + 8]
		fstp qword [esp + 16]
		fstp qword [esp + 24]
		push esi
		push droneDetailsStr
		call printf
		add esp, 48
		popad
		add eax, dword 4
	loop printDronesLoop, ecx

	mov eax, [CORS]
	mov esi, dword [schedulerCo]
	add eax, esi
	mov ebx, [eax]
	call resume
	jmp printer