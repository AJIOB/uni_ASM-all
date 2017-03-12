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
grSym equ 0AFDCh
grSpc equ 0AF20h

screen	dw xSize dup(space)
		dw space, 0FC9h, xField dup(0FCDh), 0FCBh, xSize - xField - 5 dup(0FCDh), 0FBBh, space
firstBl	dw fieldSpacing, xSize - xField - 5 dup(grSpc), 0FBAh, space
		dw fieldSpacing, grSpc, 4 dup(grSym), 15 dup(grSpc), 4 dup(grSym), grSpc, 0FBAh, space
		dw fieldSpacing, grSpc, grSym, 5 dup(grSpc), 3 dup(grSym), 2 dup(grSpc), 3 dup(grSym), grSpc, grSym, 3 dup(grSpc), grSym, 2 dup(grSpc), grSym, grSpc, 0FBAh, space
		dw fieldSpacing, grSpc, 4 dup(grSym), grSpc, grSym, 2 dup(grSpc), grSym, grSpc, grSym, 2 dup(grSpc), 3 dup(grSym, grSpc), 4 dup(grSym), grSpc, 0FBAh, space
		dw fieldSpacing, 4 dup(grSpc), grSym, grSpc, grSym, 2 dup(grSpc), grSym, grSpc, 4 dup(grSym), grSpc, 2 dup(grSym), 2 dup(grSpc), grSym, 4 dup(grSpc), 0FBAh, space
		dw fieldSpacing, grSpc, 4 dup(grSym), grSpc, grSym, 2 dup(grSpc), grSym, grSpc, grSym, 2 dup(grSpc), 3 dup(grSym, grSpc), 4 dup(grSym), grSpc, 0FBAh, space
		dw fieldSpacing, xSize - xField - 5 dup(grSpc), 0FBAh, space
delim1	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(0FCDh), 0FB9h, space
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
		dw xSize dup(space)
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