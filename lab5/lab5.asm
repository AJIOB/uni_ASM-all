;удалить в строках файла все нечетные слова

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

maxWordSize equ 50
buffer db maxWordSize + 2 dup(0)

delim equ ' '
newLineSymbol equ 13
tabulation equ 9

ASCIIZendl equ 0

badCMDArgsMessage db "Bad command-line arguments. I want only 2 arguments: source path and destination path", 10, 13, '$'

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

	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call openFiles
	call processingFile
	call closeFiles

	;mov ah, 09h
	;mov dx, offset destinationPath
	;int 21h

endMain:
	;exit
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
	mov ah, 09h
	mov dx, offset badCMDArgsMessage
	int 21h
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