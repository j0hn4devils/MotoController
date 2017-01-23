/*Animations.c*/
/*Uses ASM Libraries to drive various LED animations*/
/*Written by: John DeBrino*/
/*Revision Date: 1/18/2016*/

/*								Includes							*/
#include "Controller.h"

/*								Defines 							*/

#define TRUE (0x01u)

/*								Colors								*/
/*						 (BGR Values)							*/
#define WHITE	(0x00FFFFFEu)
#define AMBER	(0x0000C2FFu)
#define	NOCOLOR	(0x00000000u)



/*								  Code								*/

/*turnPattern*/
/*Displays the turning pattern to the LED strip selected by microcontroller*/
/*Input: Number of LEDs in strip, Condition for animation to loop until false*/
/*Output: LED Strip Colors*/

void sequentialPattern(int NumLED, char TruthCondition)
{
	int c = 0; 				/*Loop counter for amber loop*/
	int loop = 1; 		/*Loop counter for main loop*/
	int deficit = 0; /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
	int setamber = (NumLED/2 + NumLED/4); /*Set 3/4 LEDS to Amber*/

	/*Set baud for appropriate speed*/
	setSPIBaud(0x32);

	/*Ask Melton as to why using TruthCondition will not work (Separate allocation in memory?)*/
  while(Turning == TRUE)
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
	startFrame();
	return;
}

/*setStrip*/
/*Sets entire strip to desired color*/
/*Input: Size of LED strip (in LEDs)*/
/*Output: Cleared LED strip*/

void setStrip(int NumLED, int Color, int Speed)
{

	int iterator = 0;

	/*Set baud rate for fastest transfer speed*/
	setSPIBaud(Speed);
	
	for(iterator; iterator <= NumLED; iterator++)
	{
		setColor(Color);
	}
	return;	
}

/*slidePattern*/
/*Alternate LED animation that produces a sliding pattern*/
/*Input: Number of LEDs in strip*/
/*Output: LED animation*/

void slidePattern(int NumLED)
{
	int AmberIterator = 0;
	int ClearIterator = 0;
	
	/*Set baud rate low for proper animation*/
	setSPIBaud(0x77);
	
	for(AmberIterator; AmberIterator <= NumLED; AmberIterator++)
	{
		setColor(AMBER);
	}
	for(ClearIterator; ClearIterator <= NumLED; ClearIterator++)
	{
		setColor(NOCOLOR);
	}
}
