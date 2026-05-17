## The Exercise Plan

### Chapter 1 – Core PDP‑8 Mental Model

**Goals**
- Internalize AC, Link, and memory as system state
- Understand instruction sequencing and skips
- Become fluent at manual execution tracing

**Exercises**
1. ✅ Trace a simple add/store program by hand 
2. ✅ Count from 1–10 and accumulate a sum 
3. ✅ Rewrite the loop using auto‑index registers 

---

### Chapter 2 – Control Flow and Subroutines

**Goals**
- Understand `JMS` at the memory level
- Learn safe subroutine discipline
- See why return‑slot conventions exist

**Exercises**
1. ✅ Absolute‑value subroutine 
2. ✅ Compare two values (−1 / 0 / 1) 
3. ✅ Nested subroutines and state‑saving bug fix 

---

### Chapter 3 – Rotates, Shifts, and Bit Logic

**Goals**
- Treat `L:AC` as a 13‑bit shift register
- Distinguish logical vs arithmetic shifts
- Use rotates for bit manipulation

**Exercises**
1. ✅ Count bits set in a word 
2. ✅ Multiply by 10 without EAE 
3. ✅ Implement an arithmetic right shift 

---

### Chapter 4 – Multi‑Word Arithmetic

**Goals**
- Handle numbers larger than 12 bits
- Explicit carry propagation via Link
- Variable‑length arithmetic

**Exercises**
1. ✅ 24‑bit addition and subtraction 
2. ✅ Variable‑length accumulation with overflow detection 
3. ✅ Multi‑word comparison routine 

---

### Chapter 5 – OS/8 and Extended Memory

**Goals**
- Write correct OS/8 programs
- Respect field and page conventions
- Understand extended memory behavior

**Exercises**
1. ✅ OS/8‑safe program exit 
2. ✅ Field‑safe subroutine callable from field 0 
3. EAE detection with dual‑path arithmetic 

---

### Chapter 6 – I/O Programming (TTY, PTR, PTP)

**Goals**
- Understand PDP‑8 I/O at the instruction and convention level
- Work with polled I/O and device flags
- Use TTY and paper tape in a disciplined way

**Concepts**
- IOT instructions
- Skip‑on‑flag behavior
- Busy‑wait loops
- Device independence assumptions

**Exercises**
1. Character output to TTY using polling 
2. Character input with echo 
3. Line‑buffered input routine 
4. Read a block from PTR into memory 
5. Punch memory contents to PTP 

---

### Chapter 7 – File Formats and Program Lifecycle

**Goals**
- Understand what .BN, .SV, and .EX actually contain
- Trace the full PAL → LOAD → SAVE → RUN workflow step by step
- Know what each OS/8 command is doing to memory

**Concepts**
- .PA — PAL8 source file (ASCII)
- .LS — listing file with symbol table
- .BN — binary loader format (block-structured; what PAL emits)
- .SV — saved executable image (memory snapshot; product of SAVE)
- .EX — execution/chaining format (replaces running program)
- Loader block structure and how LOAD reconstructs memory

**Exercises**
1. Assemble a small program; inspect the .BN output and identify the loader blocks
2. LOAD and SAVE the program; compare the .SV image layout to the .BN input
3. Write a chaining program using .EX; verify what state carries over and what does not

---

### Chapter 8 – OS/8 Tools and Workflow

**Goals**
- Master the OS/8 command environment and standard toolchain
- Use PIP, PAL, LOAD/SAVE, TECO, and CCL fluently
- Understand how chaining composes tools into workflows

**Concepts**
- CCL (command decoder): how `.R PAL PROG` expands
- PIP: file copy, rename, delete, directory management
- PAL: assembler invocation, switches, and listing options
- LOAD / SAVE: linking and image creation workflow
- EDIT / TECO: creating and editing source files
- CHAIN: how OS/8 tools hand off to one another (PAL → CREF, CHAIN vs. return)

**Exercises**
1. Navigate OS/8: use DIR, PIP to manage files, DATE, and basic monitor commands
2. Create a source file with TECO or EDIT; assemble it; inspect the listing and symbol table
3. Execute the complete workflow: PAL → LOAD → SAVE → RUN; modify a source line and rebuild
4. Build a two-stage chaining workflow (e.g., PAL automatically invoking CREF)

---

### Chapter 9 – Loader and Multi-File Programs

**Goals**
- Build programs from multiple source files
- Understand how the loader merges modules
- Coordinate symbols across files

**Concepts**
- Multi-file PAL invocation: `PAL MAIN,UTIL`
- Loader module merging and address assignment
- Shared symbols and cross-file references
- Library-like patterns via file inclusion

**Exercises**
1. Split an existing exercise into two files (main + utility); assemble and load both
2. Resolve a cross-file symbol conflict; understand the error and fix it
3. Build a three-module program with a shared data region

