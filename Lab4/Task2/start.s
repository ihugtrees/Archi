
section .data
	string: db 'Hello, Infected File',10
	string_len: equ $-string

section .text
	global _start
	global system_call
	global infector
	extern main

_start:
	pop    dword ecx    ; ecx = argc
	mov    esi,esp      ; esi = argv
	;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
	mov     eax,ecx     ; put the number of arguments into eax
	shl     eax,2       ; compute the size of argv in bytes
	add     eax,esi     ; add the size to the address of argv 
	add     eax,4       ; skip NULL at the end of argv
	push    dword eax   ; char *envp[]
	push    dword esi   ; char* argv[]
	push    dword ecx   ; int argc

	call    main        ; int main( int argc, char *argv[], char *envp[] )

	mov     ebx,eax
	mov     eax,1
	int     0x80
	nop
		
system_call:
	push    ebp             ; Save caller state
	mov     ebp, esp
	sub     esp, 4          ; Leave space for local var on stack
	pushad                  ; Save some more caller state

	mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
	mov     ebx, [ebp+12]   ; Next argument...
	mov     ecx, [ebp+16]   ; Next argument...
	mov     edx, [ebp+20]   ; Next argument...
	int     0x80            ; Transfer control to operating system
	mov     [ebp-4], eax    ; Save returned value...

	popad                   ; Restore caller state (registers)
	mov     eax, [ebp-4]    ; place returned value where caller can see it
	add     esp, 4          ; Restore caller state
	pop     ebp             ; Restore caller state
	ret                     ; Back to caller

infector:
	push    ebp             ; Save caller state
	mov     ebp, esp
	sub     esp, 4          ; Leave space for local var on stack
	pushad                  ; Save some more caller state

	mov 	eax, 5			; open for append
	mov 	ebx, [ebp+8]
	mov 	ecx, 1026
	mov 	edx, 0x777
	int 	0x80
	mov     [ebp-4], eax    ; Save file descriptor in ebp-4
	
	mov		ebx, eax		; write infection
	mov		eax, 4
	mov		ecx, code_start
	mov		edx, code_end - code_start
	int 	0x80

	mov 	eax, 6	; close file
	mov 	ebx, [ebp-4]
	int 	0x80

	popad                   ; Restore caller state (registers)
	add     esp, 4          ; Restore caller state
	pop     ebp             ; Restore caller state
	ret                     ; Back to caller


code_start:
	infection:
		push    ebp             ; Save caller state
		mov     ebp, esp
		pushad                  ; Save some more caller state

		mov     eax, 4
		mov 	ebx, 1
		mov 	ecx, string
		mov		edx, string_len
		int     0x80
		
		popad                   ; Restore caller state (registers)
		add     esp, 4          ; Restore caller state
		pop     ebp             ; Restore caller state
		ret                     ; Back to caller
code_end: