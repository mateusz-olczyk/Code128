; Print a string under address passed in AX
; [in] AX - address of the string variable. The string must end with '$' character.
PROC_printstr:
push ax
push dx
push ds
    mov dx, seg SEG_data
    mov ds, dx
    mov dx, ax
    mov ah, 9h
    int 21h
pop ds
pop dx
pop ax
ret
