;
; beril_köse_lab4.asm
;
; Created: 25.11.2025 18:41:26
; Author : koseb
;


; Replace with your application code
.cseg
.org 0x0000 
rjmp on_reset 
.org 0x0004 
rjmp isr_t2
.org 0x0009
rjmp isr_t0

.include "macros.asm" 
.include "display.asm" 
.include "functions.asm"

isr_t0:
    
    cli
    ;ldi r16, 0x03
	mov r1, r15
    ;ldi r16, 0xB9 
	mov r2, r14 
    rcall conv_hextodec   
    rcall display          

    sei
reti
isr_t2:
    ; İstersen SREG + kullanılan register'ları push et
    ; ama step_count zaten r16,r17'yi koruyor

    rcall step_count
    ; ; how do you change counting speed ?
    ; ? burada config_t2'deki prescaler/TCNT2 ile değiştirdiğini yazacaksın raporda

    reti

on_reset: 
   stackreg ; macro for spl and sph 
   config ; macro for input , output 
   config_t0
   config_t2
   clr r14
   clr r15
   sei

main: 
	nop 
	rjmp main

