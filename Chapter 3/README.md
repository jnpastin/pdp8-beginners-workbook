# Chapter 3 — Rotates, Shifts, and Bit Logic

## Goals

- Treat `L:AC` as a 13-bit shift register
- Distinguish logical vs arithmetic shifts
- Use rotates for bit manipulation

---

## Exercise 1 — Count Bits Set in a Word

### What It Does

Processes a table of 15 input words, counting the number of set bits in each. For each word it rotates all 12 bits through the Link one at a time using `RAL`, testing Link after each rotate with `SZL`/`ISZ`. The bit count for each word is written to an output table via auto-index, then the counters are reset and the loop advances to the next input word.

### Implementation Rationale

`RAL` (Rotate AC Left through Link) shifts bit 11 into Link on each rotation. By testing Link immediately after the rotate with `SZL`, each bit is examined exactly once as it passes through. This treats `L:AC` as a 13-bit shift register, which is the natural mechanism the PDP-8 offers for bit inspection — there is no test-bit-N instruction.

`CLL` is placed after the initial `TAD I INPUT` rather than at the start of `WRDLP`. This is deliberate: `TAD` can produce a carry that sets Link, and the rotate loop depends on Link being clean at the start of the first rotation. Placing `CLL` inside the loop would add a redundant clear on every iteration after the first. Moving it to a one-time setup before the loop is the correct idiom.

`WRDCNT` is initialized to −12 (octal 7764) to count exactly 12 rotations — one per bit. After 12 rotations, `BITCNT` holds the population count.

