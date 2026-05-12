

             /
             / PDP-8 WORKBOOK
             / CHAPTER 3
             / EXERCISE 1
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 APRIL 30, 2026
             /

       0200  *0200

             /
             / GOAL: COUNT THE NUMBER OF BITS SET IN A WORD
             /


00200  1410  LOOP,   TAD I   INPUT
00201  7100          CLL
00202  7004  WRDLP,  RAL             /ROTATE BIT 11 TO L
00203  7430          SZL
00204  2340          ISZ     BITCNT  /COUNT BIT IN L
00205  7000          NOP
00206  2341          ISZ     WRDCNT
00207  5202          JMP     WRDLP
00210  7300          CLA CLL         /PREPARE FOR NEXT WORD
00211  1340          TAD     BITCNT
00212  3411          DCA I   OUTPUT  /STORE FOR COMPARISON LATER
00213  3340          DCA     BITCNT
00214  1377          TAD     (7764)
00215  3341          DCA     WRDCNT
00216  2342          ISZ     LPCNT
00217  5200          JMP     LOOP
00220  7402          HLT.            /PAUSE FOR DEBUGGING
00221  5776          JMP I   (7600)  /RETURN TO OS/8
             /SET UP AUTO-INDEX REGISTERS
00376  7600
00377  7764
       0010  *0010
00010  0277  INPUT,  277
00011  0317  OUTPUT, 317

             /DATA VALUES
       0300  *0300
00300  1537          1537
00301  6421          6421
00302  0704          0704
00303  5316          5316
00304  2245          2245
00305  7762          7762
00306  4013          4013
00307  6150          6150
00310  3472          3472
00311  0627          0627
00312  7104          7104
00313  2563          2563
00314  5041          5041
00315  1332          1332
00316  6675          6675

       0340  *0340
00340  0000  BITCNT, 0
00341  7764  WRDCNT, 7764            /(-12)
00342  7761  LPCNT,  7761.           /(-15)
             $


BITCNT 0340      
INPUT  0010      
LOOP   0200      
LPCNT  0342      
OUTPUT 0011      
WRDCNT 0341      
WRDLP  0202      


ERRORS DETECTED: 0
LINKS GENERATED: 0


