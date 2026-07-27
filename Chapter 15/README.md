# Chapter 15 - OS/8 Program Artifacts and Internals

## Status

- 🔲 Not Started

## Goals

- Understand why OS/8 uses multiple program artifacts
- Understand LOAD and SAVE at a conceptual and practical level
- Gain foundational knowledge of program representation without requiring daily binary archaeology

## Concepts

- Source versus executable representation
- .PA source files
- .LS listings and symbol tables
- .BN binary loader files
- .SV saved executable images
- Loader records and origins
- Live memory images
- SAVE as memory capture
- Why .EX is historical context rather than a required local artifact unless present on the system

## Exercises

### Exercise 1 - Follow one program through PA -> LS -> BN -> LOAD -> SAVE -> SV

- 🔲 Follow one program through PA -> LS -> BN -> LOAD -> SAVE -> SV. For each stage, document what information exists, what information is lost, and which tool consumes or produces the artifact.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Compare a program's BN file and SV image at a practical level

- 🔲 Compare a program's BN file and SV image at a practical level. Explain why both exist, why BN is loader input rather than a memory image, and why SV is executable without re-running the loader workflow.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Exercise

- 🔲 Load a program, alter a memory word before SAVE, save the program, and prove that the SV image captured the live modified state. Explain why this matters for debugging and patching.

#### Completion Notes

_To be completed after the exercise is implemented._

## Advanced Exercises

- 🔲 Decode enough BN loader records to map origins and data words back to the listing.
- 🔲 Decode enough SV structure to identify the entry point, captured segments, and stored memory words for a simple saved program.

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
