
;R5=FIRST DIGIT R6=SECOND DIGIT R7=THIRD DIGIT
display:
	mov r16, r7          
	rcall digit
	sbi portd, pd0 ; digit3 cathode
	rcall reset_digits

	mov r16, r6  
	rcall digit
	sbi portd, pd1 ; digit2 cathode
	rcall reset_digits

	mov r16, r5  
	rcall digit
	sbi portd, pd3 ; digit1 cathode
	rcall reset_digits
ret

; compare section
digit:
    cpi r16, 0
    breq label_zero
    cpi r16, 1
    breq label_one
    cpi r16, 2
    breq label_two
    cpi r16, 3
    breq label_three
    cpi r16, 4
    breq label_four
    cpi r16, 5
    breq label_five
    cpi r16, 6
    breq label_six
    cpi r16, 7
    breq label_seven
    cpi r16, 8
    breq label_eight
    cpi r16, 9
    breq label_nine
ret


reset_digits:
	cbi portd, pd3; digit1 cathode
	cbi portd, pd1; digit2 cathode
	cbi portd, pd0; digit3 cathode
ret

label_zero:
	rcall zero
ret

label_one:
	rcall one
ret

label_two:
	rcall two
ret

label_three:
	rcall three
ret

label_four:
	rcall four
ret

label_five:
	rcall five
ret

label_six:
	rcall six
ret

label_seven:
	rcall seven
ret

label_eight:
	rcall eight
ret

label_nine:
	rcall nine
ret

; print segments section
; zero segment given below
zero:
    sbi PORTD, PD4
    sbi PORTD, PD5
    sbi PORTD, PD6
    sbi PORTD, PD7
    sbi PORTB, PB0
    sbi PORTC, PC2
    cbi PORTC, PC1
	cbi PORTC, PC0

ret

one:
    cbi PORTD, PD4
    sbi PORTD, PD5
    sbi PORTD, PD6
    cbi PORTD, PD7
    cbi PORTB, PB0
    cbi PORTC, PC2
    cbi PORTC, PC1
	cbi PORTC, PC0

ret

two:
    sbi PORTD, PD4
    sbi PORTD, PD5
    cbi PORTD, PD6
    sbi PORTD, PD7
    sbi PORTB, PB0
    cbi PORTC, PC2
    sbi PORTC, PC1
	cbi PORTC, PC0

ret

three:
    sbi PORTD, PD4
    sbi PORTD, PD5
    sbi PORTD, PD6
    sbi PORTD, PD7
    cbi PORTB, PB0
    cbi PORTC, PC2
    sbi PORTC, PC1
	cbi PORTC, PC0

ret

four:
    cbi PORTD, PD4
    sbi PORTD, PD5
    sbi PORTD, PD6
    cbi PORTD, PD7
    cbi PORTB, PB0
    sbi PORTC, PC2
    sbi PORTC, PC1
	cbi PORTC, PC0

ret

five:
    sbi PORTD, PD4
    cbi PORTD, PD5
    sbi PORTD, PD6
    sbi PORTD, PD7
    cbi PORTB, PB0
    sbi PORTC, PC2
    sbi PORTC, PC1
	cbi PORTC, PC0

ret

six:
    sbi PORTD, PD4
    cbi PORTD, PD5
    sbi PORTD, PD6
    sbi PORTD, PD7
    sbi PORTB, PB0
    sbi PORTC, PC2
    sbi PORTC, PC1
	cbi PORTC, PC0

ret

seven:
    sbi PORTD, PD4
    sbi PORTD, PD5
    sbi PORTD, PD6
    cbi PORTD, PD7
    cbi PORTB, PB0
    cbi PORTC, PC2
    cbi PORTC, PC1
	cbi PORTC, PC0

ret

eight:
    sbi PORTD, PD4
    sbi PORTD, PD5
    sbi PORTD, PD6
    sbi PORTD, PD7
    sbi PORTB, PB0
    sbi PORTC, PC2
    sbi PORTC, PC1
	cbi PORTC, PC0

ret

nine:
    sbi PORTD, PD4
    sbi PORTD, PD5
    sbi PORTD, PD6
    sbi PORTD, PD7
    cbi PORTB, PB0
    sbi PORTC, PC2
    sbi PORTC, PC1
	cbi PORTC, PC0

ret