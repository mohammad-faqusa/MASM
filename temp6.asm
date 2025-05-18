.MODEL SMALL
.STACK 100H

.DATA
    ; Input/Output Buffers
    buffer      DB 100 DUP('$')   ; General purpose input buffer
    tmpBuffer DB 3 DUP('$') 
    
    ; Messages
    menu_msg db 0Dh,0Ah,'1. Array Sorting/Even Odd Count',0Dh,0Ah
             db '2. Title Case',0Dh,0Ah
             db '3. Power Two',0Dh,0Ah
             db '4. Exit',0Dh,0Ah
             db 'Enter your choice: $'
    invalid_choice_msg db 0Dh,0Ah,'Invalid choice! Press any key...$'

    newline         DB 13, 10, '$' ; an array of two elements (carriage return , new line) used to write new line
    arraySizePrompt DB 'Enter array size: $' ; msg hint user to input the array size
    elementsPrompt  DB 'Enter array elements (space-separated): $'; msg hints user to input the array elements
    msgArrayResult      DB 'Array contents: $' ; msg occur before the printed array 
    evenMsg DB 'Number of even: $' ;msg occor before displaying the number of evens 
    oddMsg  DB 'Number of odd: $';msg occor before displaying the number of odds
    msgTitle          DB 0Dh,0Ah,'Enter a sentence to convert to Title Case:',0Dh,0Ah,'$'
    msgWordCount      DB 0Dh,0Ah,'Number of words: $'
    msgConvertedTitle DB 0Dh,0Ah,'Converted Title Case:',0Dh,0Ah,'$'  

    msgSquarePrompt   DB 0Dh,0Ah,'Enter a number (0-181): $'
    msgSquareResult   DB 0Dh,0Ah,'Square: $'
    msgSquareError    DB 0Dh,0Ah,'Invalid input! Must be 0-181.$'
    
    
    ; Data Variables
    ParsedValue_array     DW 0               ; Stores converted numbers
    arraySize       DW 0               ; Size of the array
    arrayOfNumbers    DW 100 DUP(0)      ; Array to store numbers

    wordCount   DW 0              ; Counter for number of words
    squareResult      DW 0


.CODE
    

; ==================== MAIN PROGRAM ====================
MAIN PROC
    MOV AX, @DATA ; move the data section address to AX
    MOV DS, AX ; move the the stored data section address to data segment

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
    call ShowMessageDX
    call WaitForKey
    jmp menu

array_sort:
    call SortArray
    call WaitForKey
    jmp menu

title_case:
    call TitleCaseConversion
    call WaitForKey
    jmp menu

power_two:
    call CalculateSquare
    call WaitForKey
    jmp menu

exit_program:
    mov ax, 4C00h
    int 21h
MAIN ENDP

; ==================== PROCEDURES ====================

;=====================Menu Procedures ================

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

WaitForKey proc
    mov ah, 07h
    int 21h
    ret
WaitForKey endp



; ==================== Array Select ==================

SortArray PROC

    ; Get array size from user
    CALL InitializeArray ;function to initialzie the array with selected size
    
    ; Get array elements from user
    CALL FillArrayFromLine ; fill the array contents from input screen

    ;Sort the array
    CALL BubbleSortArray ; sort the array numbers using bubble sort

    ;count even and odd
    CALL CountEvenOdd  ; count the number of evens and odds of the array , and display the count on screen      
    
    ; Display the array contents
    CALL PrintArray ; function to print the content of the array 

    RET

SortArray ENDP

; Shows a message pointed to by DX
ShowMessageDX PROC 
    MOV AH, 09H ; print the bytes that it's start address determined at DX, until byte '$' 
    INT 21H 
    RET
ShowMessageDX ENDP

; Prints a newline
PrintNewLine PROC
    LEA DX, newline ;load DX with the address of newline, and it's values = 0D, 0A, '$' 
    CALL ShowMessageDX
    RET
PrintNewLine ENDP

; Reads a line of input into buffer pointed to by DI
ReadLine PROC
    PUSH AX             ;save the value of AX on stack, to avoid overwrrite 
    PUSH BX             ;save the value of BX on stack, to avoid overwrrite 
    MOV BX, 0            ; Character counter
    
