# PDP-8 Programming Workbook Plan

## Purpose

This workbook is a structured path for learning to write real PDP-8 programs in PAL8 assembly, first at the bare-machine level and then within OS/8. The goal is practical competence: the ability to design, implement, debug, and maintain non-trivial PDP-8 programs that use memory fields, device I/O, OS/8 tooling, USR services, files, and disciplined program structure.

The workbook is intentionally progressive. Each chapter introduces one primary concept area, exercises it directly, and avoids relying on later material before that material has been introduced.

## Learning Outcomes

After completing the workbook, the student should be able to:

- Trace PDP-8 execution at the instruction, AC, Link, and memory level.
- Use PAL8 idioms for loops, subroutines, auto-indexing, arithmetic, and page management.
- Write correct OS/8 programs that return safely to the monitor.
- Manage instruction fields and data fields explicitly.
- Use direct device I/O through IOT instructions.
- Use OS/8 tools to assemble, load, save, inspect, and run programs.
- Understand the practical difference between source, listing, binary loader, save, and execution/chaining artifacts.
- Build multi-file programs and reason about loader behavior.
- Diagnose PDP-8 and OS/8 control-flow failures systematically.
- Call OS/8 services through the USR interface.
- Read and write files using proper buffer and field discipline.
- Understand overlays, device handlers, logical devices, and storage behavior at the level required for application programming.
- Design larger PDP-8 programs with documented memory layout, module boundaries, and failure-analysis discipline.

## Chapter Sequence

### Chapter 1 - Core PDP-8 Mental Model

**Goals**

- Internalize AC, Link, and memory as system state.
- Understand instruction sequencing and skips.
- Become fluent at manual execution tracing.

**Exercises**

- Trace a simple add/store program by hand.
- Count from 1-10 and accumulate a sum.
- Rewrite the loop using auto-index registers.

### Chapter 2 - Control Flow and Subroutines

**Goals**

- Understand JMS at the memory level.
- Learn safe subroutine discipline.
- See why return-slot conventions exist.

**Exercises**

- Absolute-value subroutine.
- Compare two values, returning -1, 0, or 1.
- Nested subroutines and state-saving bug fix.

### Chapter 3 - Rotates, Shifts, and Bit Logic

**Goals**

- Treat L:AC as a 13-bit shift register.
- Distinguish logical and arithmetic shifts.
- Use rotates for bit manipulation.

**Exercises**

- Count bits set in a word.
- Multiply by 10 without EAE.
- Implement an arithmetic right shift.

### Chapter 4 - Multi-Word Arithmetic

**Goals**

- Handle numbers larger than 12 bits.
- Explicitly propagate carry via Link.
- Implement signed and unsigned arithmetic with overflow detection.

**Exercises**

- 24-bit addition and subtraction.
- Variable-length accumulation with overflow detection.
- Multi-word comparison routine.

### Chapter 5 - OS/8 and Extended Memory

**Goals**

- Write correct OS/8 programs.
- Respect field and page conventions.
- Understand extended memory behavior.

**Exercises**

- OS/8-safe program exit.
- Field-safe subroutine callable from field 0.
- EAE detection with dual-path arithmetic.

**Classification**

Exercise 2 is advanced. It is retained because it teaches the precise IF/DF and cross-field mechanics that later chapters depend on, but it should be treated as systems-programming depth rather than ordinary application-programming baseline.

### Chapter 6 - I/O Programming: TTY, PTR, and PTP

**Goals**

- Understand PDP-8 I/O at the instruction and convention level.
- Work with polled I/O and device flags.
- Use TTY and paper tape in a disciplined way.

**Concepts**

- IOT instructions.
- Skip-on-flag behavior.
- Busy-wait loops.
- Device independence assumptions.
- Direct device access versus OS/8-mediated I/O.

**Exercises**

- Character output to TTY using polling.
- Character input with echo.
- Line-buffered input routine.
- Read a block from PTR into memory.
- Punch memory contents to PTP.

### Chapter 7 - OS/8 Tools and Program Lifecycle

**Goals**

- Become fluent with the OS/8 development workflow.
- Understand what each command does to files and memory.
- Distinguish assembling, loading, saving, starting, and running.

**Concepts**

- PAL8 invocation patterns.
- Listing generation and symbol review.
- LOAD versus SAVE.
- GET, START, RUN, and R.
- DIR and PIP for everyday file management.
- FUTIL as an inspection tool.
- Why RUN can execute an older saved image after source or binary changes.

**Exercises**

- Assemble, load, save, run, get, and start one small program; document what changes after each command.
- Modify source, reassemble, and verify that RUN still executes the old .SV image until LOAD and SAVE are repeated.
- Modify a word in core after LOAD but before SAVE; verify that SAVE captures the live memory image.
- Use DIR, PIP, and FUTIL to inspect the files produced by the workflow.

