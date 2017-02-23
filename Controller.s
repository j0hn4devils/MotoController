				TTL			Controller.s
;-----------------------------------------------------
;Initialize background tasks (UART,TPM,etc)
;Written by John DeBrino
;Sources referrenced: Roy Melton
;Revision Date: 2/1/2016
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
PTA_PCR6_INT_MASK	EQU	0x00000040	;Mask to determine interrupt is Pin 6
PTA_PCR7_INT_MASK	EQU	0x00000080	;Mask to determine interrupt is Pin 7
PTA_RF_INT_MASK		EQU 0x010B0102 	;Mask to enable interupts on rising and falling edge for GPIO
PTA_R_INT_MASK		EQU 0x01090102 	;Mask to enable interupts on rising edge ONLY for GPIO
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
			;if impl == delay
			;{Toggle turning at Count == ~100 (1s);}

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


            EXPORT  setSignal
setSignal   ;Set signal allows manual setting of the two turn signals
            ;Inputs: Left and right select signal bools in R0 & R1
            ;Output: GPIO initalized for writes to left or right signals
            ;Regmod: None
            
            ;Save registers
            PUSH    {R2-R4}
            
            ;Instantiations
            MOVS    R4,#0           ;Master register to be ored with turn on values
                
            CMP     R0,#TRUE        ;Check if R0(Left) == True
            BNE     checkRight      ;If != True, skip next section
            
            ;Mask R4 with Pin 1 mask
setLeftTS   MOVS 	R3,#PIN1_OUT    
			ORRS    R4,R4,R3

checkRight  CMP     R1,#TRUE        ;Check if R1(Right) == True
            BNE     endSetSignal    ;If != True, skip next section

            ;Mask R4 with Pin 2 mask
TurnRightTS	
			MOVS 	R3,#PIN2_OUT
			ORRS    R4,R4,R3

            ;Set output to PDOR, then restore and return
