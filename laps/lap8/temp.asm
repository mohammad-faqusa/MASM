.model small
.stack 100h

.data
    x     DB 53        ; numeric value 5
    y     DB 54        ; numeric value 3
    sum   DB 0        ; to store result of x + y
    msg1  DB 'Moved value: $'
    msg2  DB 13,10,'Sum result: $'  ; new line before sum

.code

; MoveByte macro: move byte from src to dest via AL
MoveByte MACRO src, dest
    mov al, src
    mov dest, al
ENDM

; ADDM macro: add two bytes from memory and store result in dest
ADDM MACRO src1, src2, dest
    mov al, src1
    add al, src2
    mov dest, al
ENDM

main:
    mov ax, @data
    mov ds, ax

    ; Move value from x to y
    MoveByte x, y

    ; Display "Moved value: "
    lea dx, msg1
    mov ah, 09h
    int 21h

    ; Display the moved value (y), convert to ASCII by adding 30h
    mov al, y
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h

    ; New line + "Sum result: "
    lea dx, msg2
    mov ah, 09h
    int 21h

    ; Add x and y, store in sum
    ADDM x, y, sum

    ; Display the result, convert to ASCII
    mov al, sum
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h

    ; Exit
    mov ah, 4Ch
    int 21h

end main
