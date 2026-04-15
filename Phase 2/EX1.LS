             /
             / PDP-8 WORKBOOK
             / PHASE 2
             / EXERCISE 1
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.1 APRIL 7, 2026
             /

       0200  *0200

             /
             / GOAL: RETURN THE ABSOLUTE VALUE OF A GIVEN INPUT NUMBER
             /


             /NEGATIVE NUMBER
00200  7300          CLA CLL
00201  1377          TAD     (-1234) /-1234 = -668.
00202  3217          DCA     INPUT
00203  4776          JMS I   (ABSVAL)
00204  7402          HLT

             /ZERO
00205  7300          CLA CLL
00206  3217          DCA     INPUT
00207  4776          JMS I   (ABSVAL)
00210  7402          HLT

             /POSITIVE NUMBER
00211  7300          CLA CLL
00212  1375          TAD     (1234)  /1234=668.
00213  3217          DCA     INPUT
00214  4776          JMS I   (ABSVAL)
00215  7402          HLT

             /RETURN TO OS/8
00216  5774          JMP I   (7600)

00217  0000  INPUT,  0
00220  0000  OUTPUT, 0

00374  7600
00375  1234
00376  0400
00377  6544
       0400  *0400
             /ABSVAL -- COMPUTE THE ABSOLUTE VALUE
             /ENTRY: INPUT=SIGNED 12 BIT VALUE
             /EXIT:  OUTPUT=INPUT; AC LOST
00400  0000  ABSVAL, 0
00401  1777          TAD I   (INPUT)
00402  7510          SPA
00403  7041          CIA
00404  3776          DCA I   (OUTPUT)
00405  5600          JMP I   ABSVAL
00576  0220
00577  0217
             $


ABSVAL 0400
INPUT  0217
OUTPUT 0220