endSetSignal
            LDR		R2,=PTA_PDOR 
            STR     R4,[R2,#0]
            POP     {R2-R4}
            BX      LR


			EXPORT initPTAInterrupt
initPTAInterrupt
			;Subroutine initalizes Port A Pins 7, 4, and 5 for interrupts
			;These analog inputs will be used to drive power mode
			;and turn signals
			;Input: None
			;Output: Initialized Port A pins 7, 4, and 5
			;Regmod: None

			;Save registers
			PUSH	{R0-R2}

			;Enable Port A in SIM
			LDR		R0,=SIM_SCGC5
			LDR		R1,=EN_PTA
			STR		R1,[R0,#0]

			;Properly multiplex and set up interrupt for Pins 7, 4, and 5
			LDR		R0,=PTA_PCR_4
			LDR		R1,=PTA_R_INT_MASK      ;Mask with rising edge interrupt only
			STR		R1,[R0,#0]
			STR		R1,[R0,#4]	            ;Instead of loading PCR5, used PCR4 offset by 4
            LDR     R1,=PTA_RF_INT_MASK     ;Load new mask to allow rising and falling edge interrupt
			STR		R1,[R0,#8]				;Instead of loading PCR6, use 8 offset to access
            STR     R1,[R0,#0x0C]           ;Instead of loading PCR7, Use 0x0C offset to access 
			
			;Multiplex pins 1 and 2 for GPIO Output
			LDR		R0,=PTA_PCR_1
			LDR		R1,=GPIO_OUT_MASK
			STR		R1,[R0,#0]
			STR		R1,[R0,#4]	;Instead of loading PCR2, use PCR1 offset by 4
			
			;Init Output
			LDR		R0,=PTA_PDOR
			MOVS	R1,#0
			STR		R1,[R0,#0]
			
			;Set GPIO Pins as output
			LDR		R0,=PTA_PDDR
			MOVS	R1,#PIN1_OUT
			MOVS	R2,#PIN2_OUT
			ORRS	R2,R2,R1		;Or masks together for 1 write
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
			;Pin6 will be the input from the front aux circuit
            ;Pin7 will be the input from relay
			
			;Outputs
			;Pin1 will be new left turn signal
			;Pin2 will be new right turn signal
            
            ;An explaination of implementation:
            ;Since relay is controlling the current flow In circut,
            ;the high pin will have 12v whenever any turn signal is activated
            ;This has been verified with a multimeter. This implementation will
            ;take advantage of this by having the relay input set Turning to true
            ;and then use the turn signals from the rear to differentiate which signal
            ;is being turned on. This isn't the ideal implementation, which would be
            ;getting the signals at the source, but the exact source is unientifiable
            ;This implementation, while requireing more I/O, is more elogant than using
            ;a software delay, which would introduce a new list of problems

			;R0-R3 auto pushed

            ;Check if Relay interrupt
relayInt    LDR     R0,=PTA_ISF             ;Load the ISF to check status flags
            LDR     R1,[R0,#0]              ;Load ISF data
            LDR     R2,=PTA_PCR7_INT_MASK   ;Load Pin7 int mask
            ANDS    R1,R1,R2                ;Mask to see if same
            BNE     checkSignal             ;If not, check if signal interrupt
            
            ;Set the turning variable
setTurning  LDR     R1,=Turning             ;Load in R1 to preserve ISF in R0
            LDR     R2,[R1,#0]              ;Var data now in R2
            MOVS    R3,#TRUE                ;Move 0 to R3 using MOVS instead of LDR (No need for LDR)
            CMP     R3,R2                   ;Compare to TRUE
			BEQ		setFalse                ;If TRUE, set to false
            
            ;following code block toggle true or false, then checks if other interrupts
setTrue		MOVS	R2,#TRUE
			STRB	R2,[R1,#0]
			B		checkSignal             ;Check if other interrupts
setFalse	MOVS	R2,#FALSE
			STRB	R2,[R1,#0]

			;Read ISF and Decode Turn signal out via Hardware decoder
			;(use other port A pins for this function to reduce power use)
checkSignal	;ISF already loaded
			LDR		R1,[R0,#0]              ;Load ISF data
			LDR		R2,=PTA_PCR4_INT_MASK   ;Now load PCR4 interrupt mask
			ANDS	R2,R2,R1                ;And them together
			BEQ		TurnLeft                ;And if they're the same, turn left!
            LDR     R2,=PTA_PCR5_INT_MASK   ;Or check if PCR5
            ANDS    R2,R2,R1                ;Actual check step
            BNE     checkOn                 ;If not a right interrupt, check if bike is actually on

			;For TurnLeft/Right, PDOR is written with the bit that enables the
			;Pin identified by the PINX_OUT mask.
			
TurnRight	LDR 	R1,=PTA_PDOR
			MOVS 	R2,#PIN2_OUT
			STRB 	R2,[R1,#0]
			B		checkOn

TurnLeft	LDR		R1,=PTA_PDOR
			MOVS 	R2,#PIN1_OUT
			STRB 	R2,[R1,#0]
            
            ;Check if the bike is on. This input is arbitrarily mapped to PTA7
            
checkOn     LDR     R1,[R0,#0]              ;Load ISF Data
            LDR     R2,=PTA_PCR6_INT_MASK   ;Load the interrupt mask
            ANDS    R2,R2,R1                ;Ands Together
            BNE     clearPTAInt             ;If not equal, clear the interrupts
            
            LDR     R1,=IsOn                ;Load On boolean
            LDRB    R2,[R1,#0]              ;Load value
            MOVS    R3,#FALSE               ;Load FALSE
            CMP     R3,R2                   ;Compare var to FALSE
            BNE     setOff                  ;If not false, toggle to bike is off

            ;The following code block toggles IsOn between true and false,
            ;then segways into clearing the interrupt(s)
setOn		MOVS	R2,#TRUE
			STRB	R2,[R1,#0]
			B		clearPTAInt
setOff  	MOVS	R2,#FALSE
			STRB	R2,[R1,#0]
			
            ;Clear the interrupt so that when leaving the ISR, interrupt is not triggered
clearPTAInt ;Upon interrupt, the bits in the ISF are set to 1, and they are w1c
			;So loading the register values and writing them back to the register
			;all interrupts should clear

			;ISF preserved in R0
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
        EXPORT  IsOn
IsOn    SPACE   BYTE    ;Boolean for if bike is on
		ALIGN		;Word align

;------------------------------------------------------
;					Constants

		AREA	Constants,DATA,READONLY

;Begin constants

		ALIGN		;Word align
;------------------------------------------------------
		END
