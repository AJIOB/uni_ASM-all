
begin MACRO
	mov ax, @data	;init
	mov ds, ax
ENDM

endd MACRO
	mov ax, 4c00h
	int 21h
ENDM

print MACRO
	mov ah, 09h
	mov dx, offset text
	int 21h
ENDM