### Chapter 8 - File Formats: PA, LS, BN, and SV

**Goals**

- Understand what .PA, .LS, .BN, and .SV files contain.
- Connect PAL8 listing output to loader input and saved memory images.
- Understand file artifacts without confusing them with runtime OS/8 services.

**Concepts**

- .PA as PAL8 source text.
- .LS as listing and symbol-table output.
- .BN as binary loader input with embedded origins and data words.
- .SV as a saved executable memory image.
- OS/8 text packing and binary storage representation.
- Loader blocks, origins, checksums, and saved core segments.

**Exercises**

- Inspect OS/8 text-file packing using a small .PA file.
- Inspect a .BN file and map its loader records to the .LS listing.
- LOAD and SAVE a program; compare the .BN input with the .SV output.
- Identify the start address, segment descriptors, and captured core words in a .SV file.

**Classification**

Detailed .BN and .SV decoding is advanced OS/8 internals material. It is valuable because it demystifies the toolchain, but it is not a prerequisite for writing simple OS/8 applications.

### Chapter 9 - Loader and Multi-File Programs

**Goals**

- Build programs from multiple source files.
- Understand how the loader merges modules.
- Coordinate addresses, origins, symbols, and shared data across files.

**Concepts**

- Multi-file PAL8 assembly.
- Binary loader merging.
- Absolute origins and address collisions.
- Shared data regions.
- Symbol ownership and naming discipline.
- Library-like source organization.
- Separating module interface from implementation.

**Exercises**

- Split an existing exercise into main and utility source files.
- Build a program from three modules with one shared data region.
- Create an intentional origin overlap; diagnose and repair the layout.
- Create an intentional symbol conflict; diagnose and repair the naming/interface problem.
- Write a short module map documenting ownership of pages, symbols, and data.

### Chapter 10 - Control-Flow and Field Failure Modes

**Goals**

- Diagnose the most common PDP-8 control-flow failures.
- Apply IF/DF and CIF rules to broken programs.
- Convert prior field knowledge into a repeatable debugging method.

**Concepts**

- Direct versus indirect JMP and JMS failures.
- IF versus DF mistakes.
- CIF deferred-effect hazards.
- Bad cross-page and cross-field returns.
- Return-slot corruption.
- MONITOR ERROR-style failure analysis.
- Using HLT, RIF, RDF, listings, and memory inspection to locate faults.

**Exercises**

- Trigger and diagnose a bad indirect jump caused by a wrong IF assumption.
- Construct a CIF timing bug deliberately; trace what actually executes and why.
- Break a field-safe return path and repair it using RIF/RDF evidence.
- Diagnose a provided broken program by trace and listing only.

### Chapter 11 - USR Calls and CHAIN

**Goals**

- Call OS/8 system services through the USR interface.
- Understand parameter block layout and calling conventions.
- Maintain correct IF/DF state around OS/8 service calls.
- Use CHAIN only after the OS/8 service mechanism is understood.

**Concepts**

- USR entry through JMS I (7600).
- Function codes and parameter blocks.
- Caller obligations before and after USR calls.
- Monitor state versus user-program state.
- CHAIN as an OS/8 service-mediated handoff.
- What state survives chaining and what must not be assumed.

**Exercises**

- Make a minimal USR call with a hand-built parameter block.
- Write a reusable USR wrapper that preserves or restores documented state.
- Call USR to perform a simple OS/8 service and inspect the parameter block before and after the call.
- Chain from Program A to Program B; document which memory and register state survives.

### Chapter 12 - File I/O and Buffers

**Goals**

- Read and write files through OS/8.
- Manage buffers correctly in memory.
- Understand binary versus ASCII data handling.

**Concepts**

- OS/8 file access through USR services.
- Open/read/write/close-style calling patterns as exposed by OS/8.
- Buffer placement, alignment, and field constraints.
- ASCII text packing versus binary word data.
- Record-oriented processing.
- Error handling and cleanup paths.

**Exercises**

- Read a binary file from disk into a buffer and verify contents.
- Write a buffer to a new file and confirm using OS/8 tools.
- Read an ASCII file and count lines, words, or records.
- Process a fixed-length record file and produce a small report.

### Chapter 13 - File System and Logical Devices

**Goals**

- Reason about OS/8 disk behavior and file placement.
- Understand directory structure and block allocation.
- Work confidently with logical devices.

**Concepts**

- OS/8 directory layout and file sizes.
- Block allocation and free space.
- Fragmentation and deletion behavior.
- Logical devices such as SYS: and DSK:.
- Device assignment.
- PIP as a file-system tool, not only a copier.

**Exercises**

