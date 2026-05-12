             /
             / PDP-8 WORKBOOK
             / CHAPTER 5
             / EXERCISE 1
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 MAY 12, 2026
             /
       0000          FIELD 0
       0200          *0200
             /
             / GOAL: OS/8 SAFE PROGRAM EXIT
             / THE CONTENTS OF THE PROGRAM DON'T REALLY MATTER MUCH HERE

             / I AM JUST GOING TO CREATE A 12 BIT COUNTER AS A QUICK AND

             / EASY ROUTINE.
00200  7300          CLA CLL
00201  7001  LOOP,   IAC
00202  7430          SZL
00203  5205          JMP     FLDCHG  /JUMP OUT WHEN AC OVERFLOWS
00204  5201          JMP     LOOP
00205  6213  FLDCHG, CIF CDF 10      /CHANGE IF & DF TO 1
00206  5200          JMP     FLDCAP  /FORCE THE IF CHANGE

             /EXECUTION CONTINUES IN FIELD1
       0001          FIELD   1
       0200          *0200
10200  6214  FLDCAP, RDF             /CAPTURE FOR VALIDATION AT HLT
10201  3300          DCA     DF
10202  6224          RIF
10203  3301          DCA     IF
10204  7402          HLT
10205  6203          CIF CDF 0       /CHANGE BACK TO FIELD 0
10206  5230          JMP     OS8RET

             /EXECUTION RETURNS TO FIELD 0
       0000          FIELD   0
       0230          *0230           /NEED NEW ORIGIN, OTHERWISE 0200
00230  5777  OS8RET, JMP I   (7600)

00377  7600
       0001          FIELD   1
       0300          *0300
10300  0000  DF,     0
10301  0000  IF,     0
             $


DF     0300
FLDCAP 0200
FLDCHG 0205
IF     0301
LOOP   0201
OS8RET 0230


ERRORS DETECTED: 0
LINKS GENERATED: 0