
section .rodata
	format_string: db "%d",10,0 	; format string

section .text                    	; we write code in .text section
        global assFunc          	; 'global' directive causes the function assFunc(...) to appear in global scope
		extern c_checkValidity
		extern printf

assFunc:                        	; assFunc function definition - functions are defined as labels
        push ebp              		; save Base Pointer (bp) original value
        mov ebp, esp         		; use Base Pointer to access stack contents (do_Str(...) activation frame)
        pushad                   	; push all signficant registers onto stack (backup registers values)
        
		mov ecx, dword [ebp+8]		; x argument
		mov edx, dword [ebp+12]		; y argument

		push edx					; c_checkValidity second argument
		push ecx					; c_checkValidity first argument
		xor eax, eax				; zero eax
		call c_checkValidity
		pop ecx
		pop edx
		cmp eax,'0'
		je add_Number
		sub ecx,edx
		jmp after_Sub
		add_Number:
		add ecx,edx
		after_Sub:
		push ecx
		push format_string
		call printf
		add esp, 8
	
        popad                    	; restore all previously used registers
        mov esp, ebp				; free function activation frame
        pop ebp						; restore Base Pointer previous value (to returnt to the activation frame of main(...))
        ret