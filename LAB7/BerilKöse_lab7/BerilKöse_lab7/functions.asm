
conv_hextodec: ; SUBROUTINE OF CONVERSION
	ldi r16, HIGH(10000) ; SET THE DECIMAL DIVIDER TO 10.000 DECIMAL
	mov r4, r16
	ldi r16, LOW(10000)
	mov r3, r16
	rcall DEC_DIG ; GET DIGIT BY REPETEAD SUBTRACTION
	mov r9, r16 ; SET TEN THOUNSANDS DIGIT
	ldi r16, HIGH(1000) ; SET THE DECIMAL DIVIDER TO 1.000 DECIMAL
	mov r4, r16
	ldi r16, LOW(1000)
	mov r3, r16
	rcall DEC_DIG ; GET DIGIT BY REPETEAD SUBTRACTION
	mov r8, r16 ; SET THOUNSANDS DIGIT
	clr r4 ; SET THE DECIMAL DIVIDER TO 100 DECIMAL
	ldi r16, 100
	mov r3, r16
	rcall DEC_DIG ; GET DIGIT BY REPETEAD SUBTRACTION
	mov r7, r16 ; SET HUNDREDS DIGIT
	ldi r16, 10 ; SET THE DECIMAL DIVIDER TO 10 DECIMAL
	mov r3, r16
	rcall DEC_DIG ; GET DIGIT BY REPETEAD SUBTRACTION
	mov r6, r16 ; SET TENS DIGIT
	ldi r16, 0
	add r16, R1
	mov r5, r16 ; SET ONES DIGIT
	ret
DEC_DIG:
	ldi r16, 0 ; START WITH DECIMAL VALUE 0
DEC_DIG1:
	cp r1, r3 ; COMPARE WORD WITH DECIMAL DIVIDER VALUE
	cpc r2, r4
	brcc DEC_DIG2 ; IF CARRY CLEAR, SUBTRACT DIVIDER VALUE
	ret ; DONE SUBTRACTION
DEC_DIG2:
	sub r1, r3 ; SUBTRACT DIVIDER VALUE
	sbc r2, r4
	inc r16 ; UP ONE DIGIT
	rjmp DEC_DIG1 ; ONCE AGAIN

step_count:
	; R15 = High Byte, R14 = Low Byte
    inc r14			             
    brne check_limit    
    inc r15             

check_limit:
    ; check if r15:r14 == 1000 (0x03E8)
    
	mov r16, r15
    cpi r16, high(0x03E8)
    brne exit_step     
    
	mov r16, r14
    cpi r16, low(0x03E8)
    brne exit_step      

    ; reset to 0 if r15:r14 >= 1000
    clr r14
    clr r15

exit_step:
    ret

EEPROM_read:
	sbic EECR,EEWE ; Wait for completion of previous write
	rjmp EEPROM_read
	out EEARH, r18 ; Set up address (r18:r17) in address register
	out EEARL, r17
	sbi EECR,EERE ; Start eeprom read by writing EERE
	in r16,EEDR ; Read data from data register
ret

EEPROM_write:
	sbic EECR, EEWE
	rjmp EEPROM_write ; Wait for completion of previous write
	out EEARH, r18 ; Set up address (r18:r17) in address register
	out EEARL, r17
	out EEDR, r16 ; Write data (r16) to data register
	sbi EECR, EEMWE ; Write logical one to EEMWE
	sbi EECR, EEWE ; Start eeprom write by setting EEWE
ret