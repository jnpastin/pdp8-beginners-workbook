# Phase 2 — Control Flow and Subroutines

## Goals

- Understand `JMS` at the memory level
- Learn safe subroutine discipline
- See why return-slot conventions exist

---

## Exercise 1 — Absolute Value Subroutine

### What It Does

Implements an `ABSVAL` subroutine that reads a signed 12-bit value from `INPUT`, negates it if negative, and writes the result to `OUTPUT`. The main program exercises the subroutine with three test cases: a negative number (−1234 octal = −668 decimal), zero, and a positive number (+1234 octal = +668 decimal), halting after each for front-panel inspection.

### Implementation Rationale

The subroutine is placed on page 2 (`*0400`) rather than on the same page as the calling code. This is a deliberate demonstration of cross-page calling: the main program on page 1 calls `ABSVAL` via `JMS I (ABSVAL)`, which uses an indirect JMS through a literal containing the page-2 address. A direct `JMS ABSVAL` from page 1 would be impossible since page-1 direct addresses can only reach locations 0200–0377.

`SPA` (Skip on Plus AC) is the idiomatic test for sign on the PDP-8. If AC is positive or zero, the `CIA` (negate) is skipped and the value is stored unchanged. If AC is negative, `CIA` negates it before storing. This correctly handles all three cases — negative, zero, and positive — in two instructions.

The subroutine uses `TAD I (INPUT)` and `DCA I (OUTPUT)` rather than direct references. Since the subroutine is on page 2, it cannot directly address page-1 locations without using the literal pool to resolve cross-page references. The `(INPUT)` and `(OUTPUT)` literals place their addresses in the page-2 literal pool at the top of page 2 (0576–0577), and the indirect access through those literals reaches the actual variables.

Three separate test cases in the main program demonstrate all three code paths through the subroutine and make front-panel testing straightforward — halt, inspect `OUTPUT`, continue.

### Non-Intuitive Points for Beginners

- **`JMS` overwrites the first word of the subroutine with the return address.** `ABSVAL, 0` is the return slot — the `0` is an initialization value only, overwritten on every call. A beginner who thinks this word is a constant will be confused when its value changes during execution.
- **`JMP I ABSVAL` returns by indirect jump through the return slot.** After `JMS` stores the return address at `ABSVAL`, the routine returns by jumping through that location indirectly. This is the entire JMS/return mechanism — there is no stack, no call frame.
- **`JMS I (ABSVAL)` vs `JMP I ABSVAL` — one letter apart, opposite roles.** `JMS I (ABSVAL)` at the call site is the *call*: it stores the return address into the subroutine's entry word and transfers control there. `JMP I ABSVAL` inside the subroutine is the *return*: it reads the return address stored in that same entry word and jumps back to the caller. Both use indirect mode, but `JMS` writes the return address before jumping while `JMP` reads it back to return. Confusing the two — or missing the `I` on either — is one of the most common JMS bugs on the PDP-8.
- **`SPA` treats zero as positive.** The absolute value of zero is zero, so this is correct — but beginners may expect a separate zero test. The `SPA` skip encompasses both zero and positive values in a single instruction.
- **Cross-page indirect is required when caller and callee are on different pages.** Direct addressing on the PDP-8 is limited to the current page (128 words) and page 0. Reaching page 2 from page 1 requires an indirect reference through a literal.

### Key Learning Points

- `JMS` is a one-instruction call mechanism that stores the return address in memory at the subroutine entry word. It is not a stack push.
- Subroutines are not reentrant — the single return slot is overwritten on every call.
- Cross-page subroutine calls require indirect JMS through a pointer. Direct JMS is limited to the current page and page 0.
- `SPA` is the idiomatic sign test: it handles both positive and zero in one instruction without a separate branch.

---

## Exercise 2 — Compare Two Values (−1 / 0 / 1)

### What It Does

