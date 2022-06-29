model   tiny
.code
org 100h
locals
_start:
    mov     dx, offset buffer
    mov     dx, tail
    mov     dx, offset tail
    mov     ax, 0
    call    write_to_buf
    inc ax
    call    write_to_buf
    inc ax
    call    write_to_buf
    inc ax
    call    write_to_buf
    inc ax
    call    write_to_buf
    call    read_from_buf
    call    read_from_buf
    call    read_from_buf
    call    read_from_buf
    call    read_from_buf
    call    write_to_buf
    ;save old int
    push    ds
    mov     di, offset old_i
    xor     si, si
    mov     ds, si
    mov     si, 36
    movsw
    movsw
    pop     ds
    ;set new int
    push    es
    xor     di, di
    mov     es, di
    mov     di, 36
    mov     ax, offset my_int
    cli
    stosw
    mov     ax, cs
    stosw
    sti
    pop es

    call    begin
    ;return old int
    xor     di, di
    mov     es, di
    mov     di, 36
    mov     ax, word ptr old_i
    cli
    stosw
    mov     ax, word ptr old_i + 2
    stosw
    sti
    xor ax, ax
    int 16h
    ret

my_int:
    pushf
    push    ax
    push    di
    push    es
    in      al, 60h
    push    cs
    pop     es
    call    write_to_buf
    pop     es
    pop     di
    in      al, 61h
    mov     ah, al
    or      al, 80h
    out     61h, al
    xchg    ah, al
    nop
    nop
    out     61h, al
    mov     al, 20h
    out     20h, al
    pop     ax
    popf
    iret

begin:
    xor     ax, ax
    hlt
    call    read_from_buf
    cmp     al, 0
    je      begin
    mov     bl, al
    ;convert to ascii
    mov     cx, 10h
    xor     ah, ah
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
    ;print
    mov     dx, offset msg
    mov     ah, 9
    int     21h
    cmp     bl, 0b9h
    jne     nn
    mov     dx, offset separ
    mov     ah, 9
    int     21h
nn:
    cmp     bl, 81h
    jne     begin
    ret

write_to_buf: ; offset - адрес, иначе то что внутри 
    push    bx
    push    di
    mov     bx, tail
    ; заполнен ли буфер
    inc     bx
    cmp     bx, head
    je      ex
    ; запись в буфер
    mov     di, tail
    stosb
    ; не надо ли закольцевать?
    cmp     bx, offset bufend
    jl     store
    mov     bx, offset buffer
store:
    mov     tail, bx
ex:
    pop     di
    pop     bx
    ret

read_from_buf:
    push    bx
    xor     al, al
    mov     bx, head
    cmp     bx, tail
    je      exr
    mov     si, head
    lodsb
    cmp     bx, offset bufend
    jge     circ2
    inc     bx
    jmp     exr
circ2:
    mov     bx, offset buffer
exr:
    mov     head, bx
    pop     bx
    ret


buffer  db      15 dup(0)
bufend:
head    dw      offset buffer
tail    dw      offset buffer

old_i   dd      0, 0
msg     db "__", 0d, 0ah, 24h
separ   db 6 dup("-"), 0d, 0ah, 24h
end _start
