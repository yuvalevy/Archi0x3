global printer
extern resume, state_, WorldWidth, WorldLength, matrix_size
;; /usr/include/asm/unistd_32.h
sys_write:      equ   4
stdout:         equ   1
section .data

newline:  db 10
ender:  db '-----', 10

section .text

%macro print 2
        mov eax, sys_write
        mov ebx, stdout
        mov ecx, %1
        mov edx, %2
        int 80h
%endmacro

printer:

		mov esi, 0				; x counter
	.loop:
		mov edi, 0				; y counter
		.inner_loop:
		
			mov eax, [WorldWidth]
			mul esi					; esi = counter*WorldWidth
			mov ecx, state_
			add ecx, eax			; ecx = counter*WorldWidth + state_
			add ecx, edi
                        
			print ecx, 1

			inc edi
			mov eax, [WorldWidth]
			cmp eax, edi			; ==? WorldWidth
			jne .inner_loop
			
		print newline, 1
		
		inc esi
		mov edi, [WorldLength]
		cmp esi, edi
		jne .loop
	print ender, 5
				print newline, 1
	
        xor ebx, ebx
        call resume             ; resume scheduler

        jmp printer