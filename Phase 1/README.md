# Phase 1 — Core PDP-8 Mental Model

## Goals

- Internalize AC, Link, and memory as system state
- Understand instruction sequencing and skips
- Become fluent at manual execution tracing

---

## Exercise 1 — Trace a Simple Add/Store Program

### What It Does

Loads two octal constants into the Accumulator one at a time using `TAD`, deposits the result into a named memory location using `DCA`, then halts.

### Implementation Rationale

The exercise goal is hand-assembly and tracing, not algorithmic complexity. The program is intentionally minimal — three instructions plus an exit — so the full instruction cycle (fetch, decode, execute) can be traced for every word without losing the thread. `INPUT1`, `INPUT2`, and `OUTPUT` are placed on the same page as the code so all addresses are direct (no indirection needed), keeping the address field simple for the initial trace.

The data is placed immediately after the last instruction rather than at a separate origin. This is the natural PAL8 layout when there is no need to locate data at a specific address.

### Non-Intuitive Points for Beginners

- **`TAD` accumulates, it does not load.** There is no "load" instruction. The AC must be cleared first (`CLA`) before `TAD` behaves like a load. A beginner who forgets the initial `CLA CLL` and assumes AC starts at zero will trace correctly by accident — but only because the HLT at the beginning of memory (address 0) would have been executed, which is a separate trap.
- **`DCA` clears AC as a side effect.** After `DCA OUTPUT`, the AC is zero. This surprises beginners who expect to continue using the value.
- **The literal pool.** `JMP I (7600)` causes PAL8 to place the value `7600` at the top of the current page (0377), growing downward. This word appears in the listing even though it was never explicitly written. The `LINKS GENERATED: 1` footer line is the signal.

### Key Learning Points

- The PDP-8 has no dedicated load or store instruction — `TAD` (Two's complement Add) and `DCA` (Deposit and Clear AC) are the primitives.
- Memory is flat 12-bit words. There is no type system; a word is a word.
- Hand-tracing forces precision: you must know AC and Link value at every step.

---

## Exercise 2 — Count 1–10 and Accumulate a Sum

### What It Does

Uses an ISZ-based countdown loop to sum the integers 1 through 10. The counter `COUNTR` is initialized to −10 (octal 7766). Each iteration negates the counter value to recover the current count, adds it to `SUM`, increments the counter, and loops until ISZ skips.

### Implementation Rationale

The counter runs negative-to-zero rather than positive-to-ten because `ISZ` skips when the incremented value reaches exactly zero — there is no "skip if equals N" instruction. A negative-to-zero counter fits the instruction set directly. This is the canonical ISZ loop idiom.

The current iteration value is recovered inside the loop via `CMA IAC` (negate) rather than maintaining a separate ascending counter. This keeps the variable count to one and demonstrates that the counter can be both the loop control and a data source.

`HLT` is omitted before the OS/8 exit because the exercise intent is to verify `SUM` rather than inspect at the front panel — the final value is in memory and can be read via the monitor after the program returns. This is a deliberate choice, not an omission.

### Non-Intuitive Points for Beginners

- **`ISZ` skips the next instruction when the result is zero, not when it becomes negative.** A beginner counting from 1 upward and expecting a skip at 10 will find `ISZ` never skips for them because the counter never hits zero.
- **`CMA IAC` is CIA.** The assembler accepts `CIA` as a single mnemonic for complement-and-increment (two's complement negate). Writing `CMA IAC` inline is equivalent and more explicit, but `CIA` is the idiomatic form. Both appear in period DEC code.
- **The loop terminates on the ISZ skip, not on a JMP condition.** There is no branch-if-equal or branch-if-zero instruction. The skip after ISZ is the only conditional exit mechanism here.

### Key Learning Points

- Negative-to-zero loop counters are idiomatic on the PDP-8 because of how ISZ works.
- The AC is the only arithmetic register. All intermediate values must be spilled to memory with DCA if they need to survive a subsequent TAD or operation.
- Understanding two's complement is not optional — the machine speaks it natively at every arithmetic instruction.

---

## Exercise 3 — Rewrite Using Auto-Index Registers

### What It Does

Refactors Exercise 2 in two phases. First, a table generation loop uses an auto-index register (`AIX10` at address 0010) to write the values 1–10 into a table at `*0300`. Then a second loop uses the same auto-index register to read the table back and accumulate the sum. The auto-index register is reset between the two passes.

### Implementation Rationale

The two-phase structure (generate then sum) is deliberate — it demonstrates the full auto-index register lifecycle: initialize to `TABLE-1`, traverse forward, reset, traverse again. A single-pass approach (sum on the fly during generation) would have worked but would not have exercised the reset-between-passes requirement.

The table is generated using the negated counter value (`CIA` on `COUNTR`) so that entries are stored as positive integers 1–10. This mirrors Exercise 2's negation idiom but now the results go into memory rather than accumulating in AC.

`AIX10` is initialized to `0277` (one location before the table origin at `0300`) explicitly in the `*0010` section. The pre-increment on first use steps it to 0300, so the first write lands at 0300 and the last at 0311 — the table occupies exactly the ten locations 0300–0311.

The reset section reloads `AIX10` to 0277, so the sum loop's first read also pre-increments to 0300, traversing the same range.

### Non-Intuitive Points for Beginners

- **Auto-index registers pre-increment on every indirect access.** The increment happens before the memory access, not after. Initialize to `TABLE-1`, not `TABLE` — the first access will step the pointer to `TABLE` before loading.
- **The pre-increment fires only on indirect references through addresses 0010–0017.** A direct `TAD AIX10` reads the pointer value without any increment. This distinction is invisible from the mnemonic alone.
- **The pointer must be reset between passes.** After the table generation loop, `AIX10` points past the last entry. Reading from it again without resetting would access memory beyond the table. The reset is not automatic.
- **`CIA` is used on the counter to produce the stored value.** `COUNTR` runs from −10 to 0, so negating it inside the loop gives +10 down to +1. Without the `CIA`, the table would contain negative values.
- **The final `DCA SUM` captures the AC after the sum loop exits via ISZ skip.** At the point ISZ skips, AC holds the last value added but the DCA that would have stored the running total hasn't fired. Beginners may expect the sum to accumulate into a variable word by word; instead it accumulates in AC and is deposited only once at the end.

### Key Learning Points

- Auto-index registers are a hardware feature, not a software abstraction. They live at fixed addresses 0010–0017 and the pre-increment is unconditional on every indirect reference through those addresses.
- Data tables require explicit initialization of the pointer before each pass.
- The PDP-8's constraint of one accumulator makes multi-phase algorithms (generate, then consume) a natural pattern — you cannot keep a running sum in AC while also using it to drive memory writes.
