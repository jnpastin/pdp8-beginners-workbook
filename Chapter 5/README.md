# Chapter 5 — OS/8 and Extended Memory

## Goals

- Write correct OS/8 programs
- Respect field and page conventions
- Understand extended memory behavior

---

## Exercise 1 — OS/8-Safe Program Exit

### What It Does

Runs a tight 12-bit counter loop using `IAC`, starting from 0000 and incrementing until the accumulator rolls over from 7777 back to 0000. The overflow sets Link, which `SZL` detects to exit the loop. On overflow, execution transfers to field 1 via `CIF CDF 10` followed by a `JMP`. In field 1, the current data field and instruction field values are captured into named memory locations (`DF` and `IF` at `*0300`) for front-panel inspection. The program halts, then returns to the OS/8 monitor by resetting both fields to 0 and executing `JMP I (7600)`.

### Implementation Rationale

The counter loop is deliberately trivial. The exercise goal is the field-change and OS/8 exit sequence; the computation is just a convenient way to produce a detectable event (the 7777→0000 overflow) that triggers the transition.

`IAC` sets Link when the accumulator increments through 7777 to 0000 — the carry out of bit 11. `SZL` skips on zero Link, so the non-skip fall-through occurs precisely when overflow happens. This is the standard idiom for detecting AC overflow without a separate comparison.

`CIF CDF 10` arms the field change to field 1 but does not execute it immediately. The field change takes effect on the next `JMP` (or `JMS`). The `JMP FLDCAP` following it is what actually transfers execution to field 1 — without that jump, the `CIF` would have been issued but no field change would occur because the next instruction would still fetch from field 0.

The `RDF` / `DCA DF` and `RIF` / `DCA IF` sequence in field 1 captures the current field register values at the moment of arrival at `FLDCAP`. Since the field change has already completed by the time these execute, both will read 1 — confirming the transfer worked. The capture exists for front-panel validation, not for computation.

`HLT` is placed before the return sequence to give an opportunity to inspect `DF` and `IF` at the front panel before the program exits.

The return path requires a two-step field hop: `CIF CDF 0` arms the field change back to field 0, then `JMP OS8RET` executes it. `OS8RET` in field 0 performs the final `JMP I (7600)`. This two-label structure is required because `CIF CDF 0` must be paired with a JMP to take effect, and the `JMP I (7600)` must execute in field 0 for OS/8 to receive control correctly.

`OS8RET` is placed at a new origin (`*0230`) rather than immediately after the last field-0 instruction at 0207. Without an explicit origin, PAL8 would assign OS8RET sequentially after 0207, which is an unexecuted gap in the code — not a collision, but difficult to read and fragile if the field-0 section grows. The `*0230` makes the intent explicit. The comment `NEED NEW ORIGIN, OTHERWISE 0200` in earlier versions documented the issue; the code itself demonstrates the correct response.

`DF` and `IF` data words are placed in field 1 at `*0300`, co-located with the field-1 code that writes to them. This allows direct addressing from `FLDCAP` without cross-page indirection.

### Non-Intuitive Points for Beginners

- **`CIF` does not switch fields immediately.** The field change armed by `CIF CDF 10` is deferred until the next JMP or JMS executes. Every instruction between `CIF CDF 10` and the `JMP FLDCAP` still fetches from field 0. Removing the `JMP` — or inserting any intervening JMP to another field-0 address — would abort the field switch.
- **`FLDCAP` resolves to the same 12-bit address in both fields.** PAL8 assembles `FLDCAP` as address `0200` within field 1. The `JMP FLDCAP` in field 0 therefore encodes address `0200` in its instruction word — the same numeric address as `LOOP`. What makes it land in field 1 is the pending `CIF` that changes IF before the jump executes. Same address, different field.
- **`RDF` and `RIF` at FLDCAP read the fields as they are after the transfer.** By the time `FLDCAP` executes, IF = 1 and DF = 1 (DF tracks IF on a `CIF CDF` combined instruction). The stored values confirm the transfer happened but do not record what the fields were before.
- **`CIF CDF 0` and `JMP OS8RET` are two steps, not one.** There is no single instruction that atomically changes field and jumps to OS/8. The CIF pairs with the JMP; the JMP carries execution back to field 0; the `JMP I (7600)` in field 0 makes the OS/8 handoff. Collapsing these into fewer steps produces either a field mismatch or an illegal indirect encoding.
- **AC and Link are not cleared before the OS/8 return.** This is correct. OS/8 does not inspect AC or Link on entry; both are don't-cares at that point. Adding `CLA CLL` before `JMP I (7600)` would be cargo-cult code — it signals a misunderstanding of the OS/8 contract.

### Key Learning Points

- `CIF` defers the field change to the next JMP or JMS. The instruction following `CIF` executes in the current field. Always pair `CIF` with an immediate unconditional jump.
- Both `CIF` and `CDF` must be reset before returning to OS/8. `CIF CDF 0` (assembled as 6203) resets both in a single instruction. Using only `CIF` leaves the data field pointing into field 1, which corrupts any OS/8 memory operations after the return.
- Field-1 code and data are assembled in the same PAL8 source file using `FIELD 1` directives. Labels defined under `FIELD 1` carry field-1 addresses; the programmer is responsible for ensuring cross-field references are handled via `CIF`/`CDF` and indirect addressing, not direct jumps.
- A `*NNNN` origin directive is required whenever a new section would otherwise be assigned an address that conflicts with (or silently follows without gap from) an earlier section in the same field.
