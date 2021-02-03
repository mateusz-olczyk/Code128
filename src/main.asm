SEG_data segment
	CONST_color_black equ 0						; STA�E
	CONST_color_white equ 15
												; TRE�CI KOMUNIKAT�W
	VAR_str_error_parameter_missing db "Podaj parametr (max 24 znaki), aby wyswietlic odpowiadajacy kod kreskowy.$"
	VAR_str_error_parameter_toolong db "Przekroczono dlugosc 24 znakow. Kod kreskowy nie zmiesci sie na ekranie.$"

												; BUFOR (NP. DLA PARAMETRU PRZEKAZANEGO W KONSOLI)
	VAR_buffer_size db ?						; ile znak�w
	VAR_buffer db 256 dup(?) 					; zawarto��
	
	include VAR_codetable.asm					; tabela znak�w kodu kreskowego (107 element�w)
	
SEG_data ends
;***************************************************************************************************
SEG_code segment

	MAIN:		
	mov	ax, seg STACKP							; INICJALIZACJA STOSU
	mov	ss, ax
	lea sp, STACKP
	cld 										; ustawienie znacznika kierunku na dodatni
	
	mov si, 80h									; ZAPISANIE PRZEKAZANEGO PARAMETRU PROGRAMU
	mov di, seg SEG_data
	mov es, di
	lea di, VAR_buffer_size
	mov cl, byte ptr ds:[si] 					; ustawienie licznika
	xor ch, ch
	cmp cx, 0
	je MAIN_error_parameter_missing
	cmp cx, 25									; obliczona maksymalna d�ugo�� (+spacja) ci�gu dla rozdzielczo�ci 320
	ja MAIN_error_parameter_toolong
	dec cx 										; nie liczymy pierwszej spacji
	mov byte ptr es:[di], cl 					; zapisanie liczby znak�w
	add si, 2									; SI wskazuje na pierwszy znak
	lea di, VAR_buffer
	rep movsb 									; przepisanie do bufora
	
	mov ax, 13h									; URUCHOMIENIE TRYBU GRAFICZNEGO
	int 10h
	
	mov si, seg SEG_data
	mov ds, si
	lea si, VAR_buffer_size
	mov cl, byte ptr ds:[si]					; wczytanie liczby znak�w do CX
	xor ch, ch
	call PROC_startpoint
	inc si										; ustawienie SI na pocz�tek bufora
	mov dl, 104									; inicjalizacja rejestru DL sumy kontrolnej znakiem startu
	mov bl, 1									; ustawienie pozycji (do obliczania sumy kontrolnej)
	
	mov al, 104									; znak startu kodowania zestawem B
	call PROC_drawcode
	
	MAIN_coding:
		lodsb									; wczytaj znak z bufora do AL
		sub al, 32								; wyr�wnanie indeksu zgodnie z pocz�tkiem tabeli kodowej
		call PROC_checksum
		call PROC_drawcode
	loop MAIN_coding
	
	mov al, dl									; wczytanie znaku obliczonej sumy kontrolnej do AL
	call PROC_drawcode							; wy�wietlenie znaku kontrolnego
	call PROC_drawcodestop						; wy�wietlenie znaku stopu
	
	mov cx, 25920								; uzupe�nij reszt� linii barw� bia��
	sub cx, di
	mov al, CONST_color_white
	rep stosb
	
	mov si, es									; rozci�ganie obrazu w pionie
	mov ds, si
	mov si, 25600
	mov cx, 12480
	rep movsb
	
	mov cx, 64000								; uzupe�nij reszt� obrazu barw� bia��
	sub cx, di
	mov al, CONST_color_white
	rep stosb
	
	MAIN_waitforescape:							; CZEKAJ NA NACI�NI�CIE KLAWISZA ESC
	mov ah, 0
	int 16h
	cmp ah, 1									; czy naci�ni�to klawisz ESC?
	jne MAIN_waitforescape
	
	mov ax, 3h									; POWR�T DO TRYBU TEKSTOWEGO
	int 10h
	
	jmp MAIN_end
	
	MAIN_error_parameter_missing:				; KOMUNIKATY B��D�W
	lea ax, VAR_str_error_parameter_missing
	call PROC_printstr
	jmp MAIN_end
	MAIN_error_parameter_toolong:
	lea ax, VAR_str_error_parameter_toolong
	call PROC_printstr
	
	MAIN_end:									; KONIEC PROGRAMU
	mov	ax, 04c00h 
	int	21h

;***************************************************************************************************
include drawing.asm
include printstr.asm

SEG_code ends
;***************************************************************************************************
SEG_stack segment stack
	dw 200 dup(?)
	STACKP dw ?
SEG_stack ends
;***************************************************************************************************
end MAIN