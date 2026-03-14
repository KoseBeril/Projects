/*
 * functions.asm
 *
 *  Created: 18.11.2025 19:26:57
 *   Author: koseb
 */ 

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
	ldi  r16,  0   ; START WITH DECIMAL VALUE 0 // Counter for digits
DEC_DIG1: 
	cp    r2,  r3   ; COMPARE WORD WITH DECIMAL DIVIDER VALUE  
	cpc   r1,  r4   ; if r1:r2 >= r4:r3 then carry clear = SUBSTRACT in DEG_DIG2
	; if r1:r2 < r4:r3 set r16 for digit(sayýnýn o basamaðýnýn deðeri) and take r1:r2 as remainder, return with ret
	;kýsaca bu satýr çýkarma iþlemi yapýlabilmesi için r1:r2 >= r4:r3 koþulunu arýyor
	brcc  DEC_DIG2  ; IF CARRY CLEAR, SUBTRACT DIVIDER VALUE  
	ret    ; DONE SUBTRACTION 
DEC_DIG2: 
	sub   r2,  r3   ; SUBTRACT DIVIDER VALUE  
	sbc   r1,  r4 ;sbc= Rd <- Rd -Rr -C
	inc   r16   ; UP ONE DIGIT (çýkarma sonrasý bir bit daha bulundu)
	rjmp  DEC_DIG1  ; ONCE AGAIN 