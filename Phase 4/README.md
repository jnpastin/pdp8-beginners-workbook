# Phase 4 — Multi-Word Arithmetic

## Goals

- Handle numbers larger than 12 bits
- Explicit carry propagation via Link
- Signed and unsigned arithmetic with overflow detection

---

## Exercise 1 — 24-Bit Addition and Subtraction

### What It Does

Performs all four arithmetic operations — unsigned addition, unsigned subtraction, signed addition, and signed subtraction — on a pair of 24-bit values. Each value is split across two 12-bit words: a low word and a high word. Results are stored in six output pairs (low and high word per operation) plus one overflow/borrow flag per operation. A `GETSGN` subroutine extracts the sign of each input and computes whether the signs match, used by both signed operations for overflow and borrow detection.

The test inputs are:
- IN1: `4503:1324` (high:low)
- IN2: `3035:6543` (high:low)

### Implementation Rationale

**Unsigned addition.** The low words are added first with `CLA CLL` ensuring Link is clear. After `DCA ADDLOW`, AC is zero and Link holds the carry out of the low-word addition. `RAL` rotates Link into bit 0 of AC (producing 0 or 1), which is then added to the two high words. A second `RAL` after `DCA ADDHI` captures the carry out of the high-word addition into AC for storage as the overflow flag.

