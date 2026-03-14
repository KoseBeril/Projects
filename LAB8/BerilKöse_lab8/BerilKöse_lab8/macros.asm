/*
 * macros.asm
 *
 *  Created: 29.12.2025 20:25:53
 *   Author: koseb
 */ 
 .macro stackreg
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
.endmacro
