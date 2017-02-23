# MotoController
Project for NXP KL46. Goal of project is to create sequential LED turn signals, headlight controller,
and an alarm system to be used for motorcycles.

Turn signal/Running light implementation is nearing completeion, and only requires validation at this point (but watch that take a week or two)

Project Description:

This project implements the running light / turn signal combo using an RGB LED strip that is writable via Serial Peripheral Interface (SPI). This was done to prevent any headaches that could arise using a PWM controlled strip due to the strict timing requirements to run them. The lighting libraries were written and exist in Lighting.s (For direct interaction with the strip(s)) and Animations.c (For animation patterns)

Controller.s Holds all of the initalization code that is called in the main in Controller.c, as well as Interrupt Service Routines (ISRs) and a few utility functions, such as setSPIBaud(). The main ISR of importance is the PORTA ISR. This is the ISR that drives the modes and status of the KL46. Before further explaination, the pinouts of the PORTA pins are as follows:

PTA16: Multiplexed for MOSI for SPI0

PTA15: Multiplexed for SCK for SPI0

PTA6:  Rising/Falling sensitive input for determining if bike is on

PTA7:  Rising/Falling sensitive input for determining if the turn signals are activated

PTA5&4:Rising sensitive inputs for determining which turn signal is activated

PTA2&1:Outputs for hardware MUX to control only certain strips with 1 SPI

PTA16 and 15 are self explanatory

PTA6 connects to any circuit to the bike that will be powered if the bike is on (For my implementation, it is connected to the auxilary lighting circuit) and will toggle the boolean IsOn, which is how the KL46 keeps track of if the bike is on.

PTA7 connects to the relay + and will toggle the boolean IsTurning, which is self explainatory as to it's function

PTA5 and PTA4 will connect to the left and right turn signals and if one of these pins interrupts, the output of the SPI will be sent to the corrosponding stripby means of setting the output of Pins 1 and 2 to either high or low. Both SCK and MOSI are connected to multiplexors whose select lines are these outputs. This allows the output to be done by a single SPI as opposed to 2

PTA2 and PTA1 were described in the previous section

Note: You may be wondering why the PTA4, PTA5, and PTA7 interrupts exist as is and may think, "Can't he just wire into the turn signals and only use 2 inputs?" Unfortunately, I don't have that level of access to the bike and can only get access to an interrupted current from each turn signal (because they are obviously designed to flash). Since the relay is what causes the flashing, the positive input to the relay will always be high whenever the signals are activated, so that is used for determining if the turn signals have been activated, rather than the lines going directly to the signals, which will have a current interval. The signal inputs themselve will only determine which signal was activated. This was seen as a better solution than a software delay, which could introduce more problems.

All of these booleans that were changed are accessed in Controller.c to determine which code needs to be run (Are we in a turning scenario, is the bike even on, etc).

Hopefully this has provided a broad overview of how this project works and how to possibly wire it up yourself. If you have any questions, comments, or concerns, you can email me at either jgd5171@g.rit.edu or johndebrino@gmail.com
