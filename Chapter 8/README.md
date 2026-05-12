# Chapter 8 — OS/8 Tools and Workflow

## Goals

- Master the OS/8 command environment and standard toolchain
- Use PIP, PAL, LOAD/SAVE, TECO, and CCL fluently
- Understand how chaining composes tools into workflows

---

## Concepts

### The OS/8 Command Environment

OS/8 presents a dot (`.`) prompt from the monitor. From there, programs are run with `.R PROGNAME` or via CCL (Command and Control Language) shortcuts. The monitor is not an interactive shell in the modern sense — it is a minimal dispatcher.

### CCL — Command and Control Language

CCL is a command preprocessor that expands shorthand OS/8 commands into `.R PROGNAME` invocations with arguments. For example:

```
.PAL MYPROG        expands to:  .R PAL; MYPROG.BN<MYPROG.PA
.LOAD MYPROG                    .R LOAD; MYPROG.BN
.SAVE SYS MYPROG 200            .R SAVE; SYS:MYPROG.SV; 00200-07600
```

Understanding what CCL expands to is essential when things go wrong — the error message will come from the underlying program, not from CCL.

### PIP — Peripheral Interchange Program

PIP is the OS/8 file management utility. It copies, renames, deletes, and lists files. Key operations:

```
.PIP                              enter PIP; use DSK: as default device
DSK:NEWFILE.PA<DSK:OLDFILE.PA    copy
DSK:*DSK:                        list directory
^C                                exit PIP
```

PIP is also used to copy files between devices (e.g., disk to paper tape punch).

### PAL — PDP-8 Assembler

PAL is invoked with an output file spec and an input source file:

```
.R PAL
*MYPROG.BN,MYPROG.LS<MYPROG.PA
```

The listing goes to the second output (`.LS`); the binary goes to the first (`.BN`). Omit the `.LS` spec to suppress the listing. Error messages appear in the listing; a clean assembly has no `?` symbols.

### LOAD and SAVE

```
.R LOAD
*MYPROG.BN            load binary into core

.R SAVE
*SYS:MYPROG.SV; 00200-07577; 00200   save core 0200–7577, entry at 0200
```

SAVE takes a start address, an end address, and optionally an explicit entry point. If the entry point is omitted, it defaults to the start address.

### TECO — Text Editor and Corrector

TECO is the standard OS/8 text editor. It is not interactive in the word-processor sense — it processes editing commands. To create a new file:

```
.R TECO
*MYPROG.PA                open MYPROG.PA for output
I<text><ESC>              insert text, terminate with ESC
EX<ESC>                   write and exit
```

Key TECO commands: `I` (insert), `D` (delete character), `K` (delete line), `T` (type), `P` (advance page/buffer), `EX` (write and quit).

### CHAIN

CHAIN hands control from one OS/8 program to another without returning to the monitor. The destination receives control with the core image the chaining program left behind (plus whatever the new program loads). The chaining program calls the monitor via USR with a CHAIN function code pointing to the new program name.

The canonical example is PAL chaining to CREF (cross-reference generator) after a successful assembly. Neither program returns to the monitor between them.

CHAIN differs from RUN:
- **RUN** goes through the monitor; the monitor loads the image fresh
- **CHAIN** bypasses the monitor; the new program inherits current core (outside its load area)

---

## Exercises

### Exercise 1 — Navigate OS/8

From the OS/8 monitor:
1. List the directory with `.DIR` and with `PIP DSK:*DSK:`; compare the output
2. Use PIP to copy a source file to a backup name (e.g., `MYPROG.PA` → `MYPROG.BAK`)
3. Delete the backup with PIP
4. Use `.DATE` to check the system date; change it if wrong
5. Use `.R ABSLDR` to enter the absolute loader directly; exit with `^C`

The goal is fluency with the day-to-day command environment before writing any new code.

### Exercise 2 — Source Editing and Assembly

1. Use TECO to create a new source file from scratch (a minimal program: CLA, TAD literal, HLT)
2. Assemble it with PAL; examine the `.LS` listing — find the symbol table, the assembled words, and any errors
3. Introduce a deliberate error (undefined symbol); re-assemble; locate the `?` in the listing
4. Fix the error and re-assemble cleanly

### Exercise 3 — Full Development Cycle

Take an exercise from Chapter 5 or Chapter 6 that you have already written:
1. Edit the source with TECO to add a comment or change a label name
2. Re-assemble with PAL
3. LOAD the new .BN
4. SAVE the updated image under a new name
5. RUN both the old and new images; confirm they behave identically
6. Delete the old image with PIP

The goal is to execute the complete modify-build-test loop as it would have been done on a real OS/8 system.

### Exercise 4 — Chaining Workflow

1. Write a trivial "stage 1" program that writes a value to a known memory location and then issues a CHAIN to a "stage 2" program
2. Write the "stage 2" program that reads that memory location and displays it (via TTY or HLT for front-panel inspection)
3. Assemble, load, and save both
4. Run stage 1; verify stage 2 executes and sees the value left by stage 1
5. Document: which parts of core are preserved through the chain? Which are overwritten?
