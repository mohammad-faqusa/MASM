.model small
.stack 100h

.data
    ; No data is needed, we will just print characters directly

.code
main:
    ; Initialize data segment
    mov ax, @data
    mov ds, ax

    
    mov al, 'A'       
print_loop:
    mov dl, al        
    mov ah, 02h        
    int 21h           

    inc al            
    cmp al, 'Z' + 1   
    jle print_loop

    mov al, 'a'        
print_loop2:
    mov dl, al         
    mov ah, 02h       
    int 21h           

    inc al             
    cmp al, 'z' + 1   
    jle print_loop2     

    ; Exit the program
    mov ah, 4Ch       
    int 21h

end main
