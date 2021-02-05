SEG_data segment
    ; constants corresponding to default VGA 256-color palette
    CONST_color_black equ 0
    CONST_color_white equ 15

    ; Diagnostic messages
    VAR_str_error_parameter_missing db "Pass a message as a command line argument (max 24 characters) to create equivalent Code128.$"
    VAR_str_error_parameter_toolong db "Exceeded 24 characters. Barcode won't fit on the screen.$"

    ; Buffer for command line arguments
    VAR_buffer_size db ?
    VAR_buffer db 256 dup(?)
    
    include VAR_codetable.asm
SEG_data ends


SEG_code segment
    MAIN:
    mov ax, seg STACKP          ; initialize stack
    mov ss, ax
    lea sp, STACKP
    cld
    
    mov si, 80h                 ; 80h is the address of DOS command line arguments which
    mov di, seg SEG_data        ; start from 81h
    mov es, di
    lea di, VAR_buffer_size
    mov cl, byte ptr ds:[si]
    xor ch, ch
    cmp cx, 0
    je MAIN_error_parameter_missing
    cmp cx, 25
    ja MAIN_error_parameter_toolong
    dec cx
    mov byte ptr es:[di], cl    ; save size of the message to VAR_buffer_size
    add si, 2                   ; SI set to 82h address, ignore space character at 81h
    lea di, VAR_buffer
    rep movsb                   ; save the message to VAR_buffer
    
    mov ax, 13h                 ; Launch graphic mode 13h, resolution 320x200, 256 colors
    int 10h
    
    mov si, seg SEG_data
    mov ds, si
    lea si, VAR_buffer_size
    mov cl, byte ptr ds:[si]    ; set CX to VAR_buffer_size
    xor ch, ch
    call PROC_startpoint
    inc si                      ; set SI to address of VAR_buffer
    
    mov al, 104                 ; set AL to the start character of Code128B
    call PROC_drawcode
    
    mov dl, 104                 ; set DL to the initial value of the checksum
    mov bl, 1                   ; set BL to the current position in the barcode
    MAIN_coding:
        lodsb                   ; load one character from VAR_buffer to AL
        sub al, 32              ; decrease the value by 32 (see comment VAR_codetable.asm)
        call PROC_checksum
        call PROC_drawcode
    loop MAIN_coding
    
    mov al, dl                  ; set AL to the computed checksum value
    call PROC_drawcode          ; draw checksum barcode
    call PROC_drawcodestop      ; draw the stop character
    
    mov cx, 25920               ; fill the rest of the row with white color
    sub cx, di
    mov al, CONST_color_white
    rep stosb
    
    mov si, es                  ; currently the barcode is 1 pixel height, stretch it to have 1/5 of
    mov ds, si                  ; the screen height
    mov si, 25600
    mov cx, 12480
    rep movsb
    
    mov cx, 64000               ; fill the rest of the screen with white color
    sub cx, di
    mov al, CONST_color_white
    rep stosb
    
    MAIN_waitforescape:         ; wait for the escape key stroke
    mov ah, 0
    int 16h
    cmp ah, 1
    jne MAIN_waitforescape
    
    mov ax, 3h                  ; return to the original 3h console text mode
    int 10h
    
    jmp MAIN_end
    
    MAIN_error_parameter_missing:
    lea ax, VAR_str_error_parameter_missing 
    call PROC_printstr
    jmp MAIN_end
    MAIN_error_parameter_toolong:
    lea ax, VAR_str_error_parameter_toolong
    call PROC_printstr
    
    MAIN_end:                   ; program end
    mov ax, 04c00h 
    int 21h

    include drawing.asm         ; functions code
    include printstr.asm
SEG_code ends


SEG_stack segment stack
    dw 200 dup(?)
    STACKP dw ?
SEG_stack ends


end MAIN
