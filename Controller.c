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


/*turnPattern*/
/*Displays the turning pattern to the LED strip selected by microcontroller*/
/*Input: Number of LEDs in strip*/
/*Output: LED Strip Colors*/

void turnPattern(int NumLED)
{
	int a = 0;
	int loop = 0;
	int setAmber = ((NumLED/3)*2); /*Set 2/3 LEDS to Amber*/
	unsigned int Color = AMBER;

	/*Infinite loop as placeholder*/
	/*Will be replaced with while (var == TRUE)*/
  for(;;)
	{
		Color --;
		startFrame();
		startFrame();
		for(a = 0; a<= NumLED; a++)
		{
			/*
			if (loop <= a < setAmber)
			{
				setColor(AMBER);
			}
			else
			{
				setColor(NOCOLOR);
			}
			*/
			setColor(Color);
			
		}
		startFrame();
		startFrame();
		startFrame();
		startFrame();
		loop++;
		if (loop == (setAmber + NumLED))
		{
			loop =0;
		}

	}
	return;
}



/*Main code; runs on startup*/
int main(void)
{
	/*int x = 0;
	int y = 0;
	int z = 0;
	*/
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
		turnPattern(144);
	}

	return 0;
}




