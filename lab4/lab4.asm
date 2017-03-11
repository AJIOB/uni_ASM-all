;Игра "Змейка"


;macro HELP
begin MACRO
	mov ax, @data	;init
	mov ds, ax
	mov es, ax

	xor ax, ax
ENDM

endd MACRO
	mov ah, 4ch
	int 21h
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

screen dw 0020h, 0010h, 0031h, 0032h, 0033h
.code

main:
	begin

;set video and clear monitor
	mov ax, 0003h
	int 10h

	call initField

	call mainGame

to_close:

	endd

;procedure help

initField PROC
	mov si, offset screen
	mov di, 0B800h

	mov cx, 5
	rep movsw
ENDP

mainGame PROC
	;todo
ENDP

;end procedure help

end main