# Chapter 17 - Program Architecture

## Status

- 🔲 Not Started

## Goals

- Design maintainable PDP-8 programs before coding
- Create memory maps and module contracts
- Separate code, data, buffers, OS interfaces, and diagnostic state

## Concepts

- Memory maps as design artifacts
- Page ownership
- Field ownership
- Module interfaces
- Shared data regions
- Buffer contracts
- DF discipline across modules
- Error paths and cleanup paths
- Documented assumptions and invariants

## Exercises

### Exercise 1 - Design a complete memory map for a medium-sized program before writing code

- 🔲 Design a complete memory map for a medium-sized program before writing code. Include fields, pages, buffers, page-zero use, auto-index locations, literals, and OS/8 interface regions.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Exercise

- 🔲 Define module interfaces for a multi-module program, including entry points, input state, output state, destroyed registers, field assumptions, and shared data ownership.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Refactor an earlier working program to follow the documented architecture

- 🔲 Refactor an earlier working program to follow the documented architecture. Verify that the refactor preserves behavior while improving layout clarity and maintainability.

#### Completion Notes

_To be completed after the exercise is implemented._

## Advanced Exercises

- 🔲 Design an overlay-capable architecture, including root code, overlay region, preserved data, destroyed data, and load contracts.

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
