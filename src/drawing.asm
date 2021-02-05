; Finds the position of the first pixel of the barcode according to the number of bytes to be
; encoded. This calculation is needed to center the barcode horizontally and vertically. Every pixel
; till the starting position will be painted white. The final barcode will fit between 2/5 and 3/5
; of the screen height.
; [in] CL - number of bytes to be encoded
; [out] ES:[DI] - starting position
PROC_startpoint:
push cx
    mov di, 0a000h              ; set ES:[DI] to the address of the first pixel of VGA memory
    mov es, di
    mov di, 0
    
    mov al, 11
    mul cl
    add ax, 35
    shr ax, 1
    neg ax
    add ax, 25760
    mov cx, ax                  ; starting postion offset is now in CX
    
    mov al, CONST_color_white   ; paint everything before the starting position to white
    rep stosb
pop cx
ret


; Draws a single barcode element at index AX in array VAR_codetable.
; [in] AL - index of VAR_codetable
; [in] DS - expected to be SEG_data
; [in] ES:[DI] - starting position of drawing
; [out] AX - barcode corresponding to passed VAR_codetable index
; [out] DI - increased by 11 which corresponds to single barcode length in pixels
PROC_drawcode:
push bx
push cx
push dx
    shl al, 1                       ; multiply address by 2 because VAR_codetable is array of words
    mov bh, 0                       ; and a word has 2 bytes size
    mov bl, al
    add bx, offset VAR_codetable    ; set BX to address of corresponding barcode value
    mov ax, word ptr ds:[bx]        ; set AX to the value at VAR_codetable[AL]

    mov dx, ax                      ; save AX in DX before it will be detroyed
    mov cx, 11
    mov bx, 10000000000b
    PROC_drawcode_pixel:
        and ax, bx                  ; test bit and paint a pixel white or black
        jnz PROC_drawcode_black
        mov al, CONST_color_white
        jmp PROC_drawcode_continue
        PROC_drawcode_black:
        mov al, CONST_color_black
        PROC_drawcode_continue:
        stosb
        shr bx, 1                   ; test next bit
        mov ax, dx                  ; set AX to its original state
    loop PROC_drawcode_pixel
pop dx
pop cx
pop bx
ret


; Calculates checksum value
; [in] AL - index of VAR_codetable
; [in] BL - current position in barcode
; [in] DL - current value of the checksum
; [out] BL - incremented
; [out] DL - new value of the checksum
PROC_checksum:
push ax
    mul bl
    mov dh, 0
    add ax, dx
    push bx
    mov bl, 103
    div bl
    pop bx
    inc bl
    mov dl, ah
pop ax
ret


; Draws the stop character of the barcode
; [in] ES:[DI] - starting position of drawing
; [out] AX - stop character barcode
; [out] DI - increased by 13 which corresponds to stop character length in pixels
PROC_drawcodestop:
push bx
push cx
push dx
    mov ax, 1100011101011b              ; set AX to the stop code
    mov dx, ax                          ; save AX in DX before it will be detroyed
    mov cx, 13
    mov bx, 1000000000000b
    PROC_drawcodestop_pixel:
        and ax, bx                      ; test bit and paint a pixel white or black
        jnz PROC_drawcodestop_black
        mov al, CONST_color_white
        jmp PROC_drawcodestop_continue
        PROC_drawcodestop_black:
        mov al, CONST_color_black
        PROC_drawcodestop_continue:
        stosb
        shr bx, 1                       ; test next bit
        mov ax, dx                      ; set AX to its original state
    loop PROC_drawcodestop_pixel
pop dx
pop cx
pop bx
ret
