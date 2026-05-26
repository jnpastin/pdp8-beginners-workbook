# Chapter 6 — I/O Programming (TTY, PTR, PTP)

## Goals

- Understand PDP-8 I/O at the instruction and convention level
- Work with polled I/O and device flags
- Use TTY and paper tape in a disciplined way

---

## Exercise 1 — Character Output to TTY Using Polling

### What It Does

Outputs the string `HELLO WORLD!` to the TTY using a polled busy-wait loop, then returns to the OS/8 monitor. The string is stored as a sequence of 7-bit ASCII values (with the mark bit set) at `*0300`, terminated by a zero sentinel. A single auto-index register at `CURCHR` (`0010`) walks the string one character per iteration. Each iteration polls `TSF` to wait until the TTY output flag is set, then loads the next character via indirect auto-index, tests it for the zero sentinel with `SNA`, sends it with `TLS`, clears AC, and loops. When the sentinel is read the program exits via `CIF CDF 0` / `JMP I (7600)`.

### Implementation Rationale

**The first character is sent without a prior `TSF` poll.** The TTY output flag starts in the cleared state when a program begins. `TSF` skips when the flag is set; it loops when the flag is clear. If the program entered the busy-wait loop before any `TLS` had been issued, `TSF` would never skip — there is nothing to wait for. The flag is set by the TTY hardware only after a transmission initiated by `TLS` completes. Sending the first character blind via `JMP FRSTCH` primes the cycle: `TLS` initiates the first transmission, which causes the hardware to set the flag when done, which `TSF` can then detect for all subsequent characters.

**`CURCHR` is placed at location `0010`.** Locations `0010`–`0017` are the PDP-8 auto-index registers. Any indirect memory reference through an address in this range causes the hardware to pre-increment the location before using it as an effective address. Placing `CURCHR` at `0010` means `TAD I CURCHR` automatically advances the pointer on every access with no explicit `ISZ` or `TAD`/`IAC`/`DCA` sequence needed.

**`MESG, .` stores the address of `MESG` at `MESG` itself.** The `.` pseudo-op evaluates to the current location counter at assembly time. Since `MESG` is defined at `*0300`, `MESG, .` assembles to a word at `0300` containing the value `0300`. The initialization sequence `TAD MESG` / `DCA CURCHR` therefore loads `0300` into `CURCHR`. On the first `TAD I CURCHR`, the auto-index pre-increments `CURCHR` from `0300` to `0301`, then fetches the word at `0301` — which is `'H'`, the first character of the string. Without this self-pointer, a separate constant `MESG-1` would be required to initialize the pointer one position before the first character.

**`TLS` sends the character and clears the flag in one instruction.** After `TLS` executes, the TTY flag is immediately clear and the transmission is in progress. The subsequent `JMP STROUT` re-enters the `TSF` poll loop, which holds execution until the hardware completes the transmission and sets the flag again. `CLA` after `TLS` discards the character value; AC carries no useful information at that point and must be clear before the next `TAD I CURCHR`.

**`SNA` detects the sentinel.** The string is terminated by a zero word. `TAD I CURCHR` loads the next word into AC; `SNA` skips the `JMP OS8RET` if AC is non-zero (a valid character) and falls through to it when AC is zero (the sentinel). Zero is unambiguous as a sentinel because all valid ASCII character values, with the mark bit set, are non-zero.

### Non-Intuitive Points for Beginners

