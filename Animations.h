/*Header for Animations.c*/
/*Allows access of Animations functions in Controller*/
/*Written by: John DeBrino*/
/*Revision Date: 2/24/2017*/

extern void sequentialPattern(int NumLED, char *TruthCondition, char Speed);
extern void reverseSequentialPattern(int NumLED, char *TruthCondition, char Speed);
extern void setStrip(int NumLED, int Color, int Speed);
extern void reverseSetStrip(int NumLED, int Color, int Speed);
