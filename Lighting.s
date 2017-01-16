				TTL			Lighting.s
;-----------------------------------------------------
;Lighting controls library NXP MKL46256XXXX
;Written by John DeBrino
;Sources referrenced: Roy Melton (CMPE-250 Professor)
;Revision Date: 12/26/2016

;-----------------------------------------------------
;		  Assembler Directives and Includes

			THUMB
			GBLL MIXED_ASM_C
MIXED_ASM_C SETL {TRUE}
			OPT		64	 ;Enables listing macro expressions
			OPT		1	 ;Enables listing

;-----------------------------------------------------
;					   Equates
	
SPI_DL		EQU		0x40076006
SPI_DH		EQU		0x40076007
SPI_BASE	EQU		0x40076000
;The following equates are the hex codes for the colors
WHITE		EQU 	0x00FFFFFF
AMBER		EQU		0x00FFC200
NOCOLOR		EQU		0x00000000
	
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
			;Input: Color in R0
			;Output: Data sent through SPI
			;Regmod: R0 (Data need not be preserved)
			
		;Save registers
		PUSH	{R1-R4,LR}		;LR, nested subroutines
		
		;Load addresses
		LDR		R1,=SPI_DL		;Load data output register
		LDR		R2,=SPI_BASE	;Load the base, which is the status register
	
		;Mask Color value for LED frame
		LDR		R3,=0xFF000000	;Load first byte of LED Frame
		ORRS	R0,R0,R3		;Mask into LED Color value
		
		;Color transmission
		;RGB value is reversed. Get the impl working, then fix with proper masking
		
		
		;Transmit Start and R
		CPSID	I
		LDRB	R3,[R2,#0]		;Must read before a write
		STRH	R0,[R1,#0]		;Store new color
		LSRS	R0,R0,#SHIFT	;Shift right 8 bits to get next portion of color code
		CPSIE	I
		BL		checkTrans		;Wait until ready to transmit
		
		;Transmit G and B
		CPSID	I
		LDRB	R3,[R2,#0]		;Must read before a write
		STRB	R0,[R1,#0]		;Store new color
		LSRS	R0,R0,#SHIFT	;Shift right 8 bits to get next portion of color code
		CPSIE	I
		
		;Restore and return
		POP		{R1-R4,PC}

	

		EXPORT	startFrame
startFrame
		;Sends a start frame to the SPI
		;Input: None
		;Output: Start Frame to SPI
		;Regmod None
		
		;Preserve registers
		PUSH	{R0-R4,LR}
		
		;Move 0 to R0 as data and R1 as counter
		LDR 	R0,=0x00000000
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
		
		;Restpre and return
Endit	POP		{R0-R4,PC}	






		EXPORT	endFrame
endFrame
		;Sends an end frame through the SPI interface
		;Input: None
		;Output: End Frame through SPI
		;Regmod: None
		
		;Preserve registers
		PUSH	{R0-R4,LR}
		
		;Move FF to R0 and instantiate counter in R1
		LDR		R0,=0xFFFFFFFF
		MOVS	R1,#0
		
		;Load the DL and Base SPI addresses
		LDR		R2,=SPI_DL
		LDR		R3,=SPI_BASE
		
		;Transfer loop
endloop	CMP		R1,#2		;Check if Counter == 4
		BEQ		Endite		;If true, end loop
		BL		checkTrans	;Check if ready to transfer
		LDRB	R4,[R3,#0]	;Load status register (to write)
		STRH	R0,[R2,#0]	;Send data out SPI DL
		ADDS	R1,#1		;Increment counter
		B		endloop		;Loop
		
		;Restore and return
Endite	POP		{R0-R4,PC}





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