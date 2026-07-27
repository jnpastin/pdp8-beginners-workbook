# Chapter 9 - Loader and Multi-Module Programs

## Status

- 🔲 Not Started

## Goals

- Build larger programs from multiple source files
- Understand how the loader combines modules
- Manage module boundaries, origins, symbols, and shared data

## Concepts

- Multi-file PAL invocation
- Loader merging of binary modules
- Absolute origins and address ownership
- Shared data regions
- Symbol ownership and naming discipline
- Cross-file references and failure modes
- Module interface documentation

## Exercises

### Exercise 1 - Split an existing working program into MAIN and UTILITY modules

- 🔲 Split an existing working program into MAIN and UTILITY modules. Assemble and load the modules together, then document the public entry points, private labels, and which module owns each page or data area.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Build a three-module program with MAIN, UTILITY, and COMMON data

- 🔲 Build a three-module program with MAIN, UTILITY, and COMMON data. The modules must communicate through a documented shared data region, with explicit rules for initialization, ownership, and modification.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Intentionally create both an origin overlap and a symbol ownership problem

- 🔲 Intentionally create both an origin overlap and a symbol ownership problem. Capture the observed assembler or loader failure, explain the cause, and repair the layout or naming contract.

#### Completion Notes

_To be completed after the exercise is implemented._

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
