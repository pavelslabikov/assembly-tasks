model   tiny
.code
org 100h
locals
_start:
    
    xor     ax, ax
    int     16h
    mov     bx, ax
    mov     cx, 10h

    xor     ah, ah
    div     cl
    cmp     al, 10
    sbb     al, 69h
    das
    mov byte ptr offset msg + 3, al
    xchg    al, ah
    cmp     al, 10
    sbb     al, 69h
    das
    mov byte ptr offset msg + 4, al

    xor     ah, ah
    mov     al, bh
    div     cl
    cmp     al, 10
    sbb     al, 69h
    das
    mov byte ptr offset msg, al
    xchg    al, ah
    cmp     al, 10
    sbb     al, 69h
    das
    mov byte ptr offset msg + 1, al
    
    cmp     bl, 20h
    jb      special
    mov byte ptr offset msg + 6, bl
    mov byte ptr offset msg + 7, 20h
    mov byte ptr offset msg + 8, 20h
    jmp     print
special:
    xor     ax, ax
    mov byte ptr al, bl
    mov     cl, 3h
    mul     cl
    
    xchg    bx, dx
    mov     bx, offset spec
    add     bx, ax
    mov word ptr    ax, ds:[bx]
    mov word ptr    offset msg + 6, ax
    mov byte ptr    al, ds:[bx + 2]
    mov byte ptr    offset msg + 8, al
    xchg    bx, dx

print:

    mov     dx, offset msg
    mov     ah, 9
    int     21h

    cmp     bh, 1
    jnz     _start
    ret


msg     db "__", 9, "__", 9, "   ", 0d, 0ah, 24h
spec    db "NUL", "SOH", "STX", "ETX", "EOT", "ENQ", "ACK", "BEL", "BS ", "HT ", "LF ", "VT ", "FF ", "CR ", "SO ", "SI ", "DLE", "DC1", "DC2", "DC3", "DC4", "NAK", "SYN", "ETB", "CAN", "   ", "SUB", "ESC", 5 dup("   ")
end _start