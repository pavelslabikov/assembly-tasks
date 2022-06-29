model   tiny
.code
org 100h
locals

SCREEN_WIDTH = 639
SCREEN_HEIGHT = 349
BUTTON_SIZE = 33

_start:
    call    init_screen
    mov     ax, offset draw_figure

    mov     ax, 0ch ;set mouse handler
    mov     cx, 23
    mov     dx, offset handle_mouse_event
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
    jz      releas
    call    handle_key
;left released?
releas:
    cmp     left_release, 0
    jz      continue
    mov     byte ptr cs:left_release, 0
    cmp     m_y, 316 ;check click on menu
    jl      chk_mode
    call    handle_bottom_menu 
chk_mode:
    cmp     m_y, 313
    jge     begin
    cmp     drawing_mode, 0
    je      begin
    call    draw_figure
    jmp     begin
continue:  
;left pushed?    
    cmp     left_push, 0
    jz      begin
    cmp     m_y, 313
    jge     begin
    cmp     drawing_mode, 4h
    je      begin
    call    draw_figure
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

draw_figure proc
    dec     m_x
    dec     m_y
    cmp     brush, 0
    je      @@sq
    call    print_circle
    jmp     @@exit
@@sq:
    call    draw_rect
@@exit:
    inc     m_x
    inc     m_y
    ret
draw_figure endp

init_screen proc
    mov     ax, 10h ; video mode
    int     10h
; okno risovanie - 650x312
    mov     m_x, SCREEN_WIDTH
    mov     m_y, 315
    mov     r_width, SCREEN_WIDTH
    mov     r_height, 3
    mov     r_color, 15
    call    draw_rect ; white line
    mov     byte ptr r_color, 0
    mov     cx, 16
    mov     r_width, BUTTON_SIZE
    mov     r_height, BUTTON_SIZE
    mov     ax, 32
    mov     m_y, 349
@@lp:
    push    cx
    mov     m_x, ax
    call    draw_rect
    pop     cx
    inc     r_color
    add     ax, BUTTON_SIZE
    mov     m_y, 349
    loop    @@lp
    
    mov     r_color, 7 ;save button
    call    draw_rect

    add     m_x, BUTTON_SIZE ;load button
    mov     r_color, 2
    call    draw_rect
    call    draw_save_button
    call    draw_mode

    mov     ax, 1 ;show cursor
    int     33h
    mov     r_color, 0
    ret
init_screen endp
draw_save_button proc
    xor     bh, bh 
    mov     dl, 79 - 11
    mov     dh, 17h
    mov     ah, 2
    int     10h

    mov     ah, 9h
    mov     al, 53h
    mov     bl, 150
    mov     cx, 1
    int     10h

    mov     dl, 79 - 7
    mov     dh, 17h
    mov     ah, 2
    int     10h

    mov     al, 4ch
    mov     ah, 9h
    int     10h
    ret
draw_save_button endp
draw_mode proc
    xor     ah, ah
    mov     al, r_color
    push    ax
    push    r_height
    push    r_width
    mov     al, drawing_mode
    mov     r_color, al
    mov     m_x, 18 * BUTTON_SIZE + 2
    mov     m_y, 349
    mov     r_width, 4
    mov     r_height, BUTTON_SIZE
    call    draw_rect
    pop     r_width
    pop     r_height
    pop     ax
    mov     r_color, al
    ret
draw_mode endp
;handle key event
handle_key proc  
    xor     ax, ax
    int     16h
    cmp     ah, 48h
    je      incr_h
    cmp     ah, 50h
    je      decr_h
    cmp     ah, 4bh
    je      incr_w
    cmp     ah, 4dh
    je      decr_w
    cmp     ah, 39h
    je      refresh
    cmp     ah, 02h
    je      ch_mode
    cmp     ah, 03h
    je      ch_brush
    jmp     @@exit
incr_h:
    cmp     r_height, 32
    jge     @@exit
    add     r_height, 2
    mov     al, r_color
    call    change_color
    ret
decr_h:
    cmp     r_height, 4
    jle     @@exit
    mov     al, r_color
    push    ax
    xor     al, al
    call    change_color
    sub     r_height, 2
    pop     ax
    call    change_color
    ret
incr_w:
    cmp     r_width, 32
    jge     @@exit
    add     r_width, 2
    mov     al, r_color
    call    change_color
    ret
decr_w:
    cmp     r_width, 4
    jle     @@exit
    mov     al, r_color
    push    ax
    xor     al, al
    call    change_color
    sub     r_width, 2
    pop     ax
    call    change_color
    ret
refresh:
    mov     ax, 4h
    int     10h
    call    init_screen
    ret 
ch_mode:
    call    change_drawing_mode
    call    draw_mode
    ret
