; Author: Brian Gong
; Section: 1002
; Date Last Modified: 

;---------------------------------------------------------------------------------------------------------
section .data 
;   end program values
	programEnd equ 60
	finish equ 0

;   for output prompts
    sysread equ 0
	syswrite equ 1
	std_out equ 1
	null equ 0 ; end of string
    linefeed equ 10 ; cout << endl

;   user prompts
    wrongArgNumPrompt db "Type in 4 arguments: -W, <weight>, -D, <diameter> ", linefeed, null
    invalidArgPrompt db "Invalid arguments entered please try again", linefeed, null
	promptLength equ 50 

;   floating comparison
    floatZero dq 0.0

;   balloon calculation
    PI dq 3.14159
    heliumLift dq 0.06689

;---------------------------------------------------------------------------------------------------------
section .bss
;   uninitialized floating point doubles
    diameter resd 1
    weight resd 1
    volume resd 1

;   c++ function calls
    extern atof, ceil, printBalloonsRequired

;---------------------------------------------------------------------------------------------------------
section .text 
global main
main:

;   how to move arguments into reg values?

;   check arguments
    mov rdi, rsi ; rsi has all the command line args as a string
;    mov rdi, arg1 ; name of program
;    mov rsi, arg2 ; -W
;    mov xmm0, dword [weight]
;    mov rdx, arg3 ; -D
;    mov xmm1, dword [height]
    call commandArgChecker


;   if return value isnt 1, end program
    cmp rax, 1 
    jne endProgram


;   calculate balloons needed
    movsd xmm0, r13 ; weight
    movsd xmm1, r14 ; diameter
    call calculateBalloons


;   print the results in c++ function
    mov rax, rsp
	mov rcx, 16
	mov rdx, 0
	div rcx
	sub rsp, rdx
	mov rbx, rdx
	
	mov rdi, textLabel
	mov rsi, unitLabel
	movss xmm0, dword[length]

    call printBalloonsRequired

;	reset stack
	add rsp, rbx


    endProgram:
        mov rax, programEnd
        mov rdi, finish
        syscall


;---------------------------------------------------------------------------------------------------------
; function: command line checker
; returns: integer depending on the args passed in
global commandArgChecker
commandArgChecker:
    push r12 ; a.out
    push r13 ; weight
    push r14 ; diameter


;   check to make sure "argc" = 5
    cmp edi, 5
    jne invalidArgs


;   check -W and -D
    mov r8, qword[rsi + 8]
    cmp r8, "-W"
    jne invalidArgs

    mov r9, qword[rsi + 24]
    cmp r8, "D"
    jne invalidArgs


;   check weight, then move into preserved regs
    mov rdi, qword[rsi + 16] ; weight
    call atof ; returned value gets put in xmm0

    ucomisd xmm0, qword[floatZero] ; ucomisd is compare command for floating point doubles
    jbe invalidArgs ; jump if below equal
    movsd r13, xmm0 


;   check diameter, then move into preserved regs
    mov rdi, qword[rsi + 32] ; diameter
    call atof

    ucomisd xmm0, qword[floatZero]
    jbe invalidArgs
    movsd r14, xmm0 


;   at this point all command line args are correct
    mov rax, 1 
    jmp endFunction

;   if (argc == 1) return 0	
    wrongArgNum:
        mov rax, syswrite
        mov rdi, std_out
        mov rsi, wrongArgNumPrompt
        mov rdx, promptLength

        mov rax, 0
        jmp endFunction

;   else if (arguments dont match) return -1
    invalidArgs:
        mov rax, syswrite
        mov rdi, std_out
        mov rsi, invalidArgPrompt
        mov rdx, promptLength

        mov rax, -1
        jmp endFunction


    endFunction:
        pop r14
        pop r13
        pop r12
ret



;---------------------------------------------------------------------------------------------------------
; function: calculate balloons to lift weight
; returns: number of balloons
global calculateBalloons
calculateBalloons:
;   push xmm2 as it will hold the answer
    sub rsp, 8
    movss dword [rsp, xmm2]

;   find balloon volume:

;   4/3 (stored in r10)
    mov r10, 4 
    idiv 3

;   diameter/2 (stored in xmm0)
    mov rbp, 2
    divsd xmm0, 2

;   cube root it (stored in xmm0)
    mov r11, xmm0 
;    imul r11
    mulsd xmm0, r11 ; ^2
    mulsd xmm0, r11 ; ^3

;   4/3 * pi (stored in xmm2)
    mov xmm2, qword [PI]
    mulsd xmm2, r10

;   multiply the other half to find the volume (stored in xmm2)
    mulsd xmm2, xmm0


;   find balloons required:

;   volume * helium lift (stored in xmm2)
    mov xmm3, qword [heliumLift]
    mulsd xmm2, xmm3

;   weight/(volume * helium lift) (stored in xmm2)
    divsd xmm2, xmm1

;   return final answer - stored in xmm0
    mov xmm0, xmm2

;   pop the reg
    movsd xmm0, qword [rsp]
    add rsp, 8

ret



;---------------------------------------------------------------------------------------------------------
global checkArgs ; unused
checkArgs:
    readArgs:
        ; get each argument one by one
        mov bl, byte[rdi] 
        cmp bl, linefeed
        je checkArgs

        cmp bl, " "
        je storeArg


        inc rcx

        jmp readArgs


    storeArg:
        mov arg1, byte[rdi + rcx]


ret