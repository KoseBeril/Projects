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
	ldi R16,(1 << CS00) ; NO PRESCALER. Directly connected to the microcontrollers clock
	out TCCR0, R16
	ldi R16, (1 << TOIE0)
	out TIMSK, R16
.endmacro