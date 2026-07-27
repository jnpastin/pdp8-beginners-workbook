# Chapter 7 - OS/8 Tools and Development Workflow

## Status

- 🔲 Not Started

## Goals

- Become fluent with the OS/8 development cycle
- Understand what each tool consumes and produces
- Distinguish source, binary loader output, live memory, and saved executable images

## Concepts

- PAL8 source files (.PA)
- Listing files (.LS)
- Binary loader files (.BN)
- Saved images (.SV)
- CREF cross-reference listings
- LOAD, SAVE, GET, START, RUN, and R
- DIR, PIP, and FUTIL as everyday inspection tools
- The difference between assembling, loading, saving, and running

## Exercises

### Exercise 1 - Exercise

- 🔲 Create a small versioned program, then perform the full PAL -> LOAD -> SAVE -> RUN -> GET -> START lifecycle. After each command, document what changed on disk, what changed in memory, and what command would be needed to execute the current version.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 2 - Exercise

- 🔲 Modify the source so the program visibly identifies a new version, assemble it, and prove that RUN still executes the old saved image until LOAD and SAVE are repeated. Then modify one core word after LOAD but before SAVE and prove that SAVE captures the modified live image.

#### Completion Notes

_To be completed after the exercise is implemented._

### Exercise 3 - Exercise

- 🔲 Build the same program using PAL and CREF, then use DIR, PIP, and FUTIL to inspect the generated files. Identify symbol definitions, symbol references, file sizes, and which artifact each tool consumes or produces.

#### Completion Notes

_To be completed after the exercise is implemented._

## Advanced Exercises

- 🔲 Automate the assemble, cross-reference, load, save, and verification workflow using SUBMIT or the closest available OS/8 command procedure mechanism.

## Chapter Notes

_Implementation rationale, non-intuitive points, and key learning points will be added as exercises are completed._
