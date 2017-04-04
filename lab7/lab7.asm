; Написать программу, последовательно запускающую программы, которые расположены в заданном каталоге. 

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

;Параметр 1: путь к требуемой папке
.model small

.stack 100h

.data
maxCMDSize equ 127
cmd_size db ?
cmd_text db maxCMDSize + 2 dup(0)
folderPath db maxCMDSize + 2 dup(0)

maxWordSize equ 50
buffer db maxWordSize + 2 dup(0)

spaceSymbol equ ' '
newLineSymbol equ 13
returnSymbol equ 10
tabulation equ 9

ASCIIZendl equ 0

startText db "Program is started", '$'
badCMDArgsMessage db "Bad command-line arguments. I want only 1 argument: folder path", '$'
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

runFile:
	call findNextFile
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call runEXE
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	jmp runFile

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
;end macro help


;Result in ax: 0 if all is good, else not
parseCMD PROC
	push bx cx dx

	mov cl, cmd_size
	xor ch, ch

	mov si, offset cmd_text
	mov di, offset buffer
	call rewriteAsASCIIZWord

	mov di, offset folderPath
	call rewriteAsASCIIZWord
	cmpWordLenWith0 folderPath, badCMDArgs

	mov di, offset buffer
	call rewriteAsASCIIZWord

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
rewriteAsASCIIZWord PROC
	push ax cx di
	
loopParseWord:
	mov al, ds:[si]
	cmp al, spaceSymbol
	je isStoppedSymbol

	cmp al, newLineSymbol
	je isStoppedSymbol

	cmp al, tabulation
	je isStoppedSymbol

	cmp al, returnSymbol
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

findNextFile PROC
	;todo
	ret
ENDP

runEXE PROC
	;todo
	mov ax, 1

	ret
ENDP

end main