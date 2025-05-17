; ====  SEGMENT + STACK =================================================
.MODEL SMALL                        ; Use the SMALL memory model (≤64 KB code, ≤64 KB data)
.STACK 100H                         ; Reserve 256-byte stack (0x100)

; ====  DATA SEGMENT ====================================================
.DATA
    ; ---------- Input / output buffers ----------
    inputBuffer_array      DB 100  DUP('$')    ; Line-input buffer (100 chars, '$'-terminated)
    numberStrBuffer_array  DB 6    DUP('$')    ; Temp buffer to hold a 5-digit number + '$'

    ; ---------- Constant strings ---------------
    newline         DB 13, 10, '$'             ; CR LF sequence for DOS
    arraySizePrompt DB 'Enter array size: $'   ; Prompt for size
    elementsPrompt  DB 'Enter array elements (space-separated): $' ; Prompt for elements
    displayMsg_array DB 'Array contents: $'    ; Label shown before printing array
    evenMsg         DB 'Number of even: $'     ; Even-count prefix
    oddMsg          DB 'Number of odd: $'      ; Odd-count prefix

    ; ---------- Variables -----------------------
    ParsedValue_array DW 0                     ; Holds latest parsed number
    ArraySize        DW 0                      ; Actual size entered by user
    NumbersArray     DW 100 DUP(0)             ; Storage for up to 100 words

; ====  CODE SEGMENT ====================================================
.CODE

; ------------------------------------------------
; SortinArraySelection  – wrapper that performs
;   size input → fill → sort → print → count
; ------------------------------------------------
SortinArraySelection PROC
    CALL InitializeArray        ; Ask for array size
    CALL FillArrayFromLine      ; Read space-separated numbers
    CALL BubbleSortArray        ; Sort ascending by bubble sort
    CALL PrintArray             ; Show sorted values
    CALL CountEvenOdd           ; Display even/odd statistics
SortinArraySelection ENDP


; ====================  MAIN  ====================
MAIN PROC
    MOV AX, @DATA               ; Load address of data segment
    MOV DS, AX                  ; Set DS

    CALL InitializeArray        ; Prompt & read size
    CALL FillArrayFromLine      ; Read elements
    CALL BubbleSortArray        ; Sort them
    CALL CountEvenOdd           ; Show even/odd totals
    CALL PrintArray             ; Show final array

    MOV AH, 4Ch                 ; DOS terminate-process
    INT 21h                     ;  …with AL = 00 (implicit)
MAIN ENDP


; ==================== UTILITY ROUTINES ====================

; ---- ShowMessage_array  ----
ShowMessage_array PROC
    MOV AH, 09h                 ; DOS: display '$'-terminated string
    INT 21h                     ; Print string whose offset is in DX
    RET
ShowMessage_array ENDP

; ---- PrintNewLine_array ----
PrintNewLine_array PROC
    LEA DX, newline             ; Point DX at CR/LF buffer
    CALL ShowMessage_array      ; Print it
    RET
PrintNewLine_array ENDP


; ---- ReadLine  (raw keyboard line, buffered, no echo control) ----
ReadLine PROC
    PUSH AX                     ; Save used regs
    PUSH BX
    MOV  BX, 0                  ; BX = char index (counter)

ReadNextChar:
    MOV AH, 08h                 ; DOS: read char w/o echo
    INT 21h

    CMP AL, 13                  ; Enter pressed?
    JE  DoneReading             ; → finish

    CMP AL, 8                   ; Backspace pressed?
    JE  HandleBackspace         ; → handle erase

    MOV [DI+BX], AL             ; Store typed char
    INC BX                      ; Advance index

    MOV DL, AL                  ; Echo typed char
    MOV AH, 02h
    INT 21h
    JMP ReadNextChar

HandleBackspace:
    CMP BX, 0                   ; Anything to erase?
    JZ  ReadNextChar            ; No, ignore

    DEC BX                      ; Back up index
    MOV DL, 8                   ; Echo BS
    MOV AH, 02h
    INT 21h
    MOV DL, ' '                 ; Overwrite with space
    INT 21h
    MOV DL, 8                   ; Move cursor back again
    INT 21h
    JMP ReadNextChar

DoneReading:
    MOV BYTE PTR [DI+BX], '$'   ; Terminate buffer with '$'
    POP BX                      ; Restore regs
    POP AX
    RET
ReadLine ENDP


; ---- StringToNumber_array  (ASCII → AX) ----
StringToNumber_array PROC
    PUSH BX CX DX SI            ; Preserve regs
    XOR AX, AX                  ; AX = 0 (accumulator)
    MOV BX, 10                  ; Base-10 multiplier

