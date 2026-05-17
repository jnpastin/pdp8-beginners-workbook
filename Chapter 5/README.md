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

---

## Exercise 2 — Field-Safe Subroutine Callable from Field 0

### What It Does

Visits four extended memory fields in sequence (0→1→2→3→2→0), using five different field-change techniques along the way. Each field stores a sentinel value (7777, 6666, 5555, 4444 respectively) to confirm execution reached it. A subroutine `COUNTR` in field 3 runs a saturation loop (incrementing AC until Link sets), stores the field 3 sentinel, then returns dynamically to the calling field using CDF/CIF instructions it constructs at runtime from field values saved by the caller. The program halts in field 0 after all four sentinels are written, then returns to OS/8.

The five field-change techniques demonstrated:

| Transition | Technique |
|---|---|
| F0→F1 | Build CDF/CIF instructions dynamically, execute them in-line, jump via literal |
| F1→F2 | Build CDF/CIF using cross-field indirect data reads; jump via address-0 trampoline |
| F2→F3 | Save calling IF/DF with `RIF`/`RDF`; build CDF/CIF via literals; call via `JMS` |
| F3→F2 | Build return CDF/CIF from saved field values in field 0; return via `JMP I COUNTR` |
| F2→F0 | Hardcoded `CIF CDF 0`; jump via address-0 trampoline |

### Implementation Rationale

**Building field-change instructions dynamically.** A `CDF n` instruction is the value `6201` with the field number in bits 5–3 (i.e., field 1 = `0010`, field 2 = `0020`, etc.). To build `CDF 1` at runtime, load the field value `0010` into AC, add `6201`, and store the result (`6211`) into a memory location that will be executed. The same applies to `CIF` (`6202`). This is normal self-modifying code on the PDP-8 — the location is initialized to `0` in the source, the instruction is written there at runtime, and execution falls through it in sequence.

**The literal jump `JMP (0200)`.** `JMP (addr)` in PAL8 generates a literal containing `addr` at the end of the current page and emits `JMP I literal_location`. The indirect jump reads the literal (which contains the target address) and jumps there. Since `JMP I` causes a pending `CIF` to take effect, this is the mechanism that actually commits the field change. The destination address `0200` encodes the 12-bit address within the target field; it is the `CIF` that routes execution to the right field.

**Cross-field indirect addressing in field 1.** After `CDF 0`, the data field is field 0. `TAD I DFPTR1` uses two-level indirection: the pointer `DFPTR1` is read from the current instruction field (field 1), but the data it points to is fetched from the data field (field 0). The instruction field governs level one (where the pointer lives); the data field governs level two (where the pointed-to data lives). `DCA I` follows the same rule on write. This asymmetry does not apply to direct (non-indirect) MRI — `TAD DFPTR1` always reads from IF regardless of DF.

**The address-0 trampoline.** Each field has its own address 0000. A common PDP-8 idiom is to write a jump target into address 0 of the current field, then use `JMP I 0` to execute an indirect jump through it. This allows the destination to be determined at runtime without consuming a literal slot. Field 1 uses this to reach `FLD2IN`; field 2 uses it to reach `FLD0IN`. The target must be written before the `JMP I 0` executes, and must be rewritten for each distinct use.

**Saving the calling field before changing it.** Field 2 must call `COUNTR` in field 3 and return to field 2 afterward. `RIF` reads the current instruction field into AC bits 5–3; `RDF` reads the current data field the same way. These are captured via cross-field indirect writes (`DCA I ORIGIF`, `DCA I ORIGDF`) into field 0 locations `RTNIF` and `RTNDF` before any field change occurs. `COUNTR` later reads these values back (again via cross-field indirect) to reconstruct the return `CDF`/`CIF` instructions. The save must happen while IF and DF still reflect the calling context — any `CIF` or `CDF` before the save corrupts the return address.

**`JMS` across fields.** After `CTRDF` (a dynamically built `CDF 3`) and `CTRIF` (`CIF 3`) execute, the `JMS COUNTR` instruction causes the pending `CIF` to take effect. `JMS` stores the return address — the address of the instruction following `JMS`, in the new instruction field — at the subroutine entry location (`COUNTR`, field 3 address 0200). Execution then continues at `COUNTR+1`. This is the same mechanism as a same-field `JMS`, except the store and the entry point are now in field 3.