---

### Chapter 10 – Indirect Addressing and Control Flow Pitfalls

**Goals**
- Understand the most common PDP-8 control-flow bugs
- Know precisely when IF vs. DF applies
- Anticipate and avoid CIF timing hazards

**Concepts**
- Direct vs. indirect JMP/JMS
- Indirect fetches use IF (not DF)
- CIF is deferred — effect takes place on the next JMP or JMS only
- Field transition hazards and how they cause silent corruptions
- Recognizing bad indirect jumps from MONITOR ERROR output

**Exercises**
1. Trigger and diagnose a bad indirect jump (wrong IF assumption); fix it
2. Write a cross-field JMS using an indirect pointer; verify field register state on entry
3. Construct a CIF timing bug deliberately; trace what actually executes and why

---

### Chapter 11 – USR Calls (OS/8 System Interface)

**Goals**
- Call OS/8 system services via `JMS I (7600)`
- Understand parameter block layout
- Maintain correct IF/DF state around USR calls

**Concepts**
- The USR (User Service Routine) and its address at 7600
- `JMS I (7600)` as the OS/8 entry convention
- Parameter block: function code, arguments, return address
- IF/DF requirements before and after USR calls
- Role of the OS/8 monitor and how USR fits in

**Exercises**
1. Make a USR call to output a character string; inspect the parameter block
2. Call USR to read a file's directory entry; display filename and size
3. Write a wrapper subroutine that sets up IF/DF, calls USR, and restores state

---

### Chapter 12 – File I/O and Buffers

**Goals**
- Read and write files via OS/8
- Manage buffers correctly in memory
- Understand binary vs. ASCII data handling

**Concepts**
- OS/8 file access model (open, read, write, close via USR)
- Buffers: placement in memory, alignment, size constraints
- Binary vs. ASCII (packed vs. unpacked) data representation
- Data placement and address discipline under extended memory

**Exercises**
1. Read a binary file from disk into a buffer; verify contents
2. Write a buffer to a new file and confirm with PIP/DIR
3. Process ASCII data from disk: read a text file and count words or lines

---

### Chapter 13 – Overlays (Memory Optimization)

**Goals**
- Structure programs larger than one field
- Load code segments on demand via USR
- Understand the performance cost of overlays

**Concepts**
- Root vs. overlay code regions
- Overlay region address conventions
- USR-driven loading of overlay segments at runtime
- Relationship between overlays and the USR mechanism (Chapter 11)
- I/O cost of overlay use vs. field cost of CIF

**Exercises**
1. Convert a two-routine program to use an overlay for the less-used routine
2. Chain three overlay segments in sequence; verify correct execution order
3. Profile overlay load cost vs. running equivalent code from a second field

---

### Chapter 14 – Device Handlers (Conceptual and Applied)

**Goals**
- Understand what a device handler is and how OS/8 invokes it
- Relate IOT instructions to handler calls
- Know how to use (not write) a device handler

**Concepts**
- Device handler as an OS/8 code module
- How OS/8 dispatches I/O through handlers
- The link between IOT device codes and handler table entries
- Difference between polled I/O (Chapter 6) and handler-mediated I/O (OS/8)

**Exercises**
1. Trace the call path from a file-read USR call through to a disk handler
2. Assign a device via OS/8 commands; use it in a program
3. Compare the behavior of direct IOT vs. handler-mediated access to the same device

---

### Chapter 15 – File System and Storage Concepts

**Goals**
- Reason about OS/8 disk behavior and file placement
- Understand directory structure and block allocation
- Work confidently with logical devices

**Concepts**
- OS/8 directory layout and block allocation
- File size limits and fragmentation
- Logical devices: DSK:, SYS:, and device assignment
- PIP as a file system tool (not just a copier)

**Exercises**
1. Inspect the directory of a disk image using PIP and DIR; map used vs. free blocks
2. Fill a disk to near-capacity; observe allocation behavior; delete and re-check
3. Use device assignment to redirect SYS: and DSK: and test the effect on a program

---

### Chapter 16 – Performance and Design Tradeoffs

**Goals**
- Make informed design decisions based on resource constraints
- Understand the relative cost of different memory strategies
- Choose between fields, overlays, and single-segment designs consciously

**Concepts**
- CPU vs. I/O cost model: disk access is expensive; CIF is moderate; DF is cheap
- Tradeoff table:

| Approach | Cost | Best Use |
|----------|------|----------|
| Single field | Low complexity | Small programs |
| Multi-field | Moderate | Structured programs |
| Overlays | High I/O cost | Large programs |

- When to split vs. when to optimize in place
- Memory layout planning before coding

**Exercises**
1. Rewrite a Chapter 9 multi-file program in a single field; measure code density
2. Design (on paper) the memory layout for a hypothetical 20-routine program
3. Analyze a given layout and identify the bottleneck; propose an alternative

