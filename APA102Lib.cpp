/* library.cpp (change this)
 * Library for APA102 LED strips with KL46Z*/

/*Includes*/
#include "Controller.h"
#include "Animations.h"

/*Defines to make life easier*/
#define WHITE	0x00FFFFFEu
#define AMBER	0x0000C2FFu
#define	NOCOLOR	0x00000000u


/*Creating Class to control LED Strips currently super BETA
Never written CPP before as well
In current state, only uses specifically KL46Z SPI0*/

class APA102LedStrip
{
    public:
        APA102LedStrip()
        {
            initSPI();
            LEDStripSize=1;
            setSPIBaud(0);
        }

        APA102LedStrip(int StripSize, char Speed)
        {
            initSPI();
            LEDStripSize = StripSize;
            setSPIBaud(Speed);
        }

        void setSpeed(char newSpeed)
        {
            setSPIBaud(newSpeed);
        }

        void setStrip(int BGRValue)
        {
						startFrame();
            for(int i = 0; i <= LEDStripSize; i++)
            {
                setColor(BGRValue);
            }
        }

        void resetSize(int NewSize)
        {
            LEDStripSize = NewSize;
        }
				
				void reverseSequentialPattern(bool TruthCondition)
				{
					int b = 0;                            /*Deficit loop counter*/
					int c = 0; 				              /*Loop counter for amber loop*/
					signed int deficit = LEDStripSize-1;        /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
					int setamber = (LEDStripSize/2 + LEDStripSize/4); /*Set 3/4 LEDS to Amber*/
					int loops = LEDStripSize+setamber; 		  /*Maximum number of loops*/

					/*While the truth condition is satisfied, loop is executed*/
					while(TruthCondition == true)
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
						for (loops = 0; loops <= LEDStripSize; loops++)
									{setColor(NOCOLOR);}
									
						/*This statement catches the end of the animation and resets variables to the defaults*/
						if (deficit+setamber <= 0)
						{
							/*This is in here as the arithmetic was a bit dodgey during testing*/
							/*This catch fixed any errors that were encountered*/
							/*I assume this has something to do with negative arithmetic, but I don't know for sure*/
							if (setamber ==0)
							{
								deficit=LEDStripSize-1;
								setamber=(LEDStripSize/2)+(LEDStripSize/4);
							}
						}
					}
				}
				
				void sequentialPattern(bool TruthCondition)
				{
					int c = 0; 				                    /*Loop counter for amber loop*/
					int loop = 1; 		                    /*Loop counter for main loop*/
					int deficit = 0;                      /*Number of LEDS to set to NOCOLOR at beginning of transmission*/
					int setamber = (LEDStripSize/2 + LEDStripSize/4); /*Set 3/4 LEDS to Amber*/

					/*Loop until the truth condition is set to FALSE via interrupt*/
					while(TruthCondition == true)
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
								if (deficit > LEDStripSize)
								{
									deficit =0;
								}
							}
						}
						/*Increment the loop number; reset if > the number of LEDs and the # to be set to amber*/
						loop++;
						if (loop > (setamber + LEDStripSize))
						{
							loop = 1;
						}
					}
					return;
				}



    private:
        int LEDStripSize;

};

