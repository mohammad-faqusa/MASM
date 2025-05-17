.model small
.stack 100h

.data
    ; Menu system
    menu_msg db 0Dh,0Ah,'1. Array Sorting/Even Odd Count',0Dh,0Ah
             db '2. Title Case',0Dh,0Ah
             db '3. Power Two',0Dh,0Ah
             db '4. Exit',0Dh,0Ah
             db 'Enter your choice: $'
    invalid_choice_msg db 0Dh,0Ah,'Invalid choice! Press any key...$'

    ; Array operations
    twoDigitPrompt      DB "Enter a 2-digit number (e.g., 42), then press ENTER:$"
    msgNewLine     DB 0Dh, 0Ah, "$"
    msgSizeArray  DB "Enter number of elements (1-20):$"
    masResultArray      DB "You entered:$"
    msgEvenMsg DB "Even numbers count: $"
    msgOddMsg  DB "Odd numbers count: $"

    ; Title case operations
    msgTitle db 0Dh,0Ah,'Enter a text:',0Dh,0Ah,'$'
    msgWordCount db 0Dh,0Ah,'No. of words: $'

    ; Power two operations
    msgPowerTwo db 0Dh,0Ah,'Enter a two-digit number (00-99): $'
    msgResult db 0Dh,0Ah,'Power two of the number = $'

    ; Data storage
    str db 100 dup('$')
    counter db ?
    power_num dw ?
    power_result dw ?
    EvenCount DB 0
    OddCount  DB 0
    Array          DB 20 DUP(?)       ; reserve space for 10 numbers
         
    OutBuff        DB '00', '$'
    ; Input/Output Buffers
    inputBuffer_array      DB 100 DUP('$')   ; General purpose input buffer
    numberStrBuffer_array  DB 6 DUP('$')     ; For number-to-string conversion (5 digits + '$')
    
    ; Messages
    newline         DB 13, 10, '$'
    arraySizePrompt DB 'Enter array size: $'
    elementsPrompt  DB 'Enter array elements (space-separated): $'
    displayMsg_array      DB 'Array contents: $'
    evenMsg DB 'Number of even: $'
    oddMsg  DB 'Number of odd: $'
    
    ; Data Variables
    ParsedValue_array     DW 0               ; Stores converted numbers
    ArraySize       DW 0               ; Size of the array
    NumbersArray    DW 100 DUP(0)      ; Array to store numbers


    

.code

main proc
    mov ax, @data
    mov ds, ax

menu:
    call ClearScreen
    call DisplayMenu
    call GetChoice
    
    cmp al, '1'
    je array_sort
    cmp al, '2'
    je title_case
    cmp al, '3'
    je power_two
    cmp al, '4'
    je exit_program
    
    ; Invalid choice
    lea dx, invalid_choice_msg
    call DisplayString
    call WaitForKey
    jmp menu

array_sort:
    call SortinArraySelection
    call WaitForKey
    jmp menu

title_case:
    call TitleCaseConversion
    call WaitForKey
    jmp menu

power_two:
    call CalculatePowerTwo
    call WaitForKey
    jmp menu

exit_program:
    mov ax, 4C00h
    int 21h
main endp

ShowMessage_array PROC
    MOV AH, 09H
    INT 21H
    RET
ShowMessage_array ENDP

; Prints a newline
PrintNewLine_array PROC
    LEA DX, newline
    CALL ShowMessage_array
    RET
PrintNewLine_array ENDP

; Reads a line of input into buffer pointed to by DI
ReadLine PROC
    PUSH AX
    PUSH BX
    MOV BX, 0            ; Character counter
    
ReadNextChar:
    MOV AH, 08H          ; Read character without echo
    INT 21H
    
    CMP AL, 13           ; Check for Enter key
    JE DoneReading
    
    CMP AL, 8            ; Check for Backspace
    JE HandleBackspace
    
    ; Store valid character
    MOV [DI+BX], AL
    INC BX
    
    ; Echo character
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    JMP ReadNextChar
    
HandleBackspace:
    CMP BX, 0            ; Can't backspace at start
    JZ ReadNextChar
    
    DEC BX               ; Remove last character
    MOV DL, 8            ; Backspace
    MOV AH, 02H
    INT 21H
    MOV DL, ' '          ; Erase character
    INT 21H
    MOV DL, 8            ; Backspace again
    INT 21H
    
    JMP ReadNextChar
    
DoneReading:
    MOV BYTE PTR [DI+BX], '$'  ; Null-terminate string
    POP BX
    POP AX
    RET