- **The TTY output flag does not start set.** A programmer expecting the device to be "idle and ready" at program start will put `TSF` first and enter an infinite loop. The flag only becomes set after a `TLS` has initiated a transmission and that transmission has completed. The first send must always be unconditional.
- **`TLS` does not test readiness — it transmits regardless.** If two `TLS` instructions execute without an intervening `TSF` wait, the second character overwrites the first before the TTY has finished sending it. The `TSF` poll between characters is the entire synchronization mechanism; removing it produces garbled output at any speed above the TTY's bit rate.
- **Auto-index pre-increments, not post-increments.** The pointer must be initialized to the location *before* the first element. Initializing `CURCHR` to `MESG` (the address of the first character) instead of `MESG-1` would cause the loop to skip the first character entirely, reading from `MESG+1` on the first access. The `MESG, .` self-pointer trick satisfies this requirement: `MESG` holds `0300`, its own address, so the string content starts at `0301` and the first pre-increment lands exactly there.
- **`TAD MESG` loads the value stored *at* `MESG`, not the address of `MESG`.** The initialization works because `MESG, .` makes those two things the same. If `MESG` were defined differently (e.g., as a pointer to something else), `TAD MESG` would load whatever value was stored there, not the address `0300`. The self-pointer pattern depends on this coincidence being intentional.

### Key Learning Points

- The TTY output flag cycle: cleared at start, cleared again by `TLS`, set by the hardware when transmission completes. `TSF` tests this flag. The first character must be sent blind to start the cycle.
- `TSF` / `TLS` is the complete polled TTY output pair. `TSF` waits for the device; `TLS` sends and clears. Every character except the first requires a `TSF` wait before `TLS`.
- Auto-index registers at `0010`–`0017` pre-increment on every indirect reference. Initialize the pointer to one location before the first element of the table or string.
- The `MESG, .` idiom initializes a block such that its own address is stored in its first word, providing a ready-made `TABLE-1` pointer for auto-index traversal without a separate constant.
- Zero-sentinel string termination pairs naturally with `SNA`: load the next word, skip on non-zero to continue, fall through on zero to exit.

---

## Exercise 2 — Character Input with Echo

### What It Does

Prints the prompt `INPUT A CHARACTER (Q) TO QUIT: ` to the TTY, then enters a polled keyboard input loop. Each character read via `KRB` is passed to the `VALCHR` subroutine, which normalizes it (converting lowercase to uppercase) and checks for `Q` as a quit sentinel. Any character other than `Q` is echoed back to the TTY followed by a carriage return and line feed. Typing `Q` (or lowercase `q`) exits directly to the OS/8 monitor. The program loops, reprinting the prompt, until `Q` is received.

Two subroutines support the main loop. `CHROUT` outputs a single character passed in AC, using a double-`TSF` pattern to wait for device readiness before sending and again after to confirm completion. `VALCHR` receives a raw character from `CHAR`, performs the lowercase-to-uppercase conversion, tests for `Q`, echoes the normalized character via `CHROUT`, and returns — or jumps directly to `OS8RET` if the character was `Q`.

### Implementation Rationale

**Prompt output reuses the EX1 string-output loop.** The `TOP` entry point reinitializes `CURCHR` to the address of `MESG` on every iteration, restoring the auto-index pointer before each prompt pass. The blind-first-send (`JMP FRSTCH`) and zero-sentinel exit to `CHRIN` are identical in structure to Exercise 1. This makes the prompt loop a self-contained section that can be read independently of the input processing that follows.

**`KSF` / `KRB` mirrors the `TSF` / `TLS` output pattern.** `KSF` skips when the keyboard flag is set (a key has been struck and is waiting in the keyboard register). `JMP CHRIN` loops while the flag is clear. `KRB` reads the character into AC and clears the keyboard flag. This is the same busy-wait structure as the output side: poll the flag, then transfer.

**`CHROUT` uses a double-`TSF` guard.** The first `TSF` / `JMP FLGCHK` loop waits for the TTY to be ready before issuing `TLS`. The second `TSF` / `JMP WAIT` loop waits for the transmission to complete before returning. This is more disciplined than the EX1 output loop, which omits the initial flag check for the first character. `CHROUT` is safe to call at any time regardless of prior device state, because it always checks before sending.

