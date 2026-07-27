# PDP-8 Programming Workbook

A structured, progressive workbook for learning to write real PDP-8 programs in PAL8 assembly, from first principles through practical OS/8 programming.

Built around a PiDP-8/I running OS/8.

## Goal

Have enough practical knowledge to be a reasonably strong PDP-8 programmer, both bare metal and within OS/8.

## Structure

Each chapter directory contains:

- `README.md` - goals, concepts, exercise descriptions, implementation rationale, and key learning points.
- `EXn.PA` - PAL8 source files where present.
- `EXn.LS` - assembler listing files where present.
- Additional notes, dumps, and supporting material where appropriate.

Top-level files:

- [Workbook Plan](WoorkBook.md) - full exercise plan, concepts, progress tracking, and appendices.
- [Style and Conventions](Style_and_Conventions.md) - coding, review, and documentation standards.

## Chapters

| Chapter | Topic | Status |
|---:|---|---|
| 1 | [Core PDP-8 Mental Model](Chapter%201/README.md) | ✅ Complete |
| 2 | [Control Flow and Subroutines](Chapter%202/README.md) | ✅ Complete |
| 3 | [Rotates, Shifts, and Bit Logic](Chapter%203/README.md) | ✅ Complete |
| 4 | [Multi-Word Arithmetic](Chapter%204/README.md) | ✅ Complete |
| 5 | [OS/8 and Extended Memory](Chapter%205/README.md) | ✅ Complete |
| 6 | [I/O Programming: TTY, PTR, PTP](Chapter%206/README.md) | ✅ Complete |
| 7 | [OS/8 Tools and Development Workflow](Chapter%207/README.md) | 🔲 Not Started |
| 8 | [Command Decoder and Program Invocation](Chapter%208/README.md) | 🔲 Not Started |
| 9 | [Loader and Multi-Module Programs](Chapter%209/README.md) | 🔲 Not Started |
| 10 | [PAL8 Advanced Source Techniques](Chapter%2010/README.md) | 🔲 Not Started |
| 11 | [OS/8 Programming Model and Interfaces](Chapter%2011/README.md) | 🔲 Not Started |
| 12 | [USR Calls](Chapter%2012/README.md) | 🔲 Not Started |
| 13 | [File I/O and Buffers](Chapter%2013/README.md) | 🔲 Not Started |
| 14 | [File System, Devices, and Handlers](Chapter%2014/README.md) | 🔲 Not Started |
| 15 | [OS/8 Program Artifacts and Internals](Chapter%2015/README.md) | 🔲 Not Started |
| 16 | [Performance and Design Tradeoffs](Chapter%2016/README.md) | 🔲 Not Started |
| 17 | [Program Architecture](Chapter%2017/README.md) | 🔲 Not Started |
| 18 | [Debugging and Failure Analysis](Chapter%2018/README.md) | 🔲 Not Started |
| 19 | [Capstone: Integrated Program](Chapter%2019/README.md) | 🔲 Not Started |

## Learning Path

### Phase 1 - Bare Machine Programming

Chapters 1 through 4 establish AC, Link, memory, instruction sequencing, subroutines, bit operations, and multi-word arithmetic.

### Phase 2 - Hardware and OS Boundary

Chapters 5 and 6 introduce OS/8-safe execution, extended memory, fields, and direct device I/O.

### Phase 3 - Practical OS/8 Programming

Chapters 7 through 14 cover OS/8 workflow, command invocation, multi-module development, macros, runtime interfaces, USR calls, file I/O, devices, and handlers.

### Phase 4 - Design and Mastery

Chapters 15 through 19 cover program artifacts, performance tradeoffs, architecture, debugging, and the integrated capstone.

## Philosophy

The workbook focuses on practical competency. Deep dives are retained where they provide foundational value for future programming decisions.
