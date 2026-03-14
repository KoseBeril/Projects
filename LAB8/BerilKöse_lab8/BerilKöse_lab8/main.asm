.org 0x0000
rjmp RESET

.include "macros.asm"
RESET:
	stackreg
    ; LED -> PB1 OUTPUT
    sbi DDRB, PB1
    cbi PORTB, PB1

    ; USART Double Speed
    ldi r16, (1<<U2X)
    out UCSRA, r16

    ; Baud Rate = 9600  U2X = 1
    ldi r16, 51
    out UBRRL, r16
    clr r16
    out UBRRH, r16

    ; Enable RX and TX
    ldi r16, (1<<RXEN) | (1<<TXEN)
    out UCSRB, r16

    ; Async, 8-bit, no parity, 1 stop
    ldi r16, (1<<URSEL) | (1<<UCSZ1) | (1<<UCSZ0)
    out UCSRC, r16

    ; READY message
    ldi r17, 'R'
    rcall TRANSMIT
    ldi r17, 'E'
    rcall TRANSMIT
    ldi r17, 'A'
    rcall TRANSMIT
    ldi r17, 'D'
    rcall TRANSMIT
    ldi r17, 'Y'
	rjmp MAIN

MAIN:
    sbis UCSRA, RXC
    rjmp MAIN

    in r17, UDR

    ; '?' -> HELP
    cpi r17, '?'
    breq HELP_MSG

    ; LED CONTROL
    cpi r17, '1'
    breq LED_ON
    cpi r17, '0'
    breq LED_OFF

    ; lowercase -> uppercase
    cpi r17, 'a'
    brlo SEND_CHAR
    cpi r17, 123        ; 'z'+1
    brsh SEND_CHAR
    subi r17, 32

SEND_CHAR:
    rcall TRANSMIT
    rjmp MAIN

LED_ON:
    sbi PORTB, PB1
    rjmp SEND_CHAR

LED_OFF:
    cbi PORTB, PB1
    rjmp SEND_CHAR


HELP_MSG:
    rcall TRANSMIT
    ldi r17, 'H'
    rcall TRANSMIT
    ldi r17, 'E'
    rcall TRANSMIT
    ldi r17, 'L'
    rcall TRANSMIT
    ldi r17, 'P'
    rjmp MAIN

TRANSMIT:
    sbis UCSRA, UDRE
    rjmp TRANSMIT
    out UDR, r17
    ret