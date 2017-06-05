        global _start
        extern init_co, start_co, resume
        extern scheduler, printer


        ;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1

section .data
        ten: dd 10
section .bss

; parameters:
length:     resb    4
width:      resb    4
k:          resb    4
t:          resb    4
state:      resb    4   ; the organisms state

section .text
    align 16
   ; extern malloc 

%macro get_number 2 ; gets a number from the stack
    
    mov ebx, [ebp + 4*%2]       ; place in the stack
    push ebx
    mov ebx, make_number
    call ebx
    add esp ,4
    mov dword [%1], eax         ; the label to update
    
%endmacro

%macro myMalloc 1			; returned address in eax
	
    push ebp				; open malloc's frame
    mov ebp, esp
    sub esp, 4				; Leave space for local var on stack
    pushad					;allocate space for new node

    push %1
    ;call malloc
    add esp, 4

    mov [ebp-4], eax                ; Save returned value...
    popad                           ; Restore caller state (registers)
    mov eax, [ebp-4]                 ; place returned value where caller can see it
    
    add     esp, 4          ; Restore caller state
    pop ebp					; close malloc's frame
%endmacro


_start:
        enter 0, 0

        mov eax, [ebp+4]        ; argc
        
        cmp eax, 7
        je read_params          ; if -d doesn't exist
        
        cmp eax, 8
        je deal_with_d          ; if -d exist
        
        ; now argc < 5 || argc > 6,,,, error here
        
        ;jmp finito
        
deal_with_d:
        
read_params:                       ;;; initialize parameters ;;;
        mov eax, [ebp + 4*3]       ; "filename"
        mov eax, [eax]
        
        ;; open file and initialize state
         
        get_number length, 4       ; length
        get_number width,  5       ; width
        get_number t,      6       ; t
        get_number k,      7       ; k
       
        mov eax, 0
        mov eax, [width]
        mul dword [length]
        
        myMalloc eax
        
        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler
        mov ecx, [ebp + 4]      ; ecx = argc
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state


        xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines


finito:        ;; exit
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
