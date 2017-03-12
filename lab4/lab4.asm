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
xSize equ 80
ySize equ 25
snakeBody equ 0DBh		;symbol blackSquare
fieldBody equ 20h		;' '
appleBody equ 0Fh		;symbol SUN
xField equ 50
yField equ 21

videoStart equ 0B800h
space equ 0020h
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
		dw fieldSpacing, 2 dup(grSpc), 02FDCh, 02FDFh, grSym, 2 dup(grSpc), 2 dup(grSym, grSpc), 02FDCh, grSym, 02FDCh, grSpc, grSym, 02FDFh, 02FDDh, grSpc, 5 dup(grSym), grSpc, 0FBAh, space
		dw fieldSpacing, 2 dup(grSpc), grSym, 02FDCh, grSym, 2 dup(grSpc), 4 dup(grSym, grSpc), grSym, 02FDFh, 02FDCh, grSpc, grSym, grSpc, 02FDFh, grSpc, grSym, grSpc, 0FBAh, space
		dw fieldSpacing, grSpc, 2 dup(02FDCh, 2 dup(grSym, grSpc)), 02FDFh, grSym, 02FDFh, grSpc, grSym, 02FDCh, grSym, grSpc, 02FDFh, grSym, 02FDCh, grSym, 02FDFh, grSpc, 0FBAh, space
		dw fieldSpacing, xSize - xField - 5 dup(grSpc), 0FBAh, space
		dw space, 0FC8h, xField dup(0FCDh), 0FCAh, xSize - xField - 5 dup(0FCDh), 0FBCh, space
		dw xSize dup(space)
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

;procedure help

initField PROC
	mov si, offset screen
	xor di, di

	mov cx, xSize*ySize
	rep movsw

	ret
ENDP

mainGame PROC
	;todo
	ret
ENDP

;end procedure help

end main