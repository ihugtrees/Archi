macros:
    %macro startFunction 0
        push    ebp
        mov     ebp, esp
    %endmacro

    %macro endFunction 0
        mov     esp, ebp
        pop     ebp
        ret
    %endmacro

    %macro printwinn 1
        pushad
        push %1
        push printwin
        call printf
        add esp,8
        popad
        %endmacro
    
    %macro endFunctionParameter 0
        mov     eax, dword[ebp-4]
        mov     esp, ebp
        pop     ebp
        ret
    %endmacro
%macro generate_num 2
        push %1
        push %2
        call random_number
        add esp,8
%endmacro




%macro zero_q 1
    mov dword [%1],0
    mov dword [%1+4],0
%endmacro


%macro print_float 1
    fld qword [%1]
    sub esp,8
    fstp qword [esp]
    push format_string_2f
    call printf
    add esp,12
    %endmacro

%macro print_d 1
    pushad
    push %1
    push format_string
    call printf
    add esp,8
    popad
%endmacro





section .text                           ; functions from c libary
  align 16

     global drone:function
     extern ass3
     extern res
     extern CURR
     extern beta
     extern d
     extern T
     extern N
     extern xt
     extern yt
     extern targetCo
     extern dronesArray
     extern random_number
     extern target
     extern CORS
     extern res
     extern resume
     extern CURR
     extern endCo
     extern schedulerCo
     extern scheduler
     extern printer
     extern printf 
     extern fprintf
     extern sscanf
     extern malloc
     extern free
     extern maxint

 
    
     drone:
        
        finit

        xor eax,eax
        mov eax,dword [CURR]
        mov eax, [eax + 8]
        shl eax,2
        xor ebx,ebx
        mov ebx, [dronesArray]
        
        ;add ebx,eax
        mov ebx, [ebx + eax]
        fld qword [ebx]
        fstp qword [x1]
        ;print_float x1
        fld qword [ebx+8]
        fstp qword [y1]
        fld qword [ebx+16]
        fstp qword [alpha]
        ;print_float alpha
       


 
     calc_gagree:
        
        pushad
        generate_num deg2,deg1
        popad
        ;print_float res
        fld qword [res]
        fld qword [alpha]               ; drone old degree
        
        faddp
        fild dword [max_deg]   
        fcomip
        jae nofixdegree 
        fild dword [max_deg]
        fsub 
        jmp calc_dist
        nofixdegree:
        fild dword [zerodata]
        fcomip 
        jb calc_dist
        fild dword [max_deg]
        fadd 

        calc_dist:
        fstp qword [alpha]
        fld qword [alpha]
        fstp qword [ebx+16] 
        zero_q res
        zero_q x2           
        zero_q y2
        pushad
        generate_num zero,dis1
        popad
        fld qword [alpha]       ;load angle into st0
        fld qword [rad]
        fmul
        fcos                        ;st0 = cos(ang)
        fmul qword [res]            ;st0 = cos(ang) * distance
        fstp qword [x2]             ; distance*cos(deg)
        fld qword [x1]
        fld qword [x2]
        faddp 
        fild dword [max_dis]
        fcomip                      ;if new distance>100
        jae checklowx
        fild dword [max_dis]
        fsub
        jmp calcYsin
        checklowx:
        fild dword [zerodata]
        fcomip
        jb calcYsin
        fild dword [max_dis]
        fadd
                   
        calcYsin:
        fstp qword [x1] 
        fld qword [x1]
        fstp qword [ebx]
        fld qword [alpha]       ;load angle into st0
        fld qword [rad]
        fmul
        fsin                        ;st0 = cos(ang)
        fmul qword [res]            ;st0 = cos(ang) * distance
        fstp qword [y2]             ; distance*cos(deg)
        fld qword [y1]
        fld qword [y2]
        faddp
        fild dword [max_dis]
        fcomip                      ;if new distance>100
        jae checklowy
        fild dword [max_dis]
        fsub
        checklowy:
        fild dword [zerodata]
        fcomip
        jb myDestroy
        fild dword [max_dis]
        fadd


        mov eax,dword [CURR]
        mov eax, [eax + 8]
        myDestroy: 
        fstp qword [y1]             ;new y place
         fld qword [y1]
         fstp qword [ebx+8]
            fld dword [d]
            fstp qword [distance_input]
            ;print_float distance_input
            fld dword [beta]
            fstp qword [beta_input]
            fld qword [xt]
            fld qword [x1]
            fsub 
            fstp qword [xmd]
            fld qword [yt]
            fld qword [y1]
            fsub 
            fstp qword [ymd]
            call calc_deg 
            call calc_distance
        
          
           

            fld qword [distance_input]
            fld qword [dis_tar_dro]
            fcomip              ; check if distance to target < d
            jae resumeSchedular
            fld qword [beta_input]
            fld qword [gamma]
            
            

            fcomip
            jae resumeSchedular     ; TODO make resume scheduler
            call distroyTarget
            jmp drone

            


            calc_distance:
                startFunction
                fld qword [ymd]
                fld qword [ymd]
                fmul    
                fstp qword [ymd]
                fld qword [xmd]
                fld qword [xmd]
                fmul
                fstp qword [xmd]
                fld qword [ymd]
                fld qword [xmd]
                fadd
                fsqrt
                fstp qword [dis_tar_dro]
                pop ebp
                ret


            calc_deg:
                startFunction
                ffree
                fld qword [ymd]
                fld  qword [xmd]
                fpatan
                fstp qword [gamma]
                fld qword [gamma]
                fld qword [pi]
                fmul
                fstp qword [gamma]
                fld qword [alpha]
                fld qword [gamma]
                fsub 
                fild dword [halffeg]
                fcomip
                jb add2pi
                cont_calc_deg:
                fld qword [alpha]
                fld qword [gamma]
                fsub 
                fabs
                fstp qword [gamma]
                endFunction
                fcomip
                ja add2pi
                ffree
                pop ebp
                ret
                add2pi:
                fld qword [alpha]
                fld qword [gamma]
                fcomip
                jb fixsmaller
                 fild dword [max_deg]
                fld qword [alpha]
                fadd
                fstp qword [alpha]
                jmp cont_calc_deg
                fixsmaller:
                fild dword [max_deg]
                fld qword [gamma]
                fadd
                fstp qword [gamma]
                jmp cont_calc_deg
                

            
        distroyTarget:
            startFunction
            ffree
            xor eax,eax
            mov eax,dword [CURR]
            mov eax, [eax + 8]
            shl eax,2
            xor ebx,ebx
            mov ebx,dword [dronesArray]
            mov ebx, [ebx + eax]

            xor esi, esi
            mov esi, [ebx + 24]
            inc esi

            mov dword [ebx+24],esi
            mov esi,[T]
            cmp esi, dword [ebx+24]
            je printwinner

            mov eax,[CORS]
            mov ecx,dword [targetCo]
            add eax,ecx
            mov ebx,[eax]
            ffree
            call resume
            endFunction
            





            printwinner:
                shr eax, 2
                inc eax
                printwinn eax
                ffree   
                call endCo






                resumeSchedular:
                    xor ebx,ebx
                    xor eax,eax
                    xor esi,esi
                    mov eax,[CORS]
                    mov esi,dword [schedulerCo]
                    add eax,esi
                    mov ebx,[eax]
                    ffree
                    call resume
                    jmp drone





        

section .data
    deg: equ 360
    dis :equ 100
    deg1 :equ  60
    deg2: equ -60
    dis1 :equ 50
    zero:equ 0
    halffeg :dd 180
    max_dis : dd 100
    max_deg : dd 360
    beta_input: dq 0
    distance_input:dq 0
    rad : dq 0.0174532925199433
    pi: dq 57.2957795130823209
    degree: dd 0
    zerodata: dd 0
  

    x2: dq 0            ;delta x cordinate     
    y2: dq 0            ;first y cordinate

    x1: dq 0
    y1: dq 0
    xmd: dq 0 
    ymd: dq 0
    dis_tar_dro: dq 0
    alpha: dq 0
    gamma: dq 0
    ;maxint : DD 0xffff
    format_string_2f: db "%.2f",10,0 ; float 2 numbers after dot
    format_string : db "%d",10,0 
    printwin: db "Drone id %d: I am a winner",10,0


section .bss
 

