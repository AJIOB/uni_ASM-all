; Написать программу, последовательно запускающую программы, которые расположены в заданном каталоге. 

;-------------------MACRO-----------------
newline MACRO
	push ax
	push dx

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

println MACRO info
	push ax
	push dx

	mov ah, 09h
	mov dx, offset info
	int 21h

	newline

	pop dx
	pop ax
ENDM

;	Input:
;		ax - error code
printErrorCode MACRO
	add al, '0'
	mov dl, al
	mov ah, 06h
	int 21h

	newline
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

DTAsize equ 2Ch
DTAblock db DTAsize dup(0)

maxWordSize equ 50
buffer db maxWordSize + 2 dup(0)

PathToRequredEXE db maxCMDSize + 15 dup(0)
newProgramCMD db 0

spaceSymbol equ ' '
newLineSymbol equ 13
returnSymbol equ 10
tabulation equ 9

ASCIIZendl equ 0

startText db "Program is started", '$'
badCMDArgsMessage db "Bad command-line arguments. I want only 1 argument: folder path", '$'
endText db "Program is ended", '$'
initToRunErrorText db "Bad init to run other programs. Error code: ", '$'
runEXEErrorText db "Error running other program. Error code: ", '$'

SegmentAddress dw 0
EPBstruct db 16h dup(0)

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

	call initDTA
	call initToRun
	
	;call findFirstFile
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call runEXE
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход
	jmp endMain				;temporary
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

;	Result
;		ax = 0 => all is good
;		ax != 0 => we have an error
runEXE PROC
	push bx dx

	mov ax, SegmentAddress
	mov word ptr EPBstruct, ax							;сегментный адрес окружения для дочернего процесса - текущее окружение
	mov word ptr EPBstruct + 02h, offset newProgramCMD			;адрес командной строки
	mov word ptr EPBstruct + 06h, ax					;адрес первого FCB для дочернего процесса
	mov word ptr EPBstruct + 0Ah, ax					;адрес второго FCB для дочернего процесса

	mov ax, 4B00h				;загрузить и выполнить
	mov dx, offset folderPath	;temporary, will be PathToRequredEXE
	mov bx, offset EPBstruct
	int 21h
	
	jnc runEXEAllGood

	printErrorCode
	println runEXEErrorText

	mov ax, 1

	jmp runEXEEnd

runEXEAllGood:
	mov ax, 0

runEXEEnd:
	pop dx bx
	ret
ENDP

findFirstFile PROC
	;todo
	ret
ENDP

initDTA PROC
	push ax dx

	mov ah, 1Ah
	mov dx, offset DTAblock
	int 21h

	pop dx ax
ret
ENDP

;	Result
;		ax = 0 => all is good
;		ax != 0 => we have an error
initToRun PROC
	push bx

	mov ah, 48h
	mov bx, 0FFFFh							;виделяем максимально доступный размер (на всякий случай)
	int 21h

	jnc initToRunAllGood

	println initToRunErrorText

	printErrorCode

	mov ax, 1

	jmp initToRunEnd

initToRunAllGood:
	mov SegmentAddress, ax
	mov ax, 0

initToRunEnd:
	pop bx
	ret
ENDP

end main