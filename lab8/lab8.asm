;Написать резидентную программу «будильник». Время срабатывания будильника и длительность сигнала передать при запуске программы.

;Параметры 1, 2, 3: время начала (часы, минуты, секунды)
;Параметры 4, 5, 6: длительность (часы, минуты, секунды)
.model tiny
.386		;pusha, popa
.code
PSPstart:
	org 80h

cmd_len db ?
cmd_text db ?

	org 100h

main:
	call parseCMD
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call setHandler
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	;todo: add calculation of stop*

	mov ah, 31h
	mov al, 0
	mov dx, programLength/16 + 1

endMain:
	;exit
	mov ah, 4Ch
	int 21h

;interrupt handler
handler PROC far
	pusha
	push ds
	push es

	push es
	push 0B800h
	pop es
	mov word ptr es:[0], 4020h
	pop es

	mov ah, 34h
	int 21h

	mov ah, es:[bx]
	cmp ah, 0
	jne endHandler
	mov ah, es:[bx-1]
	cmp ah, 0
	jne endHandler

	push es
	push 0B800h
	pop es
	mov word ptr es:[0], 4020h
	pop es

	mov ah, 2Ch
	int 21h

	;проверка на возможность включения будильника
	cmp ch, startHour
	jne stopCheck
	cmp cl, startMinutes
	jne stopCheck
	cmp dh, startSeconds
	jne stopCheck
	
	;определяем текущее состояние будильника
	mov dl, isAlarmOn
	cmp dl, 0
	jne stopCheck

	;here => start alarm
	mov si, offset wakeUpText
	call printBanner
	
	jmp endHandler

stopCheck:
	;проверка на возможность выключения будильника
	cmp ch, stopHour
	jne endHandler
	cmp cl, stopMinutes
	jne endHandler
	cmp dh, stopSeconds
	jne endHandler
	
	;определяем текущее состояние будильника
	mov dl, isAlarmOn
	cmp dl, 1
	jne endHandler

	;here => stop alarm
	mov si, offset offWakeUp
	call printBanner

endHandler:
	pop es
	pop ds
	popa

	;call previous handler
	jmp far ptr intOldHandler
ENDP

;	Input:
;		si: offset of printing info
printBanner PROC
	push es
	push 0B800h
	pop es

	mov di, 9*allWidth*2 + (allWidth - widthOfBanner)

	mov cx, 7
loopPrintBanner:
	push cx

	mov cx, widthOfBanner
	rep movsw

	add di, 2*(allWidth - widthOfBanner)

	pop cx
	loop loopPrintBanner

	pop es
	ret
ENDP

;data
startHour db 0
startMinutes db 0
startSeconds db 0

durationHour db 0
durationMinutes db 0
durationSeconds db 0

stopHour db 0
stopMinutes db 0
stopSeconds db 0

badCMDArgsMessage db "Bad command-line arguments. I want only 6 arguments: start time (hour, minute, second) and duration time (hour, minute, second)", '$'

isAlarmOn db 0

widthOfBanner equ 40
allWidth equ 80
wakeUpText 	dw widthOfBanner dup(4020h)
			dw widthOfBanner dup(4020h)
			dw widthOfBanner dup(4020h)
			dw widthOfBanner dup(4020h)
			dw widthOfBanner dup(4020h)
			dw widthOfBanner dup(4020h)
			dw widthOfBanner dup(4020h)

offWakeUp	dw widthOfBanner dup(0020h)
			dw widthOfBanner dup(0020h)
			dw widthOfBanner dup(0020h)
			dw widthOfBanner dup(0020h)
			dw widthOfBanner dup(0020h)
			dw widthOfBanner dup(0020h)
			dw widthOfBanner dup(0020h)

intOldHandler dd 0



;one-time procedures

;Result in ax: 0 if all is good, else not
parseCMD PROC
	push bx cx dx si di

	cld
	mov cl, cmd_len
	xor ch, ch

	xor dx, dx
	mov di, offset cmd_text

	;skip spaces at beginning
	mov al, ' '
	repne scasb	
	inc si
	xor ax, ax

	mov si, di
	mov di, offset startHour

parseCMDloop:
	mov dl, [si]
	inc si
	cmp dl, ' '
	je SpaceIsFound

	cmp dl, '0'
	jl badCMDArgs
	cmp dl, '9'
	jg badCMDArgs

	sub dl, '0'
	mov bl, 10
	mul bl
	add ax, dx

	cmp ax, 60
	jae badCMDArgs				;ja - jump after
	cmp ax, 24
	jae testIsHour

	loop parseCMDloop

SpaceIsFound:
	mov [di], al
	cmp di, offset durationSeconds
	je argsIsGood

	inc di
	xor ax, ax

	loop parseCMDloop
	jmp argsIsGood

testIsHour:
	cmp si, offset startHour
	je badCMDArgs
	cmp si, offset durationHour
	je badCMDArgs
	
	loop parseCMDloop
	jmp SpaceIsFound

badCMDArgs:
	mov dx, offset badCMDArgsMessage
	call println
	mov ax, 1

	jmp endproc

argsIsGood:
	mov ax, 0

endproc:
	pop di si dx cx bx
	ret	
ENDP

;	Return:
;		ax: 0 if all is good, else not 
setHandler PROC
	push bx dx

	cli

	mov ah, 35h
	mov al, 08h
	int 21h

	;save old handler
	mov word ptr [offset intOldHandler], bx
	mov word ptr [offset intOldHandler + 2], es

	push ds			;restore old value of es
	pop es

	;set new handler
	mov ah, 25h
	mov dx, offset handler

	sti

	mov ax, 0

	pop dx bx
	ret
ENDP

newline PROC
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
	ret
ENDP

println PROC
	push ax
	push dx

	mov ah, 09h
	int 21h

	call newline

	pop dx
	pop ax
	ret
ENDP

programLength equ $ - PSPstart

end main