ch_brush:
    mov     al, r_color
    push    ax
    xor     al, al
    call    change_color
    call    change_brush
    pop     ax
    call    change_color
@@exit:
    ret
handle_key endp
;switch to rect or romb
change_brush proc
    cmp     brush, 1
    je      @@square
    mov     brush, 1
    ret
@@square:
    mov     brush, 0
    ret
change_brush endp
;draw rectangle
draw_rect proc
    push    ax
    push    bx
    push    cx
    mov     cx, m_x
    mov     dx, m_y
    mov     al, byte ptr r_color
    mov     ah, 0ch
    mov     bh, 0

    mov     di, r_height
    push    r_width
    cmp    cx, 0 ;bug fix of out of bounds drawing
    jle      @@exit
    cmp     cx, r_width 
    jge     lp_o
    mov     r_width, cx
lp_o:
    mov     si, r_width
    lp_i:
        int     10h
        dec     cx
        dec     si
        cmp     si, 0
        jg      lp_i
    add     cx, r_width
    dec     dx
    dec     di
    cmp     di, 0
    jnz     lp_o
@@exit:
    pop     r_width
    pop     cx
    pop     bx
    pop     ax
    ret
draw_rect endp

print_circle proc
    push    r_width
    push    r_height
    push    m_x
    push    m_y
    mov     cx, 2
    mov     ax, r_width
    div     cl
    xor     ah, ah
    mov     cl, al
    push    cx
    mov     r_height, 1
    mov     r_width, 1
    mov     ax, m_x
    mov     bx, m_y
    
@@lp1:
    mov     m_x, ax
    mov     m_y, bx
    call    draw_rect
    add     r_width, 2
    inc     ax
    dec     bx
    loop    @@lp1

    pop     cx
    inc     cx

@@lp2:
    mov     m_x, ax
    mov     m_y, bx
    call    draw_rect
    sub     r_width, 2
    dec     ax
    dec     bx
    loop    @@lp2
    
    pop     m_y
    pop     m_x
    pop     r_height
    pop     r_width
    ret
print_circle endp

handle_mouse_event:
    test    ax, 16 ;right clicked?
    jz      chck_pushed
    mov     byte ptr cs:right_click, 1
    jmp     ex2
chck_pushed:
    test    ax, 2 ;left pushed?
    jz      chck_released
    mov     byte ptr cs:left_push, 1
    jmp     save_pos
chck_released:
    test    ax, 4 ;left released?
    jz      chck_pos
    mov     byte ptr cs:left_push, 0
    mov     byte ptr cs:left_release, 1
    jmp     save_pos
chck_pos:
    test    ax, 3 ;position changed+left push?
    jz      ex2
save_pos:
    mov     m_x, cx
    mov     m_y, dx
ex2:
    retf

handle_bottom_menu proc
    xor     dx, dx
    mov     ax, m_x
    mov     cx, 33
    div     cx
    cmp     ax, 16 ;color button pressed?
    jge     @@continue
    call    change_color
    ret
@@continue:
    cmp     ax, 16 
    je      @@save_bmp
    cmp     ax, 17 
    je      @@load_bmp
    ret
@@save_bmp:
    call    create_bmp
    call    get_filename
    call    rename_file
    call    init_screen
    call    read_bmp
    ret
@@load_bmp:
    call    get_filename
    call    init_screen
    call    read_bmp
    ret
handle_bottom_menu endp

change_color proc
    mov     r_color, al
    cmp     brush, 0
    je      @@sq
    mov     m_x, SCREEN_WIDTH - BUTTON_SIZE / 2
    mov     m_y, 349
    call    print_circle
    ret
@@sq:
    mov     m_x, SCREEN_WIDTH
    mov     m_y, 349
    call    draw_rect
    ret
change_color endp

change_drawing_mode proc
    cmp     drawing_mode, 0
    je      @@dot
    mov     drawing_mode, 0
    ret
@@dot:
    mov     drawing_mode, 4h
    ret
change_drawing_mode endp

get_filename proc
    mov     ax, 3 ;video mode
    int     10h
    mov     di, offset filename ;clear filename buffer
    xor     ax, ax
    mov     cx, 20
    rep     stosb
    mov     di, offset filename
@@begin:
    xor     ax, ax ;wait for input
    int     16h
    cmp     ah, 1ch ;enter pressed?
    je      @@exit
    stosb
    push    di
    mov     ah, 0ah ;print character
    xor     bx, bx
    mov     cx, 1
    int     10h    
    mov     ah, 3 ;get cursor pos
    int     10h  
    inc     dl ;increment cursor pos  
    mov     ah, 2
    int     10h
    pop     di 
    jmp     @@begin
@@exit:    
    ret
