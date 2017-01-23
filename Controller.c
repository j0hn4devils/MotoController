/*Controller.c*/
/*Uses ASM Libraries to perform desired functions*/
/*Written by: John DeBrino*/
/*Revision Date: 1/17/2016*/

/*								Includes							*/
#include "Controller.h"
#include "Animations.h"
/*								Defines 							*/
#define LED_STRIP_SIZE	144						 /* # of LEDs in strip */

/*								Colors								*/
/*						 (BGR Values)							*/
#define WHITE	(0x00FFFFFEu)
#define AMBER	(0x0000C2FFu)
#define	NOCOLOR	(0x00000000u)

/*								  Code								*/

/*Main code; runs on startup*/
int main(void)
{
	/*int x = 0;
	int y = 0;
	int z = 0;
	*/
	
	/*Board initializations*/
 	__asm("CPSID	I");

	initSPI();
	initPITInterrupt();
	initPTAInterrupt();

	__asm("CPSIE	I");

	/*Main loop*/

	/*Main is currently being used to test features as they are being developed*/
	for(;;)
	{
		sequentialPattern(144,Turning);
		setStrip(144,WHITE,0x00);
		wait(100);
	}

	return 0;
}




