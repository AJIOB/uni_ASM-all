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

xSize equ 80
ySize equ 25
xField equ 50
yField equ 21
oneMemoBlock equ 2

videoStart equ 0B800h
space equ 0020h
snakeBodySymbol equ 0A40h
appleSymbol equ 0B0Fh
fieldSpacingBad equ space, 0FBAh, xField dup(space)
fieldSpacing equ fieldSpacingBad, 0FBAh
rbSym equ 0CFDCh	;white block with red background
rbSpc equ 0CF20h	;space with red background
ylSym equ 06FDCh	;white block with yellow background
ylSpc equ 06F20h	;space with yellow background
grSym equ 02FDBh	;white block with green background
grSpc equ 02F20h	;space with green background

screen	dw xSize dup(space)
		dw space, 0FC9h, xField dup(0FCDh), 0FCBh, xSize - xField - 5 dup(0FCDh), 0FBBh, space
firstBl	dw fieldSpacing, xSize - xField - 5 dup(rbSpc), 0FBAh, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), 15 dup(rbSpc), 4 dup(rbSym), rbSpc, 0FBAh, space
		dw fieldSpacing, rbSpc, rbSym, 5 dup(rbSpc), 3 dup(rbSym), 2 dup(rbSpc), 3 dup(rbSym), rbSpc, rbSym, 3 dup(rbSpc), rbSym, 2 dup(rbSpc), rbSym, rbSpc, 0FBAh, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), 3 dup(rbSym, rbSpc), 4 dup(rbSym), rbSpc, 0FBAh, space
		dw fieldSpacing, 4 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, 4 dup(rbSym), rbSpc, 2 dup(rbSym), 2 dup(rbSpc), rbSym, 4 dup(rbSpc), 0FBAh, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), 3 dup(rbSym, rbSpc), 4 dup(rbSym), rbSpc, 0FBAh, space
		dw fieldSpacing, xSize - xField - 5 dup(rbSpc), 0FBAh, space
delim1	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(0FCDh), 0FB9h, space
secondF	dw fieldSpacing, xSize - xField - 5 dup(ylSpc), 0FBAh, space
		dw fieldSpacing, ylSpc, 06F53h, 06F63h, 06F6Fh, 06F72h, 06F65h, 06F3Ah, ylSpc
	score	dw 4 dup(06F30h), 13 dup(ylSpc), 0FBAh, space
		dw fieldSpacing, xSize - xField - 5 dup(ylSpc), 0FBAh, space
		dw fieldSpacing, ylSpc, 06F53h, 06F70h, 2 dup(06F65h), 06F64h, 06F3Ah, ylSpc
	speed	dw 06F30h, 16 dup(ylSpc), 0FBAh, space
		dw fieldSpacing, xSize - xField - 5 dup(ylSpc), 0FBAh, space
delim2	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(0FCDh), 0FB9h, space
thirdF	dw fieldSpacing, xSize - xField - 5 dup(grSpc), 0FBAh, space
		dw fieldSpacing, grSpc, 02F4Dh, 02F61h, 02F64h, 02F65h, grSpc, 02F62h, 02F79h, 02F3Ah, 10 dup(grSpc), 02FDCh, 3 dup(grSym), 02FDCh, grSpc, 0FBAh, space
		dw fieldSpacing, 19 dup(grSpc), grSym, 02FDDh, grSym, 02FDEh, grSym, grSpc, 0FBAh, space
		dw fieldSpacing, 2 dup(grSpc), 02FDCh, 02FDFh, grSym, 2 dup(grSpc), 2 dup(grSym, grSpc), 02FDEh, 2 dup(grSym), grSpc, grSym, 02FDFh, 02FDDh, grSpc, 5 dup(grSym), grSpc, 0FBAh, space
		dw fieldSpacing, 2 dup(grSpc), grSym, 02FDCh, grSym, 2 dup(grSpc), 4 dup(grSym, grSpc), grSym, 02FDFh, 02FDCh, grSpc, grSym, grSpc, 02FDFh, grSpc, grSym, grSpc, 0FBAh, space
		dw fieldSpacing, grSpc, 2 dup(02FDCh, 2 dup(grSym, grSpc)), 2 dup(grSym), 02FDDh, grSpc, grSym, 02FDCh, grSym, grSpc, 02FDFh, grSym, 02FDCh, grSym, 02FDFh, grSpc, 0FBAh, space
		dw fieldSpacing, xSize - xField - 5 dup(grSpc), 0FBAh, space
		dw space, 0FC8h, xField dup(0FCDh), 0FCAh, xSize - xField - 5 dup(0FCDh), 0FBCh, space
		dw xSize dup(space)

snakeMaxSize equ 20
snakeSize db 2
PointSize equ 2

; XYh coordinates
; first position - tail
snakeBody dw 1B0Ch, 1C0Ch, snakeMaxSize-2 dup(0000h)

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

;get pos as (bh + (bl * xSize))*oneMemoBlock
;input: point (x,y) in bx
;output: offser in bx
CalcOffsetByPoint MACRO
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

mainGame PROC
;load base snake
	push ax bx cx ds es

	xor ch, ch
	mov cl, snakeSize
	mov si, offset snakeBody

loopInitSnake:
	mov bx, [si]
	add si, PointSize
	
	;get pos as (bh + (bl * xSize))*oneMemoBlock
	CalcOffsetByPoint

	mov di, bx

	mov ax, snakeBodySymbol
	stosw
	loop loopInitSnake

	;todo
	pop es ds cx bx ax
	ret
ENDP

;end procedure help

end main