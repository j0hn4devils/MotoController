				TTL			Controller.s
;-----------------------------------------------------
;Initialize background tasks (UART,TPM,etc)
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

;General
;Sizes are in multiples of 8 bits
DWORD		EQU 8			;Double word size
WORD		EQU 4			;Word size
HWORD		EQU	2			;Half word size
BYTE		EQU 1			;Byte size

;						SCGC5
SIM_SCGC5	EQU	0x40048038	;Absolute Address of SCGC5 Module
EN_PTE		EQU	0x00001000	;Mask to enable PORT E in SCGC5
	;Modify previous entry to enable ports B-E for future compatability

;						SCGC6
SIM_SCGC6	EQU	0x4004803C	;Absolute Address of SCGC6 Module
EN_PIT		EQU	0x00800000	;Mask to enable PIT in SCGC6

;						 PIT
PIT_BASE	EQU	0x40037000	;Base for PIT
DEBUG_EN	EQU	0x00000001	;Allow debugging by stopping timer in debug mode
PIT_LDVAL0	EQU	0x40037100	;PIT LDVAL register (Also CH0 base)
INT_10ms	EQU	0x0003A97F	;Value for LDVAL for 10ms interrupt
TCTRL		EQU	0x08		;TCTRL offset to be used with LDVAL0 Base
EN_TCTRL	EQU	0x00000003	;Enable Timer and Timer interrupt
TFLG1		EQU	0x0C		;Timer flag register offset
TFLG_CLR	EQU	0x00000001	;Mask to clear timer interrupt (w1c)	
	
;						 NVIC
NVIC		EQU	0xE000E100	;Interrupt controller base address
PIT_PRI_POS	EQU	0x16		;Pit Priority position
PIT_MASK	EQU	(1 << PIT_PRI_POS)	;PIT IRQ Priority mask (Roy W Melton)
PIT_IPR		EQU (NVIC + 0x314) 		;IPR5 offset
PIT_IRQ_PRI	EQU	(0 << PIT_PRI_POS)	;Set PIT Priority to 0 (highest)
	
;						DAC/ADC
LOW_VOLTAGE	EQU	0		;Write to DAC for 0V out
HIGH_VOLTAGE EQU 4095	;Write to DAC for 3.3V out

;-----------------------------------------------------
; 					Define Program

		AREA	ControlLibrary,CODE,READONLY
		ENTRY
		EXPORT	ControlLibrary

;-----------------------------------------------------
;					Begin Library


		EXPORT initGPIOLightDataOut
