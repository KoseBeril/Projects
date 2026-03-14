/*
 * macros.asm
 *
 *  Created: 9.12.2025 19:59:43
 *   Author: koseb
 */ 
 /*
 * macros.asm
 *
 *  Created: 8.12.2025 23:32:52
 *   Author: koseb
 */ 
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

.macro config_io
;PORTD
    ; PD2 = input (buton, pull-up)
    ; PD0, PD1, PD3, PD4, PD5, PD6, PD7 = output (digit + segment)
    ldi r16, 0b11111011          ; PD2 = 0 (input), diðerleri 1 (output)
    out DDRD, r16

    ldi r16, (1<<PD2)            ; PD2 için pull-up(button)
    out PORTD, r16
;PORTB
    ; PB0 = output (segment e), PB2 = input (buton, pull-up)
    ldi r16, (1<<PB0)            ; sadece PB0 output
    out DDRB, r16

    ldi r16, (1<<PB2)            ; PB2 pull-up(button)
    out PORTB, r16

.endmacro

.macro _read_set 
	ldi r17,0x01 
	ldi r18,0x00 
	rcall EEPROM_read 
	mov r14,r19 
 
	 ldi r17,0x02 
	ldi r18,0x00 
	rcall EEPROM_read 
	mov r15,r19 
.endmacro 


.macro macro_display
	mov r1, @1
	mov r2, @0 
    rcall conv_hextodec   
    rcall display 
.endmacro 


.macro _save_set
    ; r14 -> EEPROM 0x0001
    ldi r17, 0x01
    ldi r18, 0x00
    mov r19, @0
    rcall EEPROM_write

    ; r15 -> EEPROM 0x0002
    ldi r17, 0x02
    ldi r18, 0x00
    mov r19, @1
    rcall EEPROM_write
.endmacro

.macro check_eeprom

    _read_set ;makrosu 
	
    ;  kontrol et
	mov r16, r14
    cpi r16, 0xFF
    brne chk_done
	mov r16, r15
    cpi r16, 0xFF
    brne chk_done

    ;0 yaz
    ldi r17, 0x01
    ldi r18, 0x00
    ldi r19, 0x00
    rcall EEPROM_write

    ldi r17, 0x02
    ldi r18, 0x00
    ldi r19, 0x00
    rcall EEPROM_write

    clr r14
    clr r15

	chk_done:

.endmacro




