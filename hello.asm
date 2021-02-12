section .data
;	System Service Calls
	SYSTEM_EXIT equ 60
	SYSTEM_WRITE equ 1
	STANDARD_OUT equ 1
	SUCCESS equ 0

	LINEFEED equ 10
	NULL equ 0
	helloString db "Hello, World!", LINEFEED, NULL
	STRING_LENGTH equ 14

section .bss

section .text

global _start
_start:
;	Output "Hello, World!"
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, helloString
	mov rdx, STRING_LENGTH
	syscall
	
;	End Program
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall