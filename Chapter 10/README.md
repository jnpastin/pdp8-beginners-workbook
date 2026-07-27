# Chapter 10 - PAL8 Advanced Source Techniques

## Status

- 🔲 Not Started

## Goals

- Use PAL8 as a source-level programming tool, not only an assembler
- Use macros and conditional assembly without hiding the machine model
- Understand source organization techniques used by larger PAL8 programs

## Concepts

- Macro definitions
- Macro parameters
- Macro expansion in listings
- Conditional assembly
- Symbolic configuration
- Macro versus JMS tradeoffs
- Reusable source include patterns where available

## Exercises

### Exercise 1 - Exercise

- 🔲 Refactor duplicated instruction sequences from an earlier program into one or more PAL8 macros. Use the listing to show the expanded generated code and verify that the macro hides no required machine behavior.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Implement the same operation both as a macro and as a JMS subroutine

- 🔲 Implement the same operation both as a macro and as a JMS subroutine. Compare generated code size, execution path, AC/Link effects, maintainability, and when each form is preferable.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Exercise

- 🔲 Use conditional assembly or symbolic configuration to produce two variants of one program from the same source base, such as direct TTY I/O versus a diagnostic HLT path.

#### Completion Notes

_To be completed after the exercise is implemented._

## Advanced Exercises

- 🔲 Build a small reusable macro library for common local idioms and use it in two separate programs without making later chapters depend on the library.

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
