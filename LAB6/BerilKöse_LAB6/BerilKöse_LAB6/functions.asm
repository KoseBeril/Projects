/*
 * functions.asm
 *
 *  Created: 8.12.2025 23:32:28
 *   Author: koseb
 */ 
 EEPROM_read:
	sbic EECR,EEWE ; Wait for completion of previous write 
	rjmp EEPROM_read ; Set up address (r18:r17) in address register 
	out EEARH, r18 
	out EEARL, r17 
	sbi EECR,EERE ; Start eeprom read by writing EERE
	in r19,EEDR  ; Read data from data register 
ret 

EEPROM_write: 
	sbic EECR, EEWE  
	rjmp EEPROM_write ; Wait for completion of previous write 
	out EEARH, r18 ; Set up address (r18:r17) in address register 
	out EEARL, r17  
	out EEDR, r19 ; Write data (r16) to data register 
	sbi EECR, EEMWE ; Write logical one to EEMWE 
	sbi EECR, EEWE ; Start eeprom write by setting EEWE 
ret 


 conv_hextodec:   ; SUBROUTINE OF CONVERSION 
 ldi   r16,  HIGH(10000)   ; SET THE DECIMAL DIVIDER TO 10.000 DECIMAL  
 mov   r4,  r16 
 ldi   r16,  LOW(10000)  
 mov   r3,  r16 
 rcall DEC_DIG   ; GET DIGIT BY REPETEAD SUBTRACTION  
 mov   r9,  r16  ; SET TEN THOUNSANDS DIGIT 
 
 ldi   r16,  HIGH(1000) ; SET THE DECIMAL DIVIDER TO 1.000 DECIMAL  
 mov   r4,  r16 
 ldi   r16,  LOW(1000)  
 mov   r3,  r16 
 rcall DEC_DIG   ; GET DIGIT BY REPETEAD SUBTRACTION 
 mov   r8,  r16  ; SET THOUNSANDS DIGIT 
 
 clr   r4   ; SET THE DECIMAL DIVIDER TO 100 DECIMAL  
 ldi   r16,  100 
 mov   r3,  r16 
 rcall DEC_DIG   ; GET DIGIT BY REPETEAD SUBTRACTION 
 mov   r7,  r16  ; SET HUNDREDS DIGIT 
 
 ldi   r16,  10  ; SET THE DECIMAL DIVIDER TO 10 DECIMAL  
 mov   r3,  r16 
 rcall DEC_DIG   ; GET DIGIT BY REPETEAD SUBTRACTION 
 mov   r6,  r16  ; SET TENS DIGIT 
 
 ldi  r16, 0 
 add  r16, r2 
 mov  r5,  r16   ; SET ONES DIGIT  
 ret 
 
DEC_DIG: 
 ldi  r16,  0   ; START WITH DECIMAL VALUE 0  
DEC_DIG1: 
 cp    r2,  r3   ; COMPARE WORD WITH DECIMAL DIVIDER VALUE  
 cpc   r1,  r4 
 brcc  DEC_DIG2  ; IF CARRY CLEAR, SUBTRACT DIVIDER VALUE  
 ret    ; DONE SUBTRACTION 
DEC_DIG2: 
 sub   r2,  r3   ; SUBTRACT DIVIDER VALUE  
 sbc   r1,  r4 
 inc   r16   ; UP ONE DIGIT 
rjmp  DEC_DIG1  ; ONCE AGAIN 
	


step_count:
    ; (r15:r14) = (current value)

    ; 16-bit increment
    ldi  r16, 1
    add  r14, r16
    clr  r16
    adc  r15, r16

    ; Compare with 1000 (0x03E8)
    ldi  r16, low(1000)   ; 0xE8  //low, 16 -->24
    ldi  r17, high(1000)  ; 0x03  // high, 14 -->25
    cp   r14, r16
    cpc  r15, r17

    brlo step_done        ; current < 1000 ? çýk
    breq step_done        ; current == 1000 ? çýk

    ; current > 1000 ? wrap
    clr r14
    clr r15

step_done:
    ret
