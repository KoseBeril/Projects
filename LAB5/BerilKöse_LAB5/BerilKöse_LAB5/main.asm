
; Replace with your application code
.cseg
.org 0x0000 
rjmp on_reset 
.org 0x0004 
rjmp isr_t2
.org 0x0009
rjmp isr_t0

.def prevPIND = r18
.def prevPINB = r19
.def curPIND  = r20
.def curPINB  = r21
.def temp     = r22
.def temp2    = r23

.include "macros.asm" 
.include "display.asm" 
.include "functions.asm"

isr_t0:
    
    cli
	mov r1, r15
	mov r2, r14 
    rcall conv_hextodec   
    rcall display          
	ldi r16, 220
	out tcnt0, r16
    sei
reti


isr_t2:
	nop
reti


on_reset: 
   stackreg    
   config  
   config_io              
   config_t0                
   config_t2                 

   clr r14                   ; sayaç low = 0
   clr r15                   ; sayaç high = 0

   ; prevPIND = ilk PIND değeri
   in  prevPIND, PIND

   ; prevPINB = ilk PINB değeri
   in  prevPINB, PINB

   sei

main:

    rcall delay_small  

    in  curPIND, PIND
    in  curPINB, PINB


    mov temp, curPIND
    com temp
    and temp, prevPIND
    ldi temp2, (1<<PD2) ; PD2 falling edge var mı 
    and temp, temp2
    breq no_inc_main; yoksa atla

    ldi temp2, 255 ;sayaç 255 değilse arttır
    cp  r14, temp2
    breq no_inc_main ;sayaç 255 se arttırma
    inc r14 ;sayaç 255 değilse arttır

no_inc_main:

    mov temp, curPINB
    com temp
    and temp, prevPINB 
    ldi temp2, (1<<PB2); PB2 falling edge var mı (1->0)
    and temp, temp2 ;falling edge yoksa azalma yapma 
    breq no_dec_main

    tst r14
    breq no_dec_main
    dec r14

no_dec_main:

    ; PD2 low?
    ldi temp, (1<<PD2) ; buton basılı mı 
    and temp, curPIND
    brne not_both_main ; değilse önceki kalsın

    ; PB2 low?
    ldi temp, (1<<PB2) ; buton basılı mı 
    and temp, curPINB
    brne not_both_main ; değilse önceki kalsın

    ; → r14:r15 = 100
    ldi temp,  low(100)
    mov r14,   temp
    ldi temp,  high(100)
    mov r15,   temp

not_both_main:

    ; Prev değerlerini güncelle
    mov prevPIND, curPIND
    mov prevPINB, curPINB

rjmp main

;küçük bir delay:
delay_small:
    ldi r24, 100
d1:
    dec r24
    brne d1
    ret
