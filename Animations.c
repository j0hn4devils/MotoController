/*Animations.c*/
/*Uses ASM Libraries to drive various LED animations*/
/*Written by: John DeBrino*/
/*Revision Date: 2/1/2016*/

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

void sequentialPattern(int NumLED, char *TruthCondition, char Speed)
{
	int c = 0; 				/*Loop counter for amber loop*/
	int loop = 1; 		/*Loop counter for main loop*/
	int deficit = 0; /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
	int setamber = (NumLED/2 + NumLED/4); /*Set 3/4 LEDS to Amber*/

	/*Set baud for appropriate speed*/
	setSPIBaud(Speed);

	/*Separate allocation in memory?*/
  while(*TruthCondition == TRUE)
	{
		
		/*Transmit a start frame*/
		startFrame();
		
		/*Loop LEDS to recieve no color*/
		/*Reset deficit to 0*/
		for (; deficit > 0; deficit--)
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


void reverseSequentialPattern(int NumLED, char *TruthCondition, char Speed)
{
  int b = 0;                            /*Deficit loop counter*/
	int c = 0; 				                    /*Loop counter for amber loop*/
	signed int deficit = NumLED-1;               /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
	int setamber = (NumLED/2 + NumLED/4); /*Set 3/4 LEDS to Amber*/
  int loops = NumLED+setamber; 		      /*Maximum number of loops*/

	/*Set baud for appropriate speed*/
	setSPIBaud(Speed);
  while(*TruthCondition == TRUE)
  {
  startFrame();
  
  for (c = 0; c <= deficit; c++)  
  {
    setColor(NOCOLOR);
  }
  deficit--;
  for (b=0; b<= setamber;b++)
  {
    setColor(AMBER);
  }
	if (deficit <= 0)
		{setamber--;}
	for (loops = 0; loops <= 144; loops++)
        {setColor(NOCOLOR);}
  if (deficit+setamber <= 0)
  {
		if (setamber ==0)
		{
    deficit=NumLED-1;
		setamber=(NumLED/2)+(NumLED/4);
		}
  }
  startFrame();
  }
  

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
    
    /*Send start frame*/
    startFrame();
	
	for(; iterator <= NumLED; iterator++)
	{
		setColor(Color);
	}
    
	return;	
}

void reverseSetStrip(int NumLED, int Color, int Speed)
{
    int iterator = 0;
    int deficit = NumLED-1;
    int temp = 0;
    
    setSPIBaud(Speed);
    
    for(; iterator <= NumLED; iterator++)
    {
        for(; deficit >0; deficit--)
        {
            setColor(NOCOLOR);
        }
        for(; temp <= NumLED; deficit++)
        {
            setColor(Color);
        }
    deficit--;
    }
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
	setSPIBaud(0x33);
	
	for(; AmberIterator <= NumLED; AmberIterator++)
	{
		setColor(AMBER);
	}
	for(; ClearIterator <= NumLED; ClearIterator++)
	{
		setColor(NOCOLOR);
	}
}