ReadNextChar:
    MOV AH, 08H          ; Read character without echo, we don't want now to print the input character in screen
    INT 21H              ; 
    
    CMP AL, 13           ; Check for Enter key
    JE DoneReading       ; if the input character is 'enter' then jump to DoneReading
    
    CMP AL, 8            ; Check for Backspace
    JE HandleBackspace   ; if the character is back space, then jump to HandleBackspace to remove the previous number
    
    ; Store valid character
    MOV [DI+BX], AL     ; if the character is valid, then store at memory of address DI indexed with BX; 
    INC BX              ; increase the index BX, to check for next character
    
    ; Echo character
    MOV DL, AL ;becuase we have used 08(no echo ) input, not 01h (echo input), we need to echo the character manually after processed steps
    MOV AH, 02H
    INT 21H
    
    JMP ReadNextChar ;loop reading the characters from screen, until the pressed key is 'enter' 
    
HandleBackspace:
    CMP BX, 0            ; Can't backspace at start
    JZ ReadNextChar      ; if the input line is empty, can't get back to remove another character 
    
    DEC BX               ; Remove last character
    MOV DL, 8            ; Backspace
    MOV AH, 02H          ; print the backspace on screen, (move the cursor back)
    INT 21H
    MOV DL, ' '          ; Erase character
    INT 21H     
    MOV DL, 8            ; Backspace again, to write at returned position 
    INT 21H
    
    JMP ReadNextChar    ;ready to read next character 
    
DoneReading:
    MOV BYTE PTR [DI+BX], '$'  ; Null-terminate string '$', to determine the end position of str 
    POP BX  ;copy the saved value of BX, from stack to BX
    POP AX  ;copy the saved value of AX, from stack to AX
    RET
ReadLine ENDP


; Converts 16-bit number in AX to string
NumberToStr PROC
    PUSH AX         ;save the value of AX on stack, to avoid overwrrite 
    PUSH BX         ;save the value of BX on stack, to avoid overwrrite 
    PUSH CX         ;save the value of CX on stack, to avoid overwrrite 
    PUSH DX         ;save the value of DX on stack, to avoid overwrrite 
    PUSH DI         ;save the value of DI on stack, to avoid overwrrite 
    
    LEA DI, buffer      ;load the buffer of stored asci digital numbers recently
    MOV BX, 10           ; BX is used here as Divisor
    XOR CX, CX           ; CX is used here as Digit counter
    
    ; Handle zero case
    CMP AX, 0               ;compare AX to 0
    JNE ConvertDigits       ;if AX != 0 convert the number in AX to string
    MOV BYTE PTR [DI], '0'  ;else finish the procedure by setting '0' to buffer, 
    INC DI                      ;increament the index DI, to point after '0'
    JMP TerminateString         ;jump to TerminateString, to finish the procedure 
    
ConvertDigits:
    XOR DX, DX           ;clear the register DX
    DIV BX               ; Divide DX:AX by BX = 10
    ADD DL, '0'          ; Convert remainder to ASCII, which is stored in DX 
    PUSH DX              ; save the remainder on stack
    INC CX               ; Count digits
    TEST AX, AX          ; Check if quotient is zero
    JNZ ConvertDigits    ; loop until AX (quotient) is zero 
    
StoreDigits:
    POP DX               ; Get digits in reverse order
    MOV [DI], DL         ; move the asci digit to buffer at address location of DI 
    INC DI               ; increment the index by 1
    LOOP StoreDigits     ;loop
    
TerminateString:
    MOV BYTE PTR [DI], '$'  ; Terminate string
    
    POP DI      ;copy the saved value of DI, from stack to DI
    POP DX      ;copy the saved value of DX, from stack to DX
    POP CX      ;copy the saved value of CX, from stack to CX
    POP BX      ;copy the saved value of BX, from stack to BX
    POP AX      ;copy the saved value of AX, from stack to AX
    RET
NumberToStr ENDP

; Gets array size from user
InitializeArray PROC
    LEA DX, arraySizePrompt      ;hint the user : 'Enter array size:'
    CALL ShowMessageDX           ; print the hint message 'Enter array size:' on screen 
    
    LEA DI, buffer  ;locate the memory to store the input at buffer
    CALL ReadLine   ;write the input str line to buffer (the str input of arraySize)
    
    LEA SI, buffer      ;load the address of written buffer from input
    CALL StrToNumber    ;convert the str number in buffer to decimal number (deicmal value of arraySize)
    MOV arraySize, AX   ;store the decimal number to arraySize variable
    
    CALL PrintNewLine   ;print new line
    RET
InitializeArray ENDP