ReadLine ENDP

; Converts string to 16-bit number in AX
StringToNumber_array PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    XOR AX, AX           ; Clear result
    MOV BX, 10           ; Base 10 multiplier
    
ConvertLoop:
    MOV CL, [SI]         ; Get next character
    CMP CL, '$'          ; Check for end of string
    JE ConversionDone
    CMP CL, '0'
    JB ConversionDone
    CMP CL, '9'
    JA ConversionDone
    
    ; Valid digit - process it
    SUB CL, '0'          ; Convert to binary
    XOR CH, CH
    
    MUL BX               ; AX = AX * 10
    ADD AX, CX           ; Add new digit
    
    INC SI               ; Next character
    JMP ConvertLoop
    
ConversionDone:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
StringToNumber_array ENDP

; Converts 16-bit number in AX to string
NumberToString_array PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    
    LEA DI, numberStrBuffer_array
    MOV BX, 10           ; Divisor
    XOR CX, CX           ; Digit counter
    
    ; Handle zero case
    CMP AX, 0
    JNE ConvertDigits
    MOV BYTE PTR [DI], '0'
    INC DI
    JMP TerminateString
    
ConvertDigits:
    XOR DX, DX
    DIV BX               ; Divide AX by 10
    ADD DL, '0'          ; Convert remainder to ASCII
    PUSH DX              ; Store digit
    INC CX               ; Count digits
    TEST AX, AX          ; Check if quotient is zero
    JNZ ConvertDigits
    
StoreDigits:
    POP DX               ; Get digits in reverse order
    MOV [DI], DL
    INC DI
    LOOP StoreDigits
    
TerminateString:
    MOV BYTE PTR [DI], '$'  ; Terminate string
    
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
NumberToString_array ENDP

; Gets array size from user
InitializeArray PROC
    LEA DX, arraySizePrompt
    CALL ShowMessage_array
    
    LEA DI, inputBuffer_array
    CALL ReadLine
    
    LEA SI, inputBuffer_array
    CALL StringToNumber_array
    MOV ArraySize, AX
    
    CALL PrintNewLine_array
    RET
InitializeArray ENDP

SortinArraySelection PROC
    
    ; Get array size from user
    CALL InitializeArray
    
    ; Get array elements from user
    CALL FillArrayFromLine

    ; Display the array contents
    CALL PrintArray

    ;Sort the array
    CALL BubbleSortArray

    ;count even and odd
    CALL CountEvenOdd      
    
    ; Display the array contents
    CALL PrintArray
SortinArraySelection ENDP

; =========================================================
; Procedure: ReadNumber_array (Fixed version)
;
; Input: 
;   SI = pointer to start of number in string
; Output:
;   AX = converted number
;   SI = points to character after the number
;   Carry Flag = set if no number found (AX=0), clear if valid number
; =========================================================
ReadNumber_array PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR AX, AX           ; Initialize result to 0
    XOR CX, CX           ; Clear CX (will store digit count)
    MOV BX, 10           ; Multiplier for decimal digits
    
SkipSpace:
    MOV DL, [SI]
    CMP DL, ' '
    JNE CheckDigit
    INC SI
    JMP SkipSpace
    
CheckDigit:
    MOV DL, [SI]
    CMP DL, '0'
    JB NoNumber
    CMP DL, '9'
    JA NoNumber
    
DigitLoop:
    MOV DL, [SI]
    CMP DL, '0'
    JB NumberDone
    CMP DL, '9'
    JA NumberDone
    
    ; Multiply current result by 10 (using 16-bit safe method)
    PUSH DX              ; Save digit
    MOV DX, AX           ; DX = current value
    SHL AX, 1            ; AX = value*2
    JC Overflow          ; Check overflow
    SHL DX, 1            ; DX = value*2
    JC Overflow
    SHL DX, 1            ; DX = value*4
    JC Overflow
    SHL DX, 1            ; DX = value*8
    JC Overflow
    ADD AX, DX           ; AX = value*10 (2+8)
    JC Overflow
    
    ; Add new digit
    POP DX               ; Restore digit
    SUB DL, '0'
    ADD AX, DX
    JC Overflow
    
    INC SI               ; Next character
    INC CX               ; Digit count
    JMP DigitLoop
    
NumberDone:
    CMP CX, 0            ; Did we get any digits?
    JZ NoNumber
    CLC                  ; Clear carry (success)
    JMP ReadNumber_arrayEnd
    
NoNumber:
    XOR AX, AX           ; Return 0
    STC                  ; Set carry (no number found)
    JMP ReadNumber_arrayEnd
    
