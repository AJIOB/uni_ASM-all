;Заменить слова в строке, являющиеся числами, на слово number

;include HELP.INC

;macro HELP

begin MACRO
	mov ax, @data	;init
	mov ds, ax
	mov es, ax

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

writeNewWord MACRO
	push si
	push cx

	mov cx, 6
	lea si, newWord

	rep movsb

	pop cx
	pop si
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

	;len db 1
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
operateWithString PROC near
	push ax
	push bx
	push cx
	push si
	push di

	cld		;очистка флага направления (двигаемся слева направо)

	mov cx, [offset source + 1]

	;начальная инициализация позиции начала source & destination строк
	mov si, offset source + 2
	mov di, offset destination

	jcxz end_loop

start_loop:
	
skip_spaces:

	;пропускаем один символ пробела
	cmp [di], 20h	; space symbol ' '

	jne check_wordIsNum		;не пробел - значит символ (началось новое слово)

	movsb
	loop skip_spaces

	jcxz end_loop

check_wordIsNum:
	mov bx, di 		;backup начала слова

	cmp [di], 30h	;zero symbol '0'
	jl wordIsNotNum

	cmp [di], 39h	;nine symbol '9' 
	jg wordIsNotNum
	
	;loop start_loop

wordIsNotNum:
	

end_loop:

	pop di
	pop si
	pop cx
	pop bx
	pop ax

	ret
ENDP
;end procedure help

end main