ConvertLoop:
    MOV CL, [SI]                ; Fetch next char
    CMP CL, '$'                 ; End of string?
    JE  ConversionDone
    CMP CL, '0'                 ; Non-digit below '0'?
    JB  ConversionDone
    CMP CL, '9'                 ; Non-digit above '9'?
    JA  ConversionDone

    SUB CL, '0'                 ; Convert ASCII digit → binary
    XOR CH, CH                  ; CX = digit
    MUL BX                      ; AX = AX * 10   (DX unused)
    ADD AX, CX                  ; AX += digit
    INC SI                      ; Advance pointer
    JMP ConvertLoop

ConversionDone:
    POP SI DX CX BX             ; Restore regs
    RET
StringToNumber_array ENDP


; ---- NumberToString_array  (AX → ASCII in numberStrBuffer_array) ----
NumberToString_array PROC
    PUSH AX BX CX DX DI         ; Save regs
    LEA  DI, numberStrBuffer_array ; Output pointer
    MOV  BX, 10                 ; Divisor
    XOR  CX, CX                 ; Digit count

    CMP AX, 0
    JNE ConvertDigits
    MOV BYTE PTR [DI], '0'      ; Special-case zero
    INC DI
    JMP TerminateString

ConvertDigits:
    XOR DX, DX                  ; Clear high word
    DIV BX                      ; AX ← quotient, DL ← remainder
    ADD DL, '0'                 ; Convert remainder to ASCII
    PUSH DX                     ; Stack digits (reverse order)
    INC CX                      ; Count digits
    TEST AX, AX                 ; More digits?
    JNZ ConvertDigits

StoreDigits:
    POP DX                      ; Pop digits back (correct order)
    MOV [DI], DL
    INC DI
    LOOP StoreDigits            ; CX auto-dec, stop at 0

TerminateString:
    MOV BYTE PTR [DI], '$'      ; Add string terminator
    POP DI DX CX BX AX          ; Restore regs
    RET
NumberToString_array ENDP


; ---- InitializeArray  (prompt & read size) ----
InitializeArray PROC
    LEA DX, arraySizePrompt     ; Prompt text
    CALL ShowMessage_array
    LEA DI, inputBuffer_array   ; Buffer pointer
    CALL ReadLine               ; Get line
    LEA SI, inputBuffer_array   ; Convert to number
    CALL StringToNumber_array
    MOV ArraySize, AX           ; Save size
    CALL PrintNewLine_array     ; Newline after size
    RET
InitializeArray ENDP


; ---- ReadNumber_array  (robust single-number parser) ----
ReadNumber_array PROC
    PUSH BX CX DX               ; Save regs
    XOR AX, AX                  ; AX = 0 (result)
    XOR CX, CX                  ; CX = 0 (digit count)
    MOV BX, 10                  ; Multiplier

SkipSpace:
    MOV DL, [SI]                ; Skip leading spaces
    CMP DL, ' '
    JNE CheckDigit
    INC SI
    JMP SkipSpace

CheckDigit:
    MOV DL, [SI]
    CMP DL, '0'                 ; Below '0' → not a digit
    JB  NoNumber
    CMP DL, '9'                 ; Above '9' → not a digit
    JA  NoNumber

; ---- DigitLoop: accumulate value -----------------
DigitLoop:
    MOV DL, [SI]                ; Current char
    CMP DL, '0'
    JB  NumberDone              ; Non-digit terminates number
    CMP DL, '9'
    JA  NumberDone

    ; Multiply AX by 10   (safe 16-bit method)
    PUSH DX                     ; Save digit
    MOV DX, AX
    SHL AX, 1                   ; *2
    JC  Overflow
    SHL DX, 1                   ; *2 again → 4
    JC  Overflow
    SHL DX, 1                   ; → 8
    JC  Overflow
    SHL DX, 1                   ; → 16 (but we’ll add 8+2 = 10)
    JC  Overflow
    ADD AX, DX                  ; AX = old*10
    JC  Overflow

    POP DX                      ; Restore digit char
    SUB DL, '0'                 ; DL = numeric digit
    ADD AX, DX                  ; AX = AX + digit
    JC  Overflow

    INC SI                      ; Next input char
    INC CX                      ; Count digits
    JMP DigitLoop

NumberDone:
    CMP CX, 0                   ; Any digit found?
    JZ  NoNumber
    CLC                         ; Clear carry: success
    JMP ReadNumber_arrayEnd

NoNumber:
    XOR AX, AX                  ; AX = 0
    STC                         ; Set carry: failure
    JMP ReadNumber_arrayEnd

Overflow:
    POP DX                      ; Clean stack if pushed
    MOV AX, 0FFFFh              ; Saturate to max
    CLC                         ; Treat as success

ReadNumber_arrayEnd:
    POP DX CX BX                ; Restore regs
    RET
ReadNumber_array ENDP


; ---- FillArrayFromLine  (read elements into NumbersArray) ----
FillArrayFromLine PROC
    PUSH AX CX SI DI            ; Save regs
    LEA DX, elementsPrompt
    CALL ShowMessage_array
    LEA DI, inputBuffer_array
    CALL ReadLine               ; Whole line → buffer
    CALL PrintNewLine_array

    LEA SI, inputBuffer_array   ; SI = input ptr
    LEA DI, NumbersArray        ; DI = array ptr
    MOV CX, ArraySize           ; CX = elements to read

