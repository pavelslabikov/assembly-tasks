model   tiny
.code
org 100h
locals
_start:
;video mode
    mov     ax, 4h
    int     10h
;show cursor
    mov     ax, 1
    int     33h
;set handler
    mov     ax, 0ch
    mov     cx, 20
    mov     dx, offset handle_event
    int     33h

begin:
    hlt
;right clicked?
    cmp     right_click, 0
    jnz     exit
;keyboard?
    xor     ax, ax
    mov     ah, 1
    int     16h
    call    handle_key

;left clicked?    
    cmp     left_click, 0
    jz      begin
    call    print_square
    mov     byte ptr cs:left_click, 0
    jmp     begin

exit:
;remove handler
    mov     ax, 0ch
    xor     cx, cx
    int     33h 
;video mode
    mov     ax, 3
    int     10h
    ret

handle_key:  
    jz      ext
    xor     ax, ax
    int     16h
    cmp     ah, 48h
    je      incr
    cmp     ah, 50h
    je      decr
    jmp     ext
incr:
    cmp     sq_size, 100
    jge     ext
    add     sq_size, 2
    ret
decr:
    cmp     sq_size, 2
    jle     ext
    sub     sq_size, 2
    ret
ext:
    ret

print_square:
;1 px = 2 bits, 320x200, 80x200 bytes
    mov     si, offset position
    lodsw
    mov     cx, ax
    lodsw
    mov     dx, ax
    mov     al, byte ptr color
    mov     ah, 0ch
    mov     bh, 0

    mov     di, sq_size
    dec     cx
    dec     dx
lp_o:
    mov     si, sq_size
    lp_i:
        push    ax
        push    si
        push    di
        int     10h
        pop     di
        pop     si
        pop     ax

        dec     cx
        dec     si
        cmp     si, 0
        jnz     lp_i
    add     cx, sq_size
    dec     dx
    dec     di
    cmp     di, 0
    jnz     lp_o
    ret

handle_event:
;right clicked?
    test    ax, 10h
    jz      chck_left
    mov     byte ptr cs:right_click, 1
    jmp     ex2
;left clicked?
chck_left:
    test    ax, 4h
    jz      ex2
    mov     byte ptr cs:left_click, 1
save_pos: 
    mov     di, offset position
    shr     cx, 1
    mov     ax, cx
    stosw
    mov     ax, dx
    stosw
ex2:
    retf

position    dw 0, 0
right_click db 0
left_click db 0
sq_size    dw 5
color      db 1
end _start