.MODEL SMALL
.STACK 100H
.DATA
    str DB "HELLO WORLD!!!$"
    array1 DB 1,2,3,4    ; Example values
    array2 DB 1,2,3,5    ; Different last value
    str1 DB "EQUAL$"
    str2 DB "NOT EQUAL$"
    LEN EQU 4           ; Length of arrays

.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX

    ; Compare arrays
    MOV SI, 0         ; Index for arrays
    MOV CX, LEN       ; Loop counter

COMPARE_LOOP:
    MOV AL, array1[SI]
    CMP AL, array2[SI] ; Compare each byte
    JNE NOT_EQUAL      ; If not equal, jump

    INC SI
    LOOP COMPARE_LOOP  ; Continue loop

    ; If we reach here, arrays are equal
    LEA DX, str1       ; Load "EQUAL"
    JMP PRINT_STRING   ; Jump to printing

NOT_EQUAL:
    LEA DX, str2       ; Load "NOT EQUAL"

PRINT_STRING:
    MOV AH, 09H        ; DOS print string function
    INT 21H            ; Print message

    ; Terminate program
    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN
