.MODEL SMALL
.STACK 100h

.DATA

msg DB 'Enter a small letter : $'
newline DB 0DH, 0AH, '$'


.code

MAIN PROC
MOV AX,@DATA
MOV DS,AX

LEA DX,msg
MOV AH,09H
INT 21h

MOV AH,01h
INT 21h

LEA DX,newline
MOV AH,09H
INT 21h


CMP AL,'a'
JB CapitalToSmall

SUB AL,32
JMP EndConvert

CapitalToSmall:
ADD AL,32

EndConvert:

MOV DL,AL
MOV AH,02h
INT 21h




MOV AH,4CH
INT 21h


MAIN ENDP

END MAIN