**Lowercase detection uses the mark-bit form of the threshold.** `KRB` returns 8-bit characters with the mark bit set (bit 7 = 1), matching the `"X` encoding that PAL8 uses for character literals. Lowercase `a` is `0341` (octal), uppercase `A` is `0301`. The detection computes `AC = CHAR − 0341` via `TAD (0141)` + `TAD (0200)` + `CIA` + `TAD CHAR`. The result is zero for `a`, positive for `b`–`z` (and beyond), and negative for anything with a smaller code. `SPA` skips the `JMP UCASE` branch only for characters `≥ 0341`, sending them through the conversion block. All other characters jump directly to `UCASE` unchanged.

**The conversion subtracts `0040` from the character.** The ASCII distance between any lowercase letter and its uppercase equivalent is `0040` (32 decimal). `CIA` negates `0040` to get `7740`, then `TAD CHAR` produces the uppercase version. This works for the full a–z range because the mark bit is the same for both cases and the subtraction only affects the lower 7 bits.

**`Q`-detection fires on the normalized character.** After the lowercase block (if entered) falls through to `UCASE`, `CHAR` holds the uppercase-normalized value. The `Q` test computes `CHAR − 0321`; if the result is zero, the character was `Q`. Because normalization happens before the test, typing lowercase `q` also triggers the exit.

**`VALCHR` exits abnormally on `Q`.** When `Q` is detected, `VALCHR` jumps directly to `OS8RET` rather than returning to its caller via `JMP I VALCHR`. The return address stored at `VALCHR` (location `0241`) is left dirty but is never used. The caller's `TAD (0015)` / `JMS CHROUT` / `TAD (0012)` / `JMS CHROUT` instructions are bypassed — no CR/LF is sent before exiting, so the OS/8 prompt appears on the same line as the cursor.

### Non-Intuitive Points for Beginners

- **`KSF` and `KRB` are the input counterparts of `TSF` and `TLS`.** `KSF` tests the keyboard flag (set when a key is ready); `KRB` reads the character and clears the flag. The polling idiom is identical in structure to output — busy-wait on the flag, then transfer.
- **`CHROUT` receives its character in AC, not from `CHAR`.** The entry comment says `ENTRY: AC`. Callers load the character into AC with `TAD CHAR` or `TAD (literal)` before `JMS CHROUT`. There is no `TAD CHAR` inside `CHROUT` — `TLS` sends whatever is in AC at the moment the flag check passes.
- **The lowercase test detects characters `≥ 0341`, not just `a`–`z`.** Characters like `{`, `|`, `}`, `~` have mark-bit values `0373`–`0376` and will also pass the `SPA` check, having `0040` subtracted from them. This is harmless in practice on a PDP-8 terminal, which cannot produce those characters, but the boundary is wider than just the 26 letters.
- **`JMS` does not clear AC.** AC holds the character value when `JMS VALCHR` executes. `VALCHR` starts with `TAD (0141)` which adds to whatever AC contains on entry. The code depends on AC being zero at entry — which it is, because `DCA CHAR` zeroes AC immediately before `JMS VALCHR`.
- **`VALCHR` can exit to `OS8RET` without returning.** A subroutine that calls `JMS VALCHR` must be prepared for the possibility that `VALCHR` never returns. The return address at location `0241` is valid but never used when `Q` is typed. This is an intentional non-local exit, not a bug.

### Key Learning Points

- `KSF` / `KRB` and `TSF` / `TLS` are symmetric polled I/O pairs. The polling loop structure is identical for input and output; only the IOT opcodes differ.
- The double-`TSF` pattern in `CHROUT` (check before send, verify after) is the fully disciplined form for TTY output. It is safe to call at any point regardless of device state.
- Lowercase-to-uppercase conversion on PDP-8 mark-bit characters subtracts `0040` from the character value. The detection threshold is `0341` (mark-bit `a`); `SPA` after the threshold subtraction distinguishes lowercase from everything else.
- A subroutine may exit via a non-local jump (`JMP OS8RET`) rather than `JMP I label`. This is valid when the exit is terminal — the caller will not resume and the return slot is intentionally abandoned.
- Normalizing input before testing for a sentinel (converting `q` → `Q` before the `Q` check) means the program responds correctly to either case without a separate test.

