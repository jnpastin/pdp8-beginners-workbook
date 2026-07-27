# PDP-8 Programming Workbook

A structured, progressive workbook for learning to write real PDP-8 programs in PAL8 assembly, from first principles through practical OS/8 application development.

Built around a PiDP-8/I running OS/8.

---

## Goal

The objective of this workbook is:

> Have enough practical knowledge to be a reasonably strong PDP-8 programmer, both bare metal and within OS/8.

Upon completion, the student should be able to:

- Write and debug non-trivial PDP-8 assembly programs
- Understand AC, Link, pages, fields, and memory layout
- Use JMS and subroutine conventions correctly
- Work confidently with IF, DF, CIF, and CDF
- Use direct device I/O through IOT instructions
- Use PAL8, CREF, PIP, FUTIL, SUBMIT, and related OS/8 tooling
- Build and maintain multi-module programs
- Use OS/8 runtime interfaces and USR services
- Read and write files under OS/8
- Diagnose control-flow, field, and OS/8 return failures
- Design maintainable PDP-8 software with documented architecture

---

## Repository Structure

Each chapter contains:

- `README.md`
- `EXn.PA`
- `EXn.LS`
- Additional notes, dumps, and supporting material where appropriate

Top-level files:

- `Workbook.md` — overall workbook plan
- `Style_and_Conventions.md` — coding, review, and documentation standards

---

## Progress

| Chapter | Topic | Status |
|----------|----------|----------|
| 1 | Core PDP-8 Mental Model | ✅ Complete |
| 2 | Control Flow and Subroutines | ✅ Complete |
| 3 | Rotates, Shifts, and Bit Logic | ✅ Complete |
| 4 | Multi-Word Arithmetic | ✅ Complete |
| 5 | OS/8 and Extended Memory | ✅ Complete |
| 6 | Direct Device I/O | ✅ Complete |
| 7 | OS/8 Tools and Development Workflow | 🔲 Not Started |
| 8 | Command Decoder and Program Invocation | 🔲 Not Started |
| 9 | Loader and Multi-Module Programs | 🔲 Not Started |
| 10 | PAL8 Advanced Source Techniques | 🔲 Not Started |
| 11 | OS/8 Programming Model and Interfaces | 🔲 Not Started |
| 12 | USR Calls | 🔲 Not Started |
| 13 | File I/O and Buffers | 🔲 Not Started |
| 14 | File System, Devices, and Handlers | 🔲 Not Started |
| 15 | OS/8 Program Artifacts and Internals | 🔲 Not Started |
| 16 | Performance and Design Tradeoffs | 🔲 Not Started |
| 17 | Program Architecture | 🔲 Not Started |
| 18 | Debugging and Failure Analysis | 🔲 Not Started |
| 19 | Capstone: Integrated Program | 🔲 Not Started |

---

## Learning Path

### Phase 1 — Bare Machine Programming

Chapters 1–4

- PDP-8 architecture
- Control flow
- Subroutines
- Arithmetic
- Bit manipulation

### Phase 2 — Hardware and OS Boundary

Chapters 5–6

- Extended memory
- Fields
- OS/8 execution conventions
- Direct I/O

### Phase 3 — Practical OS/8 Programming

Chapters 7–14

- Development workflow
- Command invocation
- Multi-module development
- PAL8 macros
- OS/8 runtime interfaces
- USR
- File I/O
- Devices and handlers

### Phase 4 — Design and Mastery

Chapters 15–19

- Program artifacts
- Performance
- Architecture
- Debugging
- Capstone

---

## Philosophy

The PDP-8 rewards clarity, discipline, and precision.

This workbook focuses on practical competency rather than historical trivia or operating-system implementation details. Deep dives are included where they provide foundational understanding that improves future programming decisions.
