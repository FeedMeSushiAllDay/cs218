; Author: WRITE YOUR NAME HERE
; Section: WRITE YOUR SECTION HERE
; Date Last Modified: WRITE DATE HERE
; Program Description: This program will serve to train students in the use of the ddd debugger program and how to assemble source files.

section .data
; System service call values
SERVICE_EXIT equ 60
SERVICE_WRITE equ 1
EXIT_SUCCESS equ 0
STANDARD_OUT equ 1
NEWLINE equ 10

programDone db "Program Done.", NEWLINE 
stringLength dq 14

byteVariable1 db 51
byteVariable2 db 5
byteVariable3 db 0
wordVariable1 dw 7q	;octal value
wordVariable2 dw 0x0042 ;hex value
wordVariable3 dw 0
wordVariable4 dw 0
doubleVariable1 dd 99
doubleVariable2 dd 100
doubleVariable3 dd 0
doubleVariable4 dd 0
quadwordVariable1 dq 0x000000013f2c7924
quadwordVariable2 dq 0

section .text
global _start
_start:

; byteVariable1 + byteVariable2 = byteVariable3
	mov al, byte[byteVariable1]
	add al, byte[byteVariable2]
	mov byte[byteVariable3], al

; wordVariable1 + worldVariable2 = wordVariable3
	mov ax, word[wordVariable1]
	add ax, word[wordVariable2]
	mov word[wordVariable3], ax
	
; doubleVariable1 - doubleVariable2 = doubleVariable3
	mov eax, dword[doubleVariable1]
	sub eax, dword[doubleVariable2]
	mov dword[doubleVariable3], eax
	
; byteVariable1 * byteVariable2 = wordVariable4
	mov al, byte[byteVariable1]
	mul byte[byteVariable2]
	mov word[wordVariable4], ax

; wordVariable3 * wordVariable1 = doubleVariable4
	mul word[wordVariable1]
	mov word[doubleVariable4], ax
	mov word[doubleVariable4+2], dx

; ----------------------------------------------------
; ----------Set a break point------------------
; ----------------------------------------------------
	mov rax, 0 ; <-- Break Point Here

; quadwordVariable1 / doubleVariable2 = doubleVariable3
	mov eax, dword[quadwordVariable1]
	mov edx, dword[quadwordVariable1+4]
	idiv dword[doubleVariable2]
	mov dword[doubleVariable3], eax

; Outputs "Program Done." to the console
	mov rax, SERVICE_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, programDone
	mov rdx, qword[stringLength]
	syscall

; Ends program with success return value
last:
	mov rax, SERVICE_EXIT
	mov rdi, EXIT_SUCCESS
	syscall

