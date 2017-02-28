; Wyœwietla string pod adresem AX
; ARG: ax = offset stringa zakoñczonego znakiem '$'
; RET: ---
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