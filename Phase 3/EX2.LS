

             /
             / PDP-8 WORKBOOK
             / PHASE 3
             / EXERCISE 2
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 APRIL 30, 2026
             /

       0200  *0200

             /
             / GOAL: MULTIPLY A NUMBER BY 10 WITHOUT EAE
             /

00200  1410  LOOP,   TAD I   INPPCD  /LOAD THE NEXT MULTIPLICAND
00201  3352          DCA     MLTPCD
00202  7300  MULTOP, CLA CLL
00203  1351          TAD     MLTPLR  /GET BIT 0 OF MULTIPLIER
00204  0377          AND     (1)
00205  7440          SZA
00206  4235          JMS     ADDVAL  /ADD MULTIPLICAND IF BIT0=1
00207  7300          CLA CLL
00210  1351          TAD     MLTPLR  /ROTATE MULTIPLIER RIGHT
00211  7010          RAR
00212  3351          DCA     MLTPLR
00213  7100          CLL             /DISCARD BIT SHIFTED INTO L
00214  1352          TAD     MLTPCD  /ROTATE MULTIPLICAND LEFT
00215  7004          RAL
00216  3352          DCA     MLTPCD
00217  1351          TAD     MLTPLR 
00220  7450          SNA             /IF MULTIPLIER=0, WE'RE DONE
00221  5223          JMP     NXTWRD
00222  5202          JMP     MULTOP  /OTHERWISE KEEP PROCESSING

00223  7300  NXTWRD, CLA CLL
00224  1353          TAD     RESULT  /STORE THE RESULT FOR LATER
00225  3411          DCA I   QUOTNT
00226  3353          DCA     RESULT  /CLEAR RESULT FOR NEXT ITERATION
00227  1376          TAD     (12)
00230  3351          DCA     MLTPLR
00231  2350          ISZ     LPCNTR
00232  5200          JMP     LOOP    /PROCESS THE NEXT WORD
00233  7402          HLT
00234  5375          JMP     (7600)
                     


             /ADDS THE CURRENT MULTIPLICAND TO THE RESULT
             /ENTRY: MLTPCD
             /       RESULT
             /EXIT:  RESULT  =RESULT+MULTIPLICAND
             /       AC & L DESTROYED        
00235  0000  ADDVAL, 0
00236  7300          CLA CLL
00237  1353          TAD     RESULT
00240  1352          TAD     MLTPCD
00241  3353          DCA     RESULT
00242  5635          JMP I   ADDVAL

             /SET UP AUTO-INDEX REGISTERS
00375  7600
00376  0012
00377  0001
       0010          *0010
00010  0277  INPPCD, 277
00011  0317  QUOTNT, 317

             /DATA VALUES
       0350          *0350
00350  7761  LPCNTR, 7761            /(-15)
00351  0012  MLTPLR, 12              /(10)
00352  0000  MLTPCD, 0
00353  0000  RESULT, 0


             /INPUT DATA TABLE 
             /FOR THE PURPOSES OF THIS EXERCISE, I AM KEEPING INPUT <409(DEC)
             /TO AVOID HAVING TO DEAL WITH AC OVERFLOW, MULTI-WORD MATH IS 
             /COVERED IN PHASE 4
       0300          *0300
00300  0006          0006            
00301  0043          0043            
00302  0075          0075
00303  0132          0132
00304  0174          0174
00305  0221          0221
00306  0267          0267
00307  0324          0324
00310  0365          0365
00311  0431          0431
00312  0476          0476
00313  0532          0532
00314  0574          0574
00315  0610          0610
00316  0626          0626

             $


ADDVAL 0235      
INPPCD 0010      
LOOP   0200      
LPCNTR 0350      
MLTPCD 0352      
MLTPLR 0351      
MULTOP 0202      
NXTWRD 0223      
QUOTNT 0011      
RESULT 0353      


ERRORS DETECTED: 0
LINKS GENERATED: 0