Compares two single-word values (`INPUT1` and `INPUT2`) and writes −1 (7777), 0, or +1 to `RESULT` depending on whether INPUT1 is less than, equal to, or greater than INPUT2. A `TWOCMP` flag selects between signed (two's complement) and unsigned comparison modes.

### Implementation Rationale

The exercise prompt was open-ended on signed vs. unsigned, so a general solution was implemented that handles both. The `TWOCMP` flag dispatches to one of two paths at the top of the program.

**Unsigned path:** Negates INPUT1 and adds INPUT2. If the result is zero, the values are equal. If there is no overflow into Link (no carry), INPUT1 was greater (the subtraction did not need to borrow). If Link set, INPUT2 was greater. This uses the PDP-8's carry-out behavior from `TAD` as an unsigned comparison mechanism — standard PDP-8 idiom for unsigned ordering.

**Signed path:** Broken into two sub-cases. If the signs differ, the sign bits alone determine the result — a negative INPUT1 means INPUT1 < INPUT2 without needing to compare magnitudes. If the signs are the same, the values are in the same half of the number space, so a straight subtraction and sign test on the result gives the correct ordering without overflow risk.

The `SMSIGN` case uses `CLL` before the sign test on the subtraction result. Because both inputs have the same sign, the subtraction `INPUT1 − INPUT2` cannot overflow the 12-bit range, so Link is irrelevant — but clearing it beforehand is both defensive and communicates to a reader that Link is not used in the subsequent test.

`RESULT` is initialized to octal 3 at assembly time, an invalid sentinel. If execution somehow falls through without taking any branch, the invalid value is visible at the front panel, indicating a logic error.

### Non-Intuitive Points for Beginners

- **Unsigned comparison via subtraction and Link.** On the PDP-8, there is no "compare" instruction. Unsigned ordering is determined by performing `INPUT2 − INPUT1` (i.e., negate INPUT1 then add INPUT2) and checking whether the subtraction produced a borrow, which appears as a carry-out in Link. A set Link after `TAD INPUT2` (following `CIA` on INPUT1) means INPUT2 ≥ INPUT1.
- **Signed comparison requires sign-case splitting.** Two's complement values with different signs cannot be compared by direct subtraction — the subtraction would overflow 12 bits (e.g., −1 minus +4095 wraps). Checking the sign bits first avoids this.
- **`SNA` / `SMA` chained skips.** In `SMSIGN`, the sequence `SNA` → `JMP AEQB` → `SMA` → `JMP AGTB` → `JMP ALTB` is a three-way branch using two consecutive skip tests. A beginner must trace the skip/no-skip paths carefully — each JMP is only reached if the preceding skip did not fire.
- **`TWOCMP` dispatch at the top.** The initial `TAD TWOCMP` / `SZA` / `JMP SIGNED` sends signed comparisons to the signed path; the fall-through `JMP UNSIGN` handles unsigned. The double-jump (`SZA` skip then explicit JMP) is required because the PDP-8 has no conditional branch — only skip-and-execute-next.
- **`RESULT` pre-initialized to an invalid value.** This is a debugging technique: if the program exits without writing a valid result, the stale value of 3 (which is not −1, 0, or 1) reveals the failure immediately at the front panel.

### Key Learning Points

- The PDP-8 has no compare or branch-if instruction. All comparisons are built from subtraction, skip tests on AC sign/zero, and Link (carry) testing.
- Signed and unsigned comparisons require different algorithms — direct subtraction is only safe for signed values with the same sign.
- Chained skips (`SNA` followed immediately by `SMA`) build multi-way branches from single-bit tests.
- Sentinel initialization of output variables is a simple and effective defensive technique on a machine with no exception handling.

---

## Exercise 3 — Nested Subroutines and State-Saving

### What It Does

Implements a 7-operation calculator: addition, subtraction, greater-than, equal, less-than, absolute value, and comparison (−1/0/1). Operations are dispatched by opcode via a jump table. Both signed and unsigned modes are supported, selected by bit 11 of the `OPERAT` word. A self-contained test harness drives all operations against precomputed expected results, halting with a unique front-panel value on failure or success.

### Implementation Rationale

The exercise required nested subroutines with no specific program target. Building on the prior two exercises — absolute value and comparison — into a unified calculator provided a natural scaffold, added real complexity, and produced a program worth validating against known results.

**Dispatch via jump table.** `EXECOP` resolves the opcode to a subroutine address by indexing into `OPTBLE`, a table of subroutine addresses (`ADD`, `SUB`, `GREATR`, etc.) placed sequentially in memory immediately after the `OPTBLE` label. The resolution proceeds in four steps:

1. `TAD OPCODE` / `TAD (OPTBLE)` — adds the opcode (0–6) to the base address of the table, producing the address of the entry for that opcode. This goes into `OPTMP`.
2. `TAD I OPTMP` — dereferences `OPTMP`, reading the subroutine address stored at that table entry, and stores the result back into `OPTMP`. `OPTMP` now holds the target subroutine's address, not the table entry's address.
3. `JMS I OPTMP` — performs an indirect JMS through `OPTMP`, calling whatever subroutine address was just loaded.

The double use of `OPTMP` (first as a pointer to the table entry, then overwritten with the entry's value) is deliberate: it avoids needing a second scratch location. After step 2, the table entry address is no longer needed. This is the idiomatic PDP-8 computed call pattern — there is no computed-JMP equivalent for subroutine calls, so indirect JMS through a scratch word is the only option.

Walking through opcode 2 (GREATR) as a concrete example:

```
Memory layout:
  0342  OPTMP   (scratch word)
  0343  OPTBLE  ADD    (0240)
  0344          SUB    (0430)
  0345          GREATR (0445)   ← opcode 2 indexes here
  ...

Execution trace:
  Instruction            AC before   AC after   OPTMP after
  TAD  OPCODE            0000        0002       —
  TAD  (OPTBLE)          0002        0345       —          (0002 + 0343 = 0345)
  DCA  OPTMP             0345        0000       0345       (OPTMP = address of table slot)
  TAD I OPTMP            0000        0445       —          (read contents of 0345 = 0445 = GREATR)
  DCA  OPTMP             0445        0000       0445       (OPTMP = address of GREATR)
  JMS I OPTMP            —           —          —          (JMS indirect: reads OPTMP=0445, calls GREATR)
```

**Multi-page layout.** The program spans four pages: main code and dispatch on page 1 (0200), overflow and comparison helpers on page 2 (0400), unsigned/signed comparison bodies on page 3 (0600), and the test harness on page 4 (2000 field-0 page). Data is distributed across pages to co-locate variables with the code that references them most frequently, minimizing cross-page indirect accesses.

**`CMPRET` trampoline.** `CMPARE` is on page 2 and its callers (`GREATR`, `EQUAL`, `LESSER`) are also on page 2. When `CMPARE` dispatches to `SGNCMP` or `UNSCMP` on page 3, those routines need to return through `CMPARE`'s return slot. A simple `JMP I CMPARE` from page 3 would be a cross-page indirect that PAL8 cannot encode as a direct address. `CMPRET` is a one-word trampoline on page 2 that holds `JMP I CMPARE` — page 3 code jumps to `CMPRET` (reachable via literal), which then returns through the `CMPARE` slot. This is the correct PDP-8 solution to the cross-page return problem.

**Overflow detection.** `UNSOFL` and `SGNOFL` detect carry and signed overflow respectively. For unsigned, Link captures carry directly from the `TAD` in `ADD`/`SUB`. For subtraction, the carry sense is inverted (`CML`) because subtraction is implemented as add-of-negated, which reverses the borrow/carry relationship. For signed overflow, `SGNOFL` checks whether the result sign differs from both input signs — the standard two's complement overflow condition — extracted via the `GETSGN` helper.

**`INVSGN` helper.** Inverts a 0/1 flag value in AC using `CIA IAC`. `CIA` negates the value (two's complement), then `IAC` adds 1. For input 0: negate gives 0, plus 1 gives 1. For input 1: negate gives 7777 (−1), plus 1 wraps to 0. Result: 0→1 and 1→0 — correct logical NOT for a single-bit flag stored as a 12-bit word.

**Test harness design.** `NXTTST` advances six parallel auto-index registers simultaneously — one each for VAL1, VAL2, opcode, overflow-check flag, expected result, and expected overflow. This allows the test loop in `TESTS` to be a single tight sequence with no test-specific setup. `VAL1 = 0` is used as a sentinel to detect the end of a test group (a constraint noted in the source comment). The `CKOFLW` flag suppresses overflow comparison for operations where overflow is not meaningful (boolean comparisons, absolute value).

### Non-Intuitive Points for Beginners

- **Nested JMS and the single return slot.** Each JMS subroutine has exactly one return word. When `OPINIT` calls `EXECOP` which calls (e.g.) `ADD` which calls `UNSOFL`, there are four live return slots simultaneously — one per outstanding JMS. They are in different memory locations and do not interfere, but there is no hardware stack. A beginner who thinks of subroutine calls as stack operations will be confused when they see no push or pop.
- **The jump table requires two levels of address resolution.** A beginner might expect `TAD (OPTBLE)` plus the opcode to directly produce something callable — but `OPTBLE + opcode` is the *address of the table slot*, not a subroutine address. The table slot *contains* the subroutine address. So `TAD I OPTMP` is required to dereference the slot and retrieve the actual target. Only after that dereference does `OPTMP` hold something meaningful for `JMS I OPTMP` to call. Skipping the dereference step (going directly to `JMS I OPTMP` after computing the slot address) would attempt to JMS into the table itself — executing the subroutine address word as an instruction rather than jumping to it. The two-step write/overwrite of `OPTMP` is what makes the table lookup work in-place without a second variable.
- **The `CMPRET` trampoline is required, not optional.** From page 3, only page-0 addresses (0000–0177) and current-page addresses (0600–0777) can be encoded directly in an instruction's 7-bit address field. `CMPARE` is at 0545 and `CMPRET` is at 0544 — both on page 2, unreachable directly from page 3. The `(expr)` literal notation is the escape hatch: writing `(CMPARE)` or `(CMPRET)` causes PAL8 to place the value of that address in the page-3 literal pool, growing downward from 0777. The instruction then references the pool entry (which *is* on page 3) and the CPU follows one level of indirection through it. The four plausible forms at CMPXIT (0646), and what each actually does:

  ```
  Memory at the moment CMPXIT executes (GREATR called CMPARE from 0446):
    0544  CMPRET  contains instruction: JMP I CMPARE  (5745)
    0545  CMPARE  contains return address: 0447  (written by JMS CMPARE at 0446)
    0775  page-3 literal pool entry (value depends on which instruction assembled)

  ── Case 1: JMP I CMPARE ────────────────────────────────────────────────
    PAL8 assembly error: II (Illegal Indirect).
    CMPARE (0545) is on page 2. From page 3, direct addressing can only
    reach page 0 (0000–0177) or the current page (0600–0777).
    0545 falls in neither range. PAL8 reports II and refuses
    to assemble. This instruction cannot be encoded.

  ── Case 2: JMP I (CMPARE) ──────────────────────────────────────────────
    Assembles. PAL8 places the *address* of CMPARE (0545) into the
    page-3 literal pool, say at 0775.

    Memory:  0775 = 0545

    Execution at 0646:
      JMP I (0775)  →  reads 0775 = 0545  →  PC = 0545

    Now executing at 0545, which is CMPARE's return slot.
    That word currently contains 0447 (the return address deposited
    by JMS CMPARE). The CPU executes 0447 as an instruction:
      0447 = AND I (page 0, offset 047) — reads page-0 address 047
      as a pointer and ANDs AC with whatever it points to.
    This is garbage behavior. Control never returns to GREATR.

    The mistake: (CMPARE) puts the *address* 0545 in the pool.
    The indirection lands *at* the return slot, not *through* it.
    One more dereference would be needed to reach 0447 — but the
    I bit is already consumed. There is no double-indirect encoding.

  ── Case 3: JMP I CMPRET ────────────────────────────────────────────────
    PAL8 assembly error: II (Illegal Indirect).
    CMPRET (0544) is also on page 2, same constraint as Case 1.
    Cannot be encoded from page 3.

  ── Case 4: JMP I (CMPRET)  ← correct ──────────────────────────────────
    Assembles. PAL8 places the *address* of CMPRET (0544) into the
    page-3 literal pool at 0775.

    Memory:  0775 = 0544

    Execution at 0646:
      JMP I (0775)  →  reads 0775 = 0544  →  PC = 0544 (CMPRET)

    CMPRET executes: JMP I CMPARE
      CMPARE (0545) is on the same page as CMPRET (page 2) — directly
      addressable. The instruction reads the contents of 0545 = 0447.
      →  PC = 0447

    Execution resumes at 0447, the instruction after JMS CMPARE in GREATR. ✓
  ```
- **`CML` in `UNSOFL` corrects subtraction's carry polarity.** Subtraction is computed as `TAD VAL2` / `CIA` / `TAD VAL1`. The `CIA` (negate VAL2) means the `TAD VAL1` addition produces a carry-out (Link set) when `VAL1 >= VAL2` — the opposite of unsigned borrow convention. `CML` flips Link before the overflow test, restoring the expected sense.
- **`VAL1 = 0` cannot be used as a test input.** The sentinel detection in `TESTS` uses `SNA` on VAL1 to identify the end of a group. A genuine VAL1 of zero would be misread as a sentinel and skip the test. This is documented in the source comment and is an accepted design constraint given the machine's lack of a compare-to-constant instruction.
- **`TESTNO` is incremented twice on the first test.** `NXTTST` increments it on initial setup, and `TESTS` increments it again at the top of each iteration. On the first call, both fire, advancing the counter by 2. The `NXTTST` code detects `TESTNO = 0` on first entry and uses Link to track whether to perform the extra pre-increment for the initial state setup — a subtle self-modifying initialization idiom.

### Key Learning Points

- JMS subroutines nest correctly without any hardware support because each subroutine's return slot is a distinct memory location — nesting depth is limited only by available memory, not by a fixed stack.
- Jump tables are the PDP-8 idiom for multi-way dispatch. The pattern is: compute an offset into the table, load the target address, call or jump indirectly.
- Cross-page returns from dispatched subroutines require a trampoline when double indirection is unavailable. This is a structural consequence of the 7-bit direct address field.
- Parallel auto-index traversal of multiple related tables is an efficient test harness pattern — one ISZ-like advance per register per iteration, zero conditional logic for setup.

