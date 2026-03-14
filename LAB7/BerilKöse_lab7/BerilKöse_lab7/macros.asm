
.macro stackreg
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
.endmacro

.macro config_io
    ; PORTD: PD0,1,3,4,5,6,7 as outputs 
	ldi r16, 0b11111011
	out DDRD, r16

    ; PORTB: PB0 as output
    ldi r16, 0b00000001
    out DDRB, r16

	; PORTC: PC0, PC1, PC2 outputs 
    ldi r16, 0b00000111
    out DDRC, r16

	sbi PORTD, 2        ; pull-up PD2 
    sbi PORTB, 2        ; pull-up PB2

	; Clear segment outputs
    out PORTC, r1

.endmacro

.macro config_t0
    ; CS = 001
    ldi r16, 0b00000010
    out TCCR0, r16
    ; TOIE0 = 1
    ldi r16, 0b00000001
    out TIMSK, r16
.endmacro

.macro config_t2
    ldi r16, 0b00000011
    out TCCR2, r16

    in r16, TIMSK
    ori r16, (1 << TOIE2) 
    out TIMSK, r16
.endmacro

.macro config_adc
    ; REFS1:0 = 01 
    ; MUX3:0  = 0011
    ldi r16, 0b11000011 
    out ADMUX, r16

    ; ADEN = 1
    ; ADSC = 0 
    ; ADFR = 1 
    ; ADIF = 0 
    ; ADIE = 1 
    ;ADPS2:0 = 111 (1/128)
    ldi r16, 0b10101111 
    out ADCSRA, r16
.endmacro

.macro macro_display
	mov r1, @0
	mov r2, @1       
	
	rcall conv_hextodec   
    rcall display    
	
.endmacro

.macro _read_set
	ldi r17,0x01
	ldi r18,0x00
	rcall EEPROM_read
	mov r14,r16
	ldi r17,0x02
	ldi r18,0x00
	rcall EEPROM_read
	mov r15,r16
.endmacro

.macro _save_set 
	ldi r17,0x01
	ldi r18,0x00
	mov r16, @1
	rcall EEPROM_write
	ldi r17,0x02
	ldi r18,0x00
	mov r16, @0
	rcall EEPROM_write
.endmacro

.macro _check_eeprom
    
    _read_set
    
    ; check low byte
	mov r16, r14
    cpi r16, 0xFF
    brne finished_check 
    
    ; check high byte
	mov r16, r15
    cpi r16, 0xFF
    brne finished_check 

    clr r14
    clr r15
    _save_set r15, r14 

finished_check:
.endmacro