Overflow:
    POP DX               ; Clean stack if needed
    MOV AX, 0FFFFh       ; Return maximum value
    CLC                  ; Clear carry (treat as success)
    
ReadNumber_arrayEnd:
    POP DX
    POP CX
    POP BX
    RET
ReadNumber_array ENDP
; =========================================================
; Procedure: FillArrayFromLine
;
; Fills NumbersArray with values from input string
; Uses ReadNumber_array for each element
; =========================================================
FillArrayFromLine PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI
    
    LEA DX, elementsPrompt
    CALL ShowMessage_array
    
    LEA DI, inputBuffer_array
    CALL ReadLine
    CALL PrintNewLine_array
    
    LEA SI, inputBuffer_array    ; Input pointer
    LEA DI, NumbersArray   ; Array pointer
    MOV CX, ArraySize      ; Elements to read
    
ReadElements:
    JCXZ FillDone          ; Exit if no more elements needed
    
    CALL ReadNumber_array
    JC NoMoreNumbers       ; If no number found and CF=1
    
    ; Store the number
    MOV [DI], AX
    ADD DI, 2              ; Next array position
    DEC CX                 ; Decrement count
    
    ; Check if we need to read more numbers
    CMP CX, 0
    JZ FillDone
    
    ; Check if we've reached end of input
    CMP BYTE PTR [SI], '$'
    JE FillDone
    
    ; Skip any remaining non-digit characters
SkipToNext:
    MOV AL, [SI]
    CMP AL, '$'
    JE FillDone
    CMP AL, ' '
    JE FoundSpace
    INC SI
    JMP SkipToNext
    
FoundSpace:
    INC SI                 ; Move past the space
    JMP ReadElements
    
NoMoreNumbers:
    ; Fill remaining elements with zeros if input exhausted
    MOV WORD PTR [DI], 0
    ADD DI, 2
    LOOP NoMoreNumbers
    
FillDone:
    POP DI
    POP SI
    POP CX
    POP AX
    RET
FillArrayFromLine ENDP


; Prints the array contents
PrintArray PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA DX, displayMsg_array
    CALL ShowMessage_array
    
    LEA SI, NumbersArray
    MOV CX, ArraySize
    
PrintLoop:
    JCXZ PrintDone
    
    MOV AX, [SI]
    ADD SI, 2
    
    CALL NumberToString_array
    LEA DX, numberStrBuffer_array
    CALL ShowMessage_array
    
    ; Print space unless last element
    DEC CX
    JZ PrintDone
    
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    
    JMP PrintLoop
    
PrintDone:
    CALL PrintNewLine_array
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PrintArray ENDP

; =========================================================
; Procedure: BubbleSortArray
; 
; Sorts NumbersArray in ascending order using bubble sort
; Input: 
;   NumbersArray - the array to sort
;   ArraySize    - number of elements in array
; Output:
;   NumbersArray - sorted in ascending order
; =========================================================
BubbleSortArray PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    MOV CX, ArraySize
    DEC CX               ; Outer loop runs n-1 times
    JLE SortDone         ; If array size <= 1, already sorted

OuterLoop:
    MOV BX, 0            ; Flag to check if any swaps occurred
    LEA SI, NumbersArray ; Point to start of array
    MOV DX, CX           ; Inner loop counter
    
InnerLoop:
    MOV AX, [SI]         ; Load current element
    CMP AX, [SI+2]       ; Compare with next element
    JLE NoSwap           ; If in order, skip swap
    
    ; Swap elements
    XCHG AX, [SI+2]     ; Swap AX and next element
    MOV [SI], AX         ; Store swapped value
    MOV BX, 1            ; Set swap flag
    
NoSwap:
    ADD SI, 2            ; Move to next element
    DEC DX               ; Decrement inner counter
    JNZ InnerLoop        ; Continue inner loop
    
    TEST BX, BX          ; Check if any swaps occurred
    JZ SortDone          ; If no swaps, array is sorted
    LOOP OuterLoop       ; Continue outer loop
    
SortDone:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
BubbleSortArray ENDP

; =========================================================
;  Procedure: CountEvenOdd   (corrected)
; ---------------------------------------------------------
;  Prints
;     "Number of even: <n>"
;     "Number of odd:  <m>"
;  for the current NumbersArray / ArraySize.
;  Registers destroyed: AX BX CX DX SI  (all saved/restored)
; =========================================================
CountEvenOdd PROC
        PUSH    SI
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    AX

        XOR     BX,BX            ; even counter = 0
        XOR     CX,CX            ; odd  counter = 0

        LEA     SI, NumbersArray
        MOV     DX, ArraySize    ; loop counter
        OR      DX,DX
        JZ      CEO_Print        ; empty array => skip loop

