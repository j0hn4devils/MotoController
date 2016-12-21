/*Controller.c*/
/*Uses ASM Libraries to perform desired functions*/
/*Written by: John DeBrino*/
/*Revision Date: mm/dd/yyyy*/

/*								Includes							*/
#include "Controller.h"

/*								Defines 							*/
#define LED_STRIP_SIZE	30 /* # of LEDs in strip */

/*								Colors								*/
#define WHITE	(0x00FFFFFFu)
#define AMBER	(0x00FFC200u)
#define	NOCOLOR	(0x00000000u)

/* 									DAC 								*/
#define EN_PTE	(0x00001000u)
#define EN_DAC	(0x80000000u)
#define DAC0_OUT (0x01000000u)
#define BUF_DISABLE (0x00u)
#define EN_C0 (0xC0u)
#define DATH_MIN (0x00u)
#define DATL_MIN (0x00u)
/*								  Code								*/

/*							Initializations					*/

void initDAC0()
{
  /* Enable TPM0 module clock */
  SIM->SCGC6 |= EN_DAC;
  /* Enable port E module clock */
  SIM->SCGC5 |= EN_PTE;
  /* Connect DAC0_OUT to Port E Pin 30 (J4 Pin 11) */
  PORTE->PCR[30] = DAC0_OUT;
  /* Set DAC0 DMA disabled and buffer disabled */
  DAC0->C1 = BUF_DISABLE;
  /* Set DAC0 enabled with VDDA as reference voltage */
  /* and read pointer interrupts disabled            */
  DAC0->C0 = EN_C0;
  /* Set DAC0 output voltage at minimum value */
  DAC0->DAT[0].DATL = DATH_MIN;
  DAC0->DAT[0].DATH = DATL_MIN;
}

/*Main code; runs on startup*/
int main(void)
{

	/*Board initializations*/
	__asm("CPSID	I");

	initGPIOLightDataOut();
	initPITInterrupt();
	initADC();

	__asm("CPSIE	I");

	/*Main loop*/
	for(;;)
	{
		setColor(WHITE);
	}

	return 0;
}
