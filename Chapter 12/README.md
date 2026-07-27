# Chapter 12 - USR Calls

## Status

- 🔲 Not Started

## Goals

- Call OS/8 system services through the USR interface
- Understand parameter blocks and function conventions
- Use FETCH, INQUIRE, and CHAIN with correct field discipline

## Concepts

- USR and its entry convention
- JMS I (7600) as the service entry
- Parameter block layout
- Function codes and returned values
- FETCH and INQUIRE
- CHAIN as a service-mediated transfer
- IF/DF obligations around service calls
- The conceptual role of handlers beneath USR calls

## Exercises

### Exercise 1 - Construct a minimal USR parameter block and invoke a simple OS/8 service

- 🔲 Construct a minimal USR parameter block and invoke a simple OS/8 service. Trace every word in the parameter block before the call, after the call, and at the return point.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Use FETCH or INQUIRE to obtain information about a named file or device

- 🔲 Use FETCH or INQUIRE to obtain information about a named file or device. Display or store the returned information and explain which part depends conceptually on OS/8 device handlers.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Create Program A and Program B

- 🔲 Create Program A and Program B. Program A writes known state, invokes CHAIN to transfer to Program B, and Program B verifies what memory or state survived the transfer. Document which survival assumptions are valid and which are not.

#### Completion Notes

_To be completed after the exercise is implemented._

## Advanced Exercises

- 🔲 Write a reusable, field-safe USR wrapper that saves required field state, performs the service call, restores required state, and documents caller obligations.

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
