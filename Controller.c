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
	int b = 0; 				/*Loop counter for deficit loop*/
	int c = 0; 				/*Loop counter for amber loop*/
	int loop = 1; 		/*Loop counter for main loop*/
	int deficit = 0; /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
	int setamber = (NumLED/2 + NumLED/4); /*Set 3/4 LEDS to Amber*/

	/*Set baud for appropriate speed*/
	setSPIBaud(0x33);
	
	/*Infinite loop as placeholder*/
	/*Will be replaced with while (var == TRUE)*/
  for(;;)
	{
		
		/*Transmit a start frame*/
		startFrame();
		
		/*Loop LEDS to recieve no color*/
		/*Reset deficit to 0*/
		for (deficit; deficit > 0; deficit--)
		{
			setColor(NOCOLOR);
		}
			
		/*Loop LEDS to recieve amber color, set deficit*/
		for (c = 0; c <= loop; c++)
		{
			if (c <= setamber)
			{
				setColor(AMBER);
			}
			else
			{
				deficit++;
				if (deficit > NumLED)
				{
					deficit =0;
				}
			}
		}
			
		/*Transmit start frame as end frame, as APA102 Protocol doesn't differentiate*/
		/*an end frame from a white color transfer*/
		startFrame();
		loop++;
		if (loop > (setamber + NumLED))
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




