				TTL			Lighting.s
;-----------------------------------------------------
;Lighting controls library NXP MKL46256XXXX
;Written by John DeBrino
;Sources referrenced: Roy Melton (CMPE-250 Professor)
;Revision Date: mm/dd/yyyy

;-----------------------------------------------------
;		  Assembler Directives and Includes

			THUMB
			GBLL MIXED_ASM_C
MIXED_ASM_C SETL {TRUE}
			OPT		64	 ;Enables listing macro expressions
			OPT		1	 ;Enables listing

;-----------------------------------------------------
;					   Equates
GPIOE_PDDR	EQU		0x400FF114	;Address of PDDR for Port E
	
SPI_DL		EQU		0x40076006
SPI_DH		EQU		0x40076007
SPI_BASE	EQU		0x40076000
;The following equates are the hex codes for the colors
WHITE		EQU 	0x00FFFFFF
AMBER		EQU		0x00FFC200
NOCOLOR		EQU		0x00000000
	
SHIFT		EQU  	0x08		;Shift value to shift over bytes
	
	
;-----------------------------------------------------
; 					Define Program
		AREA	LightingLibrary,CODE,READONLY
		ENTRY
		EXPORT	LightingLibrary


;-----------------------------------------------------
;					Begin Library
			
		EXPORT setColor
setColor	;Sends 
			;Input: Color in R0
			;Output: None
			;Regmod: None
		PUSH	{R0-R3,LR}
		LDR		R1,=SPI_DL	;Load data output register
		LDR		R2,=SPI_BASE
		
		LDRB	R3,[R2,#0]
		STRB	R1,[R1,#0]		;Store new color
		NOP
		LSRS	R0,R0,#SHIFT
		LDRB	R3,[R2,#0]
		STRB	R1,[R1,#0]		;Store new color
		NOP
		LSRS	R0,R0,#SHIFT
		LDRB	R3,[R2,#0]
		STRB	R1,[R1,#0]		;Store new color
		NOP
		POP		{R0-R3,PC}
			
		ALIGN
;-----------------------------------------------------
		END