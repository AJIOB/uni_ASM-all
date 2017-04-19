;Написать резидентную программу «будильник». Время срабатывания будильника и длительность сигнала передать при запуске программы.

;Параметры 1, 2, 3: время начала (часы, минуты, секунды)
;Параметры 4, 5, 6: длительность (часы, минуты, секунды)
.model tiny
.code
	org 100h

start:
	jmp main

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

;interrupt handler
handler PROC
	pushf
	;call previous handler
	call cs:intOldHandler
	push    ds
    push    es
	push    ax
	push    bx
    push    cx
    push    dx
	push    di

	push cs
	pop ds

;	02H ¦AT¦ читать время из "постоянных" (CMOS) часов реального времени
;   выход: CH = часы в коде BCD   (пример: CX = 1243H = 12:43)
;          CL = минуты в коде BCD
;          DH = секунды в коде BCD
;   выход: CF = 1, если часы не работают
	mov     ah,  2
	int     1Ah

	;mov ah, 2Ch
	;int 21h

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
	mov dl, 1
	mov isAlarmOn, dl

	jmp endHandler

stopCheck:
	

endHandler:

	pop     di
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	pop     es
	pop     ds	
	iret
ENDP

;	Input:
;		si: offset of printing info
printBanner PROC
	push es
	push 0B800h
	pop es

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

programLength:

;one-time procedures

;Result in ax: 0 if all is good, else not
parseCMD PROC
	push bx cx dx si di

	cld
	mov bx, 80h
	mov cl, [bx]
	xor ch, ch

	xor dx, dx
	mov di, 81h

	;skip spaces at beginning
	mov al, ' '
	repne scasb	
	;inc si
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
	mov byte ptr es:[di], al
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
	mov al, 1Ch
	int 21h

	;save old handler
	mov word ptr [offset intOldHandler], bx
	mov word ptr [offset intOldHandler + 2], es

	push ds			;restore old value of es
	pop es

	;set new handler
	mov ah, 25h
	mov al, 1Ch
	mov dx, offset handler
	int 21h

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

calcucateStopTime PROC
	;todo
	ret
ENDP

convertToBCD PROC
	mov cx, 6
	mov bl, 10
	mov si, offset startHour
convertLoop:
	xor ah, ah
	mov al, [si]
	div bl

	;частное - al, остаток - ah
	mov dl, al
	;сдвиг влево на 4
	shl dl, 4
	add dl, ah
	mov [si], dl

	inc si
	loop convertLoop
	
	ret
ENDP

main:
	call parseCMD
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call setHandler
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call calcucateStopTime

	call convertToBCD

	mov ah, 31h
	mov al, 0
	mov dx, (programLength - start + 100h) / 16 + 1
	int 21h

endMain:
	;bad exit
	ret

end start