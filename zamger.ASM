; Gerald Zamora Morales 2020053672, Arquitectura de computadores grupo 2
;
; Este programa muestra una animación de la resolución de las torres de hanoi
; supone que va a recibir un número entre 1-8
; este programa utiliza un archivo de macros.
; 
;
;
;
;
; 		Tabla de evaluación
;
; Recibir la cantidad de anillos 		A
; Desplegar la animación 			B	Intente por todos los medios de quitar el parpadeo negro pero no pude.
; Resolver el problema recursivamente  	A
; mover las piesas de una columna a otra 	A
; Nota: todo sirve, el unico detalle es el parpadeo negro.
;
;



; -----------------------------Macros-----------------------------
include ./Macros.ASM
; -----------------------------endM-------------------------------

datos segment

	;------mensajes
	rotuloName db 'Gerald Zamora Morales 2020053672, fecha 25/11/2020'
	rotuloGroup db 'Arquitectura de computadores, grupo 2'
	;rotulo db 'Gerald Zamora Morales 2020053672, fecha 25/11/2020', 0Dh, 0Ah, 'Arquitectura de computadores, grupo 2', 0Dh, 0Ah, 0Ah, '$'

	errorN db 'Error de numero', 0Dh, 0Ah,'$'

	FIL db 24 ; 1-25
	COL db 0 ; 0-79
	amount db 0 ; cantidad de anillos 
	done db 0 ; si 1 entonces terminamos 

	colorsMtx db  00010001b, 00100010b, 01000100b ; colores de los anillos
	contColors db 0

	; vars
	count db 3 dup(0) ; 3 variables para guardar cuantos anillos hay en cada columna
	rects db 8 dup(3 dup(0))


	block DB ' ', 01001000b   ; Fondo rojo y frente oscuro   0100 1 000


datos ends

pila segment stack 'stack'
	dw 256 dup (?)
pila ends

codigo segment

assume cs:codigo,ds:datos,ss:pila
                                                                             
inicio: 
	mov ax, ds
	mov es, ax

	mov ax, datos
	mov ds, ax

	mov ax, pila
	mov ss, ax

	mov si, 80h
	mov cl, byte ptr es:[si]
	xor ch, ch
	inc si
         
	jmp main 

; -----------------------------procs------------------------------

errorNumero proc 

	PRINT errorN

	jmp fin
errorNumero endp 


; comienza a evaluar lo que este en es:[si] con cx digitos
; rt bx numero, cf=1 =error
getNumber proc

	PUSHS <ax, cx, dx, di>

	xor ax, ax
	xor bx, bx


	getNumberLeer:
		mov al, byte ptr es:[si]

		cmp al, " "
		je getNumberReturn

		cmp al, "0"
		jl getNumberError
		cmp al, "9"
		jg getNumberError

		sub al, 30h ; para que tenga valor de numero

		xor ah, ah
		mov di, ax ; respaldamos para sumar

		; se multiplica por la base
		mov ax, 10 
		mul bx ; ax result: dx:ax
		mov bx, ax

		add bx, di

		inc si
		loop getNumberLeer
		
		clc
		jmp getNumberReturn

	getNumberError:
		stc

	getNumberReturn:
		
	
	POPS <di, dx, cx, ax>

		ret
getNumber endp 

drawPoint proc
;col, fil, 
;pinta el punto con el block
	PUSHS <ax, bx>

	MOV AL,160           ; Calculamos BX = FIL*160+Col*2 
	MUL FIL
	XOR BH, BH
	MOV BL, COL
	SHL BX,1
	ADD BX,AX

	MOV AX, WORD PTR block     ; Movemos al AX el asterisco
    MOV WORD PTR ES:[BX],AX     ; Ponemos el asterisco en pantalla

	POPS <bx, ax>

	ret
drawPoint endp

drawRect proc
;col, fil, al=w ah=h, dx color
	PUSHS <ax, bx, dx, cx>

	xor cx, cx
	xor bx, bx

	mov bl, fil 
	mov bh, col

draw: inc cl
	
	DRAWPOINTM bh, bl, dl
	
	inc bh

	cmp cl, al
	jl draw

	xor cl, cl
	mov bh, col

	inc bl 
	dec ah 
	cmp ah, 0
	jg draw

	POPS <cx, dx, bx, ax>

	ret
drawRect endp


cleanScreen proc
	PUSHS <ax, bx, dx, cx>
	;DRAWRECTM 0, 1, 79, 25, negro 

	mov ah, 06h
	mov al, 0
	mov bh, 0
	mov ch, 1
	mov cl, 0
	mov dh, 80
	mov dl, 79

	int 10h

	POPS <cx, dx, bx, ax>

	ret 
cleanScreen endp


setTextMode proc 

	push ax

	mov ah, 03h
	int 10h

	pop ax 
	ret	
setTextMode endp  

drawColumns proc
	;alto 18
	DRAWRECTM 12, 7, 2, 18, cafe 
	DRAWRECTM 37, 7, 2, 18, cafe 
	DRAWRECTM 63, 7, 2, 18, cafe 
	ret
drawColumns endp 

printRects proc 
; imprime los rectagulos deacuerdo a la matriz y a el amount
	PUSHS<ax, bx, dx, cx, si, di>

	call cleanScreen
	call drawColumns

	xor ch, ch
	mov cl, [amount]

	lea si, rects
	lea di, rects
	inc di
	lea bx, rects
	inc bx
	inc bx

	xor ax, ax


printingRects:
	mov al, byte ptr [si]
	mov ah, byte ptr [di]

	cmp [contcolors], 3 ; manejo colores
	jne noVol0
	mov byte ptr [contcolors], 0

noVol0:
	push si
	mov dl, byte ptr [contcolors]
	xor dh, dh
	lea si, [colorsmtx]
	add si, dx
	mov dl, byte ptr [si]
	inc byte ptr [contcolors]
	pop si

	DRAWRECTM al, ah, <byte ptr [bx]>, 2, dx
	add si, 3
	add di, 3
	add bx, 3
	loop printingRects

	mov byte ptr [contcolors], 0

	POPS<di, si, cx, dx, bx, ax>
	ret
printRects endp 

startGame proc
; rc bx, cantidad de anillos
; settea la matriz y hace las cosas basicas para comenzar a jugar
	PUSHS<ax, cx, si> 

	mov amount, bl

	mov ax, 0B800H
	mov es, ax

	; llenamos la matriz
	mov cx, 8 ; cargamos los xs 
	xor si, si 
	mov ax, 1

xs:
	mov byte ptr [rects+si], al
	inc al
	add si, 3

	loop xs

	mov cx, 8 ; cargamos los xs 
	mov si, 1 
	mov ax, 23

ys:
	mov byte ptr [rects+si], al
	dec al
	dec al
	add si, 3
	loop ys

	mov cx, 8 ; cargamos los xs 
	mov si, 2 
	mov ax, 24

ws:
	mov byte ptr [rects+si], al
	dec al
	dec al
	add si, 3
	loop ws

	;DRAWRECTM 1, 23, 24, 2, verde
	;;DRAWRECTM 2, 21, 22, 2, azul
;	DRAWRECTM 3, 19, 20, 2, verde
;	DRAWRECTM 4, 17, 18, 2, rojo 
;	DRAWRECTM 5, 15, 16, 2, azul 
;	DRAWRECTM 6, 13, 14, 2, verde 
;	DRAWRECTM 7, 11, 12, 2, rojo 
;	DRAWRECTM 8, 9, 10, 2, verde 

	POPS<si, cx, ax>

	ret
startGame endp 

movUntil proc 
; mueve lo que este en el di, y le va sumando bl, hasta bh
; movemos para arriba

moving:
	call printRects
	PAUSE 150
	add byte ptr [di], bl
	cmp byte ptr [di], bh  ; hasta que llegue a 19 abjo para arriba
	jne moving

	call printRects

	ret 
movUntil endp 

positBajo proc 
; al to
; rt: bh el resultado
	PUSHS<ax, di>
	
	lea di, [count]
	mov bl, al ; sumamos el to a el index de count
	xor bh, bh 
	add di, bx 

	mov bl, byte ptr [di]  ; movemos la cantidad de anillos en esa columna
	mov ax, 2; formula saber la hasta donde 25 - 2x ; donde x = byte ptr [di]
	mul bl

	mov bx, 23
	sub bx, ax

	mov bh, bl 

	POPS<di, ax>
	ret 
positBajo endp 

moviCal proc
;ah from, al to, di rect
;rt bx: bh hasta, bl suma 
	push ax
	push dx 

; calcular si derecha o izquierda
	cmp ah, al
	jg derecha 
	mov bl, 1
	jmp izq
derecha:
	mov bl, -1
izq:

	;26*to
	xor ah, ah
	mov bh, 26
	mul bh
	mov bh, al

	; le tenemos que sumar su (24-width)/2
	mov al, 24
	sub al, byte ptr [di+2] ; w
	mov dh, 2
	div dh

	add bh, al

	pop dx
	pop ax
	ret 
moviCal endp

moveFromTO proc
; si: inicio rect, ah: from, al: to column
	PUSHS <ax, bx, cx, dx, si, di>

; movemos para arriba
	mov di, si
	inc di ; y
	mov bh, 3; hasta 3
	mov bl, -1
	call movUntil


; mover lados
	mov di, si; x
	call moviCal ; rt bx
	call movUntil

; movemos para abajo
	; calculamos que tanto tiene que bajar
	call positBajo ; rt bh
	mov di, si
	inc di ; y
	mov bl, 1
	call movUntil


	mov done, 1

; movemos el numero de columnas 
	lea di, [count]
	mov bl, ah ; sumamos el from a el index de count
	xor bh, bh 
	add di, bx 

	dec byte ptr [di] ; quitamos ese anillo de ahi

	lea di, [count]
	mov bl, al ; sumamos el to a el index de count
	xor bh, bh 
	add di, bx 
	inc byte ptr [di] ; agregamos el anillo ahi

	POPS <di, si, dx, cx, bx, ax>
	ret
moveFromTO endp 

movAnimationReally proc
; calcula qué anillo se tiene que mover a qué columna segun la pila, y llama la animación

	; sacamos el numero en la matriz
	mov bl, byte ptr [amount] ; cantidad de discos totales 
	xor bh, bh
	sub bx, word ptr [bp+10] ; para saber cual es el disco en la matriz = (N-1)*3
	mov ax, 3
	mul bx

	lea si, [rects] ; primer anillo 
	add si, ax ; le sumamos para movernos en la matriz

	mov bx, word ptr [bp+8]; este es el from
	mov ah, bl ; ponemos el from
	mov bx, word ptr [bp+4]; este es el to
	mov al, bl ; ponemos el to

	call moveFromTO ; lo movemos todo

	ret 
movAnimationReally endp

solver proc ; n, fr, center, to 
; algoritmo recursivo que resuelve el problema

 	;sub sp, 8 ;   reservar memoria en la pila para las variables locales.
    push bp
    mov bp, sp   ; Salvo el viejo BP y pongo al BP a apuntar a mi registro de activación.

	PUSHS <ax, bx, cx, dx, si, di>; salva los registros que se van a modificar

	cmp word ptr [bp+10], 1   ;  N == 1
    je finSolver ; si este es el ultimo caso entonces salte

	; sino :
	 	; tower(n-1, fr, to, cent)
	mov ax, word ptr [bp+10]
	dec ax 
	push ax ; N
	push word ptr [bp+8] ; fr
	push word ptr [bp+4] ; to
	push word ptr [bp+6] ; cent
	call solver
	add sp, 8; protocolo C

	call movAnimationReally; movemos n from -> to

	;sino:
		; tower(n-1, center, fr, to)
	mov ax, word ptr [bp+10]
	dec ax 
	push ax ; N
	push word ptr [bp+6] ; cent
	push word ptr [bp+8] ; fr
	push word ptr [bp+4] ; to
	call solver
	add sp, 8; protocolo C
	jmp finr2

finSolver:
	call movAnimationReally

finr2:
	POPS <di, si, dx, cx, bx, ax>
	pop bp
	ret
solver endp 
; orden pila :
; to
; cent
; fr
; n

; -----------------------------endp-------------------------------
main:
	MOVE
	call getNumber
	CALLIF jc, errorNumero

	mov byte ptr [amount], bl
	mov byte ptr [count], bl ; todo los aros en la columna 0

	call setTextMode
	call startGame

	; pasamos los parametros
	mov bl, byte ptr [amount] 
	xor bh, bh ; N
	push bx

	mov bx, 0 ; fr
	push bx

	mov bx, 1
	push bx ; cent

	mov bx, 2
	push bx ; to

	call solver

	add sp, 8 ; protocolo C


	; imprimimos la portada

	; marco:
	mov cx, 57 ; max width

	mov bx, 641
	mov al, 0Bh ; color
	mov ah, '-'
marcoUpDown:
	MOV WORD PTR ES:[bx], AX  
	mov di, bx
	add di, 480
	MOV WORD PTR ES:[di], AX  
	inc bl 
	inc bl
	loop marcoUpDown

	; lados del marco
	mov cx, 2 ; max width

	mov bx, 801
	mov al, 0Bh ; color
	mov ah, '|'
marcoRightLeft:
	MOV WORD PTR ES:[bx], AX  
	mov di, bx
	add di, 110
	MOV WORD PTR ES:[di], AX  
	inc bl 
	inc bl
	loop marcoRightLeft

	mov cx, 2 ; max width

	mov bx, 961
	mov al, 0Bh ; color
	mov ah, '|'
marcoRightLeft2:
	MOV WORD PTR ES:[bx], AX  
	mov di, bx
	add di, 110
	MOV WORD PTR ES:[di], AX  
	inc bl 
	inc bl
	loop marcoRightLeft2


	; letras rotulo 1
	mov cx, 51

	lea si, [rotuloName]
	mov bx, 805
	mov al, 5 ; color

rotuloP:
	mov ah, byte ptr[si]
	MOV WORD PTR ES:[bx], AX  
	inc bl 
	inc bl
	inc si
	loop rotulop


; letras rotulo 2
	mov cx, 38

	lea si, [rotuloGroup]
	mov bx, 965
	mov al, 5 ; color

rotuloP2:
	mov ah, byte ptr[si]
	MOV WORD PTR ES:[bx], AX  
	inc bx 
	inc bx
	inc si
	loop rotulop2


fin:
	;PRINT rotulo
	mov ax, 4C00h
	int 21h

     
codigo ends

end inicio
