; Wybiera pozycjê startow¹ rysowania na podstawie liczby znaków w CX
; ARG: cl = liczba znaków w buforze
; RET: es:[di] = pozycja startowa
PROC_startpoint:
push cx
	mov di, 0a000h								; ustawienie ES:[DI] na pierwszy piksel
	mov es, di
	mov di, 0
	
	mov al, 11									; OBLICZANIE POZYCJI STARTOWEJ
	mul cl
	add ax, 35
	shr ax, 1
	neg ax
	add ax, 25760
	mov cx, ax									; pozycja startowa w CX
	
	mov al, CONST_color_white					; zamalowanie pocz¹tku na bia³o
	rep stosb
pop cx
ret
;***************************************************************************************************
; Wyœwietla string pod adresem AX
; ARG: al = znak do przetworzenia (wg tabeli znaków CODE-128)
;      ds = SEG_data
;      es:[di] = pocz¹tek rysowania
; RET: ax = kod znaku w notacji pikselowej, di += 11
PROC_drawcode:
push bx
push cx
push dx
											; ZAMIANA WARTOŒCI ZNAKU Z AL NA KOD PIKSELOWY W AX
	shl al, 1								; wyznaczanie adresu kodu w BX
	mov bh, 0
	mov bl, al
	add bx, offset VAR_codetable
	mov ax, word ptr ds:[bx]				; wczytanie do AX kodu pikselowego odpowiadaj¹cego danemu znakowi

	mov dx, ax									; zapamiêtaj ci¹g pikseli w DX
	mov cx, 11
	mov bx, 10000000000b
	PROC_drawcode_pixel:
		and ax, bx								; testuj bit
		jnz PROC_drawcode_black
		mov al, CONST_color_white
		jmp PROC_drawcode_continue
		PROC_drawcode_black:
		mov al, CONST_color_black
		PROC_drawcode_continue:
		stosb
		shr bx, 1								; testuj kolejny bit
		mov ax, dx								; wczytaj ci¹g z DX
	loop PROC_drawcode_pixel
pop dx
pop cx
pop bx
ret
;***************************************************************************************************
; Akumuluje sumê kontroln¹
; ARG: al = char code,
;      bl = bie¿¹ca pozycja w kodzie,
;	   dl = bie¿¹ca wartoœæ sumy kontrolnej
; RET: bl++, dl = nowa wartoœæ sumy kontrolnej
PROC_checksum:
push ax
	mul bl										; ax = al*bl = sk³adnik sumy
	mov dh, 0
	add ax, dx									; nowa wartoœæ w ax
	push bx
	mov bl, 103									; wartoœæ modulo sumy kontrolnej
	div bl										; ah = wartoœæ sumy kontrolnej modulo 103
	pop bx										; przywróæ do bx wartoœæ pozycji
	inc bl										; nastêpna pozycja
	mov dl, ah									; aktualizacja dl
pop ax
ret
;***************************************************************************************************
; Wyœwietla znak stopu
; ARG: es:[di] = pocz¹tek rysowania
; RET: ax = kod znaku stopu w notacji pikselowej, di += 13
PROC_drawcodestop:
push bx
push cx
push dx
	mov ax, 1100011101011b						; wczytanie do AX kodu pikselowego znaku stopu
	mov dx, ax									; zapamiêtaj ci¹g pikseli w DX
	mov cx, 13
	mov bx, 1000000000000b
	PROC_drawcodestop_pixel:
		and ax, bx								; testuj bit
		jnz PROC_drawcodestop_black
		mov al, CONST_color_white
		jmp PROC_drawcodestop_continue
		PROC_drawcodestop_black:
		mov al, CONST_color_black
		PROC_drawcodestop_continue:
		stosb
		shr bx, 1								; testuj kolejny bit
		mov ax, dx								; wczytaj ci¹g z DX
	loop PROC_drawcodestop_pixel
pop dx
pop cx
pop bx
ret