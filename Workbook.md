# PDP-8 Programming Workbook Outline

### Chapter 1 - Core PDP-8 Mental Model

**Goals**

- Internalize AC, Link, and memory as system state
- Understand instruction sequencing and skips
- Become fluent at manual execution tracing

**Concepts**

- AC and Link
- Memory as state
- Instruction sequencing
- Skip instructions
- Auto-index registers

**Exercises**

- ✅ Trace a simple add/store program by hand
- ✅ Count from 1-10 and accumulate a sum
- ✅ Rewrite the loop using auto-index registers

### Chapter 2 - Control Flow and Subroutines

**Goals**

- Understand JMS at the memory level
- Learn safe subroutine discipline
- See why return-slot conventions exist

**Concepts**

- JMS mechanics
- Return slots
- Indirect returns
- Calling conventions
- Cross-page calls

**Exercises**

- ✅ Absolute-value subroutine
- ✅ Compare two values (-1 / 0 / 1)
- ✅ Nested subroutines and state-saving bug fix

### Chapter 3 - Rotates, Shifts, and Bit Logic

**Goals**

- Treat L:AC as a 13-bit shift register
- Distinguish logical vs arithmetic shifts
- Use rotates for bit manipulation

**Concepts**

- RAL/RAR
- Link as carry and shift state
- Bit masking
- Arithmetic shifts
- Logical shifts

**Exercises**

- ✅ Count bits set in a word
- ✅ Multiply by 10 without EAE
- ✅ Implement an arithmetic right shift

### Chapter 4 - Multi-Word Arithmetic

**Concepts**

- Multi-word values
- Carry propagation
- Borrow propagation
- Signed overflow
- Unsigned overflow

**Exercises**

- ✅ 24-bit addition and subtraction
- ✅ Variable-length accumulation with overflow detection
- ✅ Multi-word comparison routine

### Chapter 5 - OS/8 and Extended Memory

**Concepts**

- IF and DF
- CIF and CDF
- Deferred CIF behavior
- Cross-field access
- OS/8 return conventions

**Exercises**

- ✅ OS/8-safe program exit
- ✅ Field-safe subroutine callable from field 0
- ✅ EAE detection with dual-path arithmetic

### Chapter 6 - I/O Programming (TTY, PTR, PTP)

**Concepts**

- IOT instructions
- Device flags
- Polling loops
- TTY I/O
- PTR I/O
- PTP I/O

**Exercises**

- ✅ Character output to TTY using polling
- ✅ Character input with echo
- ✅ Line-buffered input routine
- ✅ Read a block from PTR into memory
- ✅ Punch memory contents to PTP

### Chapter 7 - OS/8 Tools and Development Workflow

**Concepts**

- .PA
- .LS
- .BN
- .SV
- PAL
- CREF
- LOAD/SAVE

**Exercises**

- 🔲 Trace a program through PAL → LOAD → SAVE → RUN
- 🔲 Demonstrate source, memory image, and saved image divergence
- 🔲 Use PAL, CREF, PIP, DIR, and FUTIL to inspect a build

Advanced:

- 🔲 Automate the workflow with SUBMIT
