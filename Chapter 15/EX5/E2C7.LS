             /
             / PDP-8 WORKBOOK
             / CHAPTER 7
             / EXERCISE 2
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 JULY 24, 2026
             /
       0000          FIELD 0
       0200          *0200
             /
             / GOAL: UNDERSTAND THE SV FILE FORMAT

000200  7300         CLA CLL
000201  7001  START, IAC
000202  7430         SZL
000203  5205         JMP     MQINC
000204  5201         JMP     START

000205  7300  MQINC, CLA CLL
000206  7501         MQA
000207  7001         IAC
000210  7430         SZL
000211  5777'        JMP     OS8RET
000212  7421         MQL
000213  5201         JMP     START

000377  0600
       0600          *0600
000600  7300  OS8RET,        CLA CLL
000601  7421         MQL
000602  6203         CDF CIF 0
000603  5777         JMP I   (7600)
000777  7600
             $


MQINC  0205
OS8RET 0600
START  0201


ERRORS DETECTED: 0
LINKS GENERATED: 1
