             ///////////////////////////////
             / SIMPLE BINARY COUNTER
             / JEREMY PASTIN
             / 2-25
             / PAL8 ASSEMBLY
             ///////////////////////////////

       0200  *200
00200  7200          CLA     /CLEAR ACCUMULATOR
00201  7100          CLL     /CLEAR LINK
00202  7001          IAC     /INCREMENT ACCUMULATOR
00203  7402          HLT     /PAUSE EXECUTION
00204  5202          JMP .-2 /JUMP BACK TWO LINES
             $




ERRORS DETECTED: 0
LINKS GENERATED: 0
