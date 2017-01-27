;Equates.s
;File of equates for NXP KL46
;Created on 1/25/16
;Created by: John DeBrino

			OPT	2			;Disables listing


;General
;Sizes are in multiples of 8 bits
DWORD		EQU 8			;Double word size
WORD		EQU 4			;Word size
HWORD		EQU	2			;Half word size
BYTE		EQU 1			;Byte size
TRUE		EQU	1			;True boolean
FALSE		EQU	0			;False boolean


;						SCGC4
SIM_SCGC4	EQU 0x40048034	;SCGC4 Absolute address
SPI0_MASK	EQU	0x00400000	;Mask to enable SPI


;						SCGC5
SIM_SCGC5	EQU	0x40048038	;Absolute Address of SCGC5 Module
EN_PTE		EQU	0x00001000	;Mask to enable PORT E
EN_PTA		EQU	0x00000200	;Mask to enable PORT A


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
PTA_PRI_POS	EQU 0x1E		;Port A Priority position
PIT_MASK	EQU	(1 << PIT_PRI_POS)	;PIT IRQ Enable mask
PIT_IPR		EQU (NVIC + 0x314) 		;IPR5 offset
PIT_IRQ_PRI	EQU	(0 << PIT_PRI_POS)	;Set PIT Priority to 0 (highest priority)
PTA_MASK	EQU (1 << PTA_PRI_POS)	;Port A IRQ Enable mask
PTA_IPR		EQU	(NVIC + 0x31C)		;IPR 7 Offset?
PTA_IRQ_PRI	EQU 0x00000000	;Mask to give priority of 1 (just below PIT)

;						 SPI
SPI_BASE	EQU	0x40076000
SPI_BAUD	EQU (SPI_BASE + 0x01)
SPI_C2		EQU (SPI_BASE + 0x02)
SPI_C1		EQU (SPI_BASE + 0x03)
SPI_DL		EQU	(SPI_BASE + 0x06)
SPI_DH		EQU	(SPI_BASE + 0x07)
SPI_C3		EQU	(SPI_BASE + 0x0B)
C2_16BIT	EQU	0x40		;Mask for C2 to enable 16 bit mode
C1_EN_MSTR	EQU	0x50		;Enables SPI and initalizes as master device
BAUD_MASK	EQU 0x33		;Mask for baud register
EN_FIFO		EQU	0x01		;Enables 64 bit FIFO
PTA15PCR	EQU	0x4004903C
PCR15CLKMASK	EQU 0x01000200
PTA16PCR		EQU 0x40049040
PCR16DATAMASK	EQU 0x01000200

;						Port A
PTA_ISF 	EQU 0x400490A0	;Interrupt status flag register
PTA_PCR_4	EQU 0x40049010	;PCR4
PTA_PCR_5	EQU	0x40049014	;PCR5
PTA_PDOR	EQU 0x400FF000	;Port data output register

;The following equates are the hex codes for the colors
WHITE		EQU 	0x00FFFFFF
AMBER		EQU		0x0000C2FF
NOCOLOR		EQU		0x00000000

	END