---

## Exercise 3 — Line-Buffered Input Routine

### What It Does

Prints the prompt `ENTER A LINE FOLLOWED BY CR (EMPTY LINE TO QUIT):` to the TTY, reads a line of keyboard input into a 128-character buffer, normalizes all lowercase letters to uppercase, then prints the buffered line back to the TTY followed by CR+LF. The cycle repeats until the user presses CR on an empty line, at which point the program exits to the OS/8 monitor.

Input is collected by `GETBFR` one character at a time using `KSF`/`KRB` polling. Each character is tested against the lowercase threshold `0341` (mark-bit `a`); characters at or above that value have `0040` subtracted to produce the uppercase equivalent. The normalized character is then tested for CR (`0215`); a CR terminates input immediately without storing. If the buffer is not yet full the character is stored via `DCA I BFRPTR` and the loop continues. The buffer holds up to 128 characters at locations `0400`–`0577`.

After `GETBFR` returns, `PRTBFR` checks whether any characters were stored. If `BFRPTR` still equals `BFRINI` (nothing stored), the program exits to OS/8 — the empty-line quit condition. Otherwise `PRTBFR` prints each stored character in order, sends CR+LF, and returns to the main loop.

### Implementation Rationale

**Four subroutines divide the work into single-responsibility sections.** `CLRBFR` zeroes the buffer before each input pass to prevent stale characters from a previous longer line appearing within a shorter subsequent one. `GETBFR` reads one full line from the keyboard. `PRTBFR` prints the buffer and implements the empty-line exit. `PRTMSG` outputs the fixed prompt. The main loop (`TOP`) sequences these four calls unconditionally; every OS/8 exit path runs through `PRTBFR`.

**`BFRINI` is the auto-index seed, not the buffer start.** The buffer occupies `0400`–`0577`. `BFRINI` holds `0377` — one location before the first buffer word. Initializing `BFRPTR` to `0377` causes the first store to land at `0400` and the first read to return from `0400`.

**Buffer fullness is detected by pointer arithmetic rather than a separate counter.** `GETBFR` stores the current character first, then evaluates `BFRPTR + BFRLEN − BFRINI`. `BFRLEN` is `−128` (octal `7600`), so the expression reaches zero when `BFRPTR = 0577` — exactly after the 128th character has been stored. The function returns at that point without reading any further keyboard input.

**`PRTEND` holds the address of the last stored character.** After `GETBFR` returns, `BFRPTR` points to the last-written location (e.g., `0402` after three characters). `PRTBFR` saves this as `PRTEND` before resetting `BFRPTR` to `BFRINI` for the read pass. The print loop continues as long as `PRTEND − BFRPTR > 0`. When `TAD I BFRPTR` increments `BFRPTR` to `PRTEND` after printing the last character, the result is zero, `SPA SNA` does not skip, and the loop exits. The last character's transmission is awaited before the exit is taken.

**The initial `KRB` in `GETBFR` discards the OS/8 entry CR.** When OS/8 launches a program, it leaves a CR in the keyboard buffer from the return key that initiated execution. `GETBFR` consumes this with a bare `KRB` (no prior `KSF` wait) before entering the polling loop. On second and later calls no CR is pending; the bare `KRB` reads stale buffer contents and discards them harmlessly, because the `KSF`/`JMP CKINFL` loop immediately overwrites `CURCHR` with the first real keystroke.

