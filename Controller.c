/*Controller.c*/
/*Uses ASM Libraries to perform desired functions*/
/*Written by: John DeBrino*/
/*Revision Date: 2/24/2016*/

/*								Includes							  */
#include "Controller.h"
#include "Animations.h"

/*								Defines 							  */
#define LED_STRIP_SIZE	43		/* # of LEDs in strip */
#define TRUE 1
#define FALSE 0

/*								Colors								  */
/*				     (BGR Values)							  */
#define WHITE	(0x00FFFFFEu)
#define AMBER	(0x0000C2FFu)
#define	NOCOLOR	(0x00000000u)

/*								  Code								  */

/*initRunningLights*/
/*Initializes the running lights for normal operation*/
/*Inputs: takes no inputs*/
/*Outputs: Initalizes the running lights to white*/
void initRunningLights(void)
{
    setSignal(FALSE,FALSE);   /*Allow transmit to both LED strips*/
    setStrip(LED_STRIP_SIZE, WHITE, 0xFF); /*Set the strips */
    setSignal(TRUE,TRUE); /*Cleanup*/
}


/*turnOffLights*/
/*Turns off lights for when bike is off*/
/*Inputs: takes no inputs*/
/*Outputs: Initalizes the running lights to OFF*/
void turnOffLights(void)
{
    setSignal(FALSE,FALSE);   /*Allow transmit to both LED strips*/
    setStrip(LED_STRIP_SIZE, NOCOLOR, 0xFF); /*Set the strips */
    setSignal(TRUE,TRUE); /*Cleanup*/
}


/*Main code; runs on startup*/
int main(void)
{
	int FirstLoop = TRUE;   /*Used to tell if first loop since bike has been powered on/off*/

	/*Board initializations*/
 	__asm("CPSID	I");

	initSPI();
	/*initPITInterrupt();*/
	initPTAInterrupt();
	initVars();

	__asm("CPSIE	I");

  /*Do forever*/
  for(;;)
  {

  /*Execute while bike is on*/
	while(IsOn == TRUE)
  {
    /*If its the first loop, run the init pattern*/
    if(FirstLoop == TRUE)
    {
      initRunningLights();
      FirstLoop = FALSE;
    }
    /*Execute if turn signal is on*/
    while(Turning == TRUE)
    {
      /*Send the reverse pattern to the strips*/
      reverseSequentialPattern(LED_STRIP_SIZE,&Turning,0x44);
      /*__asm("CPSID    I")*/
      setStrip(LED_STRIP_SIZE,WHITE,0x45);
      /*__asm("CPSIE    I")*/
    }

  }
  /*Reset first loop identifier*/
  FirstLoop = TRUE;

  /*Execute while bike is off*/
  while (IsOn == FALSE)
  {
    /*If it's the first loop, turn off the lights, please*/
    if (FirstLoop == TRUE)
    {
      turnOffLights();
      FirstLoop = FALSE;
    }


    /*Alarm like stuff to be implemented at a later date*/
    /*No timeframe will be given as I have been very busy*/
  }

  /*Reset first loop identifier*/
  FirstLoop = TRUE;

  }
}