; ---------- main counting loop ---------------------------
CEO_Loop:
        MOV     AX,[SI]          ; current element
        TEST    AX,1
        JZ      CEO_Even
        INC     CX               ; odd++
        JMP     CEO_Next
CEO_Even:
        INC     BX               ; even++
CEO_Next:
        ADD     SI,2
        DEC     DX
        JNZ     CEO_Loop

; ---------- print results -------------------------------
CEO_Print:
        ; ---- even total ----
        LEA     DX, evenMsg
        CALL    ShowMessage_array
        MOV     AX,BX
        CALL    NumberToString_array
        LEA     DX, numberStrBuffer_array
        CALL    ShowMessage_array
        CALL    PrintNewLine_array

        ; ---- odd total -----
        LEA     DX, oddMsg
        CALL    ShowMessage_array
        MOV     AX,CX
        CALL    NumberToString_array
        LEA     DX, numberStrBuffer_array
        CALL    ShowMessage_array
        CALL    PrintNewLine_array

        POP     AX
        POP     BX
        POP     CX
        POP     DX
        POP     SI
        RET
CountEvenOdd ENDP



; ===== UTILITY PROCEDURES =====

ClearScreen proc
    mov ax, 0600h   ; Scroll entire window
    mov bh, 07h     ; Normal attribute
    mov cx, 0000h   ; Upper-left corner
    mov dx, 184Fh   ; Lower-right corner
    int 10h
    
    ; Set cursor position to top-left
    mov ah, 02h
    mov bh, 00h
    mov dx, 0000h
    int 10h
    ret
ClearScreen endp

DisplayMenu proc
    mov ah, 09h
    lea dx, menu_msg
    int 21h
    ret
DisplayMenu endp

GetChoice proc
    mov ah, 01h
    int 21h
    ret
GetChoice endp

DisplayString proc
    mov ah, 09h
    int 21h
    ret
DisplayString endp

WaitForKey proc
    mov ah, 07h
    int 21h
    ret
WaitForKey endp

NewLine_title proc
    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h
    ret
NewLine_title endp

; ===== ARRAY SORTING PROCEDURES =====
; --------- Utility: Print Newline ---------
PrintNewLine PROC
    LEA DX, msgNewLine
    MOV AH, 09h
    INT 21h
    RET
PrintNewLine ENDP

; --------- Reusable Two-Digit Reader ---------
ReadTwoDigit PROC
    PUSH BX
    PUSH DX

    LEA DX, twoDigitPrompt
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    PUSH AX

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    PUSH AX

    MOV AH, 01h
    INT 21h

    POP BX
    POP AX
    MOV BH, 10
    MUL BH
    ADD AL, BL
    MOV [SI], AL

    POP DX
    POP BX
    RET
ReadTwoDigit ENDP

; --------- Procedure to Print One Number ---------
PrintByteAsTwoDigits PROC
    ; AL = value to print (0–99)
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AH, 0
    MOV BL, 10
    DIV BL              ; AL = tens, AH = units

    ADD AL, '0'
    MOV OutBuff, AL
    ADD AH, '0'
    MOV OutBuff+1, AH

    LEA DX, OutBuff
    MOV AH, 09h
    INT 21h
    CALL PrintNewLine

    POP DX
    POP BX
    POP AX
    RET
PrintByteAsTwoDigits ENDP

; -----------------------------------------------------
; UpdateEvenOddCount - Increments EvenCount or OddCount
; Input:
;   AL = value to check
; -----------------------------------------------------
UpdateEvenOddCount PROC
    PUSH AX

    TEST AL, 1          ; Check least significant bit
    JZ IsEven

    ; It's odd
    INC OddCount
    JMP DoneCheck

IsEven:
    INC EvenCount

DoneCheck:
    POP AX
    RET
UpdateEvenOddCount ENDP


; ------------------------------------------------------------
; FillArray - Fills a byte array with two-digit numbers
; Parameters:
;   SI → start address of the array
;   CL → number of elements to input
; Notes:
;   Uses ReadTwoDigit to read and store each number
;   Modifies: AX, CX, SI
; ------------------------------------------------------------
FillArray PROC
    PUSH CX
    PUSH SI

    ; Loop through CL elements
