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

.macro config_t0
	ldi r16, (1<< CS01 | 1<<CS00)
	out TCCR0, r16
	ldi r16, (1<<TOIE0)
	out TIMSK, r16
.endmacro

.macro config_t2
    ldi r16, (1<<CS22)|(1<<CS21)|(0<<CS20);timer sayaç hýzýný ayarlýyor
    out TCCR2, r16

    ; Timer2 overflow interrupt enable (TOIE2)
    in  r16, TIMSK
    ori r16, (1<<TOIE2)      ; Timer0 kullanýyorsan onun bitini silme, ORI ile ekle
    out TIMSK, r16
.endmacro




	