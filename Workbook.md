# PDP-8 Programming Workbook

## Purpose

This workbook provides a structured path toward becoming a reasonably strong PDP-8 programmer, both bare metal and within OS/8.

The emphasis is practical programming competence. Deep dives are included when they provide foundational value for later programming work.

## Exercise Plan

### Chapter 1 - Core PDP-8 Mental Model

**Status**
- ✅ Complete

**Goals**
- Internalize AC, Link, and memory as system state
- Understand instruction sequencing and skips
- Become fluent at manual execution tracing

**Concepts**
- Refer to the completed chapter documentation for the concepts already covered in this chapter.

**Exercises**
- ✅ Trace a simple add/store program by hand
- ✅ Count from 1-10 and accumulate a sum
- ✅ Rewrite the loop using auto-index registers

See [Chapter 1 README](Chapter%201/README.md) for implementation rationale, non-intuitive points, and key learning points.

---

### Chapter 2 - Control Flow and Subroutines

**Status**
- ✅ Complete

**Goals**
- Understand JMS at the memory level
- Learn safe subroutine discipline
- See why return-slot conventions exist

**Concepts**
- Refer to the completed chapter documentation for the concepts already covered in this chapter.

**Exercises**
- ✅ Absolute-value subroutine
- ✅ Compare two values (-1 / 0 / 1)
- ✅ Nested subroutines and state-saving bug fix

See [Chapter 2 README](Chapter%202/README.md) for implementation rationale, non-intuitive points, and key learning points.

---

### Chapter 3 - Rotates, Shifts, and Bit Logic

**Status**
- ✅ Complete

**Goals**
- Treat L:AC as a 13-bit shift register
- Distinguish logical vs arithmetic shifts
- Use rotates for bit manipulation

**Concepts**
- Refer to the completed chapter documentation for the concepts already covered in this chapter.

**Exercises**
- ✅ Count bits set in a word
- ✅ Multiply by 10 without EAE
- ✅ Implement an arithmetic right shift

See [Chapter 3 README](Chapter%203/README.md) for implementation rationale, non-intuitive points, and key learning points.

---

### Chapter 4 - Multi-Word Arithmetic

**Status**
- ✅ Complete

**Goals**
- Handle numbers larger than 12 bits
- Explicit carry propagation via Link
- Variable-length arithmetic

**Concepts**
- Refer to the completed chapter documentation for the concepts already covered in this chapter.

**Exercises**
- ✅ 24-bit addition and subtraction
- ✅ Variable-length accumulation with overflow detection
- ✅ Multi-word comparison routine

See [Chapter 4 README](Chapter%204/README.md) for implementation rationale, non-intuitive points, and key learning points.

---

### Chapter 5 - OS/8 and Extended Memory

**Status**
- ✅ Complete

**Goals**
- Write correct OS/8 programs
- Respect field and page conventions
- Understand extended memory behavior

**Concepts**
- Refer to the completed chapter documentation for the concepts already covered in this chapter.

**Exercises**
- ✅ OS/8-safe program exit
- ✅ Field-safe subroutine callable from field 0
- ✅ EAE detection with dual-path arithmetic

See [Chapter 5 README](Chapter%205/README.md) for implementation rationale, non-intuitive points, and key learning points.

---

### Chapter 6 - I/O Programming: TTY, PTR, PTP

**Status**
- ✅ Complete

**Goals**
- Understand PDP-8 I/O at the instruction and convention level
- Work with polled I/O and device flags
- Use TTY and paper tape in a disciplined way

**Concepts**
- IOT instructions
- Skip-on-flag behavior
- Busy-wait loops
- Device independence assumptions
- TTY keyboard and printer flag cycles
- PTR read initiation and polling
- PTP punch flag cycle
- Direct device I/O versus OS/8-mediated I/O

**Exercises**
- ✅ Character output to TTY using polling
- ✅ Character input with echo
- ✅ Line-buffered input routine
- ✅ Read a block from PTR into memory
- ✅ Punch memory contents to PTP

See [Chapter 6 README](Chapter%206/README.md) for implementation rationale, non-intuitive points, and key learning points.

---

### Chapter 7 - OS/8 Tools and Development Workflow

**Status**
- 🔲 Not Started

**Goals**
- Become fluent with the OS/8 development cycle
- Understand what each tool consumes and produces
- Distinguish source, binary loader output, live memory, and saved executable images