**Unsigned subtraction.** Computed as `IN1LOW − IN2LOW` using CIA (two's complement negate) on the subtrahend. After `DCA SUBLOW`, `SZL` tests whether Link was clear — Link set indicates the subtraction underflowed (borrowed). If it did, `TAD (7777)` subtracts 1 from the high-word difference to propagate the borrow. The high words are then subtracted the same way. `CML RAL` after `DCA SUBHI` inverts and captures the carry: the CIA-based subtraction generates a carry on no-borrow, so the sense is inverted to produce a conventional borrow flag (1 = borrow occurred).

**Signed addition and subtraction.** Both operations use the same unsigned carry/borrow mechanics for the low and high words. Overflow and borrow detection require knowing the input signs and whether they match — that is the job of `GETSGN`. After the high word is computed, the output sign is extracted with `AND (4000)` / `RTL` and XOR'd against `SIGN1` by addition (since both are 0 or 1). The result is masked to bit 0 with `AND (0001)`. For signed addition, overflow can only occur when the input signs are the same, so the XOR result is ANDed with `SMSIGN`. For signed subtraction, overflow can only occur when the input signs differ, so `SMSIGN` is inverted (via `RAR` / `CML` / `RAL`) before the AND.

**`GETSGN` subroutine.** Extracts the sign bit of each input by ANDing the high word with `4000` (bit 11) and rotating left twice to place it in bit 0. Computes `SMSIGN` by subtracting the two signs: if they are equal the result is zero, and `SZA` / `STL` / `RAL` routes a 1 into `SMSIGN`; if they differ, `CLL` forces a 0. The subroutine stores `SIGN1`, `SIGN2`, and `SMSIGN` in named data words for use by the signed arithmetic sections.

### Non-Intuitive Points for Beginners

- **`DCA` clears AC, leaving Link intact.** After storing the low-word result, AC is zero but Link still holds the carry from the addition. The immediately following `RAL` rotates that carry — and only that carry — into bit 0 of AC. This is the carry-propagation idiom: `TAD` / `TAD` / `DCA` / `RAL` / carry now in AC bit 0.
- **`SZL` tests Link before it is cleared.** On the subtraction borrow path, Link holds the borrow indicator set by the preceding CIA + TAD sequence. `SZL` branches on that value and must be read before any subsequent instruction that disturbs Link — including `CLA CLL` for the next section. The `CLA CLL` at the top of each section clears any residue, but each section's own carry/borrow test relies on Link from within that section.
- **CIA-based subtraction inverts the carry sense.** `A − B` implemented as `CIA(B) + A` produces Link=1 when no borrow occurs (the addition overflowed positively), which is the opposite of the borrow convention. `CML` corrects this for the final overflow flag. The same inversion appears in SMSIGN logic for signed subtraction.
- **`AND (4000)` / `RTL` extracts the sign into bit 0.** `4000` in octal is bit 11, the sign bit. After `AND`, only bit 11 survives. `RTL` (rotate left twice) moves bit 11 into Link on the first rotation, then Link into bit 0 on the second, producing 0 or 1 in AC. This is the standard PDP-8 idiom for isolating the sign as a usable flag value.
- **Overflow rules.** For unsigned operations, Link is the result: L=1 after addition means the result exceeded 24 bits (carry); L=1 after subtraction (after `CML` corrects the polarity) means the result went below zero (borrow). For signed operations, two conditions must both be true for overflow to have occurred:
  - **Signed addition overflows** when: the two inputs have the *same* sign, AND the output sign differs from the input sign. (Two positives produced a negative, or two negatives produced a positive.)
  - **Signed subtraction overflows** when: the two inputs have *different* signs, AND the output sign differs from the sign of IN1. (Subtracting a negative from a positive produced a negative, or vice versa.)

  The first condition (same/different input signs) is what `SMSIGN` captures. The second condition (sign of the result disagrees with what it should be) is `SIGN1 xor SIGNOUT`. Both must be true together — one without the other is a normal result.

### Key Learning Points

- Multi-word arithmetic on the PDP-8 works one word at a time. The Link register carries the inter-word carry between stages. Process low words first, capture Link immediately after storing each word, and add the captured carry into the next stage.
- Unsigned subtraction via CIA + TAD inverts the carry/borrow sense. Always apply `CML` when converting the CIA-addition carry output into a conventional borrow flag.
- Signed overflow is a function of the input signs and the output sign — not of Link. Link carries the unsigned carry; overflow is a separate computation using the sign bits.
- Subroutines that compute supporting values (like sign flags) are best placed between the unsigned and signed sections they feed, so state is available when needed without re-entry or re-computation.

---

## Exercise 2 — Variable-Length Accumulation with Overflow Detection

### What It Does

Performs unsigned addition on two arrays of 12-bit words whose length is determined at runtime from a pseudo-random value derived from the switch register. The arrays can be 1–13 words long. The result is stored in a separate output block with one extra word reserved for the final carry out.

The program has three phases:

1. **PRNG** — reads the switch register (`OSR`) as entropy, then runs 8 iterations of a mixing loop (rotate, complement, XOR-like TAD, constant injection) to produce a variable value in `RANDOM`.
2. **GETLEN** — counts the number of set bits in `RANDOM` (1–12), adds the mandatory minimum of 1, and negates the result into `VALLEN` for use as a down-counter.
3. **ADDLP** — adds corresponding words from INPUT1 and INPUT2 via auto-index registers, propagating carry through Link with `RAL` at the top of each iteration. After the loop exits, the final carry out is stored as one extra word in the result block.

Test inputs are 13-word arrays at `0400` (INPUT1) and `0420` (INPUT2). The result block at `0440` is 14 words (13 data + 1 carry-out slot). Auto-index pointers `IN1POS`, `IN2POS`, and `RESPOS` are initialized to one location before each respective array, pre-increment semantics apply on each `TAD I` / `DCA I` access.

### Implementation Rationale

**PRNG mixing.** `OSR` without a preceding `CLA CLL` is deliberate — AC and Link at program entry are additional entropy. Eight iterations of rotate-complement-TAD-rotate-IAC-constant produce a value that changes substantially with small switch register differences. The constant `5235` (octal) has bit 11 set and an irregular bit pattern, which breaks short cycles in the mixing feedback.

**Bit counting for length.** `WRDLP` counts down from −12. Each iteration shifts one bit of `RANDOM` into Link via `RAL` and conditionally increments `WRDCNT` only when that bit was 1. `WRDCNT` starts at 1, guaranteeing a minimum length of 1 even if `RANDOM` holds 0. The result is negated via `CIA` and stored in `VALLEN` so that `ISZ VALLEN` counts up to zero and exits the addition loop.

**Carry propagation.** The addition loop starts with `CLA CLL` before the first iteration only. `CLL` ensures Link is 0 so the first `RAL` inside the loop rotates in a zero carry-in, leaving the first word addition unaffected. On subsequent iterations, `RAL` rotates the Link carry-out from the previous word into bit 0 of AC before loading the next word pair. `DCA I RESPOS` stores the word result and clears AC, but Link is unaffected — it retains the carry from the `TAD I IN2POS`. This is the N-word carry-chain idiom: one `CLA CLL` before the loop, then `RAL` / `TAD` / `TAD` / `DCA` per word.

**Overflow storage.** When `ISZ VALLEN` skips (counter reaches 0), the link from the last word addition is still live. `RAL` rotates it into AC bit 0, and `DCA I RESPOS` stores the carry out at the next sequential address in the result block. No separate overflow flag variable is needed.

### Non-Intuitive Points for Beginners

- **`OSR` without `CLA` is intentional.** The program entry convention says `CLA CLL` at startup, but here both AC and Link from the previous machine state are incorporated as entropy. This deliberate deviation is explained in the goal comment block at the top of the file.
- **`DCA` does not touch Link.** Each `DCA I RESPOS` inside the addition loop clears AC to zero but leaves Link intact. The `RAL` at the top of the next iteration then rotates that carry — and only that carry — into bit 0 of AC. It is critical that no instruction between `DCA I RESPOS` and the next `RAL` modifies Link.
- **`ISZ VALLEN` can never cause an unwanted skip.** `VALLEN` is loaded with a negative count (−1 to −13). `ISZ` increments by 1 each iteration and skips when the value passes through 0. The loop body runs exactly |VALLEN| times — matching the array length — before the skip exits the loop.
- **Auto-index pointers are TABLE−1.** `IN1POS = 0377`, `IN2POS = 0417`, `RESPOS = 0437`. The first `TAD I IN1POS` pre-increments to `0400`, `TAD I IN2POS` to `0420`, and `DCA I RESPOS` to `0440` — the first elements of each array. There is no pointer-reset between iterations because each traversal is a single forward pass.
- **No links generated.** `JMP I (7600)` uses a parenthesized literal, but PAL8 allocates it above the data area at `0377` (visible in the listing). `LINKS GENERATED: 0` at the listing footer confirms no page overflow risk.

### Key Learning Points

- Variable-length arithmetic requires a runtime length value that is known before the loop starts and can be used as a down-counter. Negate the count with `CIA` and drive the loop with `ISZ`.
- The carry chain across N words requires exactly one `CLA CLL` before the first word, then `RAL` / `TAD` / `TAD` / `DCA` repeated N times. Do not re-clear Link inside the loop.
- The final carry out of an N-word addition is in Link after the last `DCA`. Capture it with `RAL` and store it as an additional result word.
- Auto-index registers initialized to TABLE−1 give correct pre-increment behavior with no special-case handling for the first access.
- A pseudo-random loop length drawn from switch register state is a practical way to exercise variable-length code paths during interactive debugging without needing a separate test harness.

---

## Exercise 3 — Multi-Word Comparison Routine

### What It Does

Compares two multi-word integers — either both unsigned or both signed two's complement — and stores a three-valued result: `0001` (A > B), `0000` (A = B), or `7777` (A < B). Both values are given as a pointer to their high word plus a word count; words are stored consecutively in memory from highest to lowest. The `TWOCMP` flag selects unsigned (`0`) or signed (`1`) mode.

The test inputs are 5-word unsigned values:
- INPUT1 (at `0351`): `1564 5465 2315 7231 6453`
- INPUT2 (at `0356`): `4156 5454 5463 7210 0756`

High word `1564` < `4156`, so the expected result is `7777` (A < B).

### Implementation Rationale

**Dispatch.** The program reads `TWOCMP` and branches immediately to `UNSIGN` (unsigned) or `SIGNED`. In both cases `CMPINI` is called first to handle any difference in word lengths before word-by-word comparison begins.

**`CMPINI` subroutine.** Computes `IN1LEN − IN2LEN`. If the lengths differ, a length comparison alone determines the result. For unsigned or same-sign positive values, a longer number is always larger; for same-sign negative values, a longer number is always more negative (smaller). The sign check uses `SIGN1` (already set on the signed path, zero on the unsigned path). `CML` inverts the carry-derived ordering when `SIGN1` is nonzero, reversing AGTB/ALTB for the negative case without any extra branch. If the lengths are equal, `CURWRD` is initialised to `CIA(IN1LEN)` for use as a down-counter in `NXTWRD`, and execution returns to the caller.

**Unsigned comparison (`UNSIGN` / `UNSCMP`).** Each word pair is compared as `CIA(B_word) + A_word`. The CIA operation on any B_word produces a carry out into Link for the zero case (CIA(0) increments through `7777` to `0000`, generating carry), and the subsequent `TAD A_word` either sustains or removes that carry. After `SNA` routes the equal-word case to `NXTWRD`, `SNL` routes the result: Link = 1 means A > B (`AGTB`), Link = 0 means A < B (`ALTB`).

**Signed comparison.** The high words of both inputs are read and their sign bits are extracted with `AND (4000)` / `RTL`, producing 0 or 1 in `SIGN1` and `SIGN2`. `CIA(SIGN2) + SIGN1` is zero when signs are equal and nonzero when they differ. Different signs are resolved immediately by `DIFSIN`: if `SIGN1` is 1 (A negative, B positive) the result is `ALTB`; if `SIGN1` is 0 (A positive, B negative) the result is `AGTB`. For same-sign values, `SMSIGN` calls `CMPINI` and then enters `SGNCMP` for a word-by-word comparison identical in structure to `UNSCMP`, using the same CIA + SNL idiom.

**`NXTWRD`.** When two corresponding words are equal, `NXTWRD` checks `CURWRD` via `ISZ`. If the counter reaches zero all words have been compared and `AEQB` stores the equal result. Otherwise, both `INPUT1` and `INPUT2` pointers are incremented by 1 to advance to the next word, and execution jumps back to either `UNSCMP` or `SGNCMP` depending on `TWOCMP`.

### Non-Intuitive Points for Beginners

- **`CIA(0)` sets Link.** CIA is CMA followed by IAC. `CMA(0000) = 7777`; `IAC(7777) = 0000` with carry out into Link. This means `CIA(B) + A` with B = 0 leaves Link = 1 regardless of A (as long as A ≤ `7777`). The SNL-based decision therefore handles the B = 0 edge case correctly without special treatment.
- **`CMPINI` uses Link from CIA + TAD to determine length order.** The carry-out of `CIA(IN2LEN) + IN1LEN` is 1 when IN1LEN > IN2LEN and 0 when IN1LEN < IN2LEN. Because `CLA` (not `CLA CLL`) precedes the sign check, that Link value is preserved through the `TAD SIGN1` and `SZA` sequence. `CML` then optionally inverts it, and `SZL` reads the (possibly flipped) value to route to `AGTB` or `ALTB`. One code path handles all four combinations of sign and relative length.
- **`SGNCMP` uses the same CIA + SNL idiom as `UNSCMP`.** For same-sign values the comparison reduces to comparing their magnitudes word by word, which is identical to unsigned comparison. Using `SMA` (test sign bit of the difference) would fail for lower words, whose values span the full 12-bit range — a difference ≥ `4000` octal would set bit 11 and be misread as negative. `SNL` is correct in both sections.
- **`NXTWRD` uses `CLA CLL` on entry.** The comparison loop arrives at `NXTWRD` only when the current words are equal. At that point AC is 0 and Link is 1 (the CIA of any nonzero value followed by `TAD` of the same value produces `AC = 0, L = 1`; CIA(0)+0 also gives `AC = 0, L = 1`). `CLA CLL` is used rather than `CLA` to ensure a clean state before the ISZ-based counter test and pointer arithmetic, neither of which depends on Link.
- **Pointers `INPUT1` and `INPUT2` are modified in place.** Rather than using a separate current-position pointer, `NXTWRD` increments the `INPUT1` and `INPUT2` data words directly. This means the values in the data section are consumed during a single comparison run and would need to be reset before re-use. For the single-run test case this is the simplest approach.

### Key Learning Points

- Multi-word comparison starts at the most significant word and works downward. The first word pair that differs determines the result; only if all word pairs are equal is the result equal.
- `CIA(B) + A` with `SNL` is the correct unsigned-comparison idiom on the PDP-8. It handles B = 0 correctly because CIA(0) produces carry via the intermediate `7777 → 0000` transition. `SMA` on the difference is wrong for words that can reach the upper half of the 12-bit range.
- Signed multi-word comparison decomposes into three independent sub-problems: different signs (sign bits alone determine the result), same-sign different lengths (`CMPINI` with `CML` for negatives), and same-sign equal lengths (word-by-word unsigned comparison, since the magnitude ordering is the same for both positive and negative values of identical sign).
- Factoring the length test into a shared `CMPINI` subroutine called from both the unsigned and signed paths avoids duplicating the length-comparison and CURWRD-initialisation logic, at the cost of requiring `SIGN1` to be set (to 0) before the unsigned path reaches `CMPINI`.
