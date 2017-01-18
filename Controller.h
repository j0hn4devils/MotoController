/*Header for Controller.c*/
/*Allows access toi ASM Libraries*/
/*Written by: John DeBrino*/
/*Revision Date: 12/26/2016*/

/*						typedef						*/
typedef int Int32;
typedef short int Int16;
typedef char	int8;
typedef unsigned int UInt32;


/*         Controller.s         */
void initGPIOLightDataOut(void);
void initPITInterrupt(void);
void initSPI(void);
void wait(int ms);
void setSPIBaud(int BaudRate);

/*					Lighting.s					*/
void setColor(int Color);
void startFrame(void);
void endFrame(void);
