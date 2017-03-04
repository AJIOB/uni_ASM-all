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
input MACRO s, leng
	push ax
	push dx

	;помещаем длину строки в строку
	mov s, leng

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

;compare [si] and second
compareb MACRO second
	push bx

	mov bx, [si]
	cmp bl, second

	pop bx
ENDM
;end macro help

.model small

.stack 100h

.data
	stringSize equ 200
	newWord db 'number$'

	source db stringSize dup('$')
	destination db 6*stringSize dup('$')
	textIn db 'Input text with numbers$'
	textRes db 'Result$'

	;len equ 48
.code

main:
	begin

	println textIn

	input source, stringSize-2

	call operateWithString

	println textRes

	println destination

	endd

;procedure help
operateWithString PROC near
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	cld		;очистка флага направления (двигаемся слева направо)

	;инициализируем счетчик
	mov bx, offset source
	mov cl, [bx + 1]
	mov ch, 00h

	;начальная инициализация позиции начала source & destination строк
	mov si, offset source + 2
	mov di, offset destination

	jcxz end_loop

start_loop:
	
skip_spaces:

	;пропускаем один символ пробела
	compareb 20h	; space symbol ' '

	jne check_wordIsNum		;не пробел - значит символ (началось новое слово)

	movsb
	loop skip_spaces

	jmp end_loop

check_wordIsNum:
	mov dx, cx 		;backup счетчика
	mov bx, si 		;backup начала слова source

loop_check_wordIsNum:
	compareb 30h	;zero symbol '0'
	jl check_space

	compareb 39h	;nine symbol '9' 
	jg check_space	;

	inc si

	loop loop_check_wordIsNum
	
	jmp wordIsNum 	;закончилась строка и не было выходов из цикла - значит в конце число

check_space:
	compareb 20h	; space symbol ' '

	jne wordIsNotNum	;не пробел и не цифра - значит это не число

wordIsNum:
	writeNewWord

	jcxz end_loop		;дошли до конца строки - выход

	jmp start_loop		;не дошли до конца строки

wordIsNotNum:
	mov si, bx		;восстанавливаем позицию начала слова
	mov cx, dx		;восстановить счетчик (как будто мы и не проверяли)

loop_wordIsNotNum:
	compareb 20h	; space symbol ' '

	je skip_spaces		;пробел - значит всё переписали

	movsb
	loop loop_wordIsNotNum

	jmp end_loop

end_loop:

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP
;end procedure help

end main