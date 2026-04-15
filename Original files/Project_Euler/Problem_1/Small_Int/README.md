# Project Euler - Problem #1 
## Small Integer version

This is the first iteration of my solution for [Problem #1](https://projecteuler.net/problem=1).  The PDP-8 natively supports an 11-bit signed value for integers, giving a maximum absolute value of 2048(Dec).  This means that, with the upper limit of 999(Dec) on the test values, we can only safely add a new value if the existing sum is <= 1024(Dec).  To work around this problem, this version outputs values between 1024(Dec) and 2048(Dec) with a "+".  This results in a long string of numbers that can be added manually to get the resultant total.

The PDF file contains a flowchart of the entire program, including subroutines that were used.
