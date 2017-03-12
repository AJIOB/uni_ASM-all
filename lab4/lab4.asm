;Игра "Змейка"


;macro HELP
endd MACRO
	mov ah, 4ch
	int 21h
ENDM

clearScreen MACRO
	push ax
	mov ax, 0003h
	int 10h
	pop ax
ENDM
;end macro help

.model small

.stack 100h

.data

;key bindings (configuration)
KUpSpeed equ 48h		;Up key
KDownSpeed equ 50h	;Down key
KMoveUp equ 11h		;W key
KMoveDown equ 1Fh	;S key
KMoveLeft equ 1Eh	;A key
KMoveRight equ 20h	;D key
KExit equ 01h 		;ESC key

xSize equ 80
ySize equ 25
xField equ 50
yField equ 21
oneMemoBlock equ 2

videoStart dw 0B800h
dataStart dw 0000h
space equ 0020h
snakeBodySymbol equ 0A40h
appleSymbol equ 0B0Fh
VWallSymbol equ 0FBAh
HWallSymbol equ 0FCDh


fieldSpacingBad equ space, VWallSymbol, xField dup(space)
fieldSpacing equ fieldSpacingBad, VWallSymbol
rbSym equ 0CFDCh	;white block with red background
rbSpc equ 0CF20h	;space with red background
ylSym equ 06FDCh	;white block with yellow background
ylSpc equ 06F20h	;space with yellow background
grSym equ 02FDBh	;white block with green background
grSpc equ 02F20h	;space with green background

screen	dw xSize dup(space)
		dw space, 0FC9h, xField dup(HWallSymbol), 0FCBh, xSize - xField - 5 dup(HWallSymbol), 0FBBh, space
firstBl	dw fieldSpacing, xSize - xField - 5 dup(rbSpc), VWallSymbol, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), 15 dup(rbSpc), 4 dup(rbSym), rbSpc, VWallSymbol, space
		dw fieldSpacing, rbSpc, rbSym, 5 dup(rbSpc), 3 dup(rbSym), 2 dup(rbSpc), 3 dup(rbSym), rbSpc, rbSym, 3 dup(rbSpc), rbSym, 2 dup(rbSpc), rbSym, rbSpc, VWallSymbol, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), 3 dup(rbSym, rbSpc), 4 dup(rbSym), rbSpc, VWallSymbol, space
		dw fieldSpacing, 4 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, 4 dup(rbSym), rbSpc, 2 dup(rbSym), 2 dup(rbSpc), rbSym, 4 dup(rbSpc), VWallSymbol, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), 3 dup(rbSym, rbSpc), 4 dup(rbSym), rbSpc, VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(rbSpc), VWallSymbol, space
delim1	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(HWallSymbol), 0FB9h, space
secondF	dw fieldSpacing, xSize - xField - 5 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, ylSpc, 06F53h, 06F63h, 06F6Fh, 06F72h, 06F65h, 06F3Ah, ylSpc
	score	dw 4 dup(06F30h), 13 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, ylSpc, 06F53h, 06F70h, 2 dup(06F65h), 06F64h, 06F3Ah, ylSpc
	speed	dw 06F30h, 16 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(ylSpc), VWallSymbol, space
delim2	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(HWallSymbol), 0FB9h, space
thirdF	dw fieldSpacing, xSize - xField - 5 dup(grSpc), VWallSymbol, space
		dw fieldSpacing, grSpc, 02F4Dh, 02F61h, 02F64h, 02F65h, grSpc, 02F62h, 02F79h, 02F3Ah, 10 dup(grSpc), 02FDCh, 3 dup(grSym), 02FDCh, grSpc, VWallSymbol, space
		dw fieldSpacing, 19 dup(grSpc), grSym, 02FDDh, grSym, 02FDEh, grSym, grSpc, VWallSymbol, space
		dw fieldSpacing, 2 dup(grSpc), 02FDCh, 02FDFh, grSym, 2 dup(grSpc), 2 dup(grSym, grSpc), 02FDEh, 2 dup(grSym), grSpc, grSym, 02FDFh, 02FDDh, grSpc, 5 dup(grSym), grSpc, VWallSymbol, space
		dw fieldSpacing, 2 dup(grSpc), grSym, 02FDCh, grSym, 2 dup(grSpc), 4 dup(grSym, grSpc), grSym, 02FDFh, 02FDCh, grSpc, grSym, grSpc, 02FDFh, grSpc, grSym, grSpc, VWallSymbol, space
		dw fieldSpacing, grSpc, 2 dup(02FDCh, 2 dup(grSym, grSpc)), 2 dup(grSym), 02FDDh, grSpc, grSym, 02FDCh, grSym, grSpc, 02FDFh, grSym, 02FDCh, grSym, 02FDFh, grSpc, VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(grSpc), VWallSymbol, space
		dw space, 0FC8h, xField dup(HWallSymbol), 0FCAh, xSize - xField - 5 dup(HWallSymbol), 0FBCh, space
		dw xSize dup(space)

