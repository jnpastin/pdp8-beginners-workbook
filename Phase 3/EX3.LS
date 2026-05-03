

             /
             / PDP-8 WORKBOOK
             / PHASE 3
             / EXERCISE 3
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 APRIL 30, 2026
             /

       0200  *0200

             /
             / GOAL: CREATE AN ARITHMETIC RIGHT SHIFT
             /

00200  7300  LOOP,   CLA CLL
00201  1350          TAD     INPUT
00202  0377          AND     (4000)  /GET THE SIGN BIT
00203  7440          SZA
00204  7120          STL             /USE LINK TO PRESERVE SIGN
00205  7200          CLA
00206  1350          TAD     INPUT
00207  7010          RAR             /BIT ROTATED IN IS PREVIOUS SIGN
00210  3354          DCA     RESULT
00211  1354          TAD     RESULT
00212  3410          DCA I   OUTPUT  /STORE RESULT FOR LATER VALIDATION
00213  1354          TAD     RESULT
00214  3350          DCA     INPUT   /RESET FOR THE NEXT ITERATION
00215  2353          ISZ     LPCNTR
00216  5200          JMP     LOOP
00217  1352          TAD     DONE
00220  7440          SZA             /CHECK IF WE PROCESSED BOTH INPUTS
00221  5231          JMP     MONRET
00222  7001          IAC             /IF NOT PREPARE FOR 2ND INPUT
00223  3352          DCA     DONE    /MARK DONE
00224  1351          TAD     INPUT2
00225  3350          DCA     INPUT   /LOAD 2ND TEST CASE
00226  1376          TAD     (7764)
00227  3353          DCA     LPCNTR  /RESET THE LOOP COUNTER
00230  5200          JMP     LOOP
00231  7402  MONRET, HLT
00232  5775          JMP I   (7600)

             /SET UP AUTO INDEX REGISTER
00375  7600
00376  7764
00377  4000
       0010          *0010
00010  0277  OUTPUT, 277

             /DATA VALUES
       0350          *0350
00350  3546  INPUT,  3546            /POSITIVE INPUT VALUE
00351  7654  INPUT2, 7654            /NEGATIVE INPUT VALUE
00352  0000  DONE,   0
00353  7764  LPCNTR, 7764            /(-12)
00354  0000  RESULT, 0
                     
             $


DONE   0352      
INPUT  0350      
INPUT2 0351      
LOOP   0200      
LPCNTR 0353      
MONRET 0231      
OUTPUT 0010      
RESULT 0354      


ERRORS DETECTED: 0
LINKS GENERATED: 0




             /
             / PDP-8 WORKBOOK
             / PHASE 3
             / EXERCISE 3
             / PAL8 ASSEMBLY
             / JEREMY PASTIN
             / VERSION 1.0 APRIL 30, 2026
             /

       0200  *0200

             /
             / GOAL: CREATE AN ARITHMETIC RIGHT SHIFT
             /

00200  7300  LOOP,   CLA CLL
00201  1350          TAD     INPUT
00202  0377          AND     (4000)  /GET THE SIGN BIT
00203  7440          SZA
00204  7120          STL             /USE LINK TO PRESERVE SIGN
00205  7200          CLA
00206  1350          TAD     INPUT
00207  7010          RAR             /BIT ROTATED IN IS PREVIOUS SIGN
00210  3354          DCA     RESULT
00211  1354          TAD     RESULT
00212  3410          DCA I   OUTPUT  /STORE RESULT FOR LATER VALIDATION
00213  1354          TAD     RESULT
00214  3350          DCA     INPUT   /RESET FOR THE NEXT ITERATION
00215  2353          ISZ     LPCNTR
00216  5200          JMP     LOOP
00217  1352          TAD     DONE
00220  7440          SZA             /CHECK IF WE PROCESSED BOTH INPUTS
00221  5231          JMP     MONRET
00222  7001          IAC             /IF NOT PREPARE FOR 2ND INPUT
00223  3352          DCA     DONE    /TOGGLE DONE
00224  1351          TAD     INPUT2
00225  3350          DCA     INPUT   /POPULATE INPUT CORRECTLY
00226  1376          TAD     (7764)
00227  3353          DCA     LPCNTR  /RESET THE LOOP COUNTER
00230  5200          JMP     LOOP
00231  7402  MONRET, HLT
00232  5775          JMP I   (7600)

             /SET UP AUTO INDEX REGISTER
00375  7600
00376  7764
00377  4000
       0010          *0010
00010  0277  OUTPUT, 277

             /DATA VALUES
       0350          *0350
00350  3546  INPUT,  3546            /POSITIVE INPUT VALUE
00351  7654  INPUT2, 7654            /NEGATIVE INPUT VALUE
00352  0000  DONE,   0
00353  7764  LPCNTR, 7764            /-12
00354  0000  RESULT, 0
                     
             $


DONE   0352      
INPUT  0350      
INPUT2 0351      
LOOP   0200      
LPCNTR 0353      
MONRET 0231      
OUTPUT 0010      
RESULT 0354      


ERRORS DETECTED: 0
LINKS GENERATED: 0