**The empty-line exit is detected by `PRTBFR`, not `GETBFR`.** If the user presses CR immediately, `GETBFR` detects CR without storing any character and returns with `BFRPTR` still equal to `BFRINI`. `PRTBFR` checks `BFRPTR − BFRINI` on entry; a zero result indicates an empty buffer and falls through to `OS8RET`. Placing this test at the output boundary keeps `GETBFR` single-responsibility and avoids requiring a special return convention to signal "no input received."

### Non-Intuitive Points for Beginners

- **`BFRINI` is one below the buffer start, not the first buffer location.** `BFRINI = 0377`, but the first stored character lands at `0400` due to auto-index pre-increment. Initializing `BFRPTR` to `0400` would cause the first character to land at `0401`.
- **`PRTEND` is the address of the last stored character, not one past it.** After N stores, `BFRPTR = 0377 + N`, and the Nth character is at `0377 + N`. The print loop exits when `PRTEND − BFRPTR = 0`, which occurs exactly after `TAD I BFRPTR` increments `BFRPTR` to `PRTEND` and reads the last character. `CLRBFR` has zeroed the location beyond `PRTEND`, but the comparison prevents the extra read from occurring.
- **`CLRBFR` clears `0400`–`0577`, not `0377`.** The first auto-index store in `CLRBFR` pre-increments `BFRPTR` from `0377` to `0400`; location `0377` is never touched. The `BFRINI` data word at address `0020` (value `0377`) is entirely separate from the buffer location `0377`.
- **The buffer fullness check fires immediately after the 128th store, without reading a further character.** After `DCA I BFRPTR` stores the 128th character, `BFRPTR = 0577`. The fullness check `BFRPTR + BFRLEN − BFRINI = 0` is satisfied on that same iteration and `GETBFR` returns. No additional keyboard read occurs.
- **`PRTBFR` is the only exit point from the main loop.** `TOP` loops unconditionally via `JMP TOP`. The OS/8 exit lives inside `PRTBFR` at `JMP OS8RET`. A programmer reading `TOP` sees no termination condition; the program ends only because `PRTBFR` detects an empty buffer and jumps past its normal return.
- **The lowercase threshold `0341` has no upper bound check.** Characters `0373`–`0377` (mark-bit `{`, `|`, `}`, `~`, DEL) also satisfy `≥ 0341` and have `0040` subtracted. A standard PDP-8 keyboard cannot generate those codes, so the missing upper bound has no practical effect.

### Key Learning Points

- A polled line-input loop requires two independent exit conditions — line terminator and buffer capacity — tested in that order so that a completely full buffer is still recognized correctly even when no CR has appeared.
- Pointer arithmetic against a derived ceiling (`BFRINI − BFRLEN`) serves as the counted-loop terminator without a separate `ISZ` counter; the same `BFRPTR` value that tracks the write position also encodes the loop bound.
- `PRTEND` must be captured before the pointer is reset for the read pass; because auto-index advances during the write phase, the final `BFRPTR` after `GETBFR` is the address of the last element, not one past it.
- Placing the program-exit test at the output boundary (`PRTBFR`) rather than the input boundary (`GETBFR`) keeps the input routine single-responsibility and avoids encoding an out-of-band "empty input" signal in the subroutine's return convention.
- An OS/8 program must discard the keyboard buffer entry CR exactly once at the start of the first input read; on subsequent calls the same unconditional `KRB` reads stale data harmlessly because the polling loop that follows always waits for a fresh keystroke before acting.

---

## Exercise 4 — Read a Block from PTR into Memory

### What It Does

Reads ASCII text from the high-speed paper tape reader (PTR) into a 3968-word buffer in field 1, starting at address `10200` (field 1, location `0200`). Each character read is normalized to uppercase, echoed to the TTY, and stored in the buffer. Input terminates when the five-character sequence CR LF \$ CR LF is detected, or when the buffer is completely full. The program halts at completion, allowing inspection of the stored data before returning to OS/8.

