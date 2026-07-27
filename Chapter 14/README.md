# Chapter 14 - File System, Devices, and Handlers

## Status

- 🔲 Not Started

## Goals

- Reason about OS/8 disk behavior and file placement
- Understand logical devices and assignment
- Understand handlers well enough to use and diagnose them

## Concepts

- OS/8 directory structure
- Block allocation and free space
- File size and contiguous allocation concerns
- Logical devices such as SYS: and DSK:
- Device assignment
- Device handlers as OS/8 code modules
- Logical versus physical devices
- Handler-mediated I/O versus direct IOT access

## Exercises

### Exercise 1 - Use DIR, PIP, and FUTIL to inspect a working disk image

- 🔲 Use DIR, PIP, and FUTIL to inspect a working disk image. Map files to sizes and free space, then explain what can and cannot be inferred about allocation from the available tools.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Redirect logical devices and repeat a known program or file workflow

- 🔲 Redirect logical devices and repeat a known program or file workflow. Document exactly which behavior changed because of assignment and which behavior remained tied to the physical device or system device.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Exercise

- 🔲 Trace a file read conceptually from application code through USR, the monitor, a handler, and the underlying hardware. Identify where Chapter 6 direct IOT knowledge fits into the handler-mediated path.

#### Completion Notes

_To be completed after the exercise is implemented._

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
