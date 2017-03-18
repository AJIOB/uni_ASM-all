;удалить в строках файла все нечетные слова

.model small

.stack 100h

.data

.code

main:
	mov ax, @data	;init
	mov ds, ax
	mov es, ax
	xor ax, ax

to_close:

	;exit
	mov ah, 4ch
	int 21h

end main