**Concepts**
- PAL8 source files (.PA)
- Listing files (.LS)
- Binary loader files (.BN)
- Saved images (.SV)
- CREF cross-reference listings
- LOAD, SAVE, GET, START, RUN, and R
- DIR, PIP, and FUTIL as everyday inspection tools
- The difference between assembling, loading, saving, and running

**Exercises**
- 🔲 Create a small versioned program, then perform the full PAL -> LOAD -> SAVE -> RUN -> GET -> START lifecycle. After each command, document what changed on disk, what changed in memory, and what command would be needed to execute the current version.
- 🔲 Modify the source so the program visibly identifies a new version, assemble it, and prove that RUN still executes the old saved image until LOAD and SAVE are repeated. Then modify one core word after LOAD but before SAVE and prove that SAVE captures the modified live image.
- 🔲 Build the same program using PAL and CREF, then use DIR, PIP, and FUTIL to inspect the generated files. Identify symbol definitions, symbol references, file sizes, and which artifact each tool consumes or produces.

**Advanced Exercises**
- 🔲 Automate the assemble, cross-reference, load, save, and verification workflow using SUBMIT or the closest available OS/8 command procedure mechanism.

---

### Chapter 8 - Command Decoder and Program Invocation

**Status**
- 🔲 Not Started

**Goals**
- Understand how OS/8 launches programs in practical use
- Understand command decoding and CCL expansion at the user level
- Build repeatable command-driven workflows

**Concepts**
- Keyboard monitor
- Command decoder
- CCL expansion
- Direct .SV execution versus R command invocation
- Command files and SUBMIT
- Program startup conventions
- Argument and device specification conventions

**Exercises**
- 🔲 Choose several common OS/8 commands, such as PAL, PIP, BASIC, and CREF, and determine what command was entered, what program was actually executed, and how the command decoder transformed the request.
- 🔲 Run the same saved program through at least two invocation paths, such as direct execution and R. Compare startup behavior, visible prompts, argument handling, and assumptions about default devices.
- 🔲 Create a repeatable command procedure that assembles a program, generates a listing and cross-reference, loads it, saves it, and verifies that the expected output files exist.

---

### Chapter 9 - Loader and Multi-Module Programs

**Status**
- 🔲 Not Started

**Goals**
- Build larger programs from multiple source files
- Understand how the loader combines modules
- Manage module boundaries, origins, symbols, and shared data

**Concepts**
- Multi-file PAL invocation
- Loader merging of binary modules
- Absolute origins and address ownership
- Shared data regions
- Symbol ownership and naming discipline
- Cross-file references and failure modes
- Module interface documentation

**Exercises**
- 🔲 Split an existing working program into MAIN and UTILITY modules. Assemble and load the modules together, then document the public entry points, private labels, and which module owns each page or data area.
- 🔲 Build a three-module program with MAIN, UTILITY, and COMMON data. The modules must communicate through a documented shared data region, with explicit rules for initialization, ownership, and modification.
- 🔲 Intentionally create both an origin overlap and a symbol ownership problem. Capture the observed assembler or loader failure, explain the cause, and repair the layout or naming contract.

---

### Chapter 10 - PAL8 Advanced Source Techniques

**Status**
- 🔲 Not Started

**Goals**
- Use PAL8 as a source-level programming tool, not only an assembler
- Use macros and conditional assembly without hiding the machine model
- Understand source organization techniques used by larger PAL8 programs

**Concepts**
- Macro definitions
- Macro parameters
- Macro expansion in listings
- Conditional assembly
- Symbolic configuration
- Macro versus JMS tradeoffs
- Reusable source include patterns where available

**Exercises**
- 🔲 Refactor duplicated instruction sequences from an earlier program into one or more PAL8 macros. Use the listing to show the expanded generated code and verify that the macro hides no required machine behavior.
- 🔲 Implement the same operation both as a macro and as a JMS subroutine. Compare generated code size, execution path, AC/Link effects, maintainability, and when each form is preferable.
- 🔲 Use conditional assembly or symbolic configuration to produce two variants of one program from the same source base, such as direct TTY I/O versus a diagnostic HLT path.

**Advanced Exercises**
- 🔲 Build a small reusable macro library for common local idioms and use it in two separate programs without making later chapters depend on the library.

---

### Chapter 11 - OS/8 Programming Model and Interfaces

**Status**
- 🔲 Not Started

**Goals**
- Understand where an application program fits within OS/8
- Learn practical OS/8 runtime interfaces before raw USR programming
- Understand SYS:, DSK:, and logical-device behavior

**Concepts**
- Application programs
- Runtime support routines
- USR as the OS/8 service boundary
- Monitor and resident OS services
- Device handlers as an abstraction layer
- ICHR and OCHR style character interfaces
- IOPEN and OOPEN style file interfaces
- SYS:, DSK:, and device assignment

**Exercises**
- 🔲 Rewrite a Chapter 6 character I/O style program to use OS/8 character-oriented runtime routines such as ICHR and OCHR, if available in the local environment. Compare the result with direct KSF/KRB and TSF/TLS code.
- 🔲 Use available file-oriented runtime routines, such as IOPEN and OOPEN, to open or prepare access to a file and display, copy, or summarize its contents. Document the calling sequence and what state must be set before the call.
- 🔲 Move a program and its data between SYS: and DSK:, alter logical-device assignments, and verify how program lookup, file lookup, and default output behavior change.

---

### Chapter 12 - USR Calls

**Status**
- 🔲 Not Started

**Goals**
- Call OS/8 system services through the USR interface
- Understand parameter blocks and function conventions
- Use FETCH, INQUIRE, and CHAIN with correct field discipline

**Concepts**
- USR and its entry convention
- JMS I (7600) as the service entry
- Parameter block layout
- Function codes and returned values
- FETCH and INQUIRE
- CHAIN as a service-mediated transfer
- IF/DF obligations around service calls
- The conceptual role of handlers beneath USR calls

**Exercises**
- 🔲 Construct a minimal USR parameter block and invoke a simple OS/8 service. Trace every word in the parameter block before the call, after the call, and at the return point.
- 🔲 Use FETCH or INQUIRE to obtain information about a named file or device. Display or store the returned information and explain which part depends conceptually on OS/8 device handlers.
- 🔲 Create Program A and Program B. Program A writes known state, invokes CHAIN to transfer to Program B, and Program B verifies what memory or state survived the transfer. Document which survival assumptions are valid and which are not.

**Advanced Exercises**
- 🔲 Write a reusable, field-safe USR wrapper that saves required field state, performs the service call, restores required state, and documents caller obligations.

---

### Chapter 13 - File I/O and Buffers

**Status**
- 🔲 Not Started

**Goals**
- Read and write files through OS/8
- Manage buffers correctly in memory
- Handle binary and ASCII data deliberately

**Concepts**
- OS/8 file access model
- Open, read, write, and close style call sequences where available
- Buffer placement and alignment
- Field constraints on buffers
- Binary word data versus packed ASCII text
- Sequential record processing
- Error handling and cleanup paths

**Exercises**
- 🔲 Read a binary file into a buffer at a documented address. Verify the buffer contents independently with FUTIL, PIP, a listing, or a controlled dump so the exercise proves the read, not just the absence of an error.
- 🔲 Generate a known data pattern in memory, write it to a new file, and verify the output file with OS/8 tools. Include at least one failure or overwrite case and document the expected behavior.
- 🔲 Read an ASCII text file and produce useful statistics, such as line count, word count, record count, or character class counts. Document how packed text representation affects processing.

**Advanced Exercises**
- 🔲 Process a fixed-length record file and generate a small report, including record count, selected fields, and validation of malformed or partial records.

---

### Chapter 14 - File System, Devices, and Handlers

**Status**
- 🔲 Not Started

**Goals**
- Reason about OS/8 disk behavior and file placement
- Understand logical devices and assignment
- Understand handlers well enough to use and diagnose them

**Concepts**
- OS/8 directory structure
- Block allocation and free space
- File size and contiguous allocation concerns
- Logical devices such as SYS: and DSK:
- Device assignment
- Device handlers as OS/8 code modules
- Logical versus physical devices
- Handler-mediated I/O versus direct IOT access

**Exercises**
- 🔲 Use DIR, PIP, and FUTIL to inspect a working disk image. Map files to sizes and free space, then explain what can and cannot be inferred about allocation from the available tools.
- 🔲 Redirect logical devices and repeat a known program or file workflow. Document exactly which behavior changed because of assignment and which behavior remained tied to the physical device or system device.
- 🔲 Trace a file read conceptually from application code through USR, the monitor, a handler, and the underlying hardware. Identify where Chapter 6 direct IOT knowledge fits into the handler-mediated path.

---

### Chapter 15 - OS/8 Program Artifacts and Internals

**Status**
- 🔲 Not Started

**Goals**
- Understand why OS/8 uses multiple program artifacts
- Understand LOAD and SAVE at a conceptual and practical level
- Gain foundational knowledge of program representation without requiring daily binary archaeology

**Concepts**
- Source versus executable representation
- .PA source files
- .LS listings and symbol tables
- .BN binary loader files
- .SV saved executable images
- Loader records and origins
- Live memory images
- SAVE as memory capture
- Why .EX is historical context rather than a required local artifact unless present on the system

**Exercises**
- 🔲 Follow one program through PA -> LS -> BN -> LOAD -> SAVE -> SV. For each stage, document what information exists, what information is lost, and which tool consumes or produces the artifact.
- 🔲 Compare a program's BN file and SV image at a practical level. Explain why both exist, why BN is loader input rather than a memory image, and why SV is executable without re-running the loader workflow.
- 🔲 Load a program, alter a memory word before SAVE, save the program, and prove that the SV image captured the live modified state. Explain why this matters for debugging and patching.

**Advanced Exercises**
- 🔲 Decode enough BN loader records to map origins and data words back to the listing.
- 🔲 Decode enough SV structure to identify the entry point, captured segments, and stored memory words for a simple saved program.

---

### Chapter 16 - Performance and Design Tradeoffs

**Status**
- 🔲 Not Started

**Goals**
- Make informed design decisions based on PDP-8 resource constraints
- Understand the relative cost of different memory strategies
- Choose between fields, overlays, macros, subroutines, and single-segment designs consciously

**Concepts**
- CPU cost versus I/O cost
- Inline code versus JMS subroutines
- Macro expansion versus shared routines
- Single-field programs
- Multi-field programs
- Overlay-like structures
- Page pressure and literal pools
- Memory layout planning before coding

**Exercises**
- 🔲 Implement a small operation three ways: inline, macro-expanded, and JMS subroutine. Compare word count, execution cost, readability, and the effect on AC, Link, and DF discipline.
- 🔲 Take one medium program design and sketch three layouts: single-field, multi-field, and overlay-like. Explain the tradeoffs in field switching, I/O cost, resident memory use, and complexity.
- 🔲 Start with a program that overflows or nearly overflows a page. Redesign the layout using page planning, literal management, or module movement rather than merely shortening comments or labels.

---

### Chapter 17 - Program Architecture

**Status**
- 🔲 Not Started

**Goals**
- Design maintainable PDP-8 programs before coding
- Create memory maps and module contracts
- Separate code, data, buffers, OS interfaces, and diagnostic state

**Concepts**
- Memory maps as design artifacts
- Page ownership
- Field ownership
- Module interfaces
- Shared data regions
- Buffer contracts
- DF discipline across modules
- Error paths and cleanup paths
- Documented assumptions and invariants

**Exercises**
- 🔲 Design a complete memory map for a medium-sized program before writing code. Include fields, pages, buffers, page-zero use, auto-index locations, literals, and OS/8 interface regions.
- 🔲 Define module interfaces for a multi-module program, including entry points, input state, output state, destroyed registers, field assumptions, and shared data ownership.
- 🔲 Refactor an earlier working program to follow the documented architecture. Verify that the refactor preserves behavior while improving layout clarity and maintainability.

**Advanced Exercises**
- 🔲 Design an overlay-capable architecture, including root code, overlay region, preserved data, destroyed data, and load contracts.

---

### Chapter 18 - Debugging and Failure Analysis

**Status**
- 🔲 Not Started

**Goals**
- Recover from real PDP-8 and OS/8 program failures
- Apply a systematic diagnostic workflow
- Use front-panel, listing, and instruction-level tools effectively

**Concepts**
- Common failure signatures
- Bad indirect jumps
- Wrong IF or DF assumptions
- Bad OS/8 return paths
- CIF deferred-effect bugs
- Return-slot corruption
- HLT as a checkpoint
- RDF and RIF for field inspection
- ODT as a debugging tool
- Listing-driven trace reconstruction

**Exercises**
- 🔲 Introduce a bad indirect jump or wrong-page control transfer into a working program. Diagnose it using the listing, memory inspection, and field-state reasoning, then repair it.
- 🔲 Reproduce a bad OS/8 return or field-state failure deliberately. Trace the return path backward and identify whether the error is IF, DF, CIF timing, or an invalid indirect jump.
- 🔲 Given a broken program and listing, diagnose the failure without running it. Produce a trace that identifies the first incorrect assumption and the minimal code change required.

**Advanced Exercises**
- 🔲 Use ODT to inspect memory, patch a small bug, and continue execution.
- 🔲 Reverse-engineer an unfamiliar PDP-8 routine and document what it does, what assumptions it makes, and how it should be called.

---

### Chapter 19 - Capstone: Integrated Program

**Status**
- 🔲 Not Started

**Goals**
- Demonstrate practical PDP-8 and OS/8 competency
- Integrate bare-metal programming, OS/8 services, file I/O, and disciplined architecture
- Produce a program that can be built, run, debugged, and maintained

**Concepts**
- Multi-module design
- OS/8 tool workflow
- Field discipline
- USR or runtime service use
- File I/O with buffers
- Documented memory map
- Module interface contracts
- Error handling and cleanup paths
- Debugging notes

**Exercises**
- 🔲 Design the program before coding. Produce the memory map, module list, shared data contract, file format or input/output contract, and build procedure.
- 🔲 Implement the program using multiple source files, correct OS/8 entry and exit behavior, field discipline, at least one OS/8 service or runtime interface, and file I/O with buffers.
- 🔲 Test, debug, and document the final program. Include normal cases, error cases, build instructions, final memory map, and a short failure-analysis note explaining how the program should be diagnosed if it fails.

**Advanced Exercises**
- 🔲 Include CHAIN or overlay-like behavior if it improves the design.
- 🔲 Include an intentional bug, diagnose it using the Chapter 18 method, and document the fix.

---

## Progress Tracking

- ✅ Chapter 1 complete (3 exercises)
- ✅ Chapter 2 complete (3 exercises)
- ✅ Chapter 3 complete (3 exercises)
- ✅ Chapter 4 complete (3 exercises)
- ✅ Chapter 5 complete (3 exercises)
- ✅ Chapter 6 complete (5 exercises)
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

## Code Review Standards

- **Correctness** - Does it produce the right result? Trace execution manually if needed.
- **Style** - Consistent spacing, alignment, and label naming. PAL8 convention is a single tab to the operand field.
- **Comments** - Labels and inline comments should describe intent precisely, not just restate the mnemonic.
- **Conventions** - Follows period PDP-8 idioms: `CLA CLL` for clear, `CIA` for negation, `ISZ`-based loop counters, `HLT` before OS/8 exit, and `CIF CDF` discipline.
- **Historical accuracy** - Code should reflect how real PDP-8 software was written in the era. Avoid anachronistic patterns.
- **OS/8 safety** - Programs that run under OS/8 must exit via `CIF CDF 00` plus `JMP I (7600)` after Chapter 5 field management is introduced.
- **Resource use** - Auto-index registers, page 0, literals, buffers, and fields should be used deliberately.
- **Runaway risk** - Execution must not fall into data words. Every code path must terminate cleanly or intentionally loop.

## Notes and Conventions

- Octal notation everywhere.
- Page 0 usage is per field on extended systems.
- AC and Link are always considered destroyed unless documented otherwise.
- I/O routines must document device usage and blocking behavior.
- Subroutines must document entry conditions, exit conditions, and preserved state.
- Cross-document references must use relative Markdown links.

## Appendix A - OS/8 Tools Quick Reference

### Monitor Commands

| Command | Effect |
|---|---|
| `DIR [device:]` | List directory of device, defaulting to DSK:. |
| `DATE MMDDYY` | Set system date. |
| `R progname` | Run a saved program via command expansion. |
| `LOAD file,file,...` | Load `.BN` files into memory. |
| `SAVE dev:name [start] [low-high]` | Save memory range as a `.SV` file. |
| `GET file` | Load a `.SV` file without starting it. |
| `START [addr]` | Start execution at an address already in memory. |

### LOAD / SAVE Workflow

```text
PAL PROG        Assemble PROG.PA into PROG.BN and listing output
LOAD PROG       Load PROG.BN into core at encoded origins
SAVE PROG 200   Save live core as PROG.SV with entry at 0200
R PROG          Reload and run PROG.SV
```

## Philosophy

The PDP-8 rewards clarity, discipline, and honesty. This plan treats the machine not as a curiosity, but as a system worthy of being programmed well.
