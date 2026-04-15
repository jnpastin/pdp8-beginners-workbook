# PDP-8 / PAL8 Style, Conventions, and Best Practices

Personal reference for this workbook. Apply these when writing or reviewing any exercise.

---

## Source File Structure

Every source file should follow this top-to-bottom order:

```
/ BLOCK COMMENT HEADER
FIELD n          / field declaration (if needed)
*NNNN            / origin
/ init section
/ main code
/ exit
/ constants and variables
*0010            / auto-index register declarations (if used)
$                / end of source
```

### Header Block Comment

```pal8
/
/ PDP-8 WORKBOOK
/ PHASE n
/ EXERCISE n
/ PAL8 ASSEMBLY
/ YOUR NAME
/ VERSION 1.0 DATE
/
```

---

## Formatting and Spacing

- **Tab size is 8 columns** — matching the historical Teletype/DECwriter hardware tab stop. Source files use real tab characters, not spaces. Set `editor.tabSize: 8` and `editor.insertSpaces: false`.
- **Four fixed column fields:** label (col 0), opcode (col 8), operand (col 16), comment (col 56). Every line must land in the same columns — inconsistent indentation is a style error.
- **Labels** are at column 0, followed immediately by a comma: `LOOP,`. The opcode begins at the next tab stop (col 8).
- **Section header comments** appear on their own line, directly above the first instruction they introduce — no blank line between the header and the code:
  ```pal8
  /MAIN LOOP
  LOOP,   TAD  COUNTR      /LOAD NEGATIVE COUNTER
  ```
- **Blank lines** separate sections; never appear _inside_ a section.
- **Inline comments** describe intent in 3–6 words. Do not comment self-evident instructions (e.g., `JMP LOOP` at the bottom of a loop needs no comment).
- All numeric literals are **octal** — no exceptions. Never write decimal unless explicitly annotated.

### Decimal Annotation in Comments

Use a trailing period — the same syntax PAL8 uses in source — to mark decimal values in comments:

```pal8
COUNTR, 7766    /-10. COUNTS TO 0 VIA ISZ
```

Undecorated numbers in comments are assumed octal. Do not use `(DEC)` or `(D)` — those are non-idiomatic.

---

## Naming Conventions

- Labels and symbols are **uppercase**, up to 6 characters (PAL8 limit).
- Names should be meaningful: `COUNTR` (6 chars) over `CTR`; `SUMLP` over `LP2`.
- Auto-index register names: `AIXnn` where `nn` is the octal address (e.g., `AIX10` for location 0010).
- Constants that are negative: annotate with octal and decimal equivalents in a comment.
  ```pal8
  MINUSN, 7766    /-10. COUNTS TO 0 VIA ISZ
  ```

---

## Instruction Idioms

### Clear AC and Link
```pal8
CLA CLL        / always together unless intentionally preserving L
```

### Negate AC (twos complement)
```pal8
CIA            / CMA IAC — preferred over writing CMA IAC inline
```

### Load a constant into AC
```pal8
CLA
TAD  VALUE     / AC = VALUE
```
Or use a literal for a page-local constant:
```pal8
TAD  (0300)    / load octal 300 via auto-generated literal
```

### ISZ-based countdown loop
```pal8
        TAD  MINN      / load -N (e.g., 7766 for -10)
        DCA  COUNTR
LOOP,   ...            / loop body
        ISZ  COUNTR    / increment; skip (exit) when COUNTR reaches 0
        JMP  LOOP
```

### Indirect auto-index read (table traversal)
```pal8
/ Initialize pointer one location BEFORE the table
        DCA  AIX10     / AIX10 = TABLE-1
...
LOOP,   TAD I  AIX10   / pre-increments AIX10, then loads M[AIX10]
```

### Indirect auto-index write (table fill)
```pal8
        DCA  AIX11     / AIX11 = DEST-1
...
        TAD  VALUE
        DCA I  AIX11   / pre-increments AIX11, then stores AC to M[AIX11]
```

---

## Page Management

Each page is 128 words (octal `0200`–`0377` on page 1, etc.):

