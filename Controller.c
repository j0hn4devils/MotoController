/*Controller.c*/
/*Uses ASM Libraries to perform desired functions*/
/*Written by: John DeBrino*/
/*Revision Date: 1/17/2016*/

/*								Includes							*/
#include "Controller.h"

/*								Defines 							*/
#define LED_STRIP_SIZE	30 /* # of LEDs in strip */

/*								Colors								*/
/*						 (BGR Values)							*/
#define WHITE	(0x00FFFFFEu)
#define AMBER	(0x0000C2FFu)
#define	NOCOLOR	(0x00000000u)

/*								  Code								*/


/*turnPattern*/
/*Displays the turning pattern to the LED strip selected by microcontroller*/
/*Input: Number of LEDs in strip*/
/*Output: LED Strip Colors*/

void turnPattern(int NumLED)
{
	int a = 0;
	int b = 0;
	int c = 0;
	int loop = 1;
	int deficit = 0;
	int setamber = (NumLED/2); /*Set 1/2 LEDS to Amber*/

	/*Infinite loop as placeholder*/
	/*Will be replaced with while (var == TRUE)*/
  for(;;)
	{
		startFrame();
		startFrame();
		/*Set entire strip*/
		
			for (b = deficit; b > 0; b--)
			{
				setColor(NOCOLOR);
			}
			for (c = 0; c <= loop; c++)
			{
				if (c <= setamber)
				{
					setColor(AMBER);
				}
				else
				{
					deficit++;
					if (deficit >= NumLED)
					{
						deficit =0;
					}
				}
			}
		
		startFrame();
		startFrame();
		startFrame();
		startFrame();
		loop++;
		if (loop >= (setamber + NumLED))
		{
			loop = 1;
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




