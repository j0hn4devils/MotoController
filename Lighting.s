				TTL			Lighting.s
;-----------------------------------------------------
;Lighting controls library NXP MKL46256XXXX
;Written by John DeBrino
;Sources referrenced: Roy Melton
;Revision Date: 2/24/2016

;-----------------------------------------------------
;		  Assembler Directives and Includes

			THUMB
			GBLL MIXED_ASM_C
MIXED_ASM_C SETL {TRUE}
			OPT		64	 ;Enables listing macro expressions
			OPT		1	 ;Enables listing

;-----------------------------------------------------
;				  Acquire Resources
			GET		EQUATES.s

;-----------------------------------------------------
;					   Equates
	
	
SHIFT		EQU  	0x10		;Shift value to shift over bytes
CHECKTRANS	EQU 	0x20		;Check if ready to send
	
;-----------------------------------------------------
; 					Define Program
		AREA	LightingLibrary,CODE,READONLY
		ENTRY
		EXPORT	LightingLibrary


;-----------------------------------------------------
;					Begin Library
			
			
			
			
		EXPORT setColor
setColor	;Sends 1 LED frame to the SPI with specified color
			;Input: Color in R0 (BGR Value)
			;Output: Data sent through SPI
			;Regmod: R0 (Data need not be preserved)
			
		;Save registers
		PUSH	{R1-R4,LR}		;LR, nested subroutines
		
		;Load addresses
		LDR		R1,=SPI_DL		;Load data output register
		LDR		R2,=SPI_BASE	;Load the base, which is the status register
	
		;Mask Color value for LED frame
		LDR		R3,=0xF0000000	;Load first byte of LED Frame (Lower brightness used for testing)
		ORRS	R0,R0,R3		;Mask into LED Color value
		
		;Copy color to R4 for proper output
		
		MOVS	R4,R0			;Copy Color Value
		LSRS	R4,#SHIFT		;Shift right by half work
		
		;Color transmission
		;Unknown if RGB transmission is in correct order
		
		;Transmit Start and B
		BL		checkTrans		;Check if ready for transfer
		CPSID	I				;Disable interrupts for critical code
		LDRB	R3,[R2,#0]		;Must read before a write
		STRH	R4,[R1,#0]		;Store new color
		CPSIE	I				;End critical code; enable interrupts
		BL		checkTrans		;Wait until ready to transmit
		

		;Transmit G and R
		CPSID	I				;Disable interrupts for critical code
		LDRB	R3,[R2,#0]		;Must read before a write
		STRH	R0,[R1,#0]		;Store new color
		CPSIE	I				;End critical code; enable interrupts
		
		;Restore and return
		POP		{R1-R4,PC}

	

		EXPORT	startFrame
startFrame
		;Sends a start frame to the SPI
		;Function is written for 16 bit transmission mode
		;Input: None
		;Output: Start Frame to SPI
		;Regmod None
		
		;Preserve registers
		PUSH	{R0-R4,LR}
		
		;Move 0 to R0 as data and R1 as counter
		MOVS 	R0,#0
		MOVS	R1,#0
		
		;Load DL and BASE for SPI in R2 and R3
		LDR		R2,=SPI_DL
		LDR		R3,=SPI_BASE
		
		;Loop
startLoop	
		CMP		R1,#2		;Check if Counter has reached 2
		BEQ		Endit		;If Counter ==2, End
		BL		checkTrans	;Check if ready for transmit
		LDRB	R4,[R3,#0]	;Load Status register values (to write)
		STRH	R0,[R2,#0]	;Store bits at DH
		ADDS	R1,#1		;Increment counter
		B		startLoop	;Loop
		
		;Restore and return
Endit	POP		{R0-R4,PC}	




checkTrans
		;Subroutine checks if the SPI interface is ready
		;to transmit, and loops until ready
		;Input: None
		;Output: None
		;Regmod: None
		
		;initializations
		;Save registers
		PUSH	{R0-R2,LR}
		
		LDR		R0,=SPI_BASE	;Load base
		MOVS	R1,#CHECKTRANS	;Load mask to check if transmit ready bit is set
		
		;Loop until ready to transmit
transLoop
		LDRB	R2,[R0,#0]		;Read the status register
		ANDS	R2,R2,R1		;Mask status register with Transmit bit mask	
		CMP		R2,R1			;Check to see if only transmit bit is set		
 		BNE 	transLoop		;If not, loop until set
		
		;Restore and Return
		POP		{R0-R2,PC}
		
		ALIGN
;-----------------------------------------------------
		END