The buffer occupies all of field 1 from `10200` through `17777`. The program code and control variables reside in field 0. Cross-field stores are managed by setting `CDF 10` once at program start; all direct memory references use IF=0 to access field-0 variables, while all indirect stores through `CURLOC` use DF=1 to write to the field-1 buffer.

### Implementation Rationale

**Three subroutines divide the work by responsibility.** `LOCINI` initializes the auto-index pointer and loop counter based on `BLKINI`, the seed value one location before the first buffer word. `CLRBFR` zeroes all 3968 words of the field-1 buffer before input begins, ensuring no stale data from a previous run appears. `RDPTR` reads from the PTR one character at a time, normalizes it, checks for the EOF sentinel sequence, echoes it to the TTY, stores it in field 1, and loops until EOF is detected or the buffer fills.

**`CDF 10` is set once at program start and persists throughout execution.** Direct memory operations (`TAD CURCHR`, `DCA COUNTR`, `ISZ COUNTR`) use the instruction field (IF=0) and therefore access field-0 variables correctly regardless of DF. Indirect memory operations (`DCA I CURLOC`) fetch the pointer value from field 0 using IF, then use the data field (DF=1) to perform the store. This single `CDF 10` at the top allows all cross-field stores to work without per-operation field switching.

**The buffer boundary is enforced by `ISZ COUNTR` wrap behavior.** `COUNTR` initializes to `0200` (the first buffer location). After each store, `ISZ COUNTR` increments it. When `COUNTR` reaches `7777` and wraps to `0`, the `ISZ` skips, causing `RDPTR` to return immediately without storing the current character. The 3968-word capacity (`7777 - 0200 + 1 = 7600` octal = 3968 decimal) is thus enforced automatically by the 12-bit arithmetic wrap.

**`CURLOC` and `COUNTR` track the same progression but serve different purposes.** `CURLOC` is the auto-index register that pre-increments before each `DCA I CURLOC` store. `COUNTR` is the loop termination detector that post-increments via `ISZ` and tests for wrap to zero. Both start at the same seed value (`BLKINI` for `CURLOC`, `BLKINI+1` for `COUNTR`), and both advance in lockstep — but `CURLOC` advances before the store, while `COUNTR` advances after, so `COUNTR` always holds the address of the location that was just written.

**The EOF detector is a five-state machine.** `EOFCTR` counts characters matched so far (initialized to `−5`, increments toward zero). `FNDDLR` is a flag set when the \$ is seen in position 3. The sequence CR LF \$ CR LF must appear in that exact order; any character that does not match the expected next character in the sequence resets the state via `EOFRST`. When the final LF is seen with `FNDDLR` set and `EOFCTR = −1`, the detector sets `EOFFND` to signal EOF.

**Each input character is masked to 7 bits before testing.** `AND (0177)` strips the parity bit (bit 7), ensuring that the sentinel tests for CR, LF, and \$ match regardless of whether the input source sets or clears the high bit. The uppercase normalization operates on the full 8-bit mark-bit character form, but the EOF detection operates on the 7-bit ASCII core.

**`RFC` initiates the read; `RSF` polls for completion; `RRB` retrieves the character.** This is the standard PDP-8 three-instruction sequence for high-speed paper tape input. `RFC` (6014) starts the reader and clears the reader flag. `RSF` (6011) skips when the flag is set (a character is ready). `RRB` (6012) reads the character into AC and clears the flag. Unlike TTY input, PTR requires the explicit `RFC` initiation before each character.

**`RDPTR` calls `LOCINI` to reset the pointers before reading.** This allows `CLRBFR` and `RDPTR` to share the same initialization logic. Both need `CURLOC` set to `BLKINI` and `COUNTR` set to `BLKINI+1`. Factoring this into `LOCINI` eliminates duplication and ensures both routines start from a consistent state.

### Non-Intuitive Points for Beginners

