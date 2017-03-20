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
sourcePath db maxCMDSize + 2 dup(0)
destinationPath db maxCMDSize + 2 dup(0)

sourceID dw 0
destID dw 0

maxWordSize equ 50
buffer db maxWordSize + 2 dup(0)

spaceSymbol equ ' '
newLineSymbol equ 13
returnSymbol equ 10
tabulation equ 9

ASCIIZendl equ 0

startText db "Program is started", '$'
badCMDArgsMessage db "Bad command-line arguments. I want only 2 arguments: source path and destination path", '$'
badSourceText db "Cannot open source file", '$'
badDestText db "Cannot open destination file", '$'
fileNotFoundText db "File not found", '$'
errorClosingSource db "Cannot close source file", '$'
errorClosingDest db "Cannot close destination file", '$'
endText db "Program is ended", '$'
errorReadSourceText db "Error reading from source file", '$'
errorWritingDestText db "Error writing to destination file", '$'

period equ 2
currWordIndex db 1		;для того, чтобы удалялось, начиная с первого слова

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
;end macro help


;Result in ax: 0 if all is good, else not
parseCMD PROC
	push bx cx dx

	mov cl, cmd_size
	xor ch, ch

	mov si, offset cmd_text
	mov di, offset buffer
	call rewriteAsASCIIZWord

	mov di, offset sourcePath
	call rewriteAsASCIIZWord

	cmpWordLenWith0 sourcePath, badCMDArgs

	mov di, offset destinationPath
	call rewriteAsASCIIZWord

	cmpWordLenWith0 destinationPath, badCMDArgs

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

;Result in ax: 0 if all is good, else not
openFiles PROC
	push bx dx

	;open source
	mov ah, 3Dh			;open source file
	mov al, 00h			;readonly, block write, other cannot write
	mov dx, offset sourcePath
	mov cl, 01h
	int 21h

	jb badOpenSource	;works when cf = 1

	mov sourceID, ax	;save file ID

	;open destination
	mov ah, 3Ch
	mov cx, 01h
	mov dx, offset destinationPath
	int 21h

	jb badOpenDest		;works when cf = 1

	mov destID, ax		;save file ID

	mov ax, 0			;return value
	jmp endOpenProc		;all is good

badOpenSource:
	println badSourceText
	cmp ax, 02h
	jne errorFound

	println fileNotFoundText

	jmp errorFound

badOpenDest:
	println badDestText
	cmp ax, 02h
	jne errorFound

	println fileNotFoundText

errorFound:
	mov ax, 1
endOpenProc:
	pop dx bx
	ret
ENDP

;macro help processing

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

readFromFileAndCheckFinish MACRO
	call readFromFile
	cmp ax, 0
	je finishProcessing

	mov si, offset buffer
	mov di, offset buffer
	mov cx, ax					;save num of symbols in buffer
	xor dx, dx
ENDM

divCurrWordIndex MACRO
	mov al, currWordIndex
	xor ah, ah

	push bx
	mov bl, period
	div bl
	pop bx
	;ah - остаток, al - частное
	mov currWordIndex, ah

	cmp ah, 0
	je movToSkip
	jmp movToWrite

ENDM
;end macro help

processingFile PROC
	push ax bx cx dx si di

	mov bx, sourceID
	resetPosInFileToStart

	mov bx, destID
	resetPosInFileToStart
	
	readFromFileAndCheckFinish

loopProcessing:
	;dx - how much good symbols in buffer
	;TODO
writeDelimsAgain:
	call writeDelims
	add dx, bx
	call checkEndBuff
	cmp ax, 2
	je finishProcessing
	cmp ax, 1
	je writeDelimsAgain

	divCurrWordIndex

movToWrite:
	call writeWord
	add dx, bx
	call checkEndBuff
	cmp ax, 2
	je finishProcessing
	cmp ax, 1
	je movToWrite

	jmp endWriteSkip

movToSkip:
	call skipWord
	call checkEndBuff
	cmp ax, 2
	je finishProcessing
	cmp ax, 1
	je movToSkip

	jmp endWriteSkip

