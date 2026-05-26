             /
             / PDP-8 WORKBOOK
             / CHAPTER 6
             / EXERCISE 5
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 MAY 22, 2026
             /
       0000          FIELD 0
       0200          *0200           /PAGE 1
             /
             / GOAL: PUNCH MEMORY CONTENTS TO PTP


00200  7300          CLA CLL
00201  1300          TAD     MESG    /LOAD THE START OF THE MESSAGE
00202  3010          DCA     CURCHR  /WILL INCREMENT TO FIRST CHAR

             /OUTPUT TO PTP
00203  5206          JMP     FRSTCH  /FLAG STARTS CLEAR SEND FIRST BLIND

00204  6021  STROUT, PSF             /CHECK IF THE FLAG IS SET
00205  5204          JMP     STROUT  /GETS SKIPPED IF THE FLAG IS SET
00206  1410  FRSTCH, TAD I   CURCHR
00207  7450          SNA             /CHECK FOR SENTINEL
00210  5214          JMP     OS8RET
00211  6026          PLS             /SEND CHAR, CLEAR FLAG
00212  7200          CLA             /CLEAR THE AC AFTER PUNCHING
00213  5204          JMP     STROUT

00214  7402  OS8RET, HLT
00215  6203          CIF CDF 0
00216  5777          JMP I   (7600)

             /DATA VALUES
00377  7600
       0010  *0010
00010  0000  CURCHR, 0

       0300  *0300
00300  0300  MESG,   .               /FIRST VALUE IS LOCATION OF STRING
00301  0310          "H              /" TELLS PAL TO USE ASCII VALUE
00302  0305          "E
00303  0314          "L
00304  0314          "L
00305  0317          "O
00306  0240          "
00307  0327          "W
00310  0317          "O
00311  0322          "R
00312  0314          "L
00313  0304          "D
00314  0241          "!
00315  0000          0               /SENTINEL AT END OF STRING
             $


CURCHR 0010
FRSTCH 0206
MESG   0300
OS8RET 0214
STROUT 0204


ERRORS DETECTED: 0
LINKS GENERATED: 0