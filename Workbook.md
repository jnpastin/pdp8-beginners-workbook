# PDP-8 Programming Workbook

## The Exercise Plan

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

**Goals**
- Handle numbers larger than 12 bits
- Explicit carry propagation via Link
- Variable-length arithmetic

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

**Goals**
- Write correct OS/8 programs
- Respect field and page conventions
- Understand extended memory behavior

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

**Goals**
- Understand PDP-8 I/O at the instruction and convention level
- Work with polled I/O and device flags
- Use TTY and paper tape in a disciplined way

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

### Chapter 8 - Command Decoder and Program Invocation

**Concepts**
- Keyboard monitor
- Command decoder
- CCL
- R command
- Command files
- SUBMIT

**Exercises**
- 🔲 Analyze several common command expansions
- 🔲 Compare direct execution versus R invocation
- 🔲 Build an automated command-driven build workflow

### Chapter 9 - Loader and Multi-Module Programs

**Concepts**
- Multi-file assembly
- Loader merging
- Symbol ownership
- Shared data regions
- Module interfaces

**Exercises**
- 🔲 Split a program into MAIN and UTILITY modules
- 🔲 Build a three-module program with shared data
- 🔲 Diagnose and repair loader and symbol conflicts

### Chapter 10 - PAL8 Advanced Source Techniques

**Concepts**
- Macros
- Parameters
- Expansion
- Conditional assembly
- Symbolic configuration

**Exercises**
- 🔲 Replace duplicated code with macros
- 🔲 Compare macro and JMS implementations
- 🔲 Generate multiple builds from one source tree

### Chapter 11 - OS/8 Programming Model and Interfaces

**Concepts**
- Runtime interfaces
- Monitor
- USR
- Device handlers
- SYS:
- DSK:

**Exercises**
- 🔲 Use character-oriented runtime interfaces
- 🔲 Use file-oriented runtime interfaces
- 🔲 Explore SYS:, DSK:, and device assignment

### Chapter 12 - USR Calls

**Concepts**
- JMS I (7600)
- Parameter blocks
- FETCH
- INQUIRE
- CHAIN
- IF/DF obligations

**Exercises**
- 🔲 Build and trace a minimal USR call
- 🔲 Use FETCH or INQUIRE
- 🔲 CHAIN between two programs

Advanced:
- 🔲 Create a reusable field-safe USR wrapper

### Chapter 13 - File I/O and Buffers

**Concepts**
- Buffer management
- Binary files
- ASCII files
- Record processing
- Memory placement

**Exercises**
- 🔲 Read a binary file into memory
- 🔲 Create and verify a generated output file
- 🔲 Process an ASCII text file

Advanced:
- 🔲 Fixed-length record processing

### Chapter 14 - File System, Devices, and Handlers

**Concepts**
- Directories
- Allocation
- Logical devices
- Device assignment
- Handlers

**Exercises**
- 🔲 Analyze disk usage and free space
- 🔲 Redirect logical devices and observe behavior
- 🔲 Trace a file request through the handler stack

### Chapter 15 - OS/8 Program Artifacts and Internals

**Concepts**
- .PA
- .LS
- .BN
- .SV
- Loader records
- Memory images

**Exercises**
- 🔲 Follow a program through PA → LS → BN → SV
- 🔲 Compare BN and SV representations
- 🔲 Demonstrate exactly what SAVE captures

Advanced:
- 🔲 Decode BN records
- 🔲 Decode SV structures

### Chapter 16 - Performance and Design Tradeoffs

**Concepts**
- CPU vs I/O costs
- Macros vs subroutines
- Fields vs overlays
- Memory planning

**Exercises**
- 🔲 Compare inline, macro, and JMS implementations
- 🔲 Compare single-field, multi-field, and overlay designs
- 🔲 Redesign a page-constrained program

### Chapter 17 - Program Architecture

**Concepts**
- Memory maps
- Module interfaces
- Shared data
- Buffer ownership
- Layering

**Exercises**
- 🔲 Design a complete memory map
- 🔲 Define module contracts
- 🔲 Refactor a program to match the architecture

Advanced:
- 🔲 Design an overlay-capable architecture

### Chapter 18 - Debugging and Failure Analysis

**Concepts**
- IF/DF debugging
- Indirect-jump failures
- OS/8 return failures
- Listing analysis
- ODT

**Exercises**
- 🔲 Diagnose a bad indirect jump
- 🔲 Diagnose a bad OS/8 return
- 🔲 Diagnose a failure from a listing alone

Advanced:
- 🔲 Patch a program with ODT
- 🔲 Reverse-engineer an unfamiliar routine

### Chapter 19 - Capstone: Integrated Program

**Concepts**
- Integration
- Architecture
- File I/O
- OS/8 services
- Testing
- Documentation

**Exercises**
- 🔲 Design the program
- 🔲 Implement the program
- 🔲 Test, debug, and document the program
