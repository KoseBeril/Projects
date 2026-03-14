;
; BerilKose_Lab2.asm
;
; Created: 11.11.2025 16:53:43
; Author : koseb
;


; Replace with your application code

.org 0x0000 
	rjmp on_reset 
.org 0x0009 
	rjmp isr_t0 

.include "macros.asm" 
.include "display.asm" 

isr_t0:  
	cli 
	ldi r16, 9
	mov r5, r16
	ldi r16, 5
	mov r6, r16
	ldi r16, 3
	mov r7, r16
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