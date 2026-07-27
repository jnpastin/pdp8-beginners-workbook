# Chapter 18 - Debugging and Failure Analysis

## Status

- 🔲 Not Started

## Goals

- Recover from real PDP-8 and OS/8 program failures
- Apply a systematic diagnostic workflow
- Use front-panel, listing, and instruction-level tools effectively

## Concepts

- Common failure signatures
- Bad indirect jumps
- Wrong IF or DF assumptions
- Bad OS/8 return paths
- CIF deferred-effect bugs
- Return-slot corruption
- HLT as a checkpoint
- RDF and RIF for field inspection
- ODT as a debugging tool
- Listing-driven trace reconstruction

## Exercises

### Exercise 1 - Introduce a bad indirect jump or wrong-page control transfer into a working program

- 🔲 Introduce a bad indirect jump or wrong-page control transfer into a working program. Diagnose it using the listing, memory inspection, and field-state reasoning, then repair it.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Reproduce a bad OS/8 return or field-state failure deliberately

- 🔲 Reproduce a bad OS/8 return or field-state failure deliberately. Trace the return path backward and identify whether the error is IF, DF, CIF timing, or an invalid indirect jump.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Given a broken program and listing, diagnose the failure without running it

- 🔲 Given a broken program and listing, diagnose the failure without running it. Produce a trace that identifies the first incorrect assumption and the minimal code change required.

#### Completion Notes

_To be completed after the exercise is implemented._

## Advanced Exercises

- 🔲 Use ODT to inspect memory, patch a small bug, and continue execution.
- 🔲 Reverse-engineer an unfamiliar PDP-8 routine and document what it does, what assumptions it makes, and how it should be called.

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
