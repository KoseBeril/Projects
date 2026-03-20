/*
 * main.c
 *
 * Created: 3/16/2026 10:34:29 PM
 *  Author: koseb
 */ 

#include <xc.h>

#define F_CPU 4000000UL  // 4 MHz Crystal
#include <avr/io.h>
#include <util/delay.h>

// Output Pin Definitions
#define RELAY1 PB6  // Relay 1 Output
#define RELAY2 PB7  // Relay 2 Output
#define TRANSISTOR  PD5  // Transistor Output
#define MOSFET PB3  // MOSFET Output
#define MOC3021 PB1  // MOC3021 (Triac Trigger) Output

// Input Pin Definitions
#define BUTTON1 PD3  // Button 1 Input

// Function to configure I/O pins
void IO_Config(void) {
	// set the BUTTON1 as INPUT
	DDRD &=~(1<<BUTTON1) ;
	PORTD |=(1<<BUTTON1);
	// SET OTHER COMPONENTS AS OUTPUT
	DDRB |=(1<<RELAY1 | 1<<RELAY2 | 1<<MOSFET | 1<<MOC3021);
	DDRD |=(1<<TRANSISTOR);
}
// Function to turn ON an output (with 1-second delay)
void Turn_On(uint8_t pin, volatile uint8_t *port) {
	
	*port |=(1<<pin);
	_delay_ms(1000);
}
// Function to turn OFF all outputs
void Turn_Off_All(void) {
	PORTB &=~(1<<RELAY1 | 1<<RELAY2 | 1<<MOSFET | 1<<MOC3021);
	PORTD &=~(1<<TRANSISTOR);
}
int main(void) {
	IO_Config();  // Configure inputs and outputs
	
	while(1)
	{
		if(!(PIND & (1<<BUTTON1)))
		{
			Turn_On(RELAY1, &PORTB);
			Turn_On(RELAY2, &PORTB);
			Turn_On(TRANSISTOR, &PORTD);
			Turn_On(MOSFET, &PORTB);
			Turn_On(MOC3021, &PORTB);
			
			Turn_Off_All();
		}
		else
		{
			
		}
	}
}
