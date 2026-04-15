             ///////////////////////////////
             / SIMPLE TWO VALUE ADDER
             / JEREMY PASTIN
             / 3-25
             / PAL8 ASSEMBLY
             ///////////////////////////////

             /ADD VARIALBE 'A' TO VARIABLE 'B', STORING THE RESULT IN
             / VARIABLE 'B'.  REPEAT UNTIL THE VALUE EXCEEDS THE
             / CAPACITY OF THE ACCUMULATOR.

       0200  *200
00200  7200          CLA             /CLEAR AC
00201  7100          CLL             /CLEAR L
00202  0003  A,      0003            /DEFINE A
00203  0000  B,      0000            /DEFINE B
00204  0001  DELAY,  0001            /CREATE A DELAY COUNTER
00205  7000  LOOP,   NOP             /DEFINE THE START OF THE LOOP
00206  3203          DCA B           /DEPOSIT AC INTO B
00207  1202          TAD A           /ADD A TO AC
00210  1203          TAD B           /ADD B TO AC

00211  2204          ISZ DELAY       /THIS LOOP SLOWS THINGS DOWN ENOUGH

                                     / FOR HUMANS TO PERCIEVE THE
                                     / CHANGES ON THE BLINKENLIGHTS.
00212  5211          JMP .-1
00213  2204          ISZ DELAY       /THIS LOOP SLOWS THINGS DOWN ENOUGH

                                     / FOR HUMANS TO PERCIEVE THE
                                     / CHANGES ON THE BLINKENLIGHTS.
00214  5213          JMP .-1
00215  2204          ISZ DELAY       /THIS LOOP SLOWS THINGS DOWN ENOUGH

                                     / FOR HUMANS TO PERCIEVE THE
                                     / CHANGES ON THE BLINKENLIGHTS.
00216  5215          JMP .-1

00217  7420          SNL             /SKIP IF AC OVERFLOWED INTO L
00220  5205          JMP LOOP        /JUMP TO THE TOP OF THE LOOP
00221  5777'         JMP 7600        /RETURN TO OS/8
00377  7600
             $


A      0202
B      0203
DELAY  0204
LOOP   0205


ERRORS DETECTED: 0
LINKS GENERATED: 1
