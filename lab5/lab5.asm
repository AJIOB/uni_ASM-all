;удалить в строках файла все нечетные слова

;-------------------MACRO-----------------
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
;-----------------end macro----------------

;Параметр 1: путь к исходному файлу
;Параметр 2: путь к результирующему файлу
.model small

.stack 100h

.data
maxCMDSize equ 127
cmd_size db ?
cmd_text db maxCMDSize + 2 dup(0)
sourcePath db maxCMDSize + 2 dup('$')
destinationPath db maxCMDSize + 2 dup('$')

sourceID dw 0
destID dw 0

maxWordSize equ 50
buffer db maxWordSize + 2 dup(0)

delim equ ' '
newLineSymbol equ 13
tabulation equ 9

ASCIIZendl equ 0

startText db "Program is started", '$'
badCMDArgsMessage db "Bad command-line arguments. I want only 2 arguments: source path and destination path", '$'
badSourceText db "Cannot open source file", '$'
fileNotFoundText db "File not found", '$'
errorClosingSource db "Cannot close source file", '$'
errorClosingDest db "Cannot close destination file", '$'
endText db "Program is ended", '$'

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

	println startText

	call parseCMD
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call openFiles
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call processingFile
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call closeFiles
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

endMain:
	;exit
	println endText

	mov ah, 4Ch
	int 21h

;MACRO HELP
cmpWordLenWith0 MACRO textline, is0Marker
	push si
	mov si, offset textline
	call strlen
	pop si
	cmp ax, 0
	je is0Marker
ENDM

;bx - ID файла
resetPosInFileToStart MACRO
	push ax bx cx dx

	mov ah, 42h
	xor al ,al 			;mov al, 0 - отсчет сначала
	xor cx, cx
	xor dx, dx			;на 0 байт относительно будет смещаться
	int 21h

	pop dx cx bx ax
ENDM
;end macro help


;Result in ax: 0 if all is good, else not
parseCMD PROC
	push bx cx dx

	mov cl, cmd_size
	xor ch, ch

	mov si, offset cmd_text
	mov di, offset buffer
	call readWord

	mov di, offset sourcePath
	call readWord

	cmpWordLenWith0 sourcePath, badCMDArgs

	mov di, offset destinationPath
	call readWord

	cmpWordLenWith0 destinationPath, badCMDArgs

	mov di, offset buffer
	call readWord

	cmpWordLenWith0 buffer, argsIsGood

badCMDArgs:
	println badCMDArgsMessage
	mov ax, 1

	jmp endproc

argsIsGood:
	mov ax, 0

endproc:
	pop dx cx bx
	ret	
ENDP

;ds:si - offset, where needed ASCIIZ string is located
;RES: ax - length
strlen PROC
	push bx si
	xor ax, ax

startCalc:
	mov bl, ds:[si] 
	cmp bl, ASCIIZendl
	je endCalc

	inc si
	inc ax
	jmp startCalc
	
endCalc:
	pop si bx
	ret
ENDP

;ds:si - offset, where we will find (result stop will be in si too)
;es:di - offset, where word will be
;cx - maximum size of word (input)
;result will be ASCIIZ
readWord PROC
	push ax cx di
	
loopParseWord:
	mov al, ds:[si]
	cmp al, delim
	je isStoppedSymbol

	cmp al, newLineSymbol
	je isStoppedSymbol

	cmp al, tabulation
	je isStoppedSymbol

	cmp al, ASCIIZendl
	je isStoppedSymbol

	mov es:[di], al

	inc di
	inc si

	loop loopParseWord

isStoppedSymbol:
	mov al, ASCIIZendl
	mov es:[di], al
	inc si

	pop di cx ax
	ret
ENDP

;Result in ax: 0 if all is good, else not
openFiles PROC
	push bx dx
	;TODO

	;open source
	mov ah, 3Dh			;open source file
	mov al, 31h			;readonly, block write
	mov dx, offset sourcePath
	mov cl, 01h
	int 21h

	jb badOpenSource	;works when cf = 1

	mov sourceID, ax	;save file ID

	;open destination
	mov ah, 3Ch
	mov cx, 00h
	mov dx, offset destinationPath
	int 21h

	jb badOpenSource	;works when cf = 1

	mov destID, ax		;save file ID

	mov ax, 0			;return value
	jmp endOpenProc		;all is good

badOpenSource:
	println badSourceText
	cmp ax, 02h
	jne errorFound

	println fileNotFoundText

errorFound:
	mov ax, 1
endOpenProc:
	pop dx bx
	ret
ENDP

processingFile PROC
	push ax bx cx dx si di

	mov bx, sourceID
	resetPosInFileToStart

	mov bx, destID
	resetPosInFileToStart
	
	;TODO

	pop di si dx cx bx ax
	ret
ENDP

;Result in ax: 0 if all is good, else not
closeFiles PROC
	push bx cx

	xor cx, cx

	mov ah, 3Eh
	mov bx, sourceID
	int 21h

	jnb goodCloseOfSource		;cf = 0

	println errorClosingSource
	inc cx 			;now it is a counter of errors

goodCloseOfSource:
	mov ah, 3Eh
	mov bx, destID
	int 21h

	jnb goodCloseOfDest			;cf = 0

	println errorClosingDest
	inc cx 			;now it is a counter of errors

goodCloseOfDest:
	mov ax, cx 		;save number of errors

	pop cx bx
	ret
ENDP

end main