**The dynamic return from `COUNTR`.** `COUNTR` does not know at assembly time which field called it. It reads `RTNDF` and `RTNIF` from field 0 via `DFPTR3` and `IFPTR3`, adds the `CDF` and `CIF` opcodes, and stores the results at `RETDF` and `RETIF` — two zeroed locations in its own code stream. Execution falls into them in sequence, exactly as it falls into `CDF1`/`CIF1` in field 0, `CDF2`/`CIF2` in field 1, and `CTRDF`/`CTRIF` in field 2. The pattern is the same throughout the program: compute an instruction word, store it into a zeroed placeholder in the instruction stream, and let sequential execution flow through it. What varies between instances is how the instruction value is computed (literal arithmetic vs. cross-field indirect read) and what immediately follows the pair (`JMP`, `JMS`, or `JMP I`).

**`JMP I` with a pending `CIF`.** For `JMP I addr`, the pointer is fetched from the current instruction field (before the field change), and the jump lands in the new instruction field (after the field change). In the field 2→0 return, address 0 of field 2 holds `FLD0IN` (0300). `CIF CDF 0` is issued, then `JMP I 0` fetches the pointer from field 2 address 0 (= 0300) and jumps to field 0 address 0300. The field change takes effect for the landing, not for the pointer fetch.

### Non-Intuitive Points for Beginners

- **`DF` is only consulted on indirect MRI.** `TAD VAR` always reads from the instruction field, regardless of what `CDF` has set. Only `TAD I VAR` respects DF for the second-level fetch. Setting DF and then doing direct `TAD` instructions is a silent no-op on the field setting — the data comes from IF anyway.
- **Field values occupy bits 5–3, not the low bits.** Field 1 is `0010`, field 2 is `0020`, field 3 is `0030`. To build a `CDF n` instruction, you add `0010 * n` to `6201`, not just `n`. Writing `TAD (1)` and `TAD (6201)` produces `6202` (`CIF 0`), not `CDF 1`.
- **`CIF` takes effect on `JMS` as well as `JMP`.** A common assumption is that only `JMP` triggers the deferred field change. `JMS` also commits a pending `CIF`, and the return address it stores is in the new field. This means cross-field `JMS` works correctly without any special handling — the return slot is automatically in the called field.
- **The two levels of a cross-field indirect read come from different fields.** `TAD I PTR` with `CDF 0` in effect: the pointer (`PTR`) is read from IF; the data the pointer addresses is read from DF (field 0). A reader unfamiliar with this rule will assume both levels use the same field, which leads to incorrect reasoning about what is being read.
- **Self-modifying locations must be initialized to `0` in the source.** A location like `CDF1, 0` is just a placeholder. The assembler emits a zero word there. At runtime, the preceding code overwrites it with the correct instruction. If the program is run a second time without reloading, these locations will contain the values from the first run — which may or may not be the same. This is why the program is single-pass: none of the self-modified locations are re-initialized on re-entry.
- **`RIF` and `RDF` read the fields as they are at the moment of execution.** If `CDF 0` has already been issued before `RDF`, it reads 0 — not the field that was current when execution entered the subroutine. The save must precede the first field change.

### Key Learning Points

- `DF` applies only to indirect MRI (`TAD I`, `DCA I`, etc.). Direct MRI always uses IF for both instruction fetch and data access. Cross-field data access requires indirect addressing.
- Field values in `CDF`/`CIF` instructions are encoded in bits 5–3 (`0010` per field). Dynamic instruction construction adds this field word to the base opcode (`6201` for `CDF`, `6202` for `CIF`).
- `CIF` takes effect on the next `JMP` or `JMS` — either direct or indirect. A subroutine call across fields works with direct `JMS`; the return address is stored in the new field automatically.
- For `JMP I` with a pending `CIF`, the pointer fetch uses the current IF; the jump lands in the new IF. Writing the jump target to a known address (address 0) before issuing `CIF CDF` + `JMP I 0` is the standard single-field trampoline idiom.
- A field-safe subroutine must save the caller's IF and DF before changing either, and restore both before returning. `RIF`/`RDF` capture the current values; cross-field indirect writes store them somewhere the subroutine can reach; dynamically built `CDF`/`CIF` instructions reconstruct the return path.
- The write-then-fall-through self-modification pattern is used consistently throughout this program: compute an instruction word, store it into a zeroed placeholder (`CDF1`, `CIF1`, `CDF2`, `CIF2`, `CTRDF`, `CTRIF`, `RETDF`, `RETIF`), and let sequential execution flow through it. What varies between instances is only how the value is computed and what immediately follows.
