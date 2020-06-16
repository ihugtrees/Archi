%macro print_target_details 5
    push dword %1
    push dword %2
    push dword %3
    push dword %4
    push dword %5
    call printf
    add esp, 8
%endmacro

%macro print_drone_details 6
    push dword %1
    push dword %2
    push dword %3
    push dword %4
    push dword %5
    push dword %6
    push dword %7
    push dword %8
    push %
    call printf
    add esp, 20
%endmacro


section .data
  targetCordinatesStr: db "%.2f,%.2f",10,0 ; float 2 numbers after dot
  droneDetailsStr: db "%d,%.2f,%.2f,%.2f,%d", 10, 0   ; format string int

section .text                           ; functions from c libary
  align 16
	 global printer:function
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
    extern N
    
    printer:
    xor esi, esi
    ;xor edi, edi
    ;xor ecx, ecx
    ;print_target_details dword [yt + 4], dword [yt], dword [xt + 4], dword [xt], targetCordinatesStr
    mov eax, dword [dronesArray]
      pushad
      add eax, dword 4
      mov eax, [eax]
      popad
    mov ecx, dword [N]
    pushad
    fld qword [yt]
    fld qword [xt]
    sub esp, 16
    fstp qword [esp]
    fstp qword [esp+8]
    push targetCordinatesStr
    call printf
    add esp, 20
    popad

    printDronesLoop:
      mov edi, dword [eax]
      pushad
      push dword [edi + 24]
      fld qword [edi + 16]
      fld qword [edi + 8]
      fld qword [edi]
      sub esp, 24
      fstp qword [esp]
      fstp qword [esp + 8]
      fstp qword [esp + 16]
      inc esi
      push esi
      dec esi
      push droneDetailsStr
      call printf
      add esp, 36
      popad
      inc esi
      add eax, dword 4

    loop printDronesLoop, ecx

    mov eax, [CORS]
    mov esi,dword [schedulerCo]
    add eax, esi
    mov  ebx, [eax]
    call resume
    jmp printer



