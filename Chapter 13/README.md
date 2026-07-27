# Chapter 13 - File I/O and Buffers

## Status

- 🔲 Not Started

## Goals

- Read and write files through OS/8
- Manage buffers correctly in memory
- Handle binary and ASCII data deliberately

## Concepts

- OS/8 file access model
- Open, read, write, and close style call sequences where available
- Buffer placement and alignment
- Field constraints on buffers
- Binary word data versus packed ASCII text
- Sequential record processing
- Error handling and cleanup paths

## Exercises

### Exercise 1 - Read a binary file into a buffer at a documented address

- 🔲 Read a binary file into a buffer at a documented address. Verify the buffer contents independently with FUTIL, PIP, a listing, or a controlled dump so the exercise proves the read, not just the absence of an error.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Exercise

- 🔲 Generate a known data pattern in memory, write it to a new file, and verify the output file with OS/8 tools. Include at least one failure or overwrite case and document the expected behavior.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Exercise

- 🔲 Read an ASCII text file and produce useful statistics, such as line count, word count, record count, or character class counts. Document how packed text representation affects processing.

#### Completion Notes

_To be completed after the exercise is implemented._

## Advanced Exercises

- 🔲 Process a fixed-length record file and generate a small report, including record count, selected fields, and validation of malformed or partial records.

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
