        global _start
        extern init_co, start_co, resume
        extern scheduler, printer


        ;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1

section .data
        ten: dd 10
section .bss
length:     resb 	1
width:      resb 	1
t:          resb 	1
k:          resb 	1

section .text

%macro get_number 2 ; gets a number from the stack
    
        mov ebx, [ebp + 4*%2]       ; place in the stack
        push ebx
        mov ebx, make_number
        call ebx
        add esp ,4      ;;;;;;;;;;;;;;;;;;;;PROBLEMMM
        mov dword [%1], eax         ; the label to update
    
%endmacro



_start:
        enter 0, 0

        ;;; initialize parameters ;;;
        
        mov eax, [ebp+4]        ; argc
        
        ;; check if -d exist
        ;; check if argc < 5... error in parameters
        
        mov eax, [ebp + 4*3]       ; "filename"
        mov eax, [eax]
        
        ;; open file and initialize state
         
start_l:        get_number length, 4       ; length
start_w:        get_number width,  5       ; width
start_t:        get_number t,      6       ; t
start_k:        get_number k,      7       ; k
end:
        
        
        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler
        mov ecx, [ebp + 4]      ; ecx = argc
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state


        xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines


        ;; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h
        
        
        
;;;;;;;;;;;;;; change it 


;; gets string and converts to a number
make_number:
        push    ebp
        mov     ebp, esp        ; Entry code - set up ebp and esp
        mov ecx, dword [ebp+8]  ; Get argument (pointer to string)
        mov eax, 0
        mov ebx, 0
make_number_loop:
        mov edx, 0
        cmp byte[ecx],0
        jz  make_number_end
        imul dword[ten]
        mov bl,byte[ecx]
        sub bl,'0'
        add eax,ebx
        inc ecx
        jmp make_number_loop
make_number_end:
        mov     esp, ebp        ; Function exit code
        pop     ebp
        ret
