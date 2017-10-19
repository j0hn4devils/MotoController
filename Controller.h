/*Header for Controller.c*/
/*Allows access to ASM Libraries*/
/*Written by: John DeBrino*/
/*Revision Date: 2/24/2016*/

/*						Variables					*/
extern volatile char *Turning;
extern volatile char IsOn;


/*						typedef						*/
typedef int Int32;
typedef short int Int16;
typedef char Int8;
typedef unsigned int UInt32;


/*                     Controller.s                 */
void initPITInterrupt(void);
void initSPI(void);
void wait(int ms);
void setSPIBaud(int BaudRate);
void initPTAInterrupt(void);
void setSignal(char LeftTurnBool, char RightTurnBool);
void initVars(void);


/*					    Lighting.s					*/
void setColor(int Color);
void startFrame(void);
void endFrame(void);
