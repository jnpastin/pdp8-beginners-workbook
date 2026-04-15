# Two Value Adder

This program is a good next step after the [Simple Binary Counter](https://github.com/jnpastin/pdp8/tree/b1f683d7062ebd181f3fa1ed25ee2ae233d82910/Simple_Binary_Counter).  The program creates two variables `A` and `B`, then 
repeatedly adds them until the Accumulator overflows.  There are a couple of new instructions included here.  `TAD` and `DCA` are responsible for moving values into and out of the Accumulator respectively.  Additionally, 
looping logic is a bit more complex.  

It should be noted that for simplicity's sake, the repeated loops are copy/pasted rather than nested.  I felt that being able to understand what was being done was more important than 
elegance.
