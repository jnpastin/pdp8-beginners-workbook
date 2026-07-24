# Chapter 7 Exercise 2 – SV File Format

---

## Purpose

Understand how SAVE files generated are structured.  In order to do this the file must be viewed at a machine code level and decoded. 

---

## SAVE File Format

Save files (.SV) contain both the binary image covered in Exercise 1, as well as the contents of core memory at the specified locations.  The structure of the file is to have a Core Control Block at the start of the first disk block, followed by information on the segments included in the save file, and then the binary representation of the executable.  The block(s) following this are captures of core memory from the addresses specified in the save command.

Note that the CCB, segment info, and core memory dumps are all interpreted as 12 bit octal numbers, while the binary representation of the program is still in the 3-from-2 byte format.

The structure of the CCB and segment info is:

| Word # | Example Value | Meaning |
| --- | --- | --- |
| 0 | 7776 | Twos complement value representing the number of segments as a negative number, in this case -2<sup>[1]</sup> |
| 1 | 6203 | Instruction to set Data Field and Instruction Field |
| 2 | 0200 | Address to start execution at |
| 3 | 2000 | Job Status Word<sup>[2]</sup> |
| 4 | 0000 | Address of the start of the first segment<sup>[3]</sup> |
| 5 | 0200 | Length of the segment, bit shifted left once.  In this example, 0200 << 1 = 0400 words |
| 6<sup>[4]</sup> | 0400 | Address of the start of the next segment |
| 7<sup>[4]</sup> | 0200 | Length of the segment, bit shifted left once |

[1] Contiguous segments are compressed into a single segment.  
[2] Job Status Word specifies which parts of the file use memory and how.  See OS/8 System Reference Manual for details.  
[3] Segments always start on an even numbered page.  In this case 0200 is the beginning of Page 1, so Page 0 is the beginning of the segment.  
[4] Additional segments beyond the first may or may not be included.  There will be one pair of starting address and length for each segment.  

In this case, beginning at word 2326.00010 the byte packed program begins, ending at 2326.00055.  This can be seen in the BYTE part of the export from FUTIL.

The remaining blocks are the core memory dumps.  These are viewed in octal, and the majority of the program can be seen from 2327.00200 to 2327.00213 and 2330.00200 to 2330.00203
