global scheduler
extern resume, end_co


section .text

scheduler:
        mov ebx, 1
.next:
;ebx 
mov ebx, 1
        call resume             ; resume printer
        loop .next

        call end_co             ; stop co-routines