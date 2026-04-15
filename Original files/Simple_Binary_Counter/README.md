# Simple Binary Counter

This is an excellent first program for new PDP users.  It utilizes extremely basic instructions, and can be keyed in on the front panel.  

The idea is that the program will add 1 to the Accumulator every time the user presses the CONT (Continue) switch.  There is no output to the screen, everything is shown on the front panel register indicators.

A flowchart PDF has been uploaded to help visualize the program.  Note that there is no "End" terminator, as this is an infinite loop.

## Basic Theory

There are 4 steps of note in this program:
```
	CLA
	CLL
```
These two commands are the preparation/initialization step.  They clear the Accumulator and Link registers respectively.  This is to ensure that the program starts in a known state.

```
	IAC
```
This line is the counting section, it increments the Accumulator.  That means that it binary adds 1 to the current contents of the Accumulator. 
```
	HLT
```
The `HLT` instruction directs the computer to pause processing.  This is useful as a simple debugging tool, and allows the user to move around in, examine the contents, or make changes to memory.  In this case it is being leveraged as a pause to show the user the current value of the Accumulator.  Toggle the CONT switch to continue processing.
```
	JMP .-2
```
This is the key to the loop.  The `JMP` instruction tells the computer to jump to back two steps in the Program Counter.  The `.` references the current line.   


## Keying in manually

The entire program is small enough and simple enough that it can be keyed into the computer directly via the front panel switches, no terminal is required.  Each instruction has a 4 digit octal value that represents it.  There are many resources that break down the purpose of each individual bit in each word, so that won't be covered here.  Instead, the process of entering things manually will be the focus of this section.  The assumption is that the program will be loaded in Page 1 of memory (0200)

The word for each line is as follows:

|Instruction|Word|
|---|---|
|`CLA`|7200|
|`CLL`|7100|
|`IAC`|7001|
|`HLT`|7402|
|`JMP .-2`|5202*|

*Note that this value will change depending on the destination of the jump.

The process of keying in this program is as follows:

1. If the computer is processing the OS, toggle the STOP switch to interrupt processing and take control manually.
2. Load the initial memory address by setting the switch register to 0200[Oct].
3. Toggle the LOAD ADD (Load Address) switch.  The Program Counter register will reflect that the system is now working at the specified memory location.
4. Set the switch register to the word for the first instruction, in this case 7200[Oct].
5. Toggle the DEP (Deposit) switch.  The Memory Address register will display the address that was just modified, and the Memory Buffer register will display the value stored in that address.  Additionally, the Program Counter will automatically advance to the next sequential address.
6. Repeat steps 3 & 4 until the entire program has been entered.

In order to validate the program has been entered correctly, the user can query each memory address similarly.

1. Load the initial memory address by setting the switch register to 0200[Oct].
2. Toggle the LOAD ADD (Load Address) switch.  The Program Counter register will reflect that the system is now working at the specified memory location.
3. Toggle the EXAM (Examine) switch.  The Memory Address register will display the address that is being examined, and the Memory Buffer register will display the value stored in that address.  Similar to the DEP switch, the EXAM switch will also increment the Program Counter to the next address.
4. Continue until the end of the program has been reached.

Execution of the program is similar.

1. Load the initial memory address by setting the switch register to 0200[Oct].
2. Toggle the LOAD ADD (Load Address) switch.  The Program Counter register will reflect that the system is now working at the specified memory location.
3. Toggle the START switch.  This will instruct the computer to begin processing instructions at the current address.  In this case processing will continue until address 0203[Oct] which has the `HLT` instruction.
4. The accumulator should show a value of 1.
5. Toggle the CONT switch to tell the computer to continue processing at the instruction in the Program Counter register, in this case, that is just the next instruction located at 0204[Oct].
6. Each successive toggle of the CONT switch will add one to the Accumulator, which the user will be able to see counting up in binary.

** Press STOP, load address 7600[Oct] and toggle START to return to OS/8**

## Compiling and Executing from within OS/8

Like all programs, this can be written, compiled, and executed from with the operating system as well

In order to do so:

1. Use EDIT to create the file: `CREATE BINCNT.PA`.
2. At the `#` prompt, type `A` to append to the current buffer.
3. Type or paste in the program.  Press `Ctrl + L` to exit typing mode.
4. At the `#` prompt, type `E` to save the file and exit.
5. Back in the OS, compile the program with `PAL ,BINCNT<BINCNT/H`
   * This is a simplification of a full command.  The implied command is: `PAL BINCNT.BN,BINCNT.LS<BINCNT.PA/H`.  This instructs the PAL8 compiler to create a binary executable (BINCNT.BN), and a human readable program listing (BINCNT.LS).  The source code used to generate it is found in BINCNT.PA, and the `/H` tells the assembler not to paginate the listing file.
   * For more information please see Chapter 3 of the [OS/8 Handbook](https://bitsavers.trailing-edge.com/pdf/dec/pdp8/os8/OS8_Handbook_Apr1974.pdf)
6. In order to see the program listing enter `TYPE BINCNT.LS`.  That will output the source code with the assembled information.  There are two columns of Octal numbers preceeding each line.  The first is the memory address that the instruction is stored in, the second is the value that is stored in the memory address.  A listing for this program has also been uploaded here for comparison purposes.
7. To load and execute the program type `LOAD BINCNT/G`.  Again this is somewhat shorthand, using the implicit `BN` extension.  The `/G` switch tells the computer to execute after loading in memory.

** Press STOP, load address 7600[Oct] and toggle START to return to OS/8**

