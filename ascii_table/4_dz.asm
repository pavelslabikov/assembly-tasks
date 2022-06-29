model   tiny
.code
org 100h
locals
; 4 + 32 + 2 = 38 symbols from beginning , 14 instructions
_start:
    mov     ax, 3
    int     10h

    mov     ax, 0b800h
    mov     es, ax
    mov     di, 480+40
    mov     si, 1e00h
;-----
    mov     ax, 1ec9h
    mov     cx, 1ed1h
    mov     dx, 1ecdh
    mov     bp, 1ebbh
    call    print
;-----
    mov     ax, 1ebah
    stosw
    mov     ax, si
    stosw
    mov     ax, 1eb3h
    stosw
    mov     ax, si
    stosw

    mov     ax, 1e30h
    mov     cx, 16
lp:
    cmp     al, 3ah
    jne      n2
    add byte ptr    al, 7h
n2:
    stosw     
    inc     ax
    xchg     ax, si
    stosw
    xchg     ax, si
    loop    lp     

    mov     es:[di], 1ebah
    add     di, 160-74+2
;-----
    mov     ax, 1ecch
    mov     cx, 1ec5h
    mov     dx, 1ec4h
    mov     bp, 1eb6h
    call    print
; -----
    mov     ax, si
    xor     dx, dx
outer:
    mov     cx, 16

    mov     es:[di], 1ebah
    mov     es:[di+2], 1e30h
    add     es:[di+2], dx
    cmp     dx, 10
    jl      next
    add byte ptr    es:[di+2], 7
next:    
    mov     es:[di+4], 1eb3h

    mov     es:[di+6], si
    add     di, 8
    cycle:
        stosw
        inc     al
        mov     es:[di], si
        add     di, 2
        loop    cycle
    mov     es:[di], 1ebah
    
    add     di, 160-72
    inc     dx
    cmp     dx, 16
    jne     outer
    ;-----
    mov     ax, 1ec8h
    mov     cx, 1ecfh
    mov     dx, 1ecdh
    mov     bp, 1ebch
    call    print
;-----

    xor ax, ax
    int 16h
    ret

print:
    stosw
    xchg     ax, dx
    stosw
    xchg     ax, cx
    stosw
    xchg     ax, cx
    mov     cx, 33
    rep     stosw
    xchg     ax, bp
    stosw
    add     di, 160-74
    ret

end _start