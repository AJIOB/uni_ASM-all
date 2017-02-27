;Заменить слова в строке, являющиеся числами, на слово number

;include HELP.INC

;macro HELP

begin MACRO
	mov ax, @data	;init
	mov ds, ax

	xor ax, ax
ENDM

endd MACRO
	mov ax, 4c00h
	int 21h
ENDM

newline MACRO
	push ax
	push dx

	mov dl, 10
	mov ah, 02h
	int 21h

	mov dl, 13
	mov ah, 02h
	int 21h

	pop dx
	pop ax
ENDM

print MACRO info
	push ax
	push dx

	;newline

	mov ah, 09h
	mov dx, offset info
	int 21h

	pop dx
	pop ax
ENDM

println MACRO info
	push ax
	push dx

	;newline

	mov ah, 09h
	mov dx, offset info
	int 21h

	newline

	pop dx
	pop ax
ENDM

;s - string
;len - string max length
input MACRO s;, len
	push ax
	push dx

	;помещаем длину строки в строку
	mov s, 48

	;ввод строки
	mov ax, 0A00h
	mov dx, offset s
	int 21h

	newline

	pop dx
	pop ax
ENDM
;end macro help

.model small

.stack 100h

.data
	stringSize equ 50
	newWord db 'number$'

	source db stringSize dup('$')
	destination db 2*stringSize dup('$')
	textIn db 'Input text with numbers$'
	textRes db 'Result$'

	len equ 0
.code

main:
	begin

	println textIn

	input source

	call operateWithString

	println textRes

	println destination

	endd

;procedure help
operateWithString PROC
	push ax
	push cx

	;cx

	pop cx
	pop ax

	ret
ENDP
;end procedure help

end main