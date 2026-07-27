# Chapter 11 - OS/8 Programming Model and Interfaces

## Status

- 🔲 Not Started

## Goals

- Understand where an application program fits within OS/8
- Learn practical OS/8 runtime interfaces before raw USR programming
- Understand SYS:, DSK:, and logical-device behavior

## Concepts

- Application programs
- Runtime support routines
- USR as the OS/8 service boundary
- Monitor and resident OS services
- Device handlers as an abstraction layer
- ICHR and OCHR style character interfaces
- IOPEN and OOPEN style file interfaces
- SYS:, DSK:, and device assignment

## Exercises

### Exercise 1 - Exercise

- 🔲 Rewrite a Chapter 6 character I/O style program to use OS/8 character-oriented runtime routines such as ICHR and OCHR, if available in the local environment. Compare the result with direct KSF/KRB and TSF/TLS code.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Exercise

- 🔲 Use available file-oriented runtime routines, such as IOPEN and OOPEN, to open or prepare access to a file and display, copy, or summarize its contents. Document the calling sequence and what state must be set before the call.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Exercise

- 🔲 Move a program and its data between SYS: and DSK:, alter logical-device assignments, and verify how program lookup, file lookup, and default output behavior change.

#### Completion Notes

_To be completed after the exercise is implemented._

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
