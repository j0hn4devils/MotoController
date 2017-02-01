				TTL			Controller.s
;-----------------------------------------------------
;Initialize background tasks (UART,TPM,etc)
;Written by John DeBrino
;Sources referrenced: Roy Melton
;Revision Date: 1/25/2016
;-----------------------------------------------------
;		  Assembler Directives and Includes

			THUMB
			GBLL MIXED_ASM_C
MIXED_ASM_C SETL {TRUE}
			OPT		64	 ;Enables listing macro expressions
			OPT		1	 ;Enables listing

;-----------------------------------------------------
;				   Acquire resources

			GET		Equates.s

;-----------------------------------------------------
;					   Equates

PTA_PCR4_INT_MASK	EQU	0x00000010	;Mask to determine interrupt is Pin 4
PTA_PCR5_INT_MASK	EQU	0x00000020	;Mask to determine interrupt is Pin 5
PTA_INT_MASK		EQU 0x010B0103 	;Mask to enable interupts on rising and falling edge for GPIO
PIN1_OUT 			EQU 0x02		;Mask for PDOR/PDDR to output 1 on Pin 1
PIN2_OUT 			EQU 0x04 		;Mask for PDOR/PDDR to output 1 on Pin 2
GPIO_OUT_MASK		EQU 0x01000100	;Mask to enable GPIO function

;-----------------------------------------------------
; 					Define Library

		AREA	ControlLibrary,CODE,READONLY
		ENTRY
		EXPORT	ControlLibrary

;-----------------------------------------------------
;					Begin Library

		EXPORT initSPI
