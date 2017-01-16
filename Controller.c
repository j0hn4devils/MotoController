/*Controller.c*/
/*Uses ASM Libraries to perform desired functions*/
/*Written by: John DeBrino*/
/*Revision Date: 12/26/2016*/

/*								Includes							*/
#include "Controller.h"

/*								Defines 							*/
#define LED_STRIP_SIZE	30 /* # of LEDs in strip */

/*								Colors								*/
#define WHITE	(0x00FFFFFEu)
#define AMBER	(0x00FFC200u)
#define	NOCOLOR	(0x00000000u)

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

	/*Main is currently being used to test features as they are being developed*/
	for(;;)
	{
		startFrame();
		startFrame();
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(WHITE);
		setColor(AMBER);
		endFrame();
		endFrame();
	}

	return 0;
}
