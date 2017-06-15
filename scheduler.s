global scheduler, first_time
extern resume, end_co
extern matrix_size, t, k

section .bss

printing_counter:   resb 4
cell_counter:       resb 4
generation_counter: resb 4
first_time:         resb 1

section .text

%macro inc_memo 2

    mov %2, 0
    mov %2, dword [%1]
    inc %2
    mov dword [%1], %2

%endmacro

scheduler:

cmp byte [first_time], 0
    jne .next
        mov byte  [first_time], 1
        mov dword [cell_counter], 0
        mov dword [printing_counter], 0
        mov dword [generation_counter], 0
            
.next:

    ; check if printing is needed
    mov ebx, [printing_counter]

    cmp ebx, [k]
    jne .cont
    
    ; calling printer
        mov ebx, 1
        mov dword [printing_counter], 0
        call resume
    
.cont:
    ; check if it is the last cell
    mov edx, [cell_counter]
    cmp edx, [matrix_size]
    jne .resume_cell
        mov dword [cell_counter], 0   ; return to the first cell
        inc_memo generation_counter, ebx

.resume_cell: 
    ; move to cell's co-routine

    inc_memo printing_counter, ebx
    mov ebx, 2
    add ebx, [cell_counter]
    call resume

    ; next cell
    inc_memo cell_counter, ebx
    
    ; check the program's interations
    mov ebx, [t]
    add ebx, ebx
    cmp ebx, [generation_counter]
    jne .next
    
    mov ebx, 1
    call resume
    call end_co             ; stop co-routines  