initGPIOLightDataOut
		;Initializes the GPOIO Port E
		;This is to allow output for the LED Strip
		;Write to data register to output
		;Input: None
		;Output: Initializations for GPIO
		;Regmod: None

		PUSH	{R0-R2,LR}			;Save registers
		;Enable clock for Port E
		LDR		R0,=SIM_SCGC5		;Load SCGC5 address
		LDR		R1,=EN_PTE			;Load PortE mask
		LDR		R2,[R0,#0]			;Load current SCGC5 value
		ORRS	R2,R2,R1			;Mask SCGC5
		STR		R2,[R0,#0]			;Store new SCGC5 value
		POP		{R0-R2,PC}			;Restore and return

changeClock
		;Sets analog output to either 1 or 0
		;used in PIT_ISR to create clock
		;Input: None
		;Output: either 3.3V or 0V to pin
		;Regmod: None

		PUSH	{R0-R2}			;Preserve registers
								;No LR (Lowest level Subroutine)

		LDR		R0,=Clock		;Get High/Low Boolean
		LDR		R1,[R0,#0]		;Get High/Low Value
		CMP		R1,#0			;Compare to 0 (low)
		BEQ		Low				;If 0, change Voltage from low to high
High	LDR		R1,=LOW_VOLTAGE	;Load low voltage value

		;Store low voltage value
		STR		R1,[R0,#0]		;Store new clock value at =Clock
		POP		{R0-R2}			;Restore and return
		BX		LR

Low		LDR		R1,=HIGH_VOLTAGE ;Load R1 with high voltage value

		;Store high voltage value
		STR		R1,[R0,#0]		;Store new clock value at =Clock
		POP		{R0-R2}			;Restore and return
		BX		LR


		EXPORT	initPITInterrupt
initPITInterrupt
		;Initialize the PIT module for periodic interrupts
		;This will be used to create the clock (if possible)
		;Input: None
		;Output: Initialized PIT
		;Regmod: None

		;PUSH modified registers
		;PC not pushed as BX LR is more efficient/no nested subroutines
		PUSH	{R0-R2}

		;Enable PIT in Gate Control 6 register
		LDR		R0,=SIM_SCGC6	;Load SCGC6 base
		LDR		R1,=EN_PIT		;Load mask to enable PIT
		LDR		R2,[R0,#0]		;Load current SCGC6 value
		ORRS	R2,R2,R1		;Or in the mask
		STR		R2,[R0,#0]		;Store new SCGC6 value

		;Disable timer when in debug mode
		LDR		R0,=PIT_BASE	;Load PIT base
		LDR		R1,=DEBUG_EN	;Load mask to disable timer in debug mode
		STR		R1,[R0,#0]		;Store mask

		;Set interrupt interval for 10ms
		LDR		R0,=PIT_LDVAL0	;Load LDVAL0 Register
		LDR		R1,=INT_10ms	;Load 10ms interrupt mask
		STR		R1,[R0,#0]		;Store mask

		;Enable PIT Timer
		LDR		R1,=EN_TCTRL	;Load TCTRL mask
		STR		R1,[R0,#TCTRL]	;Store mask at TCTRL offset

		;NVIC Configuration

		;Unmask Pit interrupts
		LDR		R0,=NVIC		;Load NVIC Base
		LDR		R1,=PIT_MASK	;Load IRQ Priority mask
		STR		R1,[R0,#0]		;Store Priority

		;Set Priority
		LDR		R0,=PIT_IPR		;Load PIT IPR
		LDR		R1,=PIT_IRQ_PRI	;Load priority
		STR		R1,[R0,#0]		;Store

		;CH0 Interrupt condition
		LDR 	R0,=PIT_LDVAL0		;Load LDVAL0, which is the CH0 Base
		LDR		R1,=TFLG_CLR		;Load mask to reset interrupt condition
		STR		R1,[R0,#TFLG1]		;Store mask at offset

		;Restore and return
		POP		{R0-R2}
		BX		LR


			EXPORT	PIT_IRQHandler
PIT_ISR
PIT_IRQHandler
			;PIT Interrupt Service Routine
			;Changes analog output to either high or low voltage
			;increments count value for time tracking
			;Input: None (ISR)
			;Output: "Clock" switched, Count incremented
			;Regmod: None

			;-----------Modify this code-----------;
			
            PUSH    {LR}				;Only PUSH LR, R0-R3 auto pushed by CPU
			LDR     R0,=Count           ;Load count address
            LDR     R1,[R0,#0]          ;Load count data
			ADDS    R1,R1,#1            ;Increment
            STR     R1,[R0,#0]          ;Store new count
			BL		changeClock			;Change clock output
			
endPIT_ISR  
			;Write 1 to TIF
			LDR     R0,=PIT_LDVAL0      ;Load CH0 base
			LDR     R1,=TFLG_CLR   		;Load mask
			STR     R1,[R0,#TFLG1]		;Store at offset
            POP     {PC}

;------------------------------------------------------
;					Variables

	AREA	Variables,DATA,READWRITE

;Begin variables

Count	SPACE	WORD	;Allocate word to count PIT interrupts
Clock	SPACE	HWORD	;Allocate Half word for boolean as to whether
						;clock is high or low. 0 Will be False case,
						;Any other value will be True case
						
		ALIGN		;Word align
;------------------------------------------------------
;					Constants

	AREA	Constants,DATA,READONLY

;Begin constants

		ALIGN		;Word align
;------------------------------------------------------
		END