; =========================================================
; Procedure: StrToNumber (Fixed version)
;
; Input: 
;   SI = pointer to start of number in string
; Output:
;   AX = converted number
;   SI = points to character after the number
;   Carry Flag = set if no number found (AX=0), clear if valid number
; =========================================================
StrToNumber PROC
    PUSH BX             ;save the value of BX on stack, to avoid overwrrite 
    PUSH CX             ;save the value of CX on stack, to avoid overwrrite 
    PUSH DX             ;save the value of DX on stack, to avoid overwrrite 
    
    XOR AX, AX           ; Initialize result to 0
    XOR CX, CX           ; Clear CX (will store digit count)
    MOV BX, 10           ; Multiplier for decimal digits
    
SkipSpace:
    MOV DL, [SI]        ;copy the character at address of SI to register DL
    CMP DL, ' '         ; compare if character is space
    JNE CheckDigit          ;if the character is not space, then jump to chack if digit
    INC SI              ;increment the pointer SI
    JMP SkipSpace       ;avoid spaces by looping SkipSpace, until reach a digit   
    
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
    JMP StrToNumberEnd
    
NoNumber:
    XOR AX, AX           ; Return 0
    STC                  ; Set carry (no number found)
    JMP StrToNumberEnd
    
Overflow:
    POP DX               ; Clean stack if needed
    MOV AX, 0FFFFh       ; Return maximum value
    CLC                  ; Clear carry (treat as success)
    
StrToNumberEnd:
    POP DX
    POP CX
    POP BX
    RET
StrToNumber ENDP

; =========================================================
; Procedure: FillArrayFromLine
;
; Fills arrayOfNumbers with values from input string
; Uses StrToNumber for each element
; =========================================================
FillArrayFromLine PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI
    
    LEA DX, elementsPrompt
    CALL ShowMessageDX
    
    LEA DI, buffer
    CALL ReadLine
    CALL PrintNewLine
    
    LEA SI, buffer    ; Input pointer
    LEA DI, arrayOfNumbers   ; Array pointer
    MOV CX, arraySize      ; Elements to read
    
ReadElements:
    JCXZ FillDone          ; Exit if no more elements needed
    
    CALL StrToNumber ; convert the str number to decimal number, set the carray 1 if no numbers, clear the carry flag if number exist 
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
    
    LEA DX, msgArrayResult
    CALL ShowMessageDX
    
    LEA SI, arrayOfNumbers
    MOV CX, arraySize
    
PrintLoop:
    JCXZ PrintDone
    
    MOV AX, [SI]
    ADD SI, 2
    
    CALL NumberToStr
    LEA DX, buffer
    CALL ShowMessageDX
    
    ; Print space unless last element
    DEC CX
    JZ PrintDone
    
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    
    JMP PrintLoop
    
PrintDone:
    CALL PrintNewLine
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PrintArray ENDP

; =========================================================
; Procedure: BubbleSortArray
; 
; Sorts arrayOfNumbers in ascending order using bubble sort
; Input: 
;   arrayOfNumbers - the array to sort
;   arraySize    - number of elements in array
; Output:
;   arrayOfNumbers - sorted in ascending order
; =========================================================
BubbleSortArray PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    MOV CX, arraySize
    DEC CX               ; Outer loop runs n-1 times
    JLE SortDone         ; If array size <= 1, already sorted

OuterLoop:
    MOV BX, 0            ; Flag to check if any swaps occurred
    LEA SI, arrayOfNumbers ; Point to start of array
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
;  for the current arrayOfNumbers / arraySize.
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

        LEA     SI, arrayOfNumbers
        MOV     DX, arraySize    ; loop counter
        OR      DX,DX            ;to check if empty, and set the zero flag if DX is zero
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
        CALL    ShowMessageDX
        MOV     AX,BX
        CALL    NumberToStr
        LEA     DX, buffer
        CALL    ShowMessageDX
        CALL    PrintNewLine

        ; ---- odd total -----
        LEA     DX, oddMsg
        CALL    ShowMessageDX
        MOV     AX,CX
        CALL    NumberToStr
        LEA     DX, buffer
        CALL    ShowMessageDX
        CALL    PrintNewLine

        POP     AX
        POP     BX
        POP     CX
        POP     DX
        POP     SI
        RET
CountEvenOdd ENDP


;====================== Title Case ============================
TitleCaseConversion PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    CALL ClearScreen
    
    ; Display prompt
    LEA DX, msgTitle
    CALL ShowMessageDX
    
    ; Read input string using existing buffer
    LEA DI, buffer
    CALL ReadLine
    CALL PrintNewLine
    
    ; Initialize variables
    MOV wordCount, 0
    MOV SI, DI          ; SI will point to current character
    MOV BL, 1           ; BL=1 means we're at start of a new word
    
