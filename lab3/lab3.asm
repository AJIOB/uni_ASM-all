;Ввести матрицу целых чисел размерностью 5x6 элементов. Найти произведение элементов столбцов


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

inSym MACRO
	mov ah, 01h
	int 21h
ENDM

printSym MACRO info
	mov ah, 02h
	mov dx, info
	int 21h
ENDM

newline MACRO
	push ax
    push dx
    printSym 0Ah
    printSym 0Dh
    pop dx
    pop ax
ENDM

println MACRO info
	push ax
	push dx

	mov ah, 09h
	mov dx, offset info
	int 21h

	;print new line
	mov dl, 10
	mov ah, 02h
	int 21h

	mov dl, 13
	mov ah, 02h
	int 21h

	pop dx
	pop ax
ENDM

printSpace MACRO
	mov ah, 02h
	mov dl, 20h
	int 21h
ENDM

;end macro help

.model small

.stack 100h

.data
	y equ 2;5
	x equ 3;6
	oneElemSize equ 2

	textIn db 'Input number$'
	textWordIsNotNum db 10,13,'Word is not number$'
	textNumOverflow db 10,13,'Number is so high/low$'
	textOriginal db 'Original matrix:$'
	
	matrix dw x*y dup(0)
	res dw x dup(0001h)

	textRes db 'Result:$'
.code

main:
	begin

	mov cx, x*y

	mov bx, offset matrix

	;jcxz to_close

inputLoop:

	println textIn

	call inputNumber

	cmp dx, 0
	je goodInput

;badInput:
	jmp inputLoop	


goodInput:
	mov word ptr [bx], ax
	add bx, oneElemSize

	loop inputLoop

;printOriginal:
	println textOriginal

	xor bx, bx	;номер строки
	mov cx, y

printOrigL1:
	push cx

	xor si, si 	;позиция в строке

	mov cx, x	
printOrigL2:
	mov ax, matrix [bx + si]

	call printNum	;show
	printSpace

	mov ax, matrix [bx + si]	;calculating
	imul res[si]
	jno noOverFlow

	mov ax, 0		;overflow - write 0

noOverFlow:
	mov res[si], ax	;writing results
	
	add si, oneElemSize

	loop printOrigL2

	newline
	add bx, oneElemSize*x
	pop cx
	loop printOrigL1


;printRes:
	println textRes

	mov bx, offset res
	mov cx, x

printLoop:
	mov ax, word ptr[bx]
	call printNum

	printSpace
	
	add bx, oneElemSize

	loop printLoop
	
to_close:

	endd

;procedure help

;result in ax
;dx will be:
;	0, if all is good
;	1, if is not digit 
;	2, if we have overflow
inputNumber PROC
	push bx

	xor bx, bx
	
checkSign:
	;TODO
	inSym
	cmp al, 2dh		;'-'
	je minus

	cmp al, 2bh		;'+'
	jne notSign

;plus:
	inSym

notSign:
	mov dx, 0001h
	push dx
	jmp next

minus:
	mov dx, -1
	push dx
	inSym

next:
	mov dx, 0000h
	push dx

	xor dx, dx

checkDigit:
	
	cmp al, 13		;'\n'
	je endlineIsInput

	;проверка на не цифру
	cmp al, 30h		;'0'
	jl pErrorNotDigit
	cmp al, 39h		;'9'
	jg pErrorNotDigit

	mov bl, al 		;сохраняем введенную цифру
	sub bl, 30h

	;добавление цифры
	pop ax
	mov dx, 10
	mul dx
	add ax, bx
	push ax

	mov bl, 80h			;chech for overflow
	and bl, ah
	cmp bl, 0
	jne pErrorOverflow

	inSym
	jmp checkDigit

endlineIsInput:
	;todo
	pop ax		;number
	pop bx		;sign
	imul bx

	xor dx, dx	;mov dx, 0
	jmp endOfProc

pErrorNotDigit:
	println textWordIsNotNum
	mov dx, 1

	jmp badEnd
	
pErrorOverflow:
	println textNumOverflow
	mov dx, 2

badEnd:
	pop ax	;number
	pop ax	;sign
	xor ax, ax

endOfProc:

	pop bx

	ret
ENDP

;input number in ax
printNum PROC
	push ax
	push bx
	push cx
	push dx

	xor cx, cx
	xor dx, dx
	cmp ax, 0
	jge noSign

	push ax
	printSym '-'
	pop ax
	mov dx, -1
	imul dx
	xor dx, dx

noSign:
	mov bx, 10
	div bx		;ax - результат, dx - остаток

	add dx, 30h	;'0'
	push dx		;будем хранить в стеке то, что выводить
	xor dx, dx

	inc cx

	cmp ax, 0
	jne noSign

	jcxz printResultEnd

printResult:
	pop dx
	printSym dx
	loop printResult

printResultEnd:
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
ENDP

;end procedure help

end main