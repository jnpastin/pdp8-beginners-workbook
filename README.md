# PDP-8 Programming Workbook

A structured, progressive workbook for learning to write real PDP-8 programs in PAL8 assembly, from first principles through OS/8 application programming and system-level debugging.

The workbook is built around a PiDP-8/I running OS/8, but the programming principles apply broadly to PDP-8 systems with PAL8, extended memory, and OS/8-style tooling.

## Purpose

The goal is practical competence. A student who completes the workbook should be able to:

- Write and trace PDP-8 assembly programs.
- Use AC, Link, memory, pages, auto-index registers, and JMS subroutines correctly.
- Manage OS/8 program entry and exit discipline.
- Use extended memory through IF, DF, CIF, and CDF.
- Program basic devices directly using IOT instructions.
- Use the OS/8 toolchain to assemble, load, save, inspect, and run programs.
- Build multi-file programs.
- Call OS/8 services through USR.
- Perform file I/O with correct buffer discipline.
- Diagnose common PDP-8 and OS/8 failures using listings, front-panel inspection, and field-state reasoning.
- Design a non-trivial PDP-8 program with a documented memory layout and module structure.

## Repository Structure

Each chapter directory contains:

- `README.md` - goals, exercise descriptions, implementation rationale, non-intuitive points, and key learning points.
- `EXn.PA` - PAL8 source files, where present.
- `EXn.LS` - PAL8 listing files, where present.
- Supporting dumps, notes, or analysis files when an exercise requires file or memory inspection.

Top-level documents:

- [Workbook Plan](WoorkBook.md) - full chapter plan, progress tracking, and required versus advanced material.
- [Style and Conventions](Style_and_Conventions.md) - coding standards, idioms, review checklist, and documentation rules.

## Chapter Overview

| Chapter | Topic | Status |
|---:|---|---|
| 1 | Core PDP-8 Mental Model | Complete |
| 2 | Control Flow and Subroutines | Complete |
| 3 | Rotates, Shifts, and Bit Logic | Complete |
| 4 | Multi-Word Arithmetic | Complete |
| 5 | OS/8 and Extended Memory | Complete |
| 6 | I/O Programming: TTY, PTR, and PTP | Complete |
| 7 | OS/8 Tools and Program Lifecycle | In progress |
| 8 | File Formats: PA, LS, BN, and SV | Not started |
| 9 | Loader and Multi-File Programs | Not started |
| 10 | Control-Flow and Field Failure Modes | Not started |
| 11 | USR Calls and CHAIN | Not started |
| 12 | File I/O and Buffers | Not started |
| 13 | File System and Logical Devices | Not started |
| 14 | Device Handlers | Not started |
| 15 | Overlays | Not started |
| 16 | Performance and Design Tradeoffs | Not started |
| 17 | Program Architecture | Not started |
| 18 | Debugging and Failure Analysis | Not started |
| 19 | Capstone: Integrated Program | Not started |

## Learning Path

The workbook is organized into four phases.

### Phase 1 - Bare-Machine Programming

Chapters 1-4 build the PDP-8 mental model: instruction tracing, skips, subroutines, rotates, bit logic, auto-indexing, and multi-word arithmetic.

### Phase 2 - Machine/OS Boundary

Chapters 5-6 introduce OS/8-safe execution, extended memory, field discipline, EAE detection, and direct device programming through IOT instructions.

### Phase 3 - OS/8 Application Programming

Chapters 7-12 cover practical OS/8 development: tools, file formats, loader behavior, multi-file programs, failure modes, USR calls, CHAIN, and file I/O.

### Phase 4 - Larger-System Design

Chapters 13-19 cover logical devices, handlers, overlays, tradeoffs, architecture, debugging, and the integrated capstone program.

## Required and Advanced Material

Most chapters contain core material required for later work. Some exercises are intentionally advanced and are retained to build deeper system understanding.

Required material includes instruction tracing, JMS subroutines, auto-indexing, Link discipline, page management, OS/8 exit discipline, IF/DF handling, polled I/O, OS/8 workflow, USR calls, file I/O, and debugging.

Advanced material includes detailed `.BN` and `.SV` decoding, dynamic construction of CIF/CDF instructions, complex cross-field return paths, deep handler behavior, overlay performance analysis, and storage allocation inspection.

Advanced exercises should be understood as systems-programming depth. Later core chapters should not depend on advanced internals unless the dependency is explicit.

## Documentation Standards

Chapter documentation follows the structure defined in [Style and Conventions](Style_and_Conventions.md):

- Goals.
- Exercise title.
- What It Does.
- Implementation Rationale.
- Non-Intuitive Points for Beginners.
- Key Learning Points.

Source and listing files follow PAL8-oriented formatting rules: uppercase labels, fixed columns, octal notation, page-aware layout, explicit field discipline, and intent-focused comments.

## Current Design Notes

The chapter sequence intentionally separates related but distinct ideas:

- Tool workflow is separated from file-format internals.
- File-format inspection is separated from multi-module loader behavior.
- CHAIN is placed after USR calls, because it depends on OS/8 service conventions.
- Control-flow and field hazards are treated as debugging/failure modes after the underlying field mechanics have already been introduced.
- Device handlers come after file I/O and logical devices, because handlers are easier to understand once OS/8-mediated I/O is concrete.
- Overlays come after USR and file I/O, because runtime loading depends on those mechanisms.

## License

Personal learning repository. Code and notes may be reused freely unless otherwise stated.
