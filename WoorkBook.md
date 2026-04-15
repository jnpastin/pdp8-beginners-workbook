## The Exercise Plan

### Phase 1 – Core PDP‑8 Mental Model

**Goals**
- Internalize AC, Link, and memory as system state
- Understand instruction sequencing and skips
- Become fluent at manual execution tracing

**Exercises**
1. ✅ Trace a simple add/store program by hand 
2. ✅ Count from 1–10 and accumulate a sum 
3. ✅ Rewrite the loop using auto‑index registers 

---

### Phase 2 – Control Flow and Subroutines

**Goals**
- Understand `JMS` at the memory level
- Learn safe subroutine discipline
- See why return‑slot conventions exist

**Exercises**
1. ✅ Absolute‑value subroutine 
2. ✅ Compare two values (−1 / 0 / 1) 
3. Nested subroutines and state‑saving bug fix 

---

### Phase 3 – Rotates, Shifts, and Bit Logic

**Goals**
- Treat `L:AC` as a 13‑bit shift register
- Distinguish logical vs arithmetic shifts
- Use rotates for bit manipulation

**Exercises**
1. Count bits set in a word 
2. Multiply by 10 without EAE 
3. Implement an arithmetic right shift 

---

### Phase 4 – Multi‑Word Arithmetic

**Goals**
- Handle numbers larger than 12 bits
- Explicit carry propagation via Link
- Variable‑length arithmetic

**Exercises**
1. 24‑bit addition and subtraction 
2. Variable‑length accumulation with overflow detection 
3. Multi‑word comparison routine 

---

### Phase 5 – OS/8 and Extended Memory

**Goals**
- Write correct OS/8 programs
- Respect field and page conventions
- Understand extended memory behavior

**Exercises**
1. OS/8‑safe program exit 
2. Field‑safe subroutine callable from field 0 
3. EAE detection with dual‑path arithmetic 

---

### Phase 6 – I/O Programming (TTY, PTR, PTP)

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

### Phase 7 – Capstone Exercises (Choose One)

**A. Big Integer Accumulator**
- Arbitrary‑precision sum
- EAE optional
- Fixed buffer with overflow handling

**B. Prime Tester**
- Uses division or modulo
- Optimized with shifts where possible

**C. Memory + I/O Utility**
- Read data via PTR, process it, output via TTY or PTP
- Field‑aware and OS/8‑safe

---

## Progress Tracking

_Update as work progresses._

Example:
- ✅ Phases 1–3 complete 
- 🔄 Phase 4 in progress 
- ⏳ Phase 6 (I/O) next 

---

## Code Review Standards

When reviewing any exercise solution, evaluate on all of the following axes:

- **Correctness** — Does it produce the right result? Trace execution manually if needed.
- **Style** — Consistent spacing, alignment, and label naming. PAL8 convention is a single tab to the operand field.
- **Comments** — Labels and inline comments should describe intent precisely, not just restate the mnemonic.
- **Conventions** — Follows period PDP-8 idioms: `CLA CLL` for clear, `CIA` for negation, `ISZ`-based loop counters, `HLT` before OS/8 exit, `CIF CDF` discipline.
- **Historical accuracy** — Code should reflect how real PDP-8 software was written in the era. Avoid anachronistic patterns.
- **OS/8 safety** — Programs that run under OS/8 must exit via `CIF CDF 00` + `JMP I (7600)`. Field must be restored before the jump.
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