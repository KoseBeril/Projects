/*
 * display.asm
 *
 *  Created: 8.12.2025 23:32:18
 *   Author: koseb
 */ 

 
display: 
   
    rcall reset_digits
    mov  r16, r5
    rcall digit
    sbi  PORTD, PD3
 
    rcall reset_digits
    mov  r16, r6
    rcall digit
    sbi  PORTD, PD1

    rcall reset_digits
    mov  r16, r7
    rcall digit
    sbi  PORTD, PD0

    rcall reset_digits
    ret


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
 sbi portd, pd4; a 
 sbi portd, pd5; b 
 sbi portd, pd6; c 
 sbi portd, pd7; d 
 sbi portb, pb0; e 
 sbi portc, pc2; f 
 cbi portc, pc1; g 
ret 
 
one: 
 cbi portd, pd4; a 
 sbi portd, pd5; b 
 sbi portd, pd6; c 
 cbi portd, pd7; d 
 cbi portb, pb0; e 
 cbi portc, pc2; f 
 cbi portc, pc1; g 
ret 

two:
 sbi portd, pd4; a 
 sbi portd, pd5; b 
 cbi portd, pd6; c 
 sbi portd, pd7; d 
 sbi portb, pb0; e 
 cbi portc, pc2; f 
 sbi portc, pc1; g 
 ret

 three:
 sbi portd, pd4; a 
 sbi portd, pd5; b 
 sbi portd, pd6; c 
 sbi portd, pd7; d 
 cbi portb, pb0; e 
 cbi portc, pc2; f 
 sbi portc, pc1; g 
 ret

 four:
 cbi portd, pd4; a 
 sbi portd, pd5; b 
 sbi portd, pd6; c 
 cbi portd, pd7; d 
 cbi portb, pb0; e 
 sbi portc, pc2; f 
 sbi portc, pc1; g 
 ret

 five:
 sbi portd, pd4; a 
 cbi portd, pd5; b 
 sbi portd, pd6; c 
 sbi portd, pd7; d 
 cbi portb, pb0; e 
 sbi portc, pc2; f 
 sbi portc, pc1; g 
 ret

 six:
 sbi portd, pd4; a 
 cbi portd, pd5; b 
 sbi portd, pd6; c 
 sbi portd, pd7; d 
 sbi portb, pb0; e 
 sbi portc, pc2; f 
 sbi portc, pc1; g 
 ret

 seven:
 sbi portd, pd4; a 
 sbi portd, pd5; b 
 sbi portd, pd6; c 
 cbi portd, pd7; d 
 cbi portb, pb0; e 
 cbi portc, pc2; f 
 cbi portc, pc1; g 
 ret

 eight:
 sbi portd, pd4; a 
 sbi portd, pd5; b 
 sbi portd, pd6; c 
 sbi portd, pd7; d 
 sbi portb, pb0; e 
 sbi portc, pc2; f 
 sbi portc, pc1; g 
 ret

nine: 
 sbi portd, pd4; a 
 sbi portd, pd5; b 
 sbi portd, pd6; c 
 sbi portd, pd7; d 
 cbi portb, pb0; e 
 sbi portc, pc2; f 
 sbi portc, pc1; g 
ret
