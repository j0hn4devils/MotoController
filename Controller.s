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


;						SCGC4
SIM_SCGC4	EQU 0x40048034
SPI0_MASK	EQU	0x00400000


;						SCGC5
SIM_SCGC5	EQU	0x40048038	;Absolute Address of SCGC5 Module
EN_PTE		EQU	0x00001000	;Mask to enable PORT E in SCGC5
	;Modify previous entry to enable ports B-E for future compatability


;						SCGC6
SIM_SCGC6	EQU	0x4004803C	;Absolute Address of SCGC6 Module
EN_PIT		EQU	0x00800000	;Mask to enable PIT
EN_DAC		EQU	0x80000000	;Mask to enable DAC0


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
DAC0_BASE	EQU	0x4003F000			;DAC0 Base
DAT0L		EQU	DAC0_BASE			
DAT0H		EQU	(DAC0_BASE + 0x01)	
DAC0_SR		EQU	(DAC0_BASE + 0x20)	
DAC0_C0		EQU	(DAC0_BASE + 0x21)	
DAC0_C1		EQU	(DAC0_BASE + 0x22)
DAC0_C2		EQU	(DAC0_BASE + 0x23)
C1_DMA_DISABLE EQU	0x00			;Mask to diable DMA/buffer
C0_DACEN_VDDREF_HP	EQU	0xC0		;Enables DAC, uses VDD as refernce
									;voltage, and High power mode is enabled
DATHL_LOW	EQU 0x00	;Low voltage for DATH/L
DATH_HIGH	EQU 0x0E	;High voltage for DATH
DATL_HIGH	EQU	0xFF	;High voltage for DATL


;						PORTE
PORTE_BASE	EQU 0x4004C000			;Base for port E
PCR_30_OFFSET	EQU	0x78			;Offset for PCR30
PTE_PCR0	EQU	PORTE_BASE			;PCR 0 located at base
PTE_PCR30	EQU (PORTE_BASE + PCR_30_OFFSET);PCR 30
ISF_MASK	EQU 0x01000000			;Mask to clear ISF (w1c)
ANALOG_OUT	EQU 0x00000000			;Mask to multiplex analog output
ANALOG_MASK	EQU (ISF_MASK :OR: ANALOG_OUT)	;Mask to fully enable analog out
GPIO_OUT	EQU 0x00000100			;Mask to muliplex GPIO Output
GPIO_MASK	EQU	(ISF_MASK :OR: GPIO_OUT)	;Mask to fully enable GPIO out


;						 SPI
SPI_BASE	EQU	0x40076000
SPI_BAUD	EQU (SPI_BASE + 0x01)
SPI_C2		EQU (SPI_BASE + 0x02)
SPI_C1		EQU (SPI_BASE + 0x03)
SPI_DL		EQU	(SPI_BASE + 0x06)
SPI_DH		EQU	(SPI_BASE + 0x07)
SPI_C3		EQU	(SPI_BASE + 0x0B)
C2_8BIT		EQU	0x08		;Mask for C2 to ensure 8 bit mode
C1_EN_MSTR	EQU	0x50		;Enables SPI and initalizes as master device
BAUD_MASK	EQU 0x00		;Mask for baud register
EN_FIFO		EQU	0x01		;Enables 64 bit FIFO

;-----------------------------------------------------
; 					Define Library

		AREA	ControlLibrary,CODE,READONLY
		ENTRY
		EXPORT	ControlLibrary

;-----------------------------------------------------
;					Begin Library

		EXPORT initSPI
initSPI
		;Inits SPI for data transmission, 8 bit mode
		;comment here
		
		PUSH	{R0-R1}
		;Enable module in SCGC4
		LDR		R0,=SIM_SCGC4
		LDR		R1,=SPI0_MASK
		LDR		R2,[R0,#0]
		ORRS	R2,R2,R1
		STR		R2,[R0,#0]
		
		LDR		R0,=SPI_BAUD
		MOVS	R1,#BAUD_MASK
		STRB	R1,[R0,#0]
		
		LDR		R0,=SPI_C1		;Load C1 address
		MOVS	R1,#C1_EN_MSTR	;Load mask
		STRB	R1,[R0,#0]		;Store mask
		
		LDR		R0,=SPI_C2		;Load C2
		MOVS	R1,#C2_8BIT		;Load mask
		STRB	R1,[R0,#0]		;Store mask

		
		POP		{R0-R1}
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
			
endPIT_ISR  
			;Write 1 to TIF
			LDR     R0,=PIT_LDVAL0      ;Load CH0 base
			LDR     R1,=TFLG_CLR   		;Load mask
			STR     R1,[R0,#TFLG1]		;Store at offset
            POP     {PC}


			ALIGN
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
