/*Controller.c*/
/*Uses ASM Libraries to perform desired functions*/
/*Written by: John DeBrino*/
/*Revision Date: mm/dd/yyyy*/

/*								Includes							*/
#include "Controller.h"

/*								Defines 							*/
#define WHITE	(0x00FFFFFFu)
#define AMBER	(0x00FFC200u)
#define	NOCOLOR	(0x00000000u)

/*								  Code								*/
int main(void)
{
	
	/*Board initializations*/
	__asm("CPSID	I");
	
	initGPIOLightDataOut();
	initPITInterrupt();
	
	__asm("CPSIE	I");
	
	/*Main loop*/
	for(;;)
	{
		setColor(WHITE);
	}
	
	return 0;
}