- Code grows **upward** from the page origin.
- Auto-generated literals (`(expr)` notation) are placed by PAL8 at the **top of the page, growing downward** from word 127. These are called *links*.
- If code and the literal pool collide, PAL8 reports a **PAGE OVERFLOW** error.
- `LINKS GENERATED: N` in the listing footer tells you how many words the literal pool consumed. Each link consumes one word from the top of the page.
- As a practical guard, treat word ~118 (octal `0366`) as a soft ceiling for code + named data. This leaves ~10 words for the literal pool.
- When in doubt, start a new page with a `*NNNN` directive rather than crowding one page.
- Named variables (data words with labels) placed directly after the last instruction are safe — PAL8 assigns them sequentially and they do not interact with the literal pool.

### Data Placement Rule

**Never place data words before the first instruction.** The CPU executes memory sequentially from the origin; a data word at `*0200` will be executed as an instruction. Always structure each page:

```
*0200           / code origin
                / ... instructions ...
                JMP I (7600

/ DATA SECTION
COUNTR, 7766
SUM,    0
```

---

## Memory and Field Discipline

- Declare the data field with `CDF` on entry: `CDF 10` for field 1.
- **Never** access cross-field memory without explicit `CDF`/`CIF` management.
- Page 0 applies per-field: page 0 of field 1 is different from page 0 of field 0.
- Prefer locating data variables on the **same page as the code** that uses them, to allow direct (not indirect) addressing.
- Auto-index registers live at **0010–0017** (page 0 of the current field). Declare them with `*0010` at the end of source.

### Literal Pool Caution
PAL8 places auto-generated literals at the **high end of the current page** (near 0377/0777). Avoid placing data in that area, and be aware of page overflow if many literals are used.

---

## OS/8 Exit Convention

Programs running under OS/8 must exit cleanly:

```pal8
        HLT              / pause for front-panel inspection (optional but good practice)
        CIF CDF  00      / restore to field 0
        JMP I  (7600)    / return to OS/8 monitor
```

- `HLT` before the exit gives an opportunity to inspect AC, Link, and memory from the front panel.
- `CIF CDF 00` must come before the `JMP I (7600)`, not after.
- Never fall off the end of code into data words — always terminate every code path explicitly.
- `.EXIT` is **not** supported by OS/8 PAL8. The correct idiom is `JMP I (7600` — the `(` allocates a literal containing `7600` in the page pool and generates an indirect jump through it. This is equivalent to what a cross-assembler `.EXIT` directive would emit.

---

## Auto-Index Registers — Key Rules

1. The pre-increment fires **only on indirect references** through 0010–0017.
2. A direct `TAD AIX10` is a plain memory read — no increment occurs.
3. Initialize the pointer to `TABLE-1`, not `TABLE` — the first access will step it to TABLE.
4. If a table needs to be traversed twice, the pointer **must be reset** between passes.
5. Use separate auto-index registers for separate concurrent traversals (e.g., AIX10 for read, AIX11 for write).
6. Field-1 auto-index registers are at field-1 addresses 10010–10017.

---

## AC, Link, MQ, and DF State

- AC, Link, and MQ are considered **destroyed** by any subroutine unless explicitly documented as preserved.
- DF (data field) is a hidden global register. Any subroutine that changes DF **must save and restore it** or document the change explicitly.
- Always initialize AC and Link (`CLA CLL`) at program entry.
- Document the AC/Link/DF state on entry and exit for every subroutine.
- Use `RDF` (6214) to read the current data field into AC bits [5:3] before changing it:
  ```pal8
  RDF              /READ CURRENT DF INTO AC BITS 5-3
  TAD  CIFCDF0     /PATCH CIF CDF INSTRUCTION
  DCA  RESTORE     /SAVE FOR LATER RESTORE
  ```

### Link Discipline

`TAD` can silently set Link on carry-out, corrupting subsequent rotates or multi-word arithmetic.

**Use `CLL` when:**
- About to do multi-word arithmetic (Link is an explicit carry operand)
- About to rotate with `RAL`/`RAR` (Link is part of the shift register)
- Cannot prove from data range that no TAD in the sequence generates a carry
- Called from an unknown site that may have left Link set

**`CLL` is optional when** the data range is documented and proven bounded — but the assumption must be stated in a comment.

Defensive `CLL` every loop iteration is considered wasteful in tight code. Justify it or move it to a one-time setup before the loop.

### Cargo-Cult Code