- **`CDF` affects only indirect addressing for data, not direct references.** A common misconception is that `CDF 10` causes all memory operations to target field 1. In reality, direct operations (`TAD CURCHR`) always use IF, and indirect operations (`DCA I CURLOC`) use IF to fetch the pointer but DF to access the data. This is why field-0 variables remain accessible after `CDF 10` is set.
- **`BLKINI = 0177`, not `0200`.** The buffer starts at field-1 address `0200`, but `BLKINI` holds `0177` — one location before. Auto-index pre-increments before every access, so initializing `CURLOC` to `0177` causes the first `DCA I CURLOC` to write to `0200`. Initializing to `0200` would cause the first write to land at `0201`, losing the first character.
- **`COUNTR` initializes to `BLKINI + 1`, not `BLKINI`.** `CURLOC` pre-increments before the store; `COUNTR` post-increments after via `ISZ`. To keep them synchronized, `COUNTR` must start one position ahead. After the first store, both hold `0200`; after the second, both hold `0201`; and so on.
- **The EOF state machine resets on any non-matching character.** If the input contains "CR LF X", the state resets immediately on seeing X. The next CR starts a fresh attempt at matching the sequence. This means the sequence must appear contiguously with no intervening characters — even spaces or nulls break it.
- **The \$ must appear as the third character of the five-character sequence.** The detector sets `FNDDLR` only when a \$ is seen and `EOFCTR + 3 = 0`, meaning exactly two characters (CR, LF) have been matched. If \$ appears earlier or later, the state resets and the sequence must begin again.
- **The buffer fullness check fires after the character is stored.** The store via `DCA I CURLOC` happens first, then `ISZ COUNTR` checks for wrap. When `COUNTR` reaches `7777` and the 3968th character is stored, the subsequent `ISZ` wraps to `0`, skips, and `RDPTR` returns. All 3968 buffer words are filled.

### Key Learning Points

- High-speed paper tape input on the PDP-8 requires a three-instruction sequence: `RFC` to initiate, `RSF` to poll for ready, `RRB` to read. This differs from keyboard input, which does not require an explicit initiation instruction.
- Extended memory cross-field stores require only one `CDF` at program start when IF and DF are used correctly. Direct memory operations always use IF; indirect operations use IF for the pointer fetch and DF for the data access. Setting DF once and leaving IF at 0 allows the program to reference field-0 control variables directly while storing to field-1 data indirectly.
- A counted loop on the PDP-8 can terminate by wrap behavior rather than an explicit comparison. Initializing a counter to the start address and using `ISZ` to detect wrap to zero eliminates the need for a separate "loop bound" constant and comparison logic.
- State machines for multi-character sentinel detection must reset cleanly on any unexpected input. A partial match followed by a non-matching character leaves the detector in a known state (reset to initial), not a corrupt or ambiguous one.
- Factoring shared initialization logic into a common subroutine (`LOCINI`) eliminates code duplication and ensures multiple routines that depend on the same preconditions start from a consistent state. This is preferable to duplicating the initialization sequence inline in each caller.

---

## Exercise 5 — Punch Memory Contents to PTP

### What It Does

Outputs the string `HELLO WORLD!` to the high-speed paper tape punch (PTP) using a polled busy-wait loop, then halts and returns to the OS/8 monitor. The string is stored as a sequence of 7-bit ASCII values (with the mark bit set) at `*0300`, terminated by a zero sentinel. A single auto-index register at `CURCHR` (`0010`) walks the string one character per iteration. Each iteration polls `PSF` to wait until the punch flag is set, then loads the next character via indirect auto-index, tests it for the zero sentinel with `SNA`, sends it with `PLS`, clears AC, and loops. When the sentinel is read the program halts before exiting via `CIF CDF 0` / `JMP I (7600)`.

### Implementation Rationale

