; Program Header Goes Here
; Author: Brian Gong
; Section: 1002
; Date Last Modified: WRITE DATE HERE
; Program Description: This program will practice using macros in x86 assembly.

; Macro 1 - Swap two values
; Macro 2 - Remove leading spaces
; Macro 3 - KMB number string to integer

;	Counts the number of characters in the null terminated string
;	Returns the count in rdx
%macro countStringLength 1
	mov rdx, 1
	mov rbx, %1
	%%countStringLengthLoop:
		mov ch, byte[rbx]
		cmp ch, NULL
		je %%countStringLengthDone
		
		inc rdx
		inc rbx
	jmp %%countStringLengthLoop
	%%countStringLengthDone:
%endmacro

section .data
; Do not modify these declarations
SYSTEM_WRITE equ 1
SYSTEM_EXIT equ 60
SUCCESS equ 0
STANDARD_OUT equ 1
LINEFEED equ 10
NULL equ 0

macro1Label db "Macro 1: "
oldValue db "Fails", LINEFEED, NULL
newValue db "Works", LINEFEED, NULL

macro2Label db "Macro 2: "
macro2message db "         <- If you see a space, you must replace.", LINEFEED, NULL

macro3Label1 db "Macro 3-1: "
macro3Label2 db "Macro 3-2: "
macro3Label3 db "Macro 3-3: "
macro3Number1 db "1.62k", NULL
macro3Number2 db "   -14.213M", NULL
macro3Number3 db "  491B", NULL
macro3Integer1 dq 0
macro3Integer2 dq 0
macro3Integer3 dq 0
macro3Expected1 dq 1620
macro3Expected2 dq -14213000
macro3Expected3 dq 491000000000
macro3Success db "Pass", LINEFEED, NULL
macro3Fail db "Fail", LINEFEED, NULL

section .bss
oldAddress resq 1
newAddress resq 1

section .text
global _start
_start:

	mov rax, oldValue
	mov qword[oldAddress], rax
	mov rax, newValue
	mov qword[newAddress], rax

; Macro 1
; Invoke macro 1 using qword[oldAddress] and qword[newAddress] as the arguments

	; YOUR CODE HERE

%macro swapValues 2
	; parameters, %1 = oldAddress, %2 = newAddress 
	push %1 ; push oldAddress into stack
	push %2 ; push newAddress into stack
	pop %1 ; pop top value of stack into argument 1 (top value was newAddress)
	pop %2 ; pop next top value into argument 2 (only value left was oldAddress)
%endmacro

swapValues qword[oldAddress], qword[newAddress] ; macro invoking

; Macro 1 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro1Label
	mov rdx, 9
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, qword[oldAddress]
	mov rdx, 6
	syscall
		
; Macro 2
; Invoke macro 2 using macro2message as the argument
; strings are byte arrays

	; YOUR CODE HERE
 %macro removeLeadingSpaces 1
    mov rax, 0 ; store current character
    mov rcx, 0 ; space count
    mov rsi, 0 ; index

	; Count 10 Leading Spaces
    %%spacesCount: 
        mov al, byte[%1 + rsi]  
        cmp al, 32 ; compare (amount of spaces == 32)
        jne %%pushLoop ; if not equal, jump to push loop
        inc rcx
        inc rsi
        jmp %%spacesCount ; repeat loop

	; After spaces, push characters to the stack until you find "null"
    %%pushLoop:
        mov al, byte[%1 + rsi]
        cmp al, NULL ; have we reached null?
        je %%pushDone ; if we reach null we're done pushing
        push rax
        inc rsi
        jmp %%pushLoop ; repeat loop

    %%pushDone:
        push rax   
        sub rsi, rcx     ; mov byte[rbx-rdx-1]

    %%popLoop:
        pop rax
        mov byte[%1 + rsi], al
        dec rsi
        cmp rsi, 0
        jne %%popLoop ; jump if not equal - rsi ^ 0

    %%lastPop: 
        pop rax
        mov byte[%1 + rsi], al ; mov byte[rbx-rdx-1], ch 
%endmacro