ReadElements:
    JCXZ FillDone               ; Finished all required elements
    CALL ReadNumber_array       ; Parse number
    JC  NoMoreNumbers           ; Carry=1 → no number found

    MOV [DI], AX                ; Store element
    ADD DI, 2                   ; Next array slot
    DEC CX                      ; One less to read
    CMP CX, 0
    JZ  FillDone

    CMP BYTE PTR [SI], '$'      ; End of line?
    JE  FillDone

SkipToNext:
    MOV AL, [SI]                ; Skip to next space
    CMP AL, '$'
    JE  FillDone
    CMP AL, ' '
    JE  FoundSpace
    INC SI
    JMP SkipToNext

FoundSpace:
    INC SI                      ; Skip that space
    JMP ReadElements

NoMoreNumbers:
    MOV WORD PTR [DI], 0        ; Pad with zeros
    ADD DI, 2
    LOOP NoMoreNumbers          ; CX auto-dec

FillDone:
    POP DI SI CX AX             ; Restore
    RET
FillArrayFromLine ENDP


; ---- PrintArray  (show NumbersArray on screen) ----
PrintArray PROC
    PUSH AX CX DX SI            ; Save regs
    LEA DX, displayMsg_array
    CALL ShowMessage_array

    LEA SI, NumbersArray
    MOV CX, ArraySize

PrintLoop:
    JCXZ PrintDone              ; Done?
    MOV AX, [SI]                ; Load element
    ADD SI, 2
    CALL NumberToString_array   ; AX → string in buffer
    LEA DX, numberStrBuffer_array
    CALL ShowMessage_array

    DEC CX                      ; Any more?
    JZ  PrintDone

    MOV DL, ' '                 ; Print space
    MOV AH, 02h
    INT 21h
    JMP PrintLoop

PrintDone:
    CALL PrintNewLine_array
    POP SI DX CX AX
    RET
PrintArray ENDP


; ---- BubbleSortArray  (optimized bubble sort) ----
BubbleSortArray PROC
    PUSH AX BX CX DX SI DI      ; Save regs
    MOV  CX, ArraySize
    DEC  CX                     ; Passes = n-1
    JLE  SortDone               ; 0 or 1 element → done

OuterLoop:
    MOV BX, 0                   ; BX = swap flag (0 = none yet)
    LEA SI, NumbersArray        ; SI = array start
    MOV DX, CX                  ; DX = inner loop count

InnerLoop:
    MOV AX, [SI]                ; Current element
    CMP AX, [SI+2]              ; Compare to next
    JLE NoSwap                  ; Already in order?

    XCHG AX, [SI+2]             ; Swap AX ↔ next
    MOV  [SI], AX               ; Store swapped value
    MOV  BX, 1                  ; Note a swap occurred

NoSwap:
    ADD SI, 2                   ; Move to next pair
    DEC DX                      ; Decrement inner counter
    JNZ InnerLoop               ; Continue inner pass

    TEST BX, BX                 ; Any swaps this pass?
    JZ   SortDone               ; None → array sorted
    LOOP OuterLoop              ; Else do another pass

SortDone:
    POP DI SI DX CX BX AX       ; Restore
    RET
BubbleSortArray ENDP


; ---- CountEvenOdd  (totals & prints even / odd) ----
CountEvenOdd PROC
    PUSH SI DX CX BX AX         ; Save regs
    XOR BX, BX                  ; BX = even counter
    XOR CX, CX                  ; CX = odd  counter

    LEA SI, NumbersArray
    MOV DX, ArraySize
    OR  DX, DX
    JZ  CEO_Print               ; No elements → skip loop

CEO_Loop:
    MOV AX, [SI]                ; Current value
    TEST AX, 1                  ; Check LSB
    JZ  CEO_Even
    INC CX                      ; Odd++
    JMP CEO_Next
CEO_Even:
    INC BX                      ; Even++
CEO_Next:
    ADD SI, 2
    DEC DX
    JNZ CEO_Loop

CEO_Print:
    ; ---- print even ----
    LEA DX, evenMsg
    CALL ShowMessage_array
    MOV AX, BX
    CALL NumberToString_array
    LEA DX, numberStrBuffer_array
    CALL ShowMessage_array
    CALL PrintNewLine_array

    ; ---- print odd  ----
    LEA DX, oddMsg
    CALL ShowMessage_array
    MOV AX, CX
    CALL NumberToString_array
    LEA DX, numberStrBuffer_array
    CALL ShowMessage_array
    CALL PrintNewLine_array

    POP AX BX CX DX SI          ; Restore
    RET
CountEvenOdd ENDP

; ---- end of source ----
END MAIN                         ; Assemble & link entry point
