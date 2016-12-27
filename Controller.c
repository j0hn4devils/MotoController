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
#define SIM (0x40047000u)
#define SCGC6 (0x103Cu)
/*								  Code								*/

/*Main code; runs on startup*/
int main(void)
{
	int x = 0;
	int y = 0;
	int z = 0;

	/*Board initializations*/
 	__asm("CPSID	I");

	/*initGPIOLightDataOut();*/
	initSPI();
	initPITInterrupt();

	__asm("CPSIE	I");

	/*Main loop*/
	for(;;)
	{
		for(x=0; x <= 20; x++){
			setColor(WHITE);
		}
		for(y=0; y <= 20; y++){
			setColor(AMBER);
		}
		for(z=0; z <= 20; z++){
			setColor(NOCOLOR);
		}
	}

	return 0;
}