---

### Chapter 17 – Program Architecture

**Goals**
- Apply fields, overlays, and subroutine conventions coherently
- Separate code, data, and OS interface regions
- Design maintainable PDP-8 programs

**Concepts**
- Canonical layout: Field 0 for control + OS calls; Field N for data; overlay region for code modules
- Separation of concerns: code vs. data vs. OS interface
- Subroutine convention discipline (from Chapter 2, applied at scale)
- Shared data regions and memory discipline across modules

**Exercises**
1. Restructure a prior exercise to use a canonical field layout
2. Define a shared data region accessible from two fields via DF switching
3. Apply the full convention set — subroutine discipline, field layout, OS/8 exit — in one program

---

### Chapter 18 – Debugging and Failure Analysis

**Goals**
- Recover from real PDP-8 program failures
- Apply a systematic diagnostic workflow
- Use front-panel and instruction-level tools effectively

**Concepts**
- Common failure signatures:
  - MONITOR ERROR 4 (bad return from user program)
  - Bad indirect jump (wrong IF assumption)
  - Wrong IF on return to OS/8
- Diagnostic workflow: Where am I? What is IF/DF? What just executed? Was it indirect?
- Tools: `HLT` as a checkpoint, `RDF` / `RIF` for field inspection, memory examination

**Exercises**
1. Introduce a bad indirect jump bug into a working program; diagnose and fix it using RDF/RIF
2. Reproduce MONITOR ERROR 4 deliberately; trace the return path backward to find the cause
3. Given a broken program (provided), diagnose the failure without running it — trace only

---

### Chapter 19 – Capstone: Integrated Program

**Goal**
Demonstrate full system-level competency by building a program that exercises everything learned.

**Requirements**
The program must:
- Use multiple source files (Chapter 9)
- Use DF or CIF correctly for extended memory (Chapters 5, 10)
- Call OS/8 via USR for at least one operation (Chapter 11)
- Perform file I/O with proper buffer management (Chapter 12)
- Exit correctly and unconditionally (Chapter 5)
- Demonstrate structured design with a documented memory layout (Chapter 17)

**Optional challenge:**
Include an intentional bug, diagnose it using the Chapter 18 methodology, and document the fix.

**Outcome**
Student can design, build, debug, and ship a real PDP-8 program.

---

## Progress Tracking

- ✅ Chapter 1 complete (exercises 1–3)
- ✅ Chapter 2 complete (exercises 1–3, code reviewed and all standards met)
- ✅ Chapter 3 complete (exercises 1–3)
- ✅ Chapter 4 complete (exercises 1–3)
- ⏳ Chapter 5 in progress (exercises 1–2 complete, exercise 3 remaining)
- 🔲 Chapter 6 not started
- 🔲 Chapter 7 not started
- 🔲 Chapter 8 not started
- 🔲 Chapter 9 not started
- 🔲 Chapter 10 not started
- 🔲 Chapter 11 not started
- 🔲 Chapter 12 not started
- 🔲 Chapter 13 not started
- 🔲 Chapter 14 not started
- 🔲 Chapter 15 not started
- 🔲 Chapter 16 not started
- 🔲 Chapter 17 not started
- 🔲 Chapter 18 not started
- 🔲 Chapter 19 not started

---

## Code Review Standards

When reviewing any exercise solution, evaluate on all of the following axes:

- **Correctness** — Does it produce the right result? Trace execution manually if needed.
- **Style** — Consistent spacing, alignment, and label naming. PAL8 convention is a single tab to the operand field.
- **Comments** — Labels and inline comments should describe intent precisely, not just restate the mnemonic.
- **Conventions** — Follows period PDP-8 idioms: `CLA CLL` for clear, `CIA` for negation, `ISZ`-based loop counters, `HLT` before OS/8 exit, `CIF CDF` discipline.
- **Historical accuracy** — Code should reflect how real PDP-8 software was written in the era. Avoid anachronistic patterns.
- **OS/8 safety** — Programs that run under OS/8 must exit via `CIF CDF 00` + `JMP I (7600)`. Field must be restored before the jump during and after the memory management module (Chapter 5)
- **Resource use** — Are auto-index registers, page 0, and literals used appropriately? No unnecessary waste of scarce page-0 locations.
- **Runaway risk** — Does execution ever fall into data words? All paths must terminate cleanly.

---

## Notes and Conventions

- Octal notation everywhere
- Page 0 usage is per‑field on extended systems
- AC and Link are always considered **destroyed unless documented otherwise**
- I/O routines must document device usage and blocking behavior

---

## Philosophy

> The PDP‑8 rewards clarity, discipline, and honesty. 
> This plan treats the machine not as a curiosity, but as a system worthy of being programmed well.

---

## License / Usage

Personal learning repository. 
Code and notes may be reused freely unless otherwise stated.

---

_End of README_