**The first character is sent without a prior `PSF` poll.** The punch output flag starts in the cleared state when a program begins. `PSF` skips when the flag is set; it loops when the flag is clear. If the program entered the busy-wait loop before any `PLS` had been issued, `PSF` would never skip — there is nothing to wait for. The flag is set by the punch hardware only after a punch operation initiated by `PLS` completes. Sending the first character blind via `JMP FRSTCH` primes the cycle: `PLS` initiates the first punch, which causes the hardware to set the flag when done, which `PSF` can then detect for all subsequent characters.

**`CURCHR` is placed at location `0010`.** Locations `0010`–`0017` are the PDP-8 auto-index registers. Placing `CURCHR` at `0010` means `TAD I CURCHR` automatically advances the pointer on every access.

**`MESG, .` stores the address of `MESG` at `MESG` itself.** The `.` pseudo-op evaluates to the current location counter at assembly time. Since `MESG` is defined at `*0300`, `MESG, .` assembles to a word at `0300` containing the value `0300`. The initialization sequence `TAD MESG` / `DCA CURCHR` therefore loads `0300` into `CURCHR`, positioning it one location before the first character.

**`PLS` punches the character and clears the flag in one instruction.** After `PLS` executes, the punch flag is immediately clear and the punch operation is in progress. The subsequent `JMP STROUT` re-enters the `PSF` poll loop, which holds execution until the hardware completes the punch and sets the flag again. `CLA` after `PLS` discards the character value; AC carries no useful information at that point and must be clear before the next `TAD I CURCHR`.

**`SNA` detects the sentinel.** The string is terminated by a zero word. `TAD I CURCHR` loads the next word into AC; `SNA` skips the `JMP OS8RET` if AC is non-zero (a valid character) and falls through to it when AC is zero (the sentinel). Zero is unambiguous as a sentinel because all valid ASCII character values, with the mark bit set, are non-zero.

### Non-Intuitive Points for Beginners

- **The punch output flag does not start set.** A programmer expecting the device to be "idle and ready" at program start will put `PSF` first and enter an infinite loop. The flag only becomes set after a `PLS` has initiated a punch operation and that operation has completed. The first send must always be unconditional.
- **`PLS` does not test readiness — it punches regardless.** If two `PLS` instructions execute without an intervening `PSF` wait, the second character overwrites the first before the punch has finished sending it. The `PSF` poll between characters is the entire synchronization mechanism; removing it produces corrupted output or lost characters.
- **`TAD MESG` loads the value stored *at* `MESG`, not the address of `MESG`.** The initialization works because `MESG, .` makes those two things the same. If `MESG` were defined differently (e.g., as a pointer to something else), `TAD MESG` would load whatever value was stored there, not the address `0300`. The self-pointer pattern depends on this coincidence being intentional.
- **The PTP and TTY use parallel I/O instruction sets.** `PSF`/`PLS` for punch mirrors `TSF`/`TLS` for TTY. The opcodes differ (6031/6036 vs 6041/6046), but the flag behavior, polling pattern, and blind-first-send requirement are identical. Code that works for TTY output can be adapted to PTP output by changing only the IOT opcodes.

### Key Learning Points

- The punch output flag cycle: cleared at start, cleared again by `PLS`, set by the hardware when punch completes. `PSF` tests this flag. The first character must be sent blind to start the cycle.
- `PSF` / `PLS` is the complete polled punch output pair. `PSF` waits for the device; `PLS` punches and clears. Every character except the first requires a `PSF` wait before `PLS`.
- The `MESG, .` idiom initializes a block such that its own address is stored in its first word, providing a ready-made auto-index seed without a separate constant.
- Zero-sentinel string termination pairs naturally with `SNA`: load the next word, skip on non-zero to continue, fall through on zero to exit.
- PDP-8 I/O devices that use the skip-on-flag / transfer pattern (TTY, PTR, PTP) all follow the same discipline: blind first operation to start the flag cycle, then poll-before-transfer for all subsequent operations. Mastering this pattern for one device transfers directly to all similar devices.
