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
