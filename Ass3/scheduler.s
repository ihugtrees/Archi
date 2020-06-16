

section .data
  	SPP equ 4 							; offset of pointer to co-routine stack in co-routine struct 
section .text                           ; functions from c libary
  align 16
	 global scheduler:function
   extern resume
   extern drone
   extern printer
   extern N
   extern main
   
   extern printerCo
   extern CORS
   extern K
    
     scheduler:
    xor edi, edi
    xor esi, esi
    xor eax, eax
    mov edi, dword 0
    schedulerLoop:
      mov eax, [N]
      shl eax, 2
      cmp eax, esi
      je initEsi
      jmp next
      initEsi:
      xor esi, esi
      
      
      next:
      mov eax, [CORS]
      add eax, esi
      mov ebx, [eax]
      ;mov ebx, [eax + SPP]
      call resume
      add esi, dword 4
      inc edi
      cmp edi, [K]
      je gotoPrinter  
      jmp schedulerLoop
    
    gotoPrinter:
      mov eax, [CORS]
      mov ecx,dword [printerCo]
      add eax, ecx
      mov ebx, [eax]
      ;mov ebx, [eax + SPP]
      call resume
      xor edi, edi
      jmp schedulerLoop


