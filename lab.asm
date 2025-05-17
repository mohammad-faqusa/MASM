.MODEL SMALL
.STACK 100h

.DATA
msg1    DB 'Enter the first number: $'
msg2    DB 'Enter the second number: $'
newline DB 13, 10, '$'
ten     DB 10

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Prompt for first number
    LEA DX, msg1
    MOV AH, 09h
    INT 21h

    MOV AH, 01h       ; Read first digit
    INT 21h
    SUB AL, '0'       ; Convert to number
    MOV BL, AL        ; Store in BL

    ; Newline
    LEA DX, newline
    MOV AH, 09h
    INT 21h

    ; Prompt for second number
    LEA DX, msg2
    MOV AH, 09h
    INT 21h

    MOV AH, 01h       ; Read second digit
    INT 21h
    SUB AL, '0'       ; Convert to number
    ADD AL, BL        ; Add both digits
    MOV AH, 0         ; Clear AH → AX = AL

    ; Divide AX by 10
    DIV ten           ; AL = quotient (tens), AH = remainder (ones)
    MOV BL,AH 
    ; Print tens digit
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; Print ones digit
    MOV AL, BL
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; Exit
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

END MAIN
