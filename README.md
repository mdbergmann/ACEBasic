# ACE - Amiga BASIC Compiler

ACE is a complete BASIC compiler for the Amiga computer platform. It compiles BASIC source code into native Amiga executables by generating Motorola 68000 assembly code, bridging BASIC's ease of use with compiled performance.

Released under the GNU General Public License (GPL v2) in 1998.

## Features

- **Full type system** - Integers, single/double precision floats, strings, arrays, pointers, and structures
- **Amiga Intuition GUI integration** - Windows, menus, gadgets, and requesters
- **Graphics primitives** - Lines, circles, areas, and turtle graphics
- **File I/O** - Sequential and random access file operations
- **Event-driven programming** - Event traps and handlers
- **External library calls** - Access AmigaDOS and shared library functions
- **Sound support** - Audio playback and speech synthesis
- **Serial communication** - Serial port access
- **IFF picture support** - Load and display Amiga IFF images

## Project Structure

| Directory | Description |
|-----------|-------------|
| `src/ace/c/` | ACE compiler source (lexer, parser, code generator) |
| `src/lib/` | Runtime library (db.lib) source |
| `include/` | Amiga system header files |
| `prgs/` | Example programs (30+ categories) |
| `utils/` | Utility programs (fd2bmap, convert2ace, etc.) |
| `docs/` | Documentation files |
| `make/` | Build scripts (ARexx) |

## Technologies

- **Languages**: C (K&R style) and Motorola 68000 assembly
- **Target Platform**: Amiga 1.3, 2.x, 3.x
- **Assembler**: vasm (vasmm68k_mot)
- **Linker**: vlink
- **Amiga APIs**: Exec, Dos, Graphics, Intuition, Diskfont, DataTypes, Rexx

## Documentation

- `ace.doc` / `ace.guide` - Main reference documentation
- `ref.guide` - Language reference guide
- `ACE_Tutorial.guide` - Tutorial for beginners
- `docs/` - Additional materials and developer notes

## Example Programs

The `prgs/` directory contains extensive examples organized by category:

- **Games** - Game implementations
- **Graphics** - Graphics demonstrations
- **GUI** - Interface examples
- **Fractals** - Mathematical visualizations
- **Turtle** - Logo-style turtle graphics
- **Astronomy** - Scientific calculations
- **Benchmarks** - Performance tests
- **File operations** - File I/O examples
- **Network/Ports** - Communications examples

## Build Pipeline

```
Source (.bas) → Preprocess (app) → Compile (ace) → Assemble (vasm) → Link (vlink) → Executable
```

## License

This project is licensed under the GNU General Public License v2. See the license file for details.

## History

ACE was originally developed between 1991-1996 and released as open source in 1998. It provides functionality comparable to Microsoft QuickBASIC or Turbo BASIC, specifically designed for Amiga development with full integration into the Amiga's native windowing and graphics systems.
