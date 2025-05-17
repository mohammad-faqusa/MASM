.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Enter a number: $'
    MSG2 DB 0DH,0AH,'You entered: $'
    NUMBER DW 0

.CODE
MAIN:
    MOV AX, @DATA
    MOV DS, AX

    ; Display prompt
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    ; Initialize
    MOV CX, 0        ; CX will store the number

READ_LOOP:
    MOV AH, 01H      ; Read character
    INT 21H
    CMP AL, 0DH      ; Enter key (Carriage return)?
    JE  DISPLAY

    ; Echo the character
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    ; Convert ASCII to number
    SUB AL, '0'      ; '0' = 30H, so this gives the digit
    MOV BL, AL       ; Save digit in BL

    ; Multiply current number by 10
    MOV AX, CX
    MOV DX, 0
    MOV SI, 10
    MUL SI           ; AX = AX * 10

    ; Add new digit
    ADD AX, BX       ; AX = AX + digit
    MOV CX, AX       ; Store back in CX

    JMP READ_LOOP

DISPLAY:
    MOV NUMBER, CX   ; Store final number

    ; New line and show result
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H

    ; Convert number to string and print
    MOV AX, NUMBER
    CALL PRINT_NUM

    ; Exit
    MOV AH, 4CH
    INT 21H

;---------------------------------------------
; Subroutine: PRINT_NUM
; Prints AX as a decimal number
;---------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0        ; digit count
    MOV BX, 10

NEXT_DIGIT:
    XOR DX, DX
    DIV BX           ; AX / 10, remainder in DX
    PUSH DX          ; save remainder (digit)
    INC CX
    CMP AX, 0
    JNE NEXT_DIGIT

PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN
