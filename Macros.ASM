;;-------------Generales---------------------
POPS Macro ListaRR
;; Hace una serie de Push a los registros que recibe en una lista
  IRP RR, <ListaRR>
     Pop RR
  EndM
EndM

PUSHS Macro ListaR
	
	IRP R, <ListaR>	
		Push R
	EndM
EndM
	
PRINT macro S
	;; imprime lo que haya en S
	PUSHS <ax, dx>

	mov ah, 09h
	lea dx, S
	int 21h

	POPS <dx, ax>
endm

INC2 Macro R

  Inc R
  Inc R
endm

CONEJO macro salto , etiqueta
  local et1
  local et2

  salto et1
  jmp et2
et1: jmp etiqueta
et2:  

endM

DSTOES macro
	
	push es
	push ds 
	pop es
endm

ESTODS macro
	
	push es 
	pop ds
	pop es 
endm

CALLIF macro salto, procs;; llama al procs si se cumple el salto
	local et1
	local et2

 
	salto et1
	jmp et2
et1: call procs	
et2:

endM

MOVE macro
	
	inc si
	dec cx
endm

;;-------------end Generales---------------------
;;-------------specificas-------------

negro EQU 00000000b
azul EQU 00010001b
verde EQU 00100010b
rojo EQU 01000100b
cafe EQU 01100100b
gris EQU 10001000b

nose EQU 01001010b


amarillo EQU 11100100b
blanca EQU 01111111b


MOVECUR macro row, column

	push dx

	mov dh, row
	mov dl, column
	call moveCursor

	pop dx

endm

DRAWPOINTM macro x, y, color

	push ax

	mov byte ptr [block+1], color
	mov al, fil
	mov ah, COL
	mov FIL, y
	mov COL, x

	call drawPoint

	mov fil, al
	mov COL, ah

	pop ax

endm

DRAWRECTM macro x, y, w, h, color

	PUSHS<ax, dx>
	mov byte ptr FIL, y
	mov byte ptr COL, x

	mov al, w
	mov ah, h

	mov dx, color

	call drawRect

	POPS<dx, ax>

endm


franjaH Macro color
local franja1
		N = 4
		mov cx, 80*N
		mov ah, color
		franja1:
			mov word ptr es:[si], ax
			inc si
			inc si          
		loop franja1
endM

Pause Macro N
local Cic1,Cic2
     push cx
     mov cx, N
cic1: push cx
     mov cx, N
cic2: nop
     loop cic2
     pop cx
     loop cic1
     pop cx
EndM