Do not add instructions from habit without understanding their purpose. Example: `CLA CLL` before returning to OS/8 is unnecessary — OS/8 reinitializes its own state. AC and Link are don't-cares at that point. Correct field registers (`CIF CDF 00`) are the only obligation. Adding `CLA CLL` at the exit signals you don't understand the contract.

---

## Subroutine and ISR Discipline

### Return to OS/8 (top-level program)

OS/8 hands control to user programs with IF=0, DF=0. The obligation is to restore these before returning:

```pal8
        CIF CDF  00      /RESTORE BOTH FIELDS TO 0
        JMP I    (7600)  /RETURN TO OS/8 MONITOR
```

- Use `CIF CDF` (not just `CIF`) — both fields must be reset.
- `CIF CDF` assembles to `6203`. The order of micro-ops (`CIF CDF` vs `CDF CIF`) does not affect the assembled value; use `CIF CDF` as the standard order (instruction field first).
- AC, Link, and MQ are don't-cares on OS/8 entry — do not add `CLA CLL` before the exit.

### JMS Subroutines

- The word at the subroutine entry label is overwritten by `JMS` with the return address. Initialize it to `0`; never use it for useful data.
- The return slot must be in writable memory (not ROM, not a different field without care).
- There is only one return slot — subroutines are **not reentrant**.
- If the subroutine changes DF, save and restore it explicitly. Save with `RDF`; restore before `JMP I SUBR`.
- Subroutine header comment must document: entry conditions, exit conditions, and any modified registers/fields:
  ```pal8
  /SUBNAME -- BRIEF DESCRIPTION
  /  ENTRY: AC = INPUT VALUE
  /  EXIT:  AC = RESULT, LINK DESTROYED
  /  USES:  DF PRESERVED
  SUBNAME, 0
  ```

### Interrupt Service Routines

Save everything on entry; restore all before `JMP I` return:
- AC, Link (save via `DCA`; restore via `TAD`+`RAL` or equivalent)
- DF (save via `RDF`)
- IF (save via `RIF`)
- Any memory locations modified
- Keep ISR body minimal — disabling interrupts for too long breaks OS/8 device polling.

| Context | Save on entry? | Restore on exit? |
|---|---|---|
| Top-level OS/8 program | No | Yes — `CIF CDF 00` |
| JMS subroutine | Yes — save DF if changed | Yes — restore DF, then `JMP I` |
| Interrupt handler | Yes — save AC, L, IF, DF | Yes — restore all |

---

## Comments

- Inline comments should describe **intent**, not restate the mnemonic.
  - Bad:  `TAD  COUNTR	/TAD COUNTR`
  - Good: `TAD  COUNTR	/ADD LOOP COUNTER TO AC`
- Use block comments (full `/` lines) to delineate program sections.
- Negative constants must be annotated with both octal and decimal:
  ```pal8
  7766    /-10.
  ```
  The trailing `.` is conventional shorthand for "decimal" in PDP-8 documentation.

---

## Self-Modifying Code

Self-modification is idiomatic on the PDP-8, not a hack. Common uses:
- Patching the address field of a `TAD` or `DCA` to implement a pointer
- Updating a `JMP` target for a computed branch

When used, comment it explicitly:

```pal8
        DCA  FETCH+1    /PATCH OPERAND OF TAD BELOW WITH CURRENT ADDRESS
FETCH,  TAD  0          /ADDRESS PATCHED AT RUNTIME
```

---

## Line Length

Historical DEC line printers were **132 columns** wide. OS/8 terminals (VT52, early VT100) were typically **72–80 columns**. The listing format adds a ~12-character prefix (address + assembled word) before the source columns, so:

| Target output width | Max source line length |
|---|---|
| 80-column terminal | ~68 characters |
| 72-column terminal | ~60 characters |
| 132-column line printer | ~120 characters |

Keep source lines within 60–68 characters to ensure listings are readable without wrapping on a period-correct terminal. Comments were historically terse for this reason.

---

## Pre-Planning Practice (Coding Sheets)

Historically, PDP-8 programmers **wrote code on paper coding sheets before touching the machine**. Machine time was expensive and often scheduled in advance; paper and pencil were free. The assembler was a verification step, not a design tool.

A typical DEC PAL8 coding sheet had these columns:

| PAGE | LOC | LABEL | OP | OPERAND | COMMENTS |
|------|-----|-------|----|---------|----------|