get_filename endp

create_bmp proc
    mov     ah, 3ch ;create file
    xor     cx, cx
    mov     dx, offset tmp_name
    int     21h
    mov     bx, ax
    
    mov     ah, 40h ;write headers
    mov     dx, offset bfType
    mov     cx, 118
    int     21h

    mov     cx, 9
    mov     dx, 312
@@lp:    
    push    cx
    call    save_screen
    push    dx

    mov     ah, 40h
    mov     dx, offset buffer
    mov     cx, 11200
    int     21h

    pop     dx
    pop     cx
    loop    @@lp

    mov     ah, 3eh ;close
    int     21h
    ret
create_bmp endp

save_screen proc ; save 35 lines to buffer starting from dx (bottom to top)
    push    bx
    mov     di, offset buffer
    xor     bh, bh
    mov     cx, 35
@@lp_o:
    push    cx
    xor     cx, cx
    @@lp_i:
        mov     ah, 0dh
        int     10h
        inc     cx
        shl     al, 4
        mov     curr_pixel, al
        
        mov     ah, 0dh
        int     10h
        inc     cx
        or      al, curr_pixel
        stosb
        cmp     cx, 639
        jl      @@lp_i
    dec     dx
    pop     cx
    loop    @@lp_o
@@exit:
    pop     bx
    ret
save_screen endp

read_bmp proc
    xor     al, al
    mov     ah, 3dh ;get file handler
    xor     cx, cx 
    mov     dx, offset filename
    int     21h

    mov     bx, ax
    mov     al, 0 ;seek from start of file
    mov     ah, 42h 
    xor     cx, cx
    mov     dx, 118
    int     21h

    mov     cx, 9 
    mov     curr_row, 312
@@lp:
    push    cx
    mov     ah, 3fh ;read from file to buffer
    mov     cx, 11200
    mov     dx, offset buffer
    int     21h
    call    write_to_screen
    pop     cx
    loop    @@lp

    mov     ah, 3eh ;close
    int     21h
    ret
read_bmp endp

rename_file proc
    mov     ah, 56h
    mov     dx, offset tmp_name
    mov     di, offset filename
    int     21h
    ret
rename_file endp

write_to_screen proc
    push    bx
    mov     si, offset buffer
    mov     cx, 35
@@lp_o:
    push    cx
    xor     cx, cx
    @@lp_i:
        mov     bx, 10
        lodsb
        xor     ah, ah
        
        shl     ax, 4
        mov     bl, al
        mov     al, ah
        xor     bh, bh
        mov     ah, 0ch
        mov     dx, curr_row
        int     10h
        inc     cx

        mov     al, bl
        shr     al, 4
        mov     ah, 0ch
        xor     bh, bh
        int     10h
        inc     cx

        cmp     cx, 639
        jl      @@lp_i
    dec     curr_row
    pop     cx
    loop    @@lp_o
@@exit:
    pop     bx
    ret
write_to_screen endp

drawing_mode db 0h ;4 - dot
brush db 0; 0-square, 1-romb
m_x dw 0
m_y dw 0
right_click db 0
left_push db 0
left_release db 0

r_width    dw 0
r_height   dw 0
r_color      db 15

curr_pixel db 0
curr_row dw 0
filename    db 20 dup(0)
tmp_name db "tmp.bmp", 0

; BITMAPFILEHEADER = 14 bytes
bfType dw 4d42h ; BM
bfSize dd 112118 ;razmer file total
bfReserved dw 0, 0
bfOffBits dd 118 ;nachalo massiva pixelei
; BITMAPINFOHEADER = 40 bytes
biSize dd 40 ;razmer zagolovka
biWidth dd 640 
biHeight dd 313
biPlanes dw 1
biBitCount dw 4 ;bits for pixel
biCompression dd 0 ; no compression
biSizeImage dd 0 ; because no compression
biXpels dd 3780 ;?
biYpels dd 3780 ;?
biClrUsed dd 16 ;kol-vo colors
biClrImp dd 0 ;all important
; palette = 64 bytes BGR
black db 0, 0, 0, 0 
blue db 169, 0, 0, 0
green db 0, 168, 0, 0
cyan db 168, 170, 0, 0
red db 0, 0, 169, 0 
violet db 169, 0, 169, 0 
brown db 0, 85, 168, 0 
white db 170, 170, 170, 0
gey db 85, 85, 85, 0
br_blue db 254, 84, 85, 0 
br_green db 85, 253, 85, 0 
br_cyan db 255, 255, 85, 0 
br_red db 84,84,254, 0 
br_violet db 255, 86, 255, 0 
yellow db 85, 255, 255, 0 
br_white db 255, 255, 255, 0 
buffer db   11200 dup(?)
end _start