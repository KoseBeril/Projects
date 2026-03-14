.macro stackreg
    ldi r16, LOW(RAMEND)
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16
.endmacro


.macro config
    ldi r16, 0xFF ; Ýþlemci resetlenince tüm port pinleri giriþ olur. Biz ise portlarý çýkýþ olarak ayarlamalýyýz.
    out DDRD, r16
    out DDRC, r16
    out DDRB, r16
.endmacro