- Inspect directory contents and map used versus free blocks.
- Fill a disk near capacity, delete files, and observe allocation behavior.
- Use device assignment to redirect logical devices and test the effect on a program.
- Explain how a file-I/O program changes when its target device assignment changes.

### Chapter 14 - Device Handlers

**Goals**

- Understand what an OS/8 device handler is and how OS/8 invokes it.
- Relate direct IOT programming to handler-mediated I/O.
- Know how to use, reason about, and diagnose handlers without requiring handler authorship.

**Concepts**

- Device handler as an OS/8 code module.
- Handler dispatch path.
- Relationship between IOT device codes and OS/8 handler abstractions.
- Differences between direct polled I/O and OS/8-mediated I/O.
- Handler constraints visible to application programs.

**Exercises**

- Trace the path from a file-read USR call to a device handler conceptually.
- Compare direct IOT access and handler-mediated access to the same class of device.
- Assign a device and observe how the same program reaches different backing storage.
- Diagnose a handler or device-assignment mismatch from observed program behavior.

### Chapter 15 - Overlays

**Goals**

- Structure programs larger than one convenient resident image.
- Load code segments on demand through OS/8 mechanisms.
- Understand the performance and design cost of overlays.

**Concepts**

- Root code versus overlay code.
- Overlay region address conventions.
- Overlay loading through USR/file services.
- Preserved state and destroyed state across overlay loads.
- I/O cost of overlays versus field cost of resident code.

**Exercises**

- Convert a two-routine program to use an overlay for a less-used routine.
- Chain or load three overlay-like segments in sequence and verify execution order.
- Measure or estimate overlay load cost versus running equivalent resident code.
- Document the overlay contract: entry point, overwritten region, preserved data, and caller obligations.

### Chapter 16 - Performance and Design Tradeoffs

**Goals**

- Make informed design decisions based on PDP-8 resource constraints.
- Understand the relative cost of fields, overlays, direct I/O, and OS/8 services.
- Choose between single-field, multi-field, and overlay designs consciously.

**Concepts**

- CPU cost versus I/O cost.
- Field switching complexity versus memory savings.
- Direct IOT speed versus OS/8 portability and structure.
- Code density, literal pools, and page pressure.
- When to split code and when to optimize in place.

**Exercises**

- Rewrite a prior multi-file program as a single-field program and compare complexity.
- Design a memory layout for a hypothetical large application before coding.
- Analyze a provided layout and identify page, field, and I/O bottlenecks.
- Refactor a page-overflowing program by changing layout rather than blindly shortening comments or labels.

### Chapter 17 - Program Architecture

**Goals**

- Apply fields, overlays, subroutines, USR calls, and module conventions coherently.
- Separate code, data, buffers, OS interface regions, and diagnostic state.
- Design maintainable PDP-8 programs before writing code.

**Concepts**

- Memory maps as design artifacts.
- Page ownership and field ownership.
- Interface contracts between modules.
- Shared data regions and DF discipline.
- Error paths and cleanup paths.
- Documentation of assumptions and invariants.

**Exercises**

- Produce a complete memory map for a medium-sized application before coding.
- Restructure a prior exercise to use a documented canonical layout.
- Define a shared data region accessed from two fields via explicit DF switching.
- Apply the full convention set in one medium-sized program.

### Chapter 18 - Debugging and Failure Analysis

**Goals**

- Recover from real PDP-8 and OS/8 program failures.
- Apply a systematic diagnostic workflow.
- Read existing PDP-8 code accurately.

**Concepts**

- Failure signatures and likely causes.
- Front-panel inspection strategy.
- Listing-driven trace reconstruction.
- RIF/RDF field inspection.
- Distinguishing addressing errors from data errors.
- Diagnosing stale state from self-modifying code.
- Reading and documenting unfamiliar historical-style routines.

**Exercises**

- Introduce a bad indirect jump into a working program; diagnose and fix it.
- Reproduce a monitor-return failure and trace the return path backward.
- Diagnose a provided broken program without running it.
- Read an unfamiliar PDP-8 routine, determine what it does, and document its assumptions.

### Chapter 19 - Capstone: Integrated Program

**Goal**

Demonstrate full system-level competency by building a program that exercises the workbook's major concepts.

**Requirements**

The program must:

- Use multiple source files.
- Use DF or CIF correctly for extended memory.
- Call OS/8 through USR for at least one operation.
- Perform file I/O with proper buffer management.
- Exit correctly and unconditionally.
- Include a documented memory map.
- Include module-level interface documentation.
- Include a short failure-analysis note describing how the program would be debugged if it failed.

**Optional Challenge**

Include an intentional bug, diagnose it using the Chapter 18 methodology, and document the fix.

**Outcome**

The student can design, build, debug, and ship a real PDP-8 program.

## Progress Tracking

- Complete: Chapter 1 - Core PDP-8 Mental Model
- Complete: Chapter 2 - Control Flow and Subroutines
- Complete: Chapter 3 - Rotates, Shifts, and Bit Logic
- Complete: Chapter 4 - Multi-Word Arithmetic
- Complete: Chapter 5 - OS/8 and Extended Memory
- Complete: Chapter 6 - I/O Programming: TTY, PTR, and PTP
- In progress: Chapter 7 - OS/8 Tools and Program Lifecycle
- Not started: Chapter 8 - File Formats: PA, LS, BN, and SV
- Not started: Chapter 9 - Loader and Multi-File Programs
- Not started: Chapter 10 - Control-Flow and Field Failure Modes
- Not started: Chapter 11 - USR Calls and CHAIN
- Not started: Chapter 12 - File I/O and Buffers
- Not started: Chapter 13 - File System and Logical Devices
- Not started: Chapter 14 - Device Handlers
- Not started: Chapter 15 - Overlays
- Not started: Chapter 16 - Performance and Design Tradeoffs
- Not started: Chapter 17 - Program Architecture
- Not started: Chapter 18 - Debugging and Failure Analysis
- Not started: Chapter 19 - Capstone: Integrated Program

## Required Versus Advanced Material

The workbook intentionally separates required programming competence from advanced system understanding.

**Required material** includes:

- Instruction tracing.
- JMS subroutines.
- Auto-indexing.
- Page management.
- Link-based arithmetic.
- Multi-word arithmetic.
- OS/8 return discipline.
- IF/DF and CIF/CDF basics.
- Polled I/O.
- OS/8 tool workflow.
- Multi-file program structure.
- USR calls.
- File I/O and buffer management.
- Systematic debugging.

**Advanced material** includes:

- Detailed .BN and .SV decoding.
- Dynamic construction of CIF/CDF instructions.
- Complex cross-field subroutine returns.
- Deep device-handler behavior.
- Overlay performance analysis.
- Detailed storage allocation inspection.

Advanced material is retained because it improves system understanding, but later exercises should not silently depend on advanced internals unless the dependency is explicitly stated.

## Code Review Standards

When reviewing any exercise solution, evaluate:

- Correctness: trace execution manually when needed.
- Runaway risk: every code path must terminate or intentionally loop.
- Style: tabs, columns, labels, comments, and PAL8 conventions.
- Comments: intent-driven, not mnemonic restatement.
- Idioms: CLA CLL, CIA, ISZ counters, auto-index seeding, Link discipline.
- OS/8 safety: reset IF and DF before returning to the monitor.
- Field discipline: explicit CDF/CIF handling and documented assumptions.
- Page discipline: literal pools, page boundaries, and direct-address limits.
- Resource use: page 0, auto-index registers, literals, buffers, and fields.
- Historical fit: period-appropriate patterns without anachronistic abstractions.

## Notes and Conventions

- Octal notation is the default.
- Page 0 usage is per-field on extended systems.
- AC, Link, and MQ are destroyed unless explicitly documented otherwise.
- Subroutines document entry conditions, exit conditions, and preserved state.
- I/O routines document device usage and blocking behavior.
- Programs that run under OS/8 must return through the documented OS/8 exit path.
- Documentation should separate programmer-visible behavior from implementation detail.

## Appendix A - OS/8 Tools Quick Reference

This appendix is reference material. Chapter 7 is the instructional path for using these tools deliberately.

### Common Monitor Commands

- `DIR [device:]` - list a directory.
- `DATE MMDDYY` - set the system date.
- `R progname` - run a saved program through CCL expansion.
- `LOAD file,file,...` - load `.BN` files into memory.
- `SAVE dev:name start low-high` - save a memory image as `.SV`.
- `GET file` - load a `.SV` file without starting it.
- `START [addr]` - start execution at an address already in memory.

### Common File Tools

- `PIP` - copy, delete, rename, concatenate, and list files.
- `FUTIL` - inspect files and disk structures.
- `PAL8` - assemble PAL8 source into binary and listings.
- `CREF` - produce cross-reference listings when needed.
- `SUBMIT` - run command procedures where available.

### Development Workflow Summary

A typical workflow is:

```text
PAL PROG        Assemble source into listing and binary output
LOAD PROG       Deposit the binary loader output into core
SAVE PROG 200   Save the loaded core image as an executable image
RUN PROG        Reload and run the saved executable image
```

The critical rule is that each step consumes the output of the previous step. Reassembling source does not update an existing saved image until the program is loaded and saved again.

## Philosophy

The PDP-8 rewards clarity, discipline, and honesty. The machine is small enough to understand completely, but only if each mechanism is treated precisely. This workbook treats PDP-8 programming as a real systems discipline: trace the machine, respect the constraints, document the contract, and prove the result.