initSPI
		;Inits SPI for data transmission, 16 bit mode
		;Input: None
		;Output: SPI Initialized; ready for data transmission
		;Regmod: None

		;Save Registers
		PUSH	{R0-R2}		;No LR; Faster implementation

		;Enable module in SCGC4
		LDR		R0,=SIM_SCGC4	;Load SCGC4 address
		LDR		R1,=SPI0_MASK	;Load mask to enable clock
		LDR		R2,[R0,#0]	;Load current SCGC4 value (don't disable other modules)
		ORRS	R2,R2,R1	;Or in the mask to enable SPI0
		STR		R2,[R0,#0]	;Store new value at SCGC4

		;Map SPI0 Output to Pins PTA15 (CLK) and PTA16 (MOSI)

		LDR		R0,=PTA15PCR	;Load PTA15PCR address
		LDR		R1,=PCR15CLKMASK;Load Mask
		STR		R1,[R0,#0]		;Store mask

		;Repeat process for PTA16

		LDR		R0,=PTA16PCR
		LDR		R1,=PCR16DATAMASK
		STR		R1,[R0,#0]

		;Set the BAUD rate
		LDR		R0,=SPI_BAUD	;Load the BAUD rate register
		MOVS	R1,#BAUD_MASK	;Load the mask for desired BAUD rate
		STRB	R1,[R0,#0]	;Store the new baud rate

		;Control register 1 initalizations
		LDR		R0,=SPI_C1	;Load C1 address
		MOVS	R1,#C1_EN_MSTR	;Load mask to enable SPI0 as a master device
		STRB	R1,[R0,#0]	;Store mask at C1

		;Control register 2 initializations
		LDR		R0,=SPI_C2	;Load C2 address
		MOVS	R1,#C2_16BIT	;Load mask to ensure 8 bit operation
		STRB	R1,[R0,#0]	;Store mask at C2

		;Restore and return
		POP		{R0-R2}
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
		LDR		R1,=PIT_MASK	;Load PIT Enable mask
		STR		R1,[R0,#0]		;Store Priority

		;Set Priority
		LDR		R0,=PIT_IPR		;Load PIT IPR
		LDR		R1,=PIT_IRQ_PRI	;Load priority
		STR		R1,[R0,#0]		;Store

		;CH0 Interrupt condition
		LDR 	R0,=PIT_LDVAL0	;Load LDVAL0, which is the CH0 Base
		LDR		R1,=TFLG_CLR	;Load mask to reset interrupt condition
		STR		R1,[R0,#TFLG1]	;Store mask at offset

		;Restore and return
		POP		{R0-R2}
		BX		LR



			EXPORT	PIT_IRQHandler
PIT_ISR
PIT_IRQHandler
			;PIT Interrupt Service Routine
			;Final features not yet set in stone
			;Current plan is to set the LED color on interrupt
			;This will emulate if the shift on the LEDs was
			;done at a 50Hz rate
			;Input: None (ISR)
			;Output: Count incremented, color set (if bool; don't set a color if bike is off)
			;Regmod: None

			;-----------Modify this code-----------;

			;No PUSH; R0-R3 auto pushed

			LDR     R0,=Count           ;Load count address
            LDR     R1,[R0,#0]          ;Load count data
			ADDS    R1,R1,#1            ;Increment
            STR     R1,[R0,#0]          ;Store new count

endPIT_ISR
			;Write 1 to TIF
			LDR     R0,=PIT_LDVAL0      ;Load CH0 base
			LDR     R1,=TFLG_CLR   		;Load mask
			STR     R1,[R0,#TFLG1]		;Store at offset
			BX	LR



			EXPORT	wait
wait
			;Subroutine waits for a specified amount of ms
			;Inputs: Time (ms) in R0
			;Output: Waits until specified time
			;Regmod: None

			PUSH		{R1-R2}

initTimer
			CPSID	I		;Disable interrupts (PIT)
			LDR		R1,=Count	;Load count address
			MOVS	R2,#0		;Move 0 to R2
			STR		R2,[R1,#0]	;Store 0 as new count
			CPSIE	I		;Enable interrupts (PIT)

timeLoop	LDR		R2,[R1,#0]	;Load count value
			CMP		R2,R0		;Compare R2 to desired time value
			BLT		timeLoop	;While Count < desired time, loop

			POP		{R1-R2}		;Restore and Return
			BX		LR

			ALIGN


			EXPORT setSPIBaud
setSPIBaud	;Subroutine sets the baud rate for the SPI
			;Inputs: Baud rate in R0
			;Output: Baud rate is set
			;Regmod: None

			PUSH	{R1}
			LDR		R1,=SPI_BAUD
			STRB	R0,[R1,#0]
			POP		{R1}
			BX		LR


			EXPORT initPTAInterrupt
initPTAInterrupt
			;Subroutine initalizes Port A Pins 4 and 5 for interrupts
			;These analog inputs will be used to drive power mode
			;and turn signals
			;Input: None
			;Output: Initialized Port A pins 4 and 5
			;Regmod: None

			;Save registers
			PUSH	{R0-R2}

			;Enable Port A in SIM
			LDR		R0,=SIM_SCGC5
			LDR		R1,=EN_PTA
			STR		R1,[R0,#0]

			;Properly multiplex and set up interrupt for Pins 4 and 5
			LDR		R0,=PTA_PCR_4
			LDR		R1,=PTA_INT_MASK
			STR		R1,[R0,#0]
			STR		R1,[R0,#4]	;Instead of loading PCR5, used PCR4 offset by 4
			
			;Multiplex pins 1 and 2 for GPIO Output
			LDR		R0,=PTA_PCR_1
			LDR		R1,=GPIO_OUT_MASK
			STR		R1,[R0,#0]
			STR		R1,[R0,#4]	;Instead of loading PCR2, use PCR1 offset by 4
			
			;Init Output
			LDR		R0,=PTA_PDOR
			LDR		R1,=0x00000000
			STR		R1,[R0,#0]
			
			;Set GPIO Pins as output
			LDR		R0,=PTA_PDDR
			MOVS	R1,#PIN1_OUT
			MOVS	R2,#PIN2_OUT
			ANDS	R2,R2,R1
			STRB	R2,[R0,#0]

			;Enable interrupts within the NVIC
			LDR		R0,=NVIC
			LDR		R1,=PTA_MASK
			LDR		R2,[R0,#0]
			ORRS	R2,R2,R1
			STR		R2,[R0,#0]

			;Set priority to 1 (Priority 0 is reserved for PIT as of now)
			LDR		R0,=PTA_IPR
			LDR		R1,=PTA_IRQ_PRI
			STR		R1,[R0,#0]

			;Clear any interrupts (see IRQ for details)
			LDR		R0,=PTA_ISF
			LDR		R1,[R0,#0]
			STR		R1,[R0,#0]

			LDR		R0,=Turning
			MOVS	R1,#0
			STRB	R1,[R0,#0]

			;Restore and Return
			POP		{R0-R2}
			BX		LR


			EXPORT PORTA_IRQHandler
PORTA_IRQHandler
PTA_IRQ		;IRQ Handler for Port A interrupts
			;Function is to toggle boolean. This boolean will
			;tell the system if the turn signal has been acitvated

			;PIN USAGES:
			;Inputs
			;Pin4 will be legacy left turn signal
			;Pin5 will be legacy right turn signal
			;Outputs
			;Pin1 will be new left turn signal
			;Pin2 will be new right turn signal

			;-------------------------------------------;
			;Currently only switching a bool for testing;
			;-------------------------------------------;


			;R0-R3 auto pushed

			LDR		R0,=Turning		;Load address of turning
			LDRB	R1,[R0,#0]		;Load value of turning
			CMP		R1,#TRUE		;Check if true

			;Toggle variable
			BEQ		setFalse
setTrue		MOVS	R1,#TRUE
			STRB	R1,[R0,#0]
			B		clearPTAInt
setFalse	MOVS	R1,#FALSE
			STRB	R1,[R0,#0]

			;Read ISF and Decode Turn signal out via Hardware decoder
			;(use other port A pins for this function to reduce power use)
			LDR		R0,=PTA_ISF
			LDR		R1,[R0,#0]
			LDR		R2,=PTA_PCR4_INT_MASK
			ANDS	R2,R2,R1
			BEQ		TurnLeft

TurnRight	LDR 	R0,=PTA_PDOR
			;LDR		R1,[R0,#0]
			MOVS 	R1,#PIN2_OUT
			STRB 	R1,[R0,#0]
			;LDR		R2,[R0,#0]
			B		clearPTAInt

TurnLeft	LDR		R0,=PTA_PDOR
			;LDR		R1,[R0,#0]
			MOVS 	R1,#PIN1_OUT
			STRB 	R1,[R0,#0]
			;LDR		R2,[R0,#0]

clearPTAInt LDR		R1,[R0,#0]
			;Upon interrupt, the bits in the ISF are set to 1, and they are w1c
			;So loading the register values and writing them back to the register
			;should clear all interrupts

			LDR		R0,=PTA_ISF
			LDR		R1,[R0,#0]
			STR		R1,[R0,#0]

			;Return (Auto-Pushed registers restored upon return)
			BX		LR

			ALIGN	;Word align
;------------------------------------------------------
;					Variables

		AREA	Variables,DATA,READWRITE

;Begin variables

Count	SPACE	WORD	;Allocate word to count PIT interrupts
		EXPORT	Turning
Turning SPACE	BYTE	;Allocate byte for Turning boolean (True if turn signal activated)

		ALIGN		;Word align

;------------------------------------------------------
;					Constants

		AREA	Constants,DATA,READONLY

;Begin constants

		ALIGN		;Word align
;------------------------------------------------------
		END
