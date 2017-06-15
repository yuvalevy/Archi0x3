global main
global WorldWidth, WorldLength, t, k, matrix_size, state
extern init_co, start_co, resume
extern scheduler, printer
extern cell_function


;; /usr/include/asm/unistd_32.h
sys_write:      equ   4
stdout:         equ   1
sys_exit:       equ   1
sys_open:       equ   5
sys_read:       equ   3
read_only:      equ   0
permissions:    equ   777

section .rodata
args_error: db "Worng number of parametes",10,0
p_length:   db "length=",0
p_width:    db "width=",0
p_gen:      db "number of generations=",0
p_fre:      db "print frequency=",0
new_line:   db 10   ,0

section .data
        ten: dd 10
section .bss

    ; parameters
WorldLength:     resb    4
casdcad: resb 1000
what_to_print:   resb    10

WorldWidth:      resb    4
casdcad2: resb 1000
k:               resb    4
casdcad3: resb 1000
t:               resb    4
casdcad4: resb 1000
state:          resb    102*102*2   ; the organisms state
    ; helpers
tmp_chr:         resb    1
matrix_size:     resb    4
debug:           resb    1

section .text
    align 16

%macro print 2
        mov eax, sys_write
        mov ebx, stdout
        mov ecx, %1
        mov edx, %2
        int 80h
%endmacro

%macro get_number 3 ; gets a number from the stack
            
    add ecx, 4      ; next string pointer
    mov ebx, [ecx]  ; ebx hold the pointer to string
    mov [what_to_print], ebx
    
    push ecx
        push ebx
    
            cmp byte [debug], 1
            jne %%skip
            
            print %2,%3

            mov ecx, [what_to_print]
            print ecx, 1
            print new_line, 1
            %%skip:
                    mov ebx, make_number
                    call ebx

        add esp ,4
    pop ecx

    mov dword [%1], eax         ; the label to update
    
%endmacro

main:
        enter 0, 0

        mov byte [debug], 0
        mov eax, 0
        mov eax, [ebp+4*2]      ; argc
        
        cmp eax, 6
        je read_params          ; if -d doesn't exist
        
        cmp eax, 7
        je deal_with_d          ; if -d exist
        
        ; now argc < 5 || argc > 6,,,, error here
   
        print args_error, 27
        
        jmp finito
        
deal_with_d:

        mov byte [debug], 1             
        
read_params:                       ;;; initialize parameters ;;;
        mov ecx, [ebp + 4*3]       ; char** argv
        add ecx, 4
        
        cmp byte [debug], 1
        jne .cont
        add ecx, 4

        .cont:
        mov ebx, [ecx]             ; filename
        push ebx                   ; save filename
        
        ; read all other parameters
        get_number WorldLength, p_length, 7      ; length
        get_number WorldWidth, p_width, 6       ; width
        get_number t, p_gen, 22                ; t
        get_number k, p_fre, 16                ; k
              
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
                    mov byte [state+esi], '0'
                    inc esi             ; one less char to read
                    jmp .cont_loop

        .is_alive:
                cmp byte [tmp_chr], 49   ; alive cell (one)
                jne .cont_loop
                    mov byte [state+esi], '1'
                    inc esi             ; one less char to read

    .cont_loop:
            
            cmp esi, [matrix_size]
            jne read_loop
           
start_program:
        xor ebx, ebx            ; scheduler is co-routine 0 
        mov edx, scheduler
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state
 
 ; initialize all cell's co-routines
		inc ebx
        mov eax, 0              ; x = 0 -> WorldLength-1

x_loop:
        mov ecx, 0              ; y = 0 -> WorldWidth-1
    y_loop:
            mov edx, cell_function
            call init_co        ; create co-routine
            
            inc ebx
            inc ecx             ; inc y
            
            mov esi, [WorldWidth]
            cmp ecx, esi
            jne y_loop
            
        inc eax                 ; inc x
        
		mov esi, [WorldLength]
        cmp eax, esi
        
        jne x_loop
    ;;; finish initialize co-routines
 
 
        xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines


finito:                         ; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h

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