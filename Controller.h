/*Header for Controller.c*/
/*Allows access toi ASM Libraries*/
/*Written by: John DeBrino*/
/*Revision Date: mm/dd/yyyy*/

/*						typedef						*/
typedef int Int32;
typedef short int Int16;
typedef char	int8;
typedef unsigned int UInt32;


/*         Controller.s         */
extern void initGPIOLightDataOut(void);
extern void initPITInterrupt(void);
extern void initDAC0(void);
/*					Lighting.s					*/
extern void setColor(int Color);