- **PAGE** — which 128-word page, to track boundaries
- **LOC** — 4-digit octal address, filled in by hand
- **LABEL** — up to 6 characters
- **OP** — mnemonic or directive
- **OPERAND** — address, label, or literal
- **COMMENTS** — intent description

Page planning, address arithmetic, and forward reference resolution were done on paper. This discipline eliminated most page overflow and addressing bugs before assembly.

For modern use, a running comment in the source file noting words used per page serves the same purpose:
```pal8
/PAGE 1  *0200  WORDS USED: 07/128  LINKS: 01
```

---

## VS Code Environment

- **Language IDs:** `.PA` files use `pal8`; `.LS` files use `pal8-listing`. Set via `files.associations` in workspace settings.
- The `pal8` language ID is provided by the `jeff-andre.pal8-syntax-vscode` extension.
- The `pal8-listing` language ID is provided by a local extension at `~/.vscode/extensions/pal8-listing-0.0.1/`. It includes a custom tmLanguage grammar that highlights address/word columns separately from source columns.
- **Tab size:** `editor.tabSize: 8`, `editor.insertSpaces: false`, `editor.detectIndentation: false` for both language IDs.
- **Rulers:** Set at 8, 16, 24, 56 for `.PA` source to mark field boundaries.
- **Auto-uppercase extension** (`local.pal8-uppercase`): intercepts the `type` command and upcases all input in `pal8` and `pal8-listing` files. Paste operations are also uppercased via `onDidChangeTextDocument`.

---

## Code Review Checklist

When reviewing a solution, check every axis:

| Axis | What to Verify |
|------|----------------|
| **Correctness** | Trace execution manually; confirm result |
| **Runaway risk** | Every code path terminates; no fall-through into data |
| **Style** | Consistent tabs, uppercase labels, section headers |
| **Comments** | Intent-driven; negative constants annotated |
| **Idioms** | `CIA` for negate, `CLA CLL` for clear, `ISZ` for loops |
| **OS/8 safety** | `CIF CDF 00` (not just `CIF`) before `JMP I (7600)`; `HLT` present |
| **Field discipline** | `CDF` set correctly; cross-field access explicit; DF restored by subroutines |
| **Auto-index use** | Pointer initialized to `TABLE-1`; reset between passes |
| **Resource use** | No unnecessary page-0 consumption; literals within page |
| **Historical fit** | Reflects era practice; no anachronistic patterns |

---

## Common Bugs

| Bug | Cause | Fix |
|-----|-------|-----|
| Wrong sum / garbage result | Auto-index loads from uninitialized memory | Initialize pointer to `TABLE-1`; fill table first |
| Program runs into data | No exit after last instruction | Add `HLT` / OS/8 exit before constants |
| Loop runs forever | ISZ counter never reaches 0 | Verify initial value is correct negative |
| ISZ skips unexpectedly | Counter hits 0 mid-loop when pre-loaded value is wrong | Recheck two's complement: –10 = 7766 |
| Table pointer off by one | Pointer initialized to TABLE instead of TABLE-1 | Always init to one location before first entry |
| Field confusion | CDF not set before accessing data field | `CDF 10` on entry; `CDF 00` before OS/8 return |
| OS/8 exit broken from field 1 | Only `CIF 00` used, DF stays at 1 | Use `CIF CDF 00` (6203) to reset both fields |
| Link corrupts rotate | TAD overflow left Link set before RAL/RAR | Add `CLL` before rotate; document data range |
| Subroutine corrupts caller's DF | Subroutine changes DF without restoring | Save with `RDF`, restore before `JMP I` return |
| Cargo-cult exit | `CLA CLL` added before OS/8 return from habit | Remove — AC/Link are don't-cares; only fields matter |
| Literal pool overflow | Too many `(expr)` literals on one page | Consolidate; use named constants in variable section |
| Data executed as code | Data labels placed at page origin before first instruction | Always put code first, data after the exit instruction |
| `.EXIT` not recognized | OS/8 PAL8 does not support the `.EXIT` directive | Use `JMP I (7600` instead |

---

## Philosophy

> The PDP-8 rewards clarity, discipline, and honesty.  
> Write code as if documenting a system worthy of being understood decades later — because it is.
