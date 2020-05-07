
section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%d",10,0	; format string

section .text
	global assFunc
	extern printf
	extern c_checkValidity

assFunc:
    push ebp
    mov ebp, esp
    pushad

    mov ecx, [ebp+8]   ;  get x-first argument
    mov edx, [ebp+12]  ;  get y-second argument

    push edx
    push ecx
    xor eax,eax
    call c_checkValidity

    pop ecx
    pop edx
    cmp eax ,'0'
    je addXY

    sub ecx,edx
    jmp noAdd

    addXY:
        add ecx,edx

    noAdd:
        push ecx			; call printf with 2 arguments -  
        push format_string			; pointer to str and pointer to format string
        
    toPrint:
        call printf   
        add esp, 8		; clean up stack after call

    popad
    mov esp, ebp
    pop ebp
    ret