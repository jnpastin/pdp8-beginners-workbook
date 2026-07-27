# Chapter 16 - Performance and Design Tradeoffs

## Status

- 🔲 Not Started

## Goals

- Make informed design decisions based on PDP-8 resource constraints
- Understand the relative cost of different memory strategies
- Choose between fields, overlays, macros, subroutines, and single-segment designs consciously

## Concepts

- CPU cost versus I/O cost
- Inline code versus JMS subroutines
- Macro expansion versus shared routines
- Single-field programs
- Multi-field programs
- Overlay-like structures
- Page pressure and literal pools
- Memory layout planning before coding

## Exercises

### Exercise 1 - Implement a small operation three ways: inline, macro-expanded, and JMS subroutine

- 🔲 Implement a small operation three ways: inline, macro-expanded, and JMS subroutine. Compare word count, execution cost, readability, and the effect on AC, Link, and DF discipline.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Exercise

- 🔲 Take one medium program design and sketch three layouts: single-field, multi-field, and overlay-like. Explain the tradeoffs in field switching, I/O cost, resident memory use, and complexity.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Start with a program that overflows or nearly overflows a page

- 🔲 Start with a program that overflows or nearly overflows a page. Redesign the layout using page planning, literal management, or module movement rather than merely shortening comments or labels.

#### Completion Notes

_To be completed after the exercise is implemented._

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
