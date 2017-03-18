;удалить в строках файла все нечетные слова

;Параметр 1: путь к исходному файлу
;Параметр 2: путь к результирующему файлу
.model small

.stack 100h

.data
maxSize equ 127
cmd_size db ?
cmd_text db maxSize+2 dup('$')
sourcePath db maxSize dup(0)
destinationPath db maxSize dup(0)
	
.code

main:
	mov ax, @data
	mov es, ax

	xor ch, ch
	mov cl, ds:[80h]			;ds еще стоит на начале PSP
	mov cmd_size, cl 		;сохраняем размер строки
	mov si, 81h
	mov di, offset cmd_text
	rep movsb
	;теперь в cmd_text то, что было записано в командную строку
	;а в cmd_size - размер

	mov ds, ax

	call parseCMD
	call openFiles
	call processingFile
	call closeFiles

endMain:
	;exit
	mov ah, 4Ch
	int 21h

parseCMD PROC
	;TODO
	ret
ENDP

openFiles PROC
	;TODO
	ret
ENDP

processingFile PROC
	;TODO
	ret
ENDP

closeFiles PROC
	;TODO
	ret
ENDP

end main