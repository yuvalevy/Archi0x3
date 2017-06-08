global main
global WorldWidth
global WorldLength
global state_
extern init_co, start_co, resume
extern scheduler, printer, test, cell


;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1
sys_open:       equ   5
sys_read:       equ   3
read_only:      equ   0
permissions:    equ   777


section .data
        ten: dd 10
section .bss

; parameters:
WorldLength:     resb    4
WorldWidth:      resb    4
matrix_size:     resb    4
k:               resb    4
t:               resb    4
state_:          resb    102*102   ; the organisms state
filename_ptr:    resb    4   ; file name pointer
tmp_chr:         resb    1

section .text
    align 16
    extern malloc 

%macro get_number 1 ; gets a number from the stack
            
    add ecx, 4      ; next string pointer
    mov ebx, [ecx]  ; ebx hold the pointer to string
    
    push ecx
        push ebx
        
            mov ebx, make_number
            call ebx

        add esp ,4
    pop ecx

    mov dword [%1], eax         ; the label to update
    
%endmacro

%macro myMalloc 1			; returned address in eax
	
    push ebp				; open malloc's frame
    mov ebp, esp
    sub esp, 4				; Leave space for local var on stack
    pushad				;allocate space for new node

    push %1
    call malloc
    add esp, 4

    mov [ebp-4], eax                ; Save returned value...
    popad                           ; Restore caller state (registers)
    mov eax, [ebp-4]                 ; place returned value where caller can see it
    
    add     esp, 4          ; Restore caller state
    pop ebp					; close malloc's frame
%endmacro

main:
        enter 0, 0

        mov eax, 0
        mov eax, [ebp+4*2]      ; argc
        
        cmp eax, 6
        je read_params          ; if -d doesn't exist
        
        cmp eax, 7
        je deal_with_d          ; if -d exist
        
        ; now argc < 5 || argc > 6,,,, error here
        
        ;jmp finito
        
deal_with_d:
        
read_params:                       ;;; initialize parameters ;;;
        mov ecx, [ebp + 4*3]       ; char** argv
        add ecx, 4
        mov ebx, [ecx]      ; filename

        push ebx                   ; save filename
        
        ; read all other parameters
        get_number WorldLength       ; length
        get_number WorldWidth        ; width
        get_number t            ; t
        get_number k            ; k
        
              
        mov eax, 0
        mov eax, [WorldWidth]
        mul dword [WorldLength]      ; eax hold the 'state' actual size
        mov [matrix_size], eax
read_file:

        ;; open file and initialize state
        ; open
        mov eax, sys_open   ; system call number 
        pop ebx             ; restore file name
        mov ecx, read_only  ; file access
        mov edx, permissions; set file permissions
        int 0x80
        ; eax holds the file-descriptor
        
        cmp eax, -1         ; if there is an error
        je finito
  
        mov ebx, eax        ; save fd
        mov ecx, tmp_chr    ; read buffer
        mov esi, 0          ; loop count (until esi = [matrix_size])
        mov edx, 1          ; read one byte
read_loop:
        
        ; read
        mov eax, sys_read   ; system call number
        int 0x80
        
        ; put in state
        .is_dead:
                cmp byte [tmp_chr], 32   ; dead cell (space)
                jne .is_alive
                    mov byte [state_+esi], 0
                    inc esi             ; one less char to read
                    jmp .cont_loop

        .is_alive:
                cmp byte [tmp_chr], 49   ; alive cell (one)
                jne .cont_loop
                    mov byte [state_+esi], 1
                    inc esi             ; one less char to read

    .cont_loop:
            
            cmp esi, [matrix_size]
            jne read_loop
            
start_program:
        xor ebx, ebx            ; scheduler is co-routine 0 
        mov edx, scheduler
        mov ecx, [ebp + 4]      ; ecx = argc
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state
 
 ; initialize all cell's co-routines
 ; create a func for the cell (put in edx)
 
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