`ISZ BITCNT` / `NOP` is used rather than `TAD BITCNT` / `IAC` / `DCA BITCNT`. The ISZ idiom is more compact and faster. The NOP absorbs the ISZ skip, which is structurally unreachable for 12-bit data (BITCNT can never reach zero within a single word's 12 iterations) but is required to keep the skip path safe.

### Non-Intuitive Points for Beginners

- **`RAL` rotates through Link, not just through AC.** The 13th bit (Link) participates in every rotate. A beginner who thinks of `RAL` as a 12-bit shift will miscalculate which bit is being examined.
- **`SZL` tests Link, not AC.** It skips if Link is zero. The skip-on-zero sense means `ISZ BITCNT` fires when Link is *one* (a set bit), not when it is zero.
- **`CLL` placement matters.** Putting `CLL` inside the rotate loop would be wasteful — it would clear Link on every iteration, destroying the bit just rotated in. It must precede the loop, not be inside it.
- **The NOP is structural, not padding.** ISZ/NOP is a well-known idiom meaning "increment and ignore the skip." Its presence signals that the skip path is intentionally discarded.
- **`WRDCNT` is reset via `TAD (7764)` / `DCA WRDCNT` on each outer loop iteration.** There is no instruction to load an immediate value into memory; the count must be reloaded explicitly through AC each time.

### Key Learning Points

- `L:AC` is a 13-bit shift register. Rotates move bits between AC and Link bidirectionally.
- Bit inspection on the PDP-8 is done by shifting bits into Link and testing with `SZL`/`SNL`.
- `CLL` before a rotate loop is not defensive — it is required for correctness whenever the incoming Link state is unknown.

---

## Exercise 2 — Multiply by 10 Without EAE

### What It Does

Multiplies each of 15 input values by 10 using the shift-and-add binary multiplication algorithm. The constant multiplier is 10 (octal 12). For each multiplicand, the algorithm tests bit 0 of the multiplier; if set, the current multiplicand is added to the running result via a subroutine. The multiplier is then shifted right one bit and the multiplicand shifted left one bit. This repeats until the multiplier reaches zero.

### Implementation Rationale

Binary multiplication without the EAE (Extended Arithmetic Element) requires implementing the algorithm in software using only rotates and add. Multiplying by the constant 10 (binary `1010`) means only two bit positions are ever set, so the algorithm terminates in at most 4 iterations rather than a full 12. The SNA test on `MLTPLR` provides early exit once all multiplier bits are consumed, avoiding unnecessary iterations.

The `ADDVAL` subroutine isolates the accumulate step. While a subroutine costs two extra words (the JMS slot and a JMP I return), it keeps the main loop readable and avoids duplicating the add sequence inline. At this scale the overhead is acceptable.

`CLL` is placed both at the top of `MULTOP` (to clear before the AND/test sequence) and after the `RAR` (to discard the bit shifted out of the multiplier into Link). These are two distinct and necessary clears — the first ensures no carry residue from the previous bit contaminates the test; the second prevents the multiplier's outgoing bit from corrupting the subsequent `RAL` on the multiplicand.

The input values are kept below 409 (decimal) to prevent the result from exceeding 12 bits, since multi-word overflow handling is deferred to Chapter 4.

### Non-Intuitive Points for Beginners

- **The multiplier and multiplicand shift in opposite directions simultaneously.** The multiplier shifts right (LSB consumed first) while the multiplicand shifts left (doubles each iteration). This mirrors the paper-and-pencil binary multiplication algorithm but is easy to lose track of when reading code.
- **`AND (1)` isolates bit 0.** There is no test-bit instruction. The idiom is to AND with a mask and skip-if-zero. After the AND, AC holds either 0 or 1 — but the AC is never used directly; it only drives the SZA skip.
- **`CLA CLL` after the `JMS ADDVAL` branch.** Whether or not `ADDVAL` was called, AC needs to be clean before the next multiply step. The CLA CLL is always executed — it is not inside the conditional.
- **`MLTPLR` is reset to 12 (octal) at the end of each outer loop iteration.** The multiplier is consumed during processing, so it must be restored before the next multiplicand is processed.
- **`DCA I QUOTNT` leaves AC at zero.** DCA always clears AC. The subsequent `DCA RESULT` therefore clears RESULT for the next iteration without needing a separate CLA — this is intentional, not incidental.

### Key Learning Points

- Binary multiplication is implemented in software using shift-and-add when the EAE is absent.
- `RAR` and `RAL` together implement a coordinated double-shift across two separate memory locations (multiplier and multiplicand), since AC can only hold one value at a time.
- Subroutines via JMS cost one word for the return address slot at the entry label plus the JMS instruction at each call site — use them when the body is reused, not for single-use sequences.

---

## Exercise 3 — Arithmetic Right Shift

### What It Does

Performs an arithmetic right shift on two test values — one positive (octal 3546 = 1894 decimal) and one negative (octal 7654 = −84 decimal) — applying 12 successive shifts to each. For each shift, the sign bit (bit 11) is extracted, placed into Link via `STL` if set, then `RAR` rotates Link into the MSB position. Results are stored via auto-index for later validation.

### Implementation Rationale

The PDP-8 has no arithmetic right shift instruction — `RAR` is a logical rotate that brings Link in from the left. To make it behave arithmetically, the sign bit must be captured and placed into Link *before* the rotate, so that the incoming bit replicates the sign rather than introducing a zero (logical) or whatever Link happened to hold.

The sequence is:
1. `AND (4000)` — isolate bit 11 (the sign)
2. `SZA` / `STL` — conditionally set Link to 1 if sign was set
3. `CLA` — clear AC (Link is preserved by CLA alone)
4. `TAD INPUT` — reload the full word
5. `RAR` — rotate right with sign bit already in Link

`CLA CLL` at the top of the loop clears both AC and Link, ensuring Link starts at zero for positive values. For negative values, the `STL` then overrides Link to 1.

Two separate inputs are processed with a single unified loop, controlled by the `DONE` flag. After the first 12-shift pass, `DONE` is tested and found zero, the flag is set, `INPUT` is loaded from `INPUT2`, the loop counter is reset, and the loop runs again. This avoids duplicating the loop body.

### Non-Intuitive Points for Beginners

- **`RAR` is not an arithmetic shift — it must be made arithmetic manually.** A beginner who uses `RAR` alone will get a logical shift (zero fill from the left for positive, garbage for negative). The sign pre-load into Link is what makes it arithmetic.
- **`CLA` does not clear Link.** Only `CLL` clears Link, and only `CLA CLL` clears both. The code uses `CLA` alone (after the sign test) to clear AC while deliberately preserving whatever Link was just set to. This is intentional and correct — but easy to misread as a mistake.
- **`STL` sets Link unconditionally.** The conditional is in the `SZA` that precedes it: if the sign bit was zero, SZA skips over STL, leaving Link at zero from the earlier `CLA CLL`. If the sign bit was non-zero, STL fires. The Link value going into `RAR` therefore equals the original sign bit.
- **`DONE` is a one-shot flag, not a toggle.** It starts at 0 and is set to 1 via `IAC` after the first pass. The second pass exits via `JMP MONRET` when `DONE` is found non-zero. It is never reset to 0.
- **`DCA INPUT` after each shift feeds the result back as the next input.** Each iteration shifts the previous result, not the original value. This is how 12 successive shifts are accumulated — the output of each shift becomes the input of the next.

### Key Learning Points

- The PDP-8 has no arithmetic shift instruction. Arithmetic behavior requires explicit sign-bit management before each rotate.
- `CLA` and `CLL` are independent micro-operations. Clearing AC and clearing Link are separate actions; use `CLA CLL` when both are needed, `CLA` alone when Link must be preserved.
- Link is not just a carry bit — it is a programmable input to the rotate hardware, and controlling what it holds before a rotate is a first-class design decision.
