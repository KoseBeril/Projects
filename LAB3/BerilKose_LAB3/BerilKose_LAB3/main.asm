;
; BerilKose_LAB3.asm
;
; Created: 18.11.2025 19:25:34
; Author : koseb
;


; Replace with your application code

.org 0x0000 
	rjmp on_reset 
.org 0x0009 
	rjmp isr_t0 

.include "macros.asm" 
.include "display.asm" 
.include "functions.asm"
isr_t0:
	cli 
	ldi r16, 0x03    ; sayýnýn high byte’ý
	mov r1, r16
	ldi r16, 0xB9     ; sayýnýn low byte’ý
	mov r2, r16
	rcall conv_hextodec
	rcall display 
	sei 
reti 
on_reset: 
	stackreg 
	config 
	config_t0 
sei 

main: 
	nop 
	rjmp main 
