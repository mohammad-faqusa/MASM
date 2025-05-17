.MODEL SMALL
.STACK 100H
.DATA
    array1 DB 1, 2, 3, 4  
    array2 DB 4, 2, 3, 2 
    len EQU 4            
    sum1 DW 0
    sum2 DW 0
    msg_equal DB "SUMS ARE EQUAL$"
    msg_not_equal DB "SUMS ARE NOT EQUAL$"

.CODE
MAIN PROC

    MOV AX, @DATA
    MOV DS, AX


    XOR AX, AX   
    XOR BX, BX  
    XOR CX, CX  
    
    LEA SI, array1
    MOV CX, len
    XOR DX, DX  

SUM_ARRAY1:
    MOV DL, [SI] 
    ADD AX, DX    
    INC SI     
    LOOP SUM_ARRAY1
    MOV sum1, AX
    
    LEA SI, array2
    MOV CX, len
    XOR AX, AX  

SUM_ARRAY2:
    MOV DL, [SI] 
    ADD AX, DX  
    INC SI     
    LOOP SUM_ARRAY2
    MOV sum2, AX 

    MOV AX, sum1
    CMP AX, sum2
    JNE NOT_EQUAL 


    LEA DX, msg_equal
    MOV AH, 09H
    INT 21H
    JMP END_PROGRAM

NOT_EQUAL:

    LEA DX, msg_not_equal
    MOV AH, 09H
    INT 21H

END_PROGRAM:
    MOV AH, 4CH  
    INT 21H

MAIN ENDP
END MAIN
