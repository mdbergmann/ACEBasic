# ACE Compiler — Evolution of Emitted 68000 Assembly

A historical reference covering how the assembly the compiler produces has
changed since the initial commit (`1bb1031`). Focus is on the emitted output,
not on internal C refactoring of the compiler — except where that refactoring
materially changed what gets emitted.

Dates and commit hashes are taken from `git log`. The repository currently has
~363 commits on `master`.

## Timeline of major emission-affecting changes

| Date       | Commit    | Headline                                                     |
|------------|-----------|--------------------------------------------------------------|
| 2026-01-26 | `41d83d6` | 020 opt (#11) — peephole pass for 68020+ instructions        |
| 2026-02-09 | `02d8941` | Codegen abstraction (Phases 1–6) — `codegen.c` helpers       |
| 2026-02-19 | `90952af` | FFP → IEEE 754 single-precision migration                    |
| 2026-02-19 | `de06436` | Compiler build switch GCC → VBCC                             |
| 2026-02-21 | `d60f75c` | ATOM primitive type (#93)                                    |
| 2026-02-22 | `0372cbf` | Object system: CLASS / METHOD / GENERIC / EXTENDS (#97)      |
| 2026-02-24 | `d4825bc` | TYPECASE type-based pattern matching (#102)                  |
| 2026-02-26 | `a0755a3` | TASKPROC SUB modifier (#114)                                 |
| 2026-02-27 | `9b09a7c` | Bounded string operations (`_strncpy`/`_strncat` w/ size)   |

The big surge of language-level changes happened in February 2026; before that,
work was mainly bug fixes, small features, and incremental tooling improvements.

---

## 1. Codegen abstraction & peephole optimizer (`02d8941`, 2026-02-09)

Before this commit, instruction sequences were spelled out inline at every
call site. The compiler's emitter was effectively `printf` calls littered
across `misc.c`, `assign.c`, `statement.c`, etc. Identical patterns appeared
many times — frame-local addressing, type-aware push/pop, runtime-call
prologues — each with subtle drift.

The commit introduced `src/ace/c/codegen.c` (now ~22 functions) including:

- `gen_frame_addr(address, buf)` — unified frame local addressing
- `gen_push(type, src)` / `gen_pop(type, dest)` / `gen_move_typed(...)` — type-aware stack ops (BYTE/SHORT use `move.w`, LONG/ADDRESS/CLASS use `move.l`)
- `gen_rt_call(funcname)` — runtime (non-library) call helper
- `gen_lib_call`, `gen_lib_open_check`
- `gen_var_addr`, `gen_load_var`, `gen_store_var`
- `gen_coerce_slots`, `gen_float_call`, `gen_bool_test`
- `gen_index_scale`, `gen_ext_to_long`
- `gen_startup_code`, `gen_exit_code`, `gen_asm_header`, `gen_asm_end`

`opt.c` (peephole optimizer) was extended with additional passes covering
patterns that the new helpers exposed more uniformly — e.g. removing redundant
`tst.l` after a `move` to a data register, replacing `add.l #1..#8,Dn` with
`addq`, and using `extb.l` on 68020+ instead of `ext.w` + `ext.l`. The 020
peephole baseline came earlier in `41d83d6` (2026-01-26).

Net effect on output: same intent, but more consistent instruction selection,
fewer redundant `tst`/`cmp`, and slightly smaller binaries.

---

## 2. Floating-point migration: FFP → IEEE 754 (`90952af`, 2026-02-19)

The largest single shift in emitted code. `SINGLE` was originally Motorola
Fast Floating Point (FFP) format using `mathffp.library` and
`mathtrans.library`. The migration moved every float operation onto IEEE 754
single-precision via `mathieeesingbas.library` and `mathieeesingtrans.library`.

What changed in the emitted assembly:

- **LVO names**: every `_LVOSPxxx` reference was renamed to `_LVOIEEESPxxx`
  (`SPAdd → IEEESPAdd`, `SPMul → IEEESPMul`, `SPFlt → IEEESPFlt`, etc.).
- **Library names** in startup: `mathffp.library` / `mathtrans.library` →
  `mathieeesingbas.library` / `mathieeesingtrans.library`.
- **Float literals**: integer constants encoding floats switched format.
  `1.5` went from FFP `$C0000041` to IEEE `$3FC00000`; `0.5` from `$80000040`
  to `$3F000000`; `2.0` from `$80000042` to `$40000000`. These constants are
  embedded in both compiler-emitted code and hand-written runtime asm
  (`gfx.s`, `turtle.s`, `time.s`, `sound.s`, `misc.s`, the math files).
- **Library base symbols**: `_MathBase` and `_MathTransBase` symbol names
  were preserved, but the bases they hold are now the IEEE libraries. This
  kept the diff small and means existing assembly references didn't all need
  renaming.

A related and load-bearing pitfall lives in the runtime: on K&R `float`
parameter declarations, VBCC inserts DP↔SP conversion code that uses
`_MathIeeeDoubTransBase` — which is only opened when the program uses trig.
The fix is to use ANSI `func(float x)` prototypes throughout the runtime so
that path is never taken (recorded in `MEMORY.md` and the runtime asm files).

A subtler issue tracked in `MEMORY.md` (Known Compiler Bugs): if a *module*
uses trig but the main program doesn't reference `_MathTransBase`, the
compiler doesn't open the trans library in startup, and the link-resolved
module XREF leaves the base NULL. Workaround: have the main program use any
trig function. Root cause is in `sym.c:589` where `mathtransused` only flips
on main-program XREF.

---

## 3. Compiler build toolchain: GCC → VBCC (`de06436`, 2026-02-19)

Same day as the IEEE migration. The compiler binary is now built with VBCC
(matching the runtime library toolchain). This affects how the compiler
*itself* runs but not, directly, the assembly it produces — except for
prototyping-related fixes (acedef.h prototypes, `%ld` casts, etc.) that
prevent VBCC implicit-int issues from causing wrong code generation.

VBCC build settings (per `MEMORY.md`):
- `Makefile-ace`: `CC=/vbcc/bin/vc`, `CFLAGS=-c -O2 -cpu=68000`,
  `LDFLAGS=-cpu=68000 -lmieee -lamiga`
- `Makefile-lib`: dual targets — `CPU=68020` default (output `lib/`) and
  `CPU=68000` (output `lib/68000/`, needs `vc.lib`)
- `bas` script auto-detects `OPTION 2-` in source → links 68000 libs +
  `vc.lib`; otherwise 68020 libs.

Tools (`yap`, `parseusing`) carry `OPTION 2-` so they remain runnable on stock
68000 machines.

---

## 4. ATOM primitive type (`d60f75c`, 2026-02-21)

Lightweight symbolic constants. Each ATOM literal lowers to a 32-bit hash
(FNV-1a). They occupy a 4-byte slot at runtime and compare with a single
`cmp.l`. They participate in GENERIC dispatch alongside CLASS types — the
GENERIC dispatch site has a separate fast path for ATOM operands that does
not walk a parent chain (see `dispatch.s`).

---

## 5. Object system: CLASS / METHOD / GENERIC / EXTENDS (`0372cbf`, 2026-02-22)

A large addition. The relevant emission patterns:

### CLASS instance layout

A CLASS instance is allocated like a STRUCT, but with a hidden 4-byte slot at
offset 0 holding a **pointer to the class descriptor** (not the hash itself —
the hash lives inside the descriptor). User members start at offset 4.

The descriptor is emitted once per CLASS in the DATA section by
`declare.c:542–545`:

```
_CLASSDESC_FOO:
    dc.l    $hash, _CLASSDESC_PARENT     ; 0=hash, 4=parent descriptor ptr
```

For a `DIM x AS Foo` style declaration the emitter reserves 4 bytes for the
descriptor pointer and writes it into the BSS block at startup
(`declare.c:620`, `declare.c:662–663`, label form `#_CLASSDESC_<NAME>`).

Member access via `->` compiles to a normal struct member access on the
instance's BSS block — the descriptor pointer at offset 0 is only read when
the runtime needs to do dispatch or `_isa_check`.

### METHOD definition

A METHOD compiles like a SUB but with deterministic linkage label
`_METH_<Name>_<Class>` and is always XDEF'd so cross-module dispatch can
find it. Two-phase parameter parsing scans for class-typed parameters
before emitting the body (so the compiler knows which parameters drive
dispatch).

### GENERIC dispatch

`dispatch.s` provides the runtime dispatch helper, with three paths:

- single CLASS arg → walk parent chain via the descriptor's parent pointer
- single ATOM arg → exact hash match, no walk
- multi-arg → exact match across all dispatch positions

### EXTENDS

`CLASS Foo EXTENDS Bar`:
- copies parent members into the child layout (`copy_struct_members`) so
  member offsets remain consistent across the hierarchy
- chains descriptors: `_CLASSDESC_Foo`'s parent pointer points at
  `_CLASSDESC_Bar`
- runtime parent walk in `dispatch.s` and `isa.s` traverses that chain

Error codes added: 86–89 (CLASS), 90–91 (METHOD), 92–96 (GENERIC), 97
(EXTENDS).

---

## 6. TYPECASE pattern matching (`d4825bc`, 2026-02-24)

A control structure that branches based on the runtime type of a CLASS
expression with narrowing inside each arm. Implementation in
`control.c::typecase_statement`. Notable codegen:

- The switch subject is evaluated **once** into a temporary frame slot
  (`addr[lev] += 4`) holding the descriptor pointer.
- Each arm calls `_isa_check` (in `isa.s`) which walks the parent chain.
- Inside each arm, the type-cased identifier is temporarily rewritten in the
  symbol table so member access compiles against the matched CLASS — the
  emitted offsets reflect the narrowed type.

Error codes: 98–101 (TYPECASE).

---

## 7. TASKPROC SUB modifier (`a0755a3`, 2026-02-26)

A new SUB modifier marking a function as an Exec Task entry point. The
compiler emits a different prologue/epilogue:

- **Prologue**: save scratch registers (`movem.l d1-d7/a0-a6,-(sp)`).
- **Epilogue**: restore the same set, then `Wait(0)` before returning so
  the task does not return-into-thin-air, which is the most common Amiga
  multitasking crash.

Constraints enforced at compile time:

- Error 102 — TASKPROC SUB must have zero parameters.
- Error 103 — TASKPROC SUB cannot be called directly from ACE code (only
  launched through `taskutil::TaskLaunch`).

Files touched: `acedef.h` (taskprocsym), `lexvar.c` (rword[] entry — must
stay alphabetically ordered), `parse.c`, `sub.c`, `lex.c`.

---

## 8. Bounded string operations (`9b09a7c`, 2026-02-27)

Previously, string assignments emitted a call to an unbounded `_strcpy` and
trusted the destination to be `MAXSTRINGSIZE` bytes. With explicit
`STRING x SIZE n` declarations and struct string members of arbitrary size,
that was a buffer-overflow vector.

Post-change emission: every string-write site emits the destination size in
`d1` before calling `_strncpy` / `_strncat` (defined in
`src/lib/asm/simple_str.s`).

Sites updated:

- `assign_to_string_variable` (size from `SYM->size`)
- `assign_to_string_array` (added `element_size` param)
- struct member string assignment (2 sites; size from `STRUCM->strsize`)
- `extvar` string assignment
- string concatenation in `expr.c`
- `LINE INPUT #` (`file.c` emits size in `d1`; `_do_line_input` in `file.s`
  uses `d1` instead of hardcoded `#MAXSTRINGSIZE`)

`SYM->size` defaults to `MAXSTRLEN` in `enter()` (`sym.c:147`) and is
overridden by an explicit `STRING SIZE` in `declare.c`. SWAP strings
(`memory.c`) and COMMON init (`declare.c`) were intentionally left
unchanged.

The earlier `string-buffer-safety` branch (note in `MEMORY.md`) is the
predecessor of this work.

---

## 9. Other notable emitted-code adjustments

These are smaller but have shown up in commits and `MEMORY.md`:

- **CONST SINGLE FFP literals (#76)**: the `CONST` union field was `float`
  not `LONG`, which produced wrong literal bit patterns when read back.
  Fixed by changing the union member type. Branch
  `fix-const-single-type`.
- **String array assignment garbage bytes**: a missing brace block in
  `assign.c`'s `case array` handler. Branch `yap-phase2-directives`.
- **`PRINT #n, ""`**: writes a `0x00` byte before the newline. Documented
  as intentional (CHR$(0) as a file delimiter), not a bug. See `docs/ref.txt`.
- **020 opt (`41d83d6`)**: introduced peephole replacements that only fire
  on 68020+ targets — the modern dual-CPU runtime split (`lib/` vs
  `lib/68000/`) keeps these gated correctly.

---

## 10. Files where emission-related changes concentrate

Compiler side:
- `src/ace/c/misc.c` — historical core of code emission (~13 commits)
- `src/ace/c/codegen.c` — new abstraction layer (`02d8941`+)
- `src/ace/c/expr.c` — float ops, type coercion, concat sizing
- `src/ace/c/sub.c` — SUB / METHOD / TASKPROC prologue/epilogue, dispatch
- `src/ace/c/declare.c` — CLASS descriptors, instance layout, BSS init
- `src/ace/c/control.c` — TYPECASE
- `src/ace/c/assign.c` — bounded string assignments
- `src/ace/c/file.c` — LINE INPUT bounded buffer
- `src/ace/c/opt.c` — peephole passes

Runtime side (`src/lib/asm/`):
- `fmath.s`, `ieee_math.s`, `lmath.s` — float math (post-IEEE)
- `gfx.s`, `turtle.s`, `sound.s`, `time.s` — IEEE float constant rewrites
- `simple_str.s` — bounded `_strncpy` / `_strncat` (`9b09a7c`)
- `dispatch.s`, `isa.s` — object dispatch and parent-chain walk
- `file.s` — `_do_line_input` size-aware buffer
- `startup/startup.s` — IEEE library opening

Specs:
- `specs/ieee-float-migration-phases.txt`, `specs/ieee-float-migration-state.txt`
- `specs/compiler-native-float.txt`
- `specs/compiler-refactoring.txt` / `compiler-refactoring-state.txt`
- `specs/class-method-dispatch-state.txt`
- `specs/exec-tasks.txt` / `exec-tasks-state.txt`
- `specs/httpclient-stateless-refactoring.txt`

---

## Summary

The arc, in one sentence per era:

1. **Pre-2026-02**: Foundational FFP-based BASIC compiler with hand-rolled
   inline emitter; the only major emission improvement was the 020 peephole
   pass.
2. **2026-02-09**: `codegen.c` extracted recurring instruction patterns into
   helpers and the peephole optimizer gained passes that exploit the new
   uniformity.
3. **2026-02-19**: Float subsystem moved from FFP to IEEE 754; the compiler
   itself moved from GCC to VBCC the same day.
4. **2026-02-21 → 02-26**: Object system, ATOM, TYPECASE, and TASKPROC
   landed in quick succession, each adding a distinct emission pattern
   (descriptors, hash literals, narrowing, task-safe prologues).
5. **2026-02-27**: String emission became bounds-checked at every site;
   `d1` is now part of the calling convention for string copies.
