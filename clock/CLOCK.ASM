code    segment
        assume  cs:code,ds:code
        org     100h
start:  jmp     load
        old     dd  0
        buf     db  ' 00:00:00 ',0

decode  proc
        mov     ah,  al
        and     al,  15
        shr     ah,  4
        add     al,  '0'
        add     ah,  '0'
        mov     buf[bx + 1],  ah
        mov     buf[bx + 2],  al
        add     bx,  3
        ret
decode  endp

clock   proc
        pushf
        call    cs:old
        push    ds
        push    es
	push    ax
	push    bx
        push    cx
        push    dx
	push    di
        push    cs
        pop     ds

        mov     ah,  2
        int     1Ah

        xor     bx,  bx
        mov     al,  ch
        call    decode
        mov     al,  cl
        call    decode
        mov     al,  dh
        call    decode

        mov     ax,  0B800h
        mov     es,  ax
        xor     di,  di
        xor     bx,  bx
        mov     ah,  1Bh
@@1:    mov     al,  buf[bx]
        stosw
        inc     bx
        cmp     buf[bx],  0
        jnz     @@1

@@5:    pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     es
        pop     ds
        iret
clock   endp
end_clock:

load:   mov     ax,  351Ch
        int     21h
        mov     word ptr old,  bx
        mov     word ptr old + 2,  es
        mov     ax,  251Ch
        mov     dx,  offset clock
        int     21h
        mov     ax,  3100h
        mov     dx, (end_clock - start + 10Fh) / 16
        int     21h
code    ends
        end     start
