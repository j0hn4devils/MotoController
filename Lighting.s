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

;The following equates are the hex codes for the colors
WHITE		EQU 	0x00FFFFFF
AMBER		EQU		0x00FFC200
NOCOLOR		EQU		0x00000000
	
	
;-----------------------------------------------------
; 					Define Program
		AREA	LightingLibrary,CODE,READONLY
		ENTRY
		EXPORT	LightingLibrary


;-----------------------------------------------------
;					Begin Library
			
		EXPORT setColor
setColor	;Sets the GPIO output of PTE PIN0 to
			;Desired color
			;Input: Color in R1
			;Output: None
			;Regmod: None
		PUSH	{R0,LR}
		LDR		R0,=GPIOE_PDDR	;Load data output register
		STR		R1,[R0,#0]		;Store new color
		POP		{R0,PC}
			
			
;-----------------------------------------------------
		END