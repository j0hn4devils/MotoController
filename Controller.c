/*Controller.c*/
/*Uses ASM Libraries to perform desired functions*/
/*Written by: John DeBrino*/
/*Revision Date: 1/25/2016*/

/*								Includes							  */
#include "Controller.h"
#include "Animations.h"

/*								Defines 							  */
#define LED_STRIP_SIZE	43		/* # of LEDs in strip */
#define TRUE 1
#define FALSE 0

/*								Colors								  */
/*						 (BGR Values)							      */
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
    
    setSignal(TRUE,TRUE);   /*Allow transmit to both LED strips*/
    setStrip(LED_STRIP_SIZE, WHITE, 0xFF); /*Set the strips */
    setSignal(FALSE,FALSE); /*Cleanup*/
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

	initSPI();
	initPITInterrupt();
	initPTAInterrupt();
    
    /*Remove the following initialization on implementation to main*/
    /*Move to the "if (Running == True)" statement*/
    initRunningLights();
    
	__asm("CPSIE	I");

	/*Main loop*/

	/*Main is currently being used to test features as they are being developed*/
	for(;;)
	{
		/*If the bool for turning has been set for true, run the*/
		/*Sequential pattern until the bool is reset to false*/
		if (Turning == TRUE)
		{
			reverseSequentialPattern(LED_STRIP_SIZE,&Turning,0x43);
			setStrip(LED_STRIP_SIZE,WHITE,0x0F);
		}

	}
}