snakeMaxSize equ 20
snakeSize db 2
PointSize equ 2

; XYh coordinates
; first position - head
snakeBody dw 1C0Ch, 1B0Ch, snakeMaxSize-1 dup(0000h)

stopVal equ 00h
forwardVal equ 01h
backwardVal equ 0FFh

Bmoveright db 01h
Bmovedown db 00h

waitTime db 10h

.code

main:
	mov ax, @data	;init
	mov ds, ax
	mov dataStart, ax
	mov ax, videoStart
	mov es, ax
	xor ax, ax

	clearScreen

	call initField

	call mainGame

to_close:
	;clearScreen

	endd

;more macro help

;ZF = 1 - buffer is free
;AH = scan-code
CheckBuffer MACRO
	mov ax, 11h
	int 16h
ENDM

;end macro help

;procedure help

initField PROC
	mov si, offset screen
	xor di, di

	mov cx, xSize*ySize
	rep movsw

	ret
ENDP

;get pos as (bh + (bl * xSize))*oneMemoBlock
;input: point (x,y) in bx
;output: offser in bx
CalcOffsetByPoint PROC
	push ax dx
	
	xor ah, ah
	mov al, bl
	mov dl, xSize
	mul dl
	mov dl, bh
	xor dh, dh
	add ax, dx
	mov dx, oneMemoBlock	;длину каждого блока
	mul dx
	mov bx, ax

	pop dx ax
ENDP

;change snake body in array
;old last element is always saved
;delete old last element from screen
MoveSnake PROC
	push ax bx cx si di es

	mov al, snakeSize
	xor ah, ah 		;в ah - длина массива
	mov cx, ax 		;cx - счетчик кол-ва сдвигов
	mov bx, PointSize
	mul bx			;теперь получим в ax реальную позицию в памяти относительно начала массива
	mov di, offset snakeBody
	add di, ax 		;di - адрес следующего после последнего элемента массива
	mov si, di
	sub si, PointSize 			;si - адрес последнего элемента массива

	;удалить конец змейки с экрана
	mov es, videoStart
	mov bx, ds:[si]
	call CalcOffsetByPoint
	mov di, bx			;установили память, куда будем писать пробел
	mov ax, space
	stosw

	mov es, dataStart	;для работы с данными
	std				;идем от конца к началу
	rep movsw

	mov bx, snakeBody 	;текущая позиция головы

	add bh, Bmoveright
	add bl, Bmovedown	;новая позиция головы
	mov snakeBody, bx	;сохраняем новую позицию головы
	;все тело в памяти сдвинуто

	pop es di si cx bx ax
ENDP

mainGame PROC
;load base snake
	push ax bx cx dx ds es

	xor ch, ch
	mov cl, snakeSize
	mov si, offset snakeBody

loopInitSnake:
	mov bx, [si]
	add si, PointSize
	
	;get pos as (bh + (bl * xSize))*oneMemoBlock
	call CalcOffsetByPoint

	mov di, bx

	mov ax, snakeBodySymbol
	stosw
	loop loopInitSnake

checkAndMoveLoop:
	
	CheckBuffer
	jz noSymbolInBuff

	;exit
	cmp ah, KExit
	je endLoop_relink

noSymbolInBuff:

;MoveSnake:
	;сдвигаем все тело
	call MoveSnake

	mov bx, snakeBody 		;в bx точка головы змеи
	call CalcOffsetByPoint	;в bx смещение в памяти, соответствующее точке

	mov es, videoStart
	mov ax, es:[bx]		;в ax текущий символ в памяти es:bx (куда должна стать змейка)

	cmp ax, appleSymbol
	je AppleIsNext

	cmp ax, snakeBodySymbol
	je SnakeIsNext

	cmp ax, HWallSymbol
	je PortalUpDown

	cmp ax, VWallSymbol
	je PortalLeftRight

	jmp GoNext

endLoop_relink:
	jmp endLoop

AppleIsNext:
	;todo
SnakeIsNext:
	;todo
PortalUpDown:
	;todo
PortalLeftRight:
	;todo
	jmp endLoop
GoNext:
	mov di, snakeBody		;вывести новое начало змейки
	mov ax, snakeBodySymbol
	stosw

	jmp checkAndMoveLoop

endLoop:
	;todo
	pop es ds dx cx bx ax
	ret
ENDP

;end procedure help

end main