; Wybiera pozycj� startow� rysowania na podstawie liczby znak�w w CX
; ARG: cl = liczba znak�w w buforze
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
	
	mov al, CONST_color_white					; zamalowanie pocz�tku na bia�o
	rep stosb
pop cx
ret
;***************************************************************************************************
; Wy�wietla string pod adresem AX
; ARG: al = znak do przetworzenia (wg tabeli znak�w CODE-128)
;      ds = SEG_data
;      es:[di] = pocz�tek rysowania
; RET: ax = kod znaku w notacji pikselowej, di += 11
PROC_drawcode:
push bx
push cx
push dx
											; ZAMIANA WARTO�CI ZNAKU Z AL NA KOD PIKSELOWY W AX
	shl al, 1								; wyznaczanie adresu kodu w BX
	mov bh, 0
	mov bl, al
	add bx, offset VAR_codetable
	mov ax, word ptr ds:[bx]				; wczytanie do AX kodu pikselowego odpowiadaj�cego danemu znakowi

	mov dx, ax									; zapami�taj ci�g pikseli w DX
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
		mov ax, dx								; wczytaj ci�g z DX
	loop PROC_drawcode_pixel
pop dx
pop cx
pop bx
ret
;***************************************************************************************************
; Akumuluje sum� kontroln�
; ARG: al = char code,
;      bl = bie��ca pozycja w kodzie,
;	   dl = bie��ca warto�� sumy kontrolnej
; RET: bl++, dl = nowa warto�� sumy kontrolnej
PROC_checksum:
push ax
	mul bl										; ax = al*bl = sk�adnik sumy
	mov dh, 0
	add ax, dx									; nowa warto�� w ax
	push bx
	mov bl, 103									; warto�� modulo sumy kontrolnej
	div bl										; ah = warto�� sumy kontrolnej modulo 103
	pop bx										; przywr�� do bx warto�� pozycji
	inc bl										; nast�pna pozycja
	mov dl, ah									; aktualizacja dl
pop ax
ret
;***************************************************************************************************
; Wy�wietla znak stopu
; ARG: es:[di] = pocz�tek rysowania
; RET: ax = kod znaku stopu w notacji pikselowej, di += 13
PROC_drawcodestop:
push bx
push cx
push dx
	mov ax, 1100011101011b						; wczytanie do AX kodu pikselowego znaku stopu
	mov dx, ax									; zapami�taj ci�g pikseli w DX
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
		mov ax, dx								; wczytaj ci�g z DX
	loop PROC_drawcodestop_pixel
pop dx
pop cx
pop bx
ret