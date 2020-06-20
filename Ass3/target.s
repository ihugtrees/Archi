%macro generate_num 2
	push %1
	push %2
	call random_number
	add esp,8
%endmacro

section .text                           ; functions from c libary
	align 16
	global target:function
	global xt
	global yt
	extern res
	extern CORS
	extern schedulerCo
	extern resume
	extern drone
	extern scheduler
	extern printer
	extern random_number
	extern printf
	extern fprintf
	extern sscanf
	extern malloc
	extern free

target:
	finit
	xor edx,edx
	generate_num edx,distance
	fld qword [res]
	fstp qword [xt]
	generate_num edx,distance
	fld qword [res]
	fstp qword [yt]

	xor ebx,ebx
	xor eax,eax
	xor esi,esi
    
	mov eax,[CORS]
	mov esi,dword [schedulerCo]
	add eax,esi
	mov ebx, [eax]
	call resume
	jmp target

section .data
	xt :dq 0
	yt :dq 0
	distance :equ 100