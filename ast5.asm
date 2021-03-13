; Author: Brian Gong
; Section: 1002
; Date Last Modified: WRITE DATE HERE
; Program Description: This program will practice writing functions in x86 assembly.

; program questions:
; should the empty strings be in section .bss? 
; what are the bit sizes of the strings? and function call arguments?
; what do i push onto the stack when calling functions?
; is the user entering the null terminated string?

;---------------------------------------------------------------------------------------------------------
section .data 
	; end program values
	programEnd equ 60
	finish equ 0

	; for cin/cout
	sysread equ 0
	syswrite equ 1
	std_in equ 0
	std_out equ 1
	linefeed equ 10 
	null equ 0 ; end of string
	newLine db linefeed, null ; cout << endl

	; input prompts
	userPrompt db "Input your desired KMB format numbers: ", null
	strLength equ 40 ; length of ^^^
	maxInputSize db 100 ; buffer size

;---------------------------------------------------------------------------------------------------------
section .bss
; Uninitialized Data
	; null terminated string
	nullString resb 1 
	inLine resb strLength+2
	
	outputString resb 1

	; address for 64 bit value
	convertedValue resq 1 

;---------------------------------------------------------------------------------------------------------
section .text 
global _start
_start:

	; prompt user
	mov rdi, userPrompt ; arg1
	mov rsi, nullString ; arg2
	mov edx, dword[maxInputSize] ; arg3
	call promptUser

	; find string length
	mov rdi, nullString
	call getNullStrLength

	; print null termianted string
	mov edi, nullString
	call printNullStr


	; compare strings
	mov edi, nullString 
	mov esi, <arg2>???
	call compareStrings


	; convert null string to 64 bit value
	mov edi, nullString
	push convertedValue

endProgram:
; 	Ends program with success return value
	mov rax, programEnd
	mov rdi, finish
	syscall



;---------------------------------------------------------------------------------------------------------
; function 1: int promptUser(outputString, responseBuffer, maxSize)
; returns: input size
global promptUser
promptUser:
	push rbp ; base ptr
	mov rbp, rdi
	push rbx ; Preserved Registers

	mov rbx, inLine ; inLine addy
	mov rcx, 0 ; char count
	
	; prompt user (cout << userPrompt)
	mov rax, syswrite ; call code for write()
	mov rdi, std_out ; standard output
	mov rsi, userPrompt ; message address
	mov rdx, strLength ; length value of prompt string
	syscall

	; call for user response (cin >> nullString)
	readString:
		mov rax, sysread ; call code for read()
		mov rdi, std_in ; standard input
		lea rsi, byte[nullString] ; address of chr
		mov rdx, 1 ; read count
		syscall

		; get string size by getting each character, one by one
		mov al, byte[nullString] 

		; if linefeed is reached, input done
		cmp al, linefeed 
		je readDone ; je = jump when equal

		; else:
		inc rcx ; count++
		cmp rcx, maxInputSize ; if # characters ≥ max buffer size
		jae readString ; stop placing in buffer

		mov byte [rbx], al ; inLine[i] = chr
		inc rbx ; update tmpStr addy

		jmp readString

	; return answer.length()
	readDone:
		cmp rcx, maxInputSize ; if # characters ≥ max buffer size
		jae clearBuffer
		
		mov byte [rbx], null ; add null termination
		mov rax, rcx ; return input size
		jne functionDone

	; find a way to get past this function if the characters <= max buffer size
	; return -1
	clearBuffer:
		mov rcx, -1 ; clear buffer
		mov byte [rbx], null ; add null termination
		mov byte[rcx], eax ; return -1
		
	functionDone:
		pop rbx ; Restore Preserved Registers
		pop rbp ; clear stack
ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 2: int getStrLength(nullString)
; returns: null string length
global getNullStrLength
getNullStrLength:
	push rbx 
	mov rbx, rdi ; put arg1 into function reg
	mov rdx, 0 ; length counter

	strCountLoop:
		; if the end of string is reached, we're done
		cmp byte [rbx], null 
		je strCountDone

		inc rdx
		inc rbx
		jmp strCountLoop

	strCountDone:
		mov byte[rdx], eax ; return length


	pop rbx ; Restore Preserved Registers
ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 3: void printStr(nullString)
; returns: nothing
global printStr
printStr:
	push rbx
	mov rbx, rdi 
	mov rdx, 0

	mov rax, syswrite ; call code for write()
	mov rdi, std_out ; standard output
	mov rsi, rbx ; message address
	; variable with null string length?
	syscall

	pop rbx ; Restore Preserved Registers
ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 4: int compareStrings(nullString, outputString)
; returns: number by which they are equal
global compareStrings
compareStrings:
	push rbp ; base ptr
	mov rbp, rdi


	
	pop rbp ; clear stack
ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 5: int convertStr(nullString, storeValue)
; returns: 1 for successful convert, -1 if not
global convertStr
convertStr:
	push rbp ; base ptr
	mov rbp, rdi

	

	pop rbp ; clear stack
ret ; end function