ConvertLoop:
    MOV AL, [SI]        ; Get current character
    CMP AL, '$'         ; Check for end of string
    JE ConversionDone
    
    ; Check if we're at start of a word
    CMP BL, 1
    JNE NotWordStart
    
    ; Convert to uppercase if lowercase letter
    CMP AL, 'a'
    JB NotLower
    CMP AL, 'z'
    JA NotLower
    SUB AL, 20h         ; Convert to uppercase
    MOV [SI], AL
    INC wordCount       ; Increment word count
    MOV BL, 0           ; No longer at start of word
    JMP NextChar
    
NotLower:
    ; Check if it's an uppercase letter (don't convert but count as word)
    CMP AL, 'A'
    JB NotLetter
    CMP AL, 'Z'
    JA NotLetter
    INC wordCount       ; Increment word count
    MOV BL, 0           ; No longer at start of word
    JMP NextChar
    
NotLetter:
    ; Check for space (word separator)
    CMP AL, ' '
    JNE NextChar
    MOV BL, 1           ; Next character starts new word
    JMP NextChar
    
NotWordStart:
    ; Convert to lowercase if uppercase letter (not at start of word)
    CMP AL, 'A'
    JB NotUpper
    CMP AL, 'Z'
    JA NotUpper
    ADD AL, 20h         ; Convert to lowercase
    MOV [SI], AL
    
NotUpper:
    ; Check for space (word separator)
    CMP AL, ' '
    JNE NextChar
    MOV BL, 1           ; Next character starts new word
    
NextChar:
    INC SI
    JMP ConvertLoop
    
ConversionDone:
    ; Display the converted string
    LEA DX, msgConvertedTitle
    CALL ShowMessageDX
    LEA DX, buffer
    CALL ShowMessageDX
    CALL PrintNewLine
    
    ; Display word count
    LEA DX, msgWordCount
    CALL ShowMessageDX
    MOV AX, wordCount
    CALL NumberToStr
    LEA DX, buffer
    CALL ShowMessageDX
    CALL PrintNewLine
    
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
TitleCaseConversion ENDP


; ==================== SQUARE CALCULATION PROCEDURE ====================
CalculateSquare PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    CALL ClearScreen
    
SquareInput:
    ; Display prompt using existing procedure
    LEA DX, msgSquarePrompt
    CALL ShowMessageDX
    
    ; Read input using existing ReadLine
    LEA DI, tmpBuffer
    CALL ReadLine
    
    lea DX, tmpBuffer
    ; CALL ShowMessageDX

    ; Convert input to number using existing StrToNumber
    LEA SI, tmpBuffer
    CALL StrToNumber
    JC InvalidInput      ; If conversion failed (CF=1)
    
    ; Validate range (0-181)
    CMP AX, 0
    JL InvalidInput
    CMP AX, 181
    JG InvalidInput
    
    ; Calculate square (n*n)
    MOV BX, AX           ; Store input number
    MUL BX               ; AX = AX * BX
    MOV squareResult, AX ; Store result
    
    ; Display result using existing procedures
    LEA DX, msgSquareResult
    CALL ShowMessageDX
    
    ; Display input number
    MOV AX, BX
    CALL NumberToStr
    LEA DX, buffer
    CALL ShowMessageDX
    
    ; Display " squared = "
    MOV AH, 02h
    MOV DL, ' '
    INT 21h
    MOV DL, 's'
    INT 21h
    MOV DL, 'q'
    INT 21h
    MOV DL, 'u'
    INT 21h
    MOV DL, 'a'
    INT 21h
    MOV DL, 'r'
    INT 21h
    MOV DL, 'e'
    INT 21h
    MOV DL, 'd'
    INT 21h
    MOV DL, ' '
    INT 21h
    MOV DL, '='
    INT 21h
    MOV DL, ' '
    INT 21h
    
    ; Display result
    MOV AX, squareResult
    CALL NumberToStr
    LEA DX, buffer
    CALL ShowMessageDX
    
    JMP SquareDone
    
InvalidInput:
    LEA DX, msgSquareError
    CALL ShowMessageDX
    CALL PrintNewLine
    JMP SquareInput      ; Let user try again
    
SquareDone:
    CALL PrintNewLine
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CalculateSquare ENDP


END MAIN