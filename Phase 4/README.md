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

  The first condition (same/different input signs) is what `SMSIGN` captures. The second condition (sign of the result disagrees with what it should be) is `SIGN1 ⊕ SIGNOUT`. Both must be true together — one without the other is a normal result.

### Key Learning Points

- Multi-word arithmetic on the PDP-8 works one word at a time. The Link register carries the inter-word carry between stages. Process low words first, capture Link immediately after storing each word, and add the captured carry into the next stage.
- Unsigned subtraction via CIA + TAD inverts the carry/borrow sense. Always apply `CML` when converting the CIA-addition carry output into a conventional borrow flag.
- Signed overflow is a function of the input signs and the output sign — not of Link. Link carries the unsigned carry; overflow is a separate computation using the sign bits.
- Subroutines that compute supporting values (like sign flags) are best placed between the unsigned and signed sections they feed, so state is available when needed without re-entry or re-computation.