endWriteSkip:
	push dx
	mov dl, currWordIndex
	inc dl
	mov currWordIndex, dl 			;we skip/write one word
	pop dx

	;temp: close loop
	;jmp finishProcessing

	jmp loopProcessing

finishProcessing:
	mov cx, dx
	call writeToFile

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

;ds:si - offset to byte source (will change)
;es:di - offset to byte destination (will change)
;cx - max length (will change)
;bx - num of writing symbols
writeDelims PROC
	push ax
	xor bx, bx

startWriteDelimsLoop:
	mov al, ds:[si]
	cmp al, spaceSymbol
	je isDelim

	cmp al, tabulation
	je isDelim

	cmp al, newLineSymbol
	je isDelim

	cmp al, returnSymbol
	je isDelim

	jmp isNotDelim

isDelim:
	movsb
	inc bx
	loop startWriteDelimsLoop

isNotDelim:
	pop ax
	ret
ENDP

;ds:si - offset, where we will find (will change)
;es:di - offset, where word will be (will change)
;cx - maximum size of word (will change)
;bx - num of writing symbols
writeWord PROC
	push ax 
	xor bx, bx

loopParseWordWW:
	mov al, ds:[si]
	cmp al, spaceSymbol
	je isStoppedSymbolWW

	cmp al, newLineSymbol
	je isStoppedSymbolWW

	cmp al, tabulation
	je isStoppedSymbolWW

	cmp al, returnSymbol
	je isStoppedSymbolWW

	cmp al, ASCIIZendl
	je isStoppedSymbolWW

	movsb
	inc bx
	loop loopParseWordWW

isStoppedSymbolWW:
	pop ax
	ret
ENDP

;ds:si - offset, where we will find (will change)
;cx - maximum size of word (will change)
;bx - num of skipped symbols
skipWord PROC
	push ax
	xor bx, bx
	
loopParseWordSW:
	mov al, ds:[si]
	cmp al, spaceSymbol
	je isStoppedSymbolSW

	cmp al, newLineSymbol
	je isStoppedSymbolSW

	cmp al, tabulation
	je isStoppedSymbolSW

	cmp al, returnSymbol
	je isStoppedSymbolSW

	cmp al, ASCIIZendl
	je isStoppedSymbolSW

	inc si
	inc bx
	loop loopParseWordSW

isStoppedSymbolSW:
	pop ax
	ret
ENDP

;reads to buffer maxWordSize symbols
;RES: ax - how much symbols we read
readFromFile PROC
	push bx cx dx

	mov ah, 3Fh
	mov bx, sourceID
	mov cx, maxWordSize
	mov dx, offset buffer
	int 21h

	jnb goodRead					;cf = 0 - we read file

	println errorReadSourceText
	mov ax, 0

goodRead:
	pop dx cx bx
	ret
ENDP

;cx - size to write from begin of buffer
;RES: ax - number of writed bytes
writeToFile PROC
	push bx cx dx

	mov ah, 40h
	mov bx, destID
	mov dx, offset buffer
	int 21h

	jnb goodWrite					;cf = 0 - we read file

	println errorWritingDestText
	mov ax, 0

goodWrite:
	pop dx cx bx
	ret
ENDP

;save registers in required values
;RES:
;	ax = 0 - not end of buffer
;	ax = 1 - end of buffer
;	ax = 2 - end of processing
checkEndBuff PROC
	cmp cx, 0
	jne notEndOfBuffer

	cmp dx, 0
	je skipWrite

	mov cx, dx
	call writeToFile

skipWrite:
	call readFromFile
	cmp ax, 0
	je endOfProcessing

	mov si, offset buffer
	mov di, offset buffer
	mov cx, ax					;save num of symbols in buffer
	xor dx, dx

	mov ax, 1
	ret

endOfProcessing:
	mov ax, 2
	ret

notEndOfBuffer:
	mov ax, 0
	ret
ENDP

end main