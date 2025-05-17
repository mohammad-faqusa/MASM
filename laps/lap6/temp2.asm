.MODEL SMALL
.STACK 100H
.DATA
    msg1 DB 'Enter the first number: $'
    msg2 DB 'Enter the second number: $'
    msg3 DB 'Numbers between them are: $'
    num1 DB ?
    num2 DB ?
    newline DB 13, 10, '$'

.CODE

sum PROC 

sum ENDP
MAIN PROC
    ; Initialize data segment
    MOV AX, @DATA
    MOV DS, AX

    ; Print message to enter the first number
    LEA DX, msg1
    MOV AH, 09H
    INT 21H

    ; Read the first number
    MOV AH, 01H
    INT 21H
    SUB AL, '0' ; Convert ASCII to integer
    MOV num1, AL

    ; Print newline
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    ; Print message to enter the second number
    LEA DX, msg2
    MOV AH, 09H
    INT 21H

    ; Read the second number
    MOV AH, 01H
    INT 21H
    SUB AL, '0' ; Convert ASCII to integer
    MOV num2, AL

    ; Print newline
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    ; Print message for numbers between them
    LEA DX, msg3
    MOV AH, 09H
    INT 21H

    ; Compare num1 and num2
    MOV AL, num1
    MOV BL, num2
    CMP AL, BL
    JL  PRINT_NUMBERS ; If num1 < num2, jump to PRINT_NUMBERS
    XCHG AL, BL       ; Swap num1 and num2 if num1 > num2
    MOV num1, AL      ; Update num1 and num2 after swapping
    MOV num2, BL

PRINT_NUMBERS:
    MOV AL, num1      ; Start from num1 + 1
    INC AL            ; Increment to the next number

PRINT_LOOP:
    CMP AL, num2      ; Compare current number with num2
    JGE DONE          ; If current number >= num2, exit loop

    ; Print the current number
    MOV DL, AL
    ADD DL, '0'       ; Convert integer to ASCII
    MOV AH, 02H
    INT 21H

    ; Print a space
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    INC AL            ; Increment to the next number
    JMP PRINT_LOOP    ; Repeat the loop

DONE:
    ; Print newline
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    ; Exit program
    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN