;Написать резидентную программу «будильник». Время срабатывания будильника и длительность сигнала передать при запуске программы.

;-------------------------macro-help------------------------------
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
;--------------------------end-macro------------------------------

;Параметры 1, 2, 3: время начала (часы, минуты, секунды)
;Параметры 4, 5, 6: длительность (часы, минуты, секунды)
.model tiny

.code
	org 100h

main:
	call parseCMD
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	call setHandler
	cmp ax, 0
	jne endMain				;Какая-то ошибка - выход

	;todo: resident end

endMain:
	;exit
	mov ah, 4Ch
	int 21h

;interrupt
handler PROC
	;todo: write
ENDP

;data
startHour db 0
startMinutes db 0
startSeconds db 0

durationHour db 0
durationMinutes db 0
durationSeconds db 0

badCMDArgsMessage db "Bad command-line arguments. I want only 6 arguments: start time (hour, minute, second) and duration time (hour, minute, second)", '$'

isAlarmOn db 0

wakeUpText 	dw 40 dup(4020h)
			dw 40 dup(4020h)
			dw 40 dup(4020h)
			dw 40 dup(4020h)
			dw 40 dup(4020h)
			dw 40 dup(4020h)
			dw 40 dup(4020h)

offWakeUp	dw 40 dup(0020h)
			dw 40 dup(0020h)
			dw 40 dup(0020h)
			dw 40 dup(0020h)
			dw 40 dup(0020h)
			dw 40 dup(0020h)
			dw 40 dup(0020h)

programLength equ $ - main

;one-time procedures

;Result in ax: 0 if all is good, else not
parseCMD PROC
	push bx cx dx si di

	mov si, 80h
	mov cl, [si]
	xor ch, ch

	xor ax, ax
	xor dx, dx
	mov si, 81h
	mov di, offset startHour

parseCMDloop:
	mov dl, [si]
	cmp dl, ' '
	je SpaceIsFound

	cmp dl, '0'
	jl badCMDArgs
	cmp dl, '9'
	jg badCMDArgs

	mov bl, 10
	mul bl
	add ax, dx

	cmp ax, 60
	jae badCMDArgs				;ja - jump after
	cmp ax, 24
	jae testIsHour

	loop parseCMDloop

SpaceIsFound:
	;todo
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
	println badCMDArgsMessage
	mov ax, 1

	jmp endproc

argsIsGood:
	mov ax, 0

endproc:
	pop di si dx cx bx
	ret	
ENDP

;	Return:
setHandler PROC
	push bx
	;todo

	pop bx
	ret
ENDP

.stack 100h

end main