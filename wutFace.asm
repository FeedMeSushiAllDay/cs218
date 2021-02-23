section .data
;	System Service Calls
	SYSTEM_EXIT equ 60
	SYSTEM_WRITE equ 1
	STANDARD_OUT equ 1
	SUCCESS equ 0

section .bss

section .text

global _start
_start:

%macro calculateAdjustment 3

; divide y by x
mov ax, %2
mov dx, %2 + 2
div %1

; add 6
add ax, 6

;  multiply by 12
mov eax, 12
movsx ebx, ax
mul ebx

; storing answer in 64 bit
mov %3, eax
mov %3 + 4, edx

%endmacro 

calculateAdjustment word[wordX], dword[dwordY], qword[answer] ; invoke


;	End Program
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall