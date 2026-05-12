# Chapter 7 — File Formats and Program Lifecycle

## Goals

- Understand what .BN, .SV, and .EX actually contain
- Trace the full PAL → LOAD → SAVE → RUN workflow step by step
- Know what each OS/8 command is doing to memory

---

## Concepts

### File Types

**.PA** — PAL8 source file. Plain ASCII text, one statement per line. The assembler reads this.

**.LS** — Listing file. Human-readable output from PAL showing each source line alongside its assembled octal value and address. Contains the symbol table at the end.

**.BN** — Binary loader format. What PAL emits when it assembles successfully. Structured as a sequence of blocks: each block has a load address followed by data words. The LOAD command reads this and deposits the words into memory. Not a flat binary image — the load address is embedded.

**.SV** — Saved executable image. Produced by the SAVE command after a program has been loaded into memory. Contains the memory image from a start address through an end address, plus the starting address for execution. SAVE captures AC, L, IF, DF, and the PC along with the memory image.

**.EX** — Execution/chaining format. Similar to .SV but used specifically for chaining — one OS/8 program handing control to another. The receiving program is loaded and execution begins without returning to the monitor.

### The PAL → LOAD → SAVE → RUN Workflow

```
PAL PROG         Assemble PROG.PA → PROG.BN (and PROG.LS)
LOAD PROG        Read PROG.BN; deposit words into core at the addresses encoded in each block
SAVE PROG 200    Snapshot core from 0200 onward into PROG.SV; record entry point 0200
RUN PROG         Load PROG.SV into core and jump to the saved entry point
```

Each command does one specific thing. SAVE knows nothing about source code — it snapshots whatever is currently in core. If you assemble a new version without SAVE-ing after LOAD, RUN still executes the old image.

### Loader Block Structure (.BN)

A .BN file consists of variable-length blocks, each beginning with a word count and load address, followed by that many data words. The LOAD command uses the load address in each block — not the current PC — to determine where to deposit the words. Multiple blocks in one file can load to non-contiguous addresses. A termination block (word count of zero) ends the file.

---

## Exercises

### Exercise 1 — Inspect the .BN Loader Format

Write a minimal program (a counter or trivial loop), assemble it with PAL, and examine the resulting .BN file using PIP or a dump utility. Identify:
- How many blocks are present
- The load address encoded in each block
- The content of each word vs. the expected assembled values from the .LS listing

Confirm that the .BN content matches the .LS output line by line.

### Exercise 2 — LOAD, SAVE, and Compare

Using the program from Exercise 1:
1. LOAD the .BN file
2. SAVE the result to a .SV file
3. Examine both the .BN and .SV files with a dump utility; note the structural difference
4. Identify: where is the entry point stored in the .SV file? What range of core is captured?
5. Modify a word in core at the front panel *after* LOAD but *before* SAVE; verify the modified word appears in the .SV image

The goal is to make concrete that SAVE captures the live memory state, not the source.

### Exercise 3 — Program Chaining with .EX

Write two short programs:
- **Program A**: does a small computation, then chains to Program B via `JMS I (7600)` with the CHAIN function code
- **Program B**: picks up where A left off (reading a known memory location that A wrote)

Assemble, load, and save both. Run Program A and observe: does Program B start? Does it see A's data? Document which state (AC, memory, fields) survives the chain.