FillLoop:
    PUSH CX         ; save loop counter
    CALL ReadTwoDigit
    INC SI          ; move to next array element
    POP CX
    LOOP FillLoop

    POP SI
    POP CX
    RET
FillArray ENDP

; -------------------------------------------------------
; BubbleSort - Sorts an array of bytes in ascending order
; Parameters:
;   SI → address of array
;   CL → number of elements
; Notes:
;   Uses Bubble Sort (slow but simple)
;   Destroys: AX, BX, CX, DX
; -------------------------------------------------------




ReadTwoDigitNumber proc
    ; Read tens digit
    mov ah, 01h
    int 21h
    sub al, '0'
    mov bl, 10
    mul bl
    
    ; Read units digit
    mov bl, al
    mov ah, 01h
    int 21h
    sub al, '0'
    add al, bl
    ret
ReadTwoDigitNumber endp

PrintTwoDigitNumber proc
    aam             ; AH = AL/10, AL = AL%10
    add ax, 3030h   ; Convert to ASCII
    
    mov dl, ah      ; Tens digit
    mov bh, al      ; Save units digit
    mov ah, 02h
    int 21h
    
    mov dl, bh      ; Units digit
    int 21h
    ret
PrintTwoDigitNumber endp

; ===== TITLE CASE PROCEDURES (FIXED WORD COUNTING) =====

TitleCaseConversion proc
    call ClearScreen
    lea dx, msgTitle
    call DisplayString
    
    ; Read input string
    xor si, si
read_string:
    mov ah, 01h
    int 21h
    cmp al, 0Dh
    je end_read
    mov str[si], al
    inc si
    jmp read_string
end_read:
    mov str[si], '$'
    
    ; Initialize counters
    mov counter, 0
    xor si, si
    mov bl, 1       ; BL=1 means we're at start of a new word

count_words:
    mov al, str[si]
    cmp al, '$'
    je start_conversion

    cmp al, ' '
    je space_found

    ; If we're at start of word and found non-space
    cmp bl, 1
    jne not_word_start
    
    inc counter     ; Count this new word
    mov bl, 0       ; No longer at start of word
    jmp next_char

space_found:
    mov bl, 1       ; Next char will be start of new word
    jmp next_char

not_word_start:
    ; Just continue through the word
    jmp next_char

next_char:
    inc si
    jmp count_words

start_conversion:
    ; Now convert to title case
    xor si, si
    mov bl, 1       ; Reset word start flag

convert_case:
    mov al, str[si]
    cmp al, '$'
    je conversion_done

    cmp al, ' '
    je space_found2

    cmp bl, 1
    jne not_word_start2

    ; Capitalize first letter of word
    cmp al, 'a'
    jb skip_upper
    cmp al, 'z'
    ja skip_upper
    sub al, 20h
    mov str[si], al

skip_upper:
    mov bl, 0
    jmp next_char2

space_found2:
    mov bl, 1
    jmp next_char2

not_word_start2:
    ; Convert to lowercase if uppercase
    cmp al, 'A'
    jb next_char2
    cmp al, 'Z'
    ja next_char2
    add al, 20h
    mov str[si], al

next_char2:
    inc si
    jmp convert_case

conversion_done:
    ; Display results
    call NewLine_title
    lea dx, str
    call DisplayString

    call NewLine_title
    lea dx, msgWordCount
    call DisplayString
    mov al, counter
    call PrintTwoDigitNumber
    call NewLine_title

    ret
TitleCaseConversion endp

; ===== POWER TWO PROCEDURES =====

CalculatePowerTwo proc
    call ClearScreen
    lea dx, msgPowerTwo
    call DisplayString
    
    ; Get 2-digit number
    call ReadTwoDigitNumber  ; Returns in AL
    xor ah, ah              ; Clear AH (AX = 00-99)
    mov power_num, ax       ; Store number
    
    ; Calculate square (AX * AX)
    mul ax
    mov power_result, ax    ; Store result (0-9801)
    
    ; Display result
    lea dx, msgResult
    call DisplayString
    
    ; Print 4 digits with leading zeros
    mov ax, power_result
    mov cx, 1000
    call PrintDigit
    mov cx, 100
    call PrintDigit
    mov cx, 10
    call PrintDigit
    
    ; Print units digit
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    call NewLine_title
    ret
CalculatePowerTwo endp

PrintDigit proc
    xor dx, dx
    div cx          ; AX = quotient, DX = remainder
    push dx         ; Save remainder
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax          ; Restore remainder to AX
    ret
PrintDigit endp

END MAIN