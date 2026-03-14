
; A-PD4, B-PD5, C-PD6, D-PD7, E-PB0, F-PC2, G-PC1, DP-PC0
; DIGIT1 CATHODE-PD3
; DIGIT2 CATHODE-PD1
; DIGIT3 CATHODE-PD0
; LED FOR PWM-PB1
; PB2-BUTON WITH EXTERNAL PULL-UP RESISTANCE
; PD2-BUTON (INT0) WITHOUT EXTERNAL PULL-UP RESISTANCE

.org 0x0000
	rjmp on_reset
.org 0x0004
	rjmp isr_t2
.org 0x0009            
    rjmp isr_t0
.org 0x000E
	rjmp isr_adc

.include "macros.asm"
.include "display.asm"
.include "functions.asm"

isr_t0:

	push r16           
    in r16, SREG     
    push r16           

	sbrs r29, 0       
    rjmp show_adc     
    rjmp show_set_value

show_adc:
    macro_display r24, r25  
    rjmp end_isr_t0

show_set_value:
    macro_display r14, r15  
    rjmp end_isr_t0

end_isr_t0:
    ldi r16, 220
    out tcnt0, r16          ; brightness control
    pop r16               
    out SREG, r16      
    pop r16             
    reti         

reti                 

isr_t2:
    nop
reti

isr_adc:
	cli
	in r24, ADCL
	in r25, ADCH
	sbi ADCSRA, ADSC
	sei
reti

on_reset:
	clr r14             
    clr r15         
	clr r16   

	stackreg	; macro for spl and sph
	config_io	; macro for input , output 
	config_t0   ; macro for timer0 setup
	;config_t2   ; macro for timer2 setup
	_check_eeprom ;check eeprom location and read content of location in r14 and r15

	config_adc
	clr r29

	sei
	rjmp main

main: 
    sbi adcsra, adsc    ; START CONVERSION
    
    rcall STARTUP       ; BOTH PORTB2 AND PORTD2 PRESSED

    sbis pinb, pinb2    ; IF PORTB2 PIN PRESSED, CALL ARTIR
    rcall ARTIR
    sbic pinb, pinb2    ; IF PORTB2 PIN UN-PRESSED, CLEAR R30
    cbr r30, 1
    
    rcall delay_sec    

    sbis pind, pind2    ; IF PORTD2 PIN PRESSED, CALL AZALT
    rcall AZALT
    sbic pind, pind2    ; IF PORTD2 PIN UN-PRESSED, CLEAR R31
    cbr r31, 1

    rcall delay_sec
    rjmp main

STARTUP:
    sbic pinb, pinb2    
    ret                 
    sbic pind, pind2    
    ret                 
    rcall delay_sec    
    sbrs r29, 0         
    rjmp set_goster     
    rjmp adc_goster    

set_goster:
    _read_set           
    sbr r29, 1          
    
loop_release_set:
    sbis pinb, pinb2
    rjmp loop_release_set
    sbis pind, pind2
    rjmp loop_release_set
ret

adc_goster:
    _save_set r15, r14  
    cbr r29, 1          
    
loop_release_adc:
	sbis pinb, pinb2
    rjmp loop_release_adc
    sbis pind, pind2
    rjmp loop_release_adc
 ret

ARTIR:
    sbrs r29, 0         
    ret
    sbrc r30, 0         
    ret
    inc r14             
    sbr r30, 1          
    ret

AZALT:
    sbrs r29, 0        
    ret
    sbrc r31, 0         
    ret
    dec r14             
    sbr r31, 1          
    ret

; debounce delay
delay_sec:
    ldi r20, 20
d1: ldi r21, 255
d2: dec r21
    brne d2
    dec r20
    brne d1
    ret