removeLeadingSpaces macro2message ; invoke macro

; Macro 2 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Label
	mov rdx, 9
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2message
	countStringLength macro2message
	syscall
	
; Macro 3 - Test 1
; Invoke macro 3 using macro3Integer1 and macro3Number1 as the arguments

	; YOUR CODE HERE

	KMB_string macro3Integer1, macro3Number1 ; invoke

%macro KMB_string 2 
	mov rax, 0 ; sum
    mov rbx, 0 
    mov rsi, 0 ; index
    mov rcx, 0      
    mov r8, 10 ; pre - set the register
    mov r9, 0 ; bool act as sign
    %%beforeMinus:
        mov cl, byte[%2+rsi]   ; grab a byte of cl from 64-bit rax
        cmp cl, 32    
        jne %%duringMinus
        inc rsi
        jmp %%beforeMinus
    %%duringMinus:
        cmp cl, 45 ; '-'
        jne %%preLoop
        mov r9, 1
        inc rsi
    %%preLoop:
        mov cl, byte[%2+rsi]
        cmp cl, 46    ; .
        je %%decimalPoint
        cmp cl, 107 ; k
        je %%kLoop
        cmp cl, 77  ; M
        je %%mLoop
        cmp cl, 66  ; B
        je %%bLoop
        sub cl, '0' ; digit = ch - 48 / basically changing from char to int!
        mul r8
        add rax, rcx
        inc rsi
        jmp %%preLoop
    %%decimalPoint:
        inc rsi          
    %%postLoop:
        mov cl, byte[%2 + rsi]
        cmp cl, 107   ; k
        je %%kLoop
        cmp cl, 77    ; M
        je %%mLoop
        cmp cl, 66    ; B
        je %%bLoop
        sub cl, '0'
        mul r8
        add rax, rcx
        inc rsi
        inc rbx ; pointer counter 
        jmp %%postLoop
    %%kLoop:
        mov rcx, 3           
        sub rcx, rbx
        jmp %%powLoop
    %%mLoop:
        mov rcx, 6          
        sub rcx, rbx
        jmp %%powLoop
    %%bLoop:
        mov rcx, 9             
        sub rcx, rbx          
        jmp %%powLoop          
    %%powLoop:
        cmp rcx, 0  ; find NULL
        je %%powDone  
        imul r8 ; in case is signed..
        dec rcx
        jmp %%powLoop
    %%powDone:
        cmp r9, 0          
        je %%output              
        neg rax                    
    %%output: 
        mov qword[%1], rax ; END 
%endmacro

; Macro 3 - Test 1 Results - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label1
	mov rdx, 11
	syscall
	
	mov rax, qword[macro3Expected1]
	cmp rax, qword[macro3Integer1]
	je macroTest3_1_success
		mov rsi, macro3Fail
		jmp macroTest3_1_print
	macroTest3_1_success:
		mov rsi, macro3Success
	macroTest3_1_print:
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 6
	syscall
	
; Macro 3 - Test 2
; Invoke macro 3 using macro3Integer2 and  macro3Number2 as the arguments

	; YOUR CODE HERE

; Macro 3 - Test 2 Results - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label2
	mov rdx, 11
	syscall
	
	mov rax, qword[macro3Expected2]
	cmp rax, qword[macro3Integer2]
	je macroTest3_2_success
		mov rsi, macro3Fail
		jmp macroTest3_2_print
	macroTest3_2_success:
		mov rsi, macro3Success
	macroTest3_2_print:
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 6
	syscall	
	
; Macro 3 - Test 3
; Invoke macro 3 using macro3Integer3 and macro3Number3 as the arguments

	; YOUR CODE HERE

; Macro 3 - Test 3 Results - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label3
	mov rdx, 11
	syscall
	
	mov rax, qword[macro3Expected3]
	cmp rax, qword[macro3Integer3]
	je macroTest3_3_success
		mov rsi, macro3Fail
		jmp macroTest3_3_print
	macroTest3_3_success:
		mov rsi, macro3Success
	macroTest3_3_print:
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 6
	syscall	
	
endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall