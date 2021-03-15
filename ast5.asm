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
	userPrompt db "Input your desired KMB format numbers or type quit to be done: ", linefeed, null
	promptLength equ 40 ; length of ^^^

	validKMB db "your KMB number was successfully converted", linefeed, null
	successStrLength equ 30 

	nonValidKMB db "not a valid KMB", linefeed, null
	errorStrLength equ 15 

	quitString db "Quit", linefeed, null


	maxInputSize db 100 ; buffer size

;---------------------------------------------------------------------------------------------------------
section .bss
; Uninitialized Data
	; null terminated string
	nullString resb 1 
	inLine resb promptLength+2
	
	outputString resb 1

	; address for 64 bit value
	convertedValue resq 1 

;---------------------------------------------------------------------------------------------------------
section .text 
global _start
_start:

;promptLoop:
	; prompt user
	mov rdi, userPrompt ; arg1
	mov rsi, nullString ; arg2
	mov edx, dword[maxInputSize] ; arg3
	call promptUser

	; compare strings
	mov rdi, nullString
    mov rsi, quitString
    call compareStrings 

	; if user entered quit, end program
	cmp rax, 1
    je endProgram 

	; if user intput < 0, jump to printBadInput
	cmp rax, 0
    jl badInput

	; if user intput < min value, jump to printBadMin
	cmp rax, -999,999,999,999 
    jl badInput      

	; if user intput > max value, jump to printBadMax
    cmp rax, 999,999,999,999
    jg badInput          

	; non valid string entered, prompt the error and end program
	badInput:
		mov rdi, nonValidKMB
		call printString
		jmp endProgram

	; input passed all checks, convert to 64 bit value
	convertStrings:
		mov rdi, nullString
		mov rsi, convertedValue
		call convertString

	; output message that converting was complete
	convertDone:
		mov rdi, validKMB
		call printString

	; clear the buffer
	mov rcx, maxInputSize
    mov rsi, 0
    clearBuffer:
        mov byte[buffer + rsi], 0
        inc rsi
        loop clearBuffer

	; jmp promptLoop 

endProgram:
; 	Ends program with success return value
	mov rax, programEnd
	mov rdi, finish
	syscall


;---------------------------------------------------------------------------------------------------------
; function 1: int getStrLength(nullString)
; returns: null string length
global getLength
getLength:
	push rbx 
	mov rbx, rdi ; put arg1 into function reg
	mov rdx, 0 ; length counter

	strCountLoop:
		; if the end of string is reached, we're done
		cmp byte [rbx + rdx], null 
		je strCountDone

		inc rdx
		inc rbx
		jmp strCountLoop

	strCountDone:
		mov rax, rdx ; return length


	pop rbx ; Restore Preserved Registers
ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 2: void printStr(nullString)
; returns: nothing
global printString
printStr:
	push rbx
	mov rbx, rdi 
	mov rdx, 0

	mov rax, syswrite ; call code for write()
	mov rdi, std_out ; standard output
	mov rsi, rbx ; message address

	; find string length to print it out
	mov rdi, rbx
	call getLength
	mov rdx, rax ; rax is variable with null string length?

	syscall

	pop rbx ; Restore Preserved Registers
ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 3: int promptUser(outputString, responseBuffer, maxSize)
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
	mov rdx, promptLength ; length value of prompt string
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
		cmp rcx, maxInputSize ; compare # characters to max buffer size
		jae clearBuffer ; if greater then clear buffer and return -1
		
		mov byte [rbx], null ; add null termination
		mov rax, rcx ; return input size ; value wrong?
		jmp functionDone 

	; find a way to get past this function if the characters <= max buffer size
	; return -1
	clearBuffer:
		mov byte [rbx], null ; add null termination
		mov rax, -1 ; return -1

	functionDone:
		pop rbx ; Restore Preserved Registers
		pop rbp ; clear stack
ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 4: int compareStrings(nullString, nullString???)
; returns: number by which they are equal
global compareStrings
compareStrings:
	push rbp ; base ptr
	push r8
	push r9
	push r10
	push r11

	mov r8, rdi ; first str
	mov r9, rsi ; second str
	mov rbp, 0 ; char counter

	getStringLengths:
		mov rdi, r8
        call getLength  
        mov r10, rax ; store length of string1 in r10

        mov rdi, r9 
        call getLength  
        mov r11, rax ; Store length of string2 in r11


	; setup for string1 ascii value loop
	mov rcx, r10
    mov r12, 0 ; string1Value = 0

	firstStringValue:
        add r12b, byte[r8] ; string1Value += string1[i]
        inc r8 ; get next char
        loop compareFirstString 
	

	; setup for string2 ascii value loop
	mov rcx, r11  
    mov r13, 0 ; ; string2Value = 0

	secondStringLength:
        add r11b, byte[r13] ; string2Value += string2[i]
        inc r13 ; get next char
        loop secondStringLength


	compareStrings:
		; if string1Value != string2Value, jump to notEqual
		cmp r12, r13 
        jne notEqual 

        mov rax, 1 ; return 1 in rax if strings are equal
        jmp functionDone

    notEqual:
        mov rax, 0 ; return 0 in rax if string are not equal
		jmp functionDone

	functionDone:	
		; clear stack
		pop r11
		pop r10
		pop r9
		pop r8
		pop rbp 

ret ; end function


;---------------------------------------------------------------------------------------------------------
; function 5: int convertStr(nullString, storeValue)
; returns: 1 for successful convert, -1 if not
global convertString
convertString:

	push rbx
	push r14
	push r15

	mov rax, 0 ; rSum
    mov r14, 0 ; flag for sign
    mov r15, 0 ; pointCount

    ignoreLeadingSpaces:
        cmp byte[rdi], 0x20         ; compare string[i] with space
        jne spacesDone              ; if string[i] != space, jump to spacesDone
        inc rdi                     ; i++
        jmp ignoreLeadingSpaces     
    
	spacesDone:
        cmp byte[rdi], '-'          ; compare string[i] with '-'
        jne beforePointCheck        ; if string[i] != '-', jump to beforePointCheck
        mov r14, 1                  ; set flag for negate
        inc rdi                     ; i++
    
	beforePointCheck:
        cmp byte[rdi], '.'
        je badString                ; if string[i] == '.', jump to badString (no digit before .)
        cmp byte[rdi], '9'
        ja badString                ; if string[i] > '9', jump to badString (string starts with non digit)
    
	beforePoint:
        mov rbx, 0
        mov bl, byte[rdi]           ; bl = string[i]

        cmp bl, '.'                 
        jb badString                ; if string[i] < '.', jump to badString

        cmp bl, '.'
        je pointHit                 ; if string[i] == '.', jump to pointHit

        cmp bl, '9'
        ja kmbCheck                 ; if string[i] > '9', jump to kmbCheck
        
        sub bl, '0'                 ; convert string[i] to digit
        mul qword[num_10]           ; rSum = rSum * 10
        add rax, rbx                ; rSum = rSum + digit

        inc rdi                     ; i++
        jmp beforePoint

    pointHit:
        inc rdi                     ; Skip over '.'
        cmp byte[rdi], '0'
        jb badString                ; if string[i] < '0', jump to badString (no digit after .)
        cmp byte[rdi], '9'
        ja badString                ; if string[i] > '9', jump to badString (no digit after .)
    
	afterPoint:
        mov rbx, 0
        mov bl, byte[rdi]           ; bl = string[i]

        cmp bl, '0'
        jb badString                ; if string[i] < '0', jump to badString

        cmp bl, '9'
        ja formatCheck              ; if string[i] > '9', jump to formatCheck

        sub bl, '0'                 ; Convert string[i] to digit
        mul qword[num_10]           ; rSum = rSum * 10
        add rax, rbx                ; rSum = rSum + digit

        inc rdi                     ; i++
        inc r15                     ; pointCount++
        jmp afterPoint
    
    formatCheck:
        cmp bl, 'k'
        je kConvert
        cmp bl, 'K'
        je kConvert

        cmp bl, 'm'
        je mConvert
        cmp bl, 'M' 
        je mConvert

        cmp bl, 'b'
        je bConvert
        cmp bl, 'B'
        je bConvert
        ; if none of the kmb checks are met, falls through to badString

    badString:
        mov rax, -1           
        jmp convertDone
    
	kConvert:
        mov rcx, 3
        sub rcx, r15
        jmp powLoop
    
	mConvert:
        mov rcx, 6
        sub rcx, r15
        jmp powLoop
    
	bConvert:
        mov rcx, 9
        sub rcx, r15
		jmp powLoop
    
	powLoop:
        cmp rcx, 0
        je powDone
        mul qword[num_10] 
        loop powLoop
    
	powDone:
        cmp r14, 0              ; compare negate flag with 0
        je convertDone          ; if negate flag == 0, then go to convertDone
        neg rax                 ; negate rSum
    
	convertDone:
        mov qword[rsi], rax     ; set result to rSum, rSum return in rax regardless as well

	pop r15
	pop r14
	pop rbx

 ret ; end function