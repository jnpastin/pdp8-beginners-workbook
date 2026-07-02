             /
             / PDP-8 WORKBOOK
             / CHAPTER 7
             / EXERCISE 1
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 JULY 2, 2026
             /
       0000          FIELD 0
       0200          *0200
             /
             / GOAL: UNDERSTAND THE BN FILE FORMAT

00200  7300          CLA CLL
00201  7421          MQL             /CLEAR AC, L, MQ
00202  7001  TOP,    IAC             /INCREMENT AC
00203  7430          SZL             /INCREMENT MQ IF AC OVERLOADS
00204  5206          JMP     MQINC
00205  5202          JMP     TOP

00206  7300  MQINC,  CLA CLL         /AC & L ARE ALL 1S AT THIS POINT
00207  7501          MQA             /PULL MQ INTO EMPTY AC
00210  7001          IAC
00211  7430          SZL
00212  5215          JMP     OS8RET  /RETURN TO OS/8 IF MQ OVERLOADS
00213  7421          MQL             /PUSH BACK INTO MQ, CLEAR AC
00214  5202          JMP     TOP     /START INCREMENTING AC AGAIN

00215  6203  OS8RET, CIF CDF 0
00216  5777          JMP I   (7600)  /RETURN TO OS/8
00377  7600
             $


MQINC  0206
OS8RET 0215
TOP    0202


ERRORS DETECTED: 0
LINKS GENERATED: 0

