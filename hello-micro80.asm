    ; 🐟 для Микро-80
    .tape rk-bin        ; формат ленты для wav
    .binfile hellom80.rk; имя файла
    .download tape      ; формат двоичного файла .rk
    ; .download bin     ; формат двоичного файла .bin без заголовков
    .org 0
prompt  equ 0F82Dh
puts    equ 0F818h

    lxi hl, msg
    call puts
    jmp prompt

msg:
    db 1fh,'priwet, mir!',0dh,0ah,0


