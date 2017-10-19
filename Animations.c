/*Animations.c*/
/*Uses ASM Libraries to drive various LED animations*/
/*Written by: John DeBrino*/
/*Revision Date: 2/24/2016*/

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

/*sequentialPattern*/
/*Displays the turning pattern to the LED strip selected by microcontroller*/
/*Input: Number of LEDs in strip, Condition for animation to loop until false, speed of transfer*/
/*Output: LED Strip Colors*/
/*Problems: Pattern is inefficient, Pattern is not needed for current implementation*/

void sequentialPattern(int NumLED, volatile char *TruthCondition, char Speed)
{
	int c = 0; 				                    /*Loop counter for amber loop*/
	int loop = 1; 		                    /*Loop counter for main loop*/
	int deficit = 0;                      /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
	int setamber = (NumLED/2 + NumLED/4); /*Set 3/4 LEDS to Amber*/

	/*Set baud for appropriate speed*/
	setSPIBaud(Speed);

	/*Loop until the truth condition is set to FALSE via interrupt*/
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
			
		/*Loop LEDS to recieve amber color, set deficit */
    /*(Number of LEDs to recieve no color before AMBER LEDs are written)*/
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
		/*Increment the loop number; reset if > the number of LEDs and the # to be set to amber*/
		loop++;
		if (loop > (setamber + NumLED))
		{
			loop = 1;
		}
	}
	return;
}


/*reverseSequentialPattern*/
/*Displays the turning pattern to the LED strip selected by microcontroller; pattern is reverse of the normal sequential one*/
/*Input: Number of LEDs in strip, Condition for animation to loop until false, speed of transfer*/
/*Output: LED Strip Colors*/
void reverseSequentialPattern(int NumLED, volatile char *TruthCondition, char Speed)
{
	int b = 0;                            /*Deficit loop counter*/
	int c = 0; 				              /*Loop counter for amber loop*/
	signed int deficit = NumLED-1;        /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
	int setamber = (NumLED/2 + NumLED/4); /*Set 3/4 LEDS to Amber*/
	int loops = NumLED+setamber; 		  /*Maximum number of loops*/

	/*Set baud for appropriate speed*/
	setSPIBaud(Speed);
	
  /*While the truth condition is satisfied, loop is executed*/
  while(*TruthCondition == TRUE)
  {
    /*Send a start frame to begin transmission*/
    startFrame();
  
    /*loop LEDs to recieve no color*/
    /*This is the deficit, and decreases every iteration*/
    for (c = 0; c <= deficit; c++)  
    {
      setColor(NOCOLOR);
    }
    /*Decrement the deficit (thats pleasing to say outloud)*/
    deficit--;
    
    /*Loop LEDs to recieve the amber color*/
    for (b=0; b<= setamber;b++)
    {
      setColor(AMBER);
    }
    
    /*If the deficit is below zero, start subtracting from setAmber*/
    /*This causes the sliding motion*/
    
    if (deficit <= 0)
    {
      setamber--;
    }
    
    /*This is currently a brute force way to set LEDs that are after*/
    /*the amber ones to off. A better implementation will be thought of later on*/
    for (loops = 0; loops <= NumLED; loops++)
          {setColor(NOCOLOR);}
          
    /*This statement catches the end of the animation and resets variables to the defaults*/
    if (deficit+setamber <= 0)
    {
      /*This is in here as the arithmetic was a bit dodgey during testing*/
      /*This catch fixed any errors that were encountered*/
      /*I assume this has something to do with negative arithmetic, but I don't know for sure*/
      if (setamber ==0)
      {
        deficit=NumLED-1;
        setamber=(NumLED/2)+(NumLED/4);
      }
    }
  }
}


/*setStrip*/
/*Sets entire strip to desired color*/
/*Input: Size of LED strip (in LEDs), Color of LEDs, Speed of Transfer*/
/*Output: Cleared LED strip*/

void setStrip(int NumLED, int Color, int Speed)
{

	int iterator = 0;	/*Instantiate and iterator*/

	/*Set baud rate for fastest transfer speed*/
	setSPIBaud(Speed);
    
	/*Send start frame*/
	startFrame();
	
	/*Send the color over the strip*/
	for(; iterator <= NumLED; iterator++)
	{
		setColor(Color);
	} 
	/*Done with transfer*/
	return;	
}


/*In development*/
/*Goal is to set a strip from the last LED to the first LED*/
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
