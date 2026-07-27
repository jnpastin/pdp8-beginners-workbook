# PDP-8 Programming Workbook

## Purpose

This workbook provides a structured path toward becoming a reasonably strong PDP-8 programmer, both bare metal and within OS/8.

The emphasis is practical programming competence.

Not every topic is equally important.

The workbook distinguishes:

- Core skills
- Foundational deep dives
- Advanced internals

Core skills are required.

Foundational deep dives are taught because they improve future understanding.

Advanced internals are included only where they provide significant value.

---

# Chapter 1 — Core PDP-8 Mental Model

## Goals

- Internalize AC, Link, and memory as system state
- Understand skips and instruction sequencing
- Become fluent at manual tracing

## Exercises

- ✅ Trace a simple add/store program by hand
- ✅ Count from 1–10 and accumulate a sum
- ✅ Rewrite the loop using auto-index registers

---

# Chapter 2 — Control Flow and Subroutines

## Goals

- Understand JMS
- Understand return slots
- Learn subroutine discipline

## Exercises

- ✅ Absolute-value subroutine
- ✅ Compare two values
- ✅ Nested subroutines and state-saving bug fix

---

# Chapter 3 — Rotates, Shifts, and Bit Logic

## Goals

- Treat L:AC as a shift register
- Learn bit manipulation techniques
- Build software shift operations

## Exercises

- ✅ Count bits set in a word
- ✅ Multiply by 10 without EAE
- ✅ Arithmetic right shift

---

# Chapter 4 — Multi-Word Arithmetic

## Goals

- Arithmetic beyond 12 bits
- Carry propagation
- Signed and unsigned arithmetic

## Exercises

- ✅ 24-bit add/subtract
- ✅ Variable-length accumulation
- ✅ Multi-word comparison

---

# Chapter 5 — OS/8 and Extended Memory

## Goals

- Understand IF and DF
- Use CIF and CDF correctly
- Write OS/8-safe programs

## Exercises

- ✅ OS/8-safe exit
- ✅ Field-safe subroutine
- ✅ EAE detection with dual-path arithmetic

---

# Chapter 6 — Direct Device I/O

## Goals

- IOT instructions
- Device flags
- Polled I/O

## Exercises

- ✅ Character output
- ✅ Character input with echo
- ✅ Line-buffered input

## Advanced

- ✅ PTR input
- ✅ PTP output

---

# Chapter 7 — OS/8 Tools and Development Workflow

## Goals

- Understand the development lifecycle
- Become fluent with OS/8 tools
- Understand listings and cross-references

## Exercises

- [ ] PAL → LOAD → SAVE → RUN lifecycle
- [ ] Source changes versus saved images
- [ ] Build workflow using PAL, CREF, PIP, DIR, and FUTIL

## Advanced

- [ ] Automate the workflow using SUBMIT

---

# Chapter 8 — Command Decoder and Program Invocation

## Goals

- Understand how programs are launched
- Understand command expansion
- Understand practical command workflows

## Exercises

- [ ] Compare direct invocation, R, and CCL
- [ ] Trace command expansion
- [ ] Build a workflow using command procedures

---

# Chapter 9 — Loader and Multi-Module Programs

## Goals

- Build larger programs
- Understand loader behavior
- Manage module boundaries

## Exercises

- [ ] Split a program into modules
- [ ] Shared data region
- [ ] Diagnose and repair loader conflicts

---

# Chapter 10 — PAL8 Advanced Source Techniques

## Goals

- Learn PAL macros
- Learn conditional assembly
- Organize larger source bases

## Exercises

- [ ] Create and use a macro
- [ ] Compare macro versus JMS implementation
- [ ] Use conditional assembly

## Advanced

- [ ] Build a reusable macro library

---

# Chapter 11 — OS/8 Programming Model and Interfaces

## Goals

- Understand the practical OS/8 architecture
- Learn runtime programming interfaces
- Understand SYS: and DSK:

## Concepts

Application

↓ Runtime Interfaces

↓ USR

↓ Monitor

↓ Handlers

↓ IOT

↓ Hardware

## Exercises

- [ ] Character-oriented interfaces (ICHR/OCHR)
- [ ] File-oriented interfaces (IOPEN/OOPEN)
- [ ] SYS:, DSK:, and device assignment

---

# Chapter 12 — USR Calls

## Goals

- Use OS/8 services
- Build parameter blocks
- Understand CHAIN

## Exercises

- [ ] Minimal USR call
- [ ] FETCH or INQUIRE
- [ ] CHAIN

## Advanced

- [ ] Field-safe USR wrapper

---

# Chapter 13 — File I/O and Buffers

## Goals

- Practical file processing
- Buffer management
- Text and binary file handling

## Exercises

- [ ] Read a file
- [ ] Write a file
- [ ] Process a file

## Advanced

- [ ] Fixed-length record processing

---

# Chapter 14 — File System, Devices, and Handlers

## Goals

- Understand logical devices
- Understand handler architecture
- Understand storage concepts

## Exercises

- [ ] Analyze directories and allocation
- [ ] SYS:, DSK:, and device assignment
- [ ] Trace a file request through handlers

---

# Chapter 15 — OS/8 Program Artifacts and Internals

## Goals

- Understand PA, LS, BN, and SV
- Understand LOAD versus SAVE
- Understand program lifecycle artifacts

## Exercises

- [ ] Follow PA → LS → BN → LOAD → SAVE → SV
- [ ] Explain why BN and SV are different
- [ ] Demonstrate what SAVE actually captures

## Advanced

- [ ] Decode BN records
- [ ] Decode SV structures

---

# Chapter 16 — Performance and Design Tradeoffs

## Goals

- Make informed design decisions
- Understand PDP-8 resource tradeoffs
- Manage page and field constraints

## Exercises

- [ ] Compare macro, inline, and JMS implementations
- [ ] Compare single-field and multi-field designs
- [ ] Redesign a page-overflowing program

---

# Chapter 17 — Program Architecture

## Goals

- Design maintainable programs
- Create memory maps
- Define interfaces between modules

## Exercises

- [ ] Design a memory layout
- [ ] Define module interfaces
- [ ] Refactor an existing program architecture

## Advanced

- [ ] Design an overlay-capable architecture

---

# Chapter 18 — Debugging and Failure Analysis

## Goals

- Build a systematic debugging process
- Diagnose PDP-8 failures
- Read unfamiliar code

## Exercises

- [ ] Diagnose a bad indirect jump
- [ ] Diagnose a bad OS/8 return
- [ ] Diagnose a program using listing analysis only

## Advanced

- [ ] ODT debugging
- [ ] Reverse-engineer an unfamiliar routine

---

# Chapter 19 — Capstone: Integrated Program

## Goal

Demonstrate practical PDP-8 and OS/8 competency.

## Exercises

- [ ] Design the program
- [ ] Implement the program
- [ ] Test, debug, and document the program

## Requirements

- Multiple source files
- OS/8 services
- File I/O
- Field discipline
- Documented memory map
- Documented module interfaces
- Debugging notes

## Optional Challenge

- [ ] Use macros where appropriate
- [ ] Use CHAIN
- [ ] Include and diagnose an intentional bug

---

# Appendices

## Appendix A — OS/8 Tool Reference

- PAL8
- CREF
- PIP
- FUTIL
- SUBMIT

## Appendix B — PAL8 Macro Reference

## Appendix C — OS/8 Runtime Interface Reference

## Appendix D — USR Reference

## Appendix E — Program Artifact Reference

- PA
- LS
- BN
- SV

## Appendix F — Debugging Checklist
