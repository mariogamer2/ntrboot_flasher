/*---------------------------------------------------------------------------------

  Copyright (C) 2005
  	Michael Noland (joat)
  	Jason Rogers (dovoto)
  	Dave Murphy (WinterMute)

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any
  damages arising from the use of this software.

  Permission is granted to anyone to use this software for any
  purpose, including commercial applications, and to alter it and
  redistribute it freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you
     must not claim that you wrote the original software. If you use
     this software in a product, an acknowledgment in the product
     documentation would be appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and
     must not be misrepresented as being the original software.
  3. This notice may not be removed or altered from any source
     distribution.

---------------------------------------------------------------------------------*/
#define ICACHE_SIZE	0x2000
#define DCACHE_SIZE	0x1000
#define CACHE_LINE_SIZE	32
//---------------------------------------------------------------------------------
	.arm
//---------------------------------------------------------------------------------
	.global	DC_FlushAll
	.type	DC_FlushAll STT_FUNC
//---------------------------------------------------------------------------------
DC_FlushAll:
/*---------------------------------------------------------------------------------
	Clean and invalidate entire data cache
---------------------------------------------------------------------------------*/
    MOV     R12, #0

outer_loop:
    MOV     R0, #0
    MOV     R2, R12,LSL#30

inner_loop:
    ORR     R1, R2, R0,LSL#5 @ generate segment and line address
    MCR     p15, 0, R1,c7,c14, 2 @ clean and flush the line
    ADD     R0, R0, #1
    CMP     R0, #0x20 @ ' '
    BCC     inner_loop
    ADD     R12, R12, #1
    CMP     R12, #4
    BCC     outer_loop
    MOV     R0, #0
    MCR     p15, 0, R0,c7,c10, 4
    BX      LR

//---------------------------------------------------------------------------------
	.global	DC_FlushRange
	.type	DC_FlushRange STT_FUNC
//---------------------------------------------------------------------------------
DC_FlushRange:
/*---------------------------------------------------------------------------------
	Clean and invalidate a range
---------------------------------------------------------------------------------*/
	add	r1, r1, r0
	bic	r0, r0, #(CACHE_LINE_SIZE - 1)
.flush:
	mcr	p15, 0, r0, c7, c14, 1		@ clean and flush address
	add	r0, r0, #CACHE_LINE_SIZE
	cmp	r0, r1
	blt	.flush
	bx	lr

//---------------------------------------------------------------------------------
	.global	DC_InvalidateAll
	.type	DC_InvalidateAll STT_FUNC
//---------------------------------------------------------------------------------
DC_InvalidateAll:
/*---------------------------------------------------------------------------------
	Clean and invalidate entire data cache
---------------------------------------------------------------------------------*/
	mov	r0, #0
	mcr	p15, 0, r0, c7, c6, 0
	bx	lr

//---------------------------------------------------------------------------------
	.global	DC_InvalidateRange
	.type	DC_InvalidateRange STT_FUNC
//---------------------------------------------------------------------------------
DC_InvalidateRange:
/*---------------------------------------------------------------------------------
	Invalidate a range
---------------------------------------------------------------------------------*/
	cmp r1, #0x4000
	bcs DC_InvalidateAll
	
	BIC     R2, R0, #CACHE_LINE_SIZE - 1
	ADD     R0, R0, R1
	ADD     R0, R0, #CACHE_LINE_SIZE - 1
	BIC     R0, R0, #CACHE_LINE_SIZE - 1
	CMP     R2, R0
	BXCS    LR

.invalidate:
	MCR     p15, 0, R2,c7,c6, 1
	ADD     R2, R2, #CACHE_LINE_SIZE
	CMP     R2, R0
	BCC     .invalidate
	BX      LR

