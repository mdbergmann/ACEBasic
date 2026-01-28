# Closure Implementation Plan for ACE Basic

## Problem Summary

ACE Basic has no first-class functions. You cannot store a reference to a SUB in a variable, pass it as an argument, or capture variables from an enclosing scope. The goal is to add closures — callable values that enclose over their environment.

## Current Architecture Constraints

- **Two-level scope only**: Level 0 (main, frame `a4`) and Level 1 (SUB, frame `a5`). No nested SUBs.
- **Single-pass compiler**: No second pass to retroactively change variable storage.
- **No GC**: `ACEalloc` allocates heap memory; `free_alloc()` frees everything at exit. No individual free or reference counting.
- **Existing indirect call**: `CALL variable(args)` where variable is LONGINT generates `move.l var,a0; jsr (a0)` — but discards the return value and has no type safety (`statement.c:460-491`).
- **Existing address-of**: `@SUB_name` pushes the code address of a SUB as a LONGINT (`basfun.c:1574`).

## Approach: Two-Phase Implementation

### Why not reference capture?

Reference capture (JavaScript/Python-style) requires "boxing" variables on the heap and changing how ALL accesses to that variable are generated. This conflicts with the single-pass compiler architecture and would require invasive changes to every variable access path. Too risky.

### Recommended: Function pointers (Phase 1) + Value-capture closures via BIND (Phase 2)

Value capture (like C++ `[=]`) copies values at closure-creation time. No variable access changes needed. Uses existing `ACEalloc` for heap records.

---

## Phase 1: INVOKE — Indirect Calls with Return Values

**Goal**: Allow calling through a function pointer variable and capturing the return value in an expression.

### Syntax

```basic
DECLARE SUB LONGINT Add(LONGINT a, LONGINT b)

SUB LONGINT Add(LONGINT a, LONGINT b)
  Add = a + b
END SUB

funcPtr& = @Add
result& = INVOKE funcPtr&(3, 4)    ' result = 7

' Also works as a statement (discard return value):
INVOKE funcPtr&(3, 4)
```

### Why INVOKE and not overloading CALL?

CALL already dispatches through the mc-subroutine path for LONGINT variables, but it discards d0 and can't appear in expressions. Adding a new keyword avoids breaking existing semantics and makes the intent explicit.

### Implementation

**`acedef.h`** — Add `invokesym` to the ACE-specific reserved words enum (alphabetically between `inputboxstrsym` and `integerkindsym`).

**`lexvar.c`** — Add `"INVOKE"` to `rword[]` in the ACE-specific section (alphabetically between `"INPUTBOX$"` and `"INTEGER_KIND"`).

**`statement.c`** — Add an `invokesym` case in the statement dispatcher. When `sym == invokesym`:
1. `insymbol()` to get the variable name
2. Verify it exists as a LONGINT/ADDRESS variable (or later, a closure)
3. If `(` follows, parse and push arguments using the existing `load_mc_params` pattern
4. Generate: `move.l -N(frameptr),a0; jsr (a0); add.l #popcount,sp`
5. If the variable has a linked SUB signature (via `other` field), type-check arguments

**`factor.c`** — Add handling so INVOKE can appear in expression context:
1. When `sym == invokesym` is encountered in `factor()`:
   - Parse identically to the statement version
   - After `jsr (a0)`, push d0 onto the expression stack: `move.l d0,-(sp)` or `move.w d0,-(sp)` depending on the SUB's return type
   - Return the appropriate type

**`sym.c` / symbol table** — When `funcPtr& = @SubName`, the compiler can store a cross-reference to the SUB's SYM node in the variable's `other` field. This enables type checking at INVOKE sites without a new type. No changes to SYM struct needed — `other` already exists.

### Assembly Output Example

```asm
; funcPtr& = @Add
pea     _SUB_Add
move.l  (sp)+,-4(a4)         ; store in funcPtr& frame slot

; result& = INVOKE funcPtr&(3, 4)
move.l  #3,-(sp)             ; push arg 1
move.l  #4,-(sp)             ; push arg 2
move.l  -4(a4),a0            ; load funcPtr&
jsr     (a0)                 ; indirect call
addq    #8,sp                ; pop 2 x 4-byte args
move.l  d0,-(sp)             ; push return value for expression
; ... assignment stores (sp)+ into result& ...
```

### Files Changed

| File | Change |
|------|--------|
| `src/ace/c/acedef.h:320` | Add `invokesym` to enum |
| `src/ace/c/lexvar.c:102` | Add `"INVOKE"` to `rword[]` |
| `src/ace/c/statement.c` | Add `invokesym` case (~30 lines) |
| `src/ace/c/factor.c` | Add `invokesym` handling in `factor()` (~30 lines) |

---

## Phase 2: BIND — Value-Capture Closures

**Goal**: Create callable objects that pre-bind some arguments to a SUB.

### Syntax

```basic
SUB LONGINT AddN(LONGINT n, LONGINT x)
  AddN = n + x
END SUB

' Bind first argument, creating a closure
adder& = BIND(@AddN, 5)

' Invoke — only pass the unbound args
result& = INVOKE adder&(10)     ' calls AddN(5, 10) => 15

' Pass closure to another SUB
CALL UseCallback(adder&)

SUB UseCallback(ADDRESS cb&)
  PRINT INVOKE cb&(20)          ' prints 25
END SUB
```

### Closure Record Layout (heap-allocated)

```
Offset  Size  Field
------  ----  -----
0       4     Magic marker (0x434C5352 = "CLSR")
4       4     Function pointer (address of _SUB_name)
8       2     Total param count of the SUB
10      2     Number of bound arguments
12      2     Return type of the SUB
14      2*N   Type of each bound arg (shorttype/longtype/singletype/stringtype)
14+2*N  var   Values of bound args (2 bytes for short, 4 bytes for long/single/string)
```

### How INVOKE Dispatches

INVOKE checks whether the variable points to a raw code address or a closure record by reading the first 4 bytes and comparing against the magic marker:

```asm
move.l  -N(a4),a2            ; load the variable
cmp.l   #$434C5352,(a2)      ; is it a closure record?
bne.s   _raw_call_NNN        ; no -> raw indirect call

; --- closure dispatch ---
; Read bound_count from offset 10
move.w  10(a2),d4
; Push bound args from closure record onto stack (unrolled at compile time if signature known)
; Push free args from INVOKE argument list
; Load func_ptr from offset 4
move.l  4(a2),a0
jsr     (a0)
; Clean up stack, push return value
bra.s   _done_NNN

_raw_call_NNN:
; --- raw function pointer dispatch ---
move.l  a2,a0
jsr     (a0)
; Clean up stack, push return value

_done_NNN:
```

**Optimization**: If the compiler can statically determine at compile time that a variable always holds a closure (e.g., it was assigned from BIND), skip the runtime check and always use the closure dispatch path.

### BIND Implementation

BIND is a built-in function returning LONGINT (the closure address):

1. Parse `BIND(@SubName, expr1, expr2, ...)`
2. First arg must evaluate to a SUB address — look up the SUB's SYM entry to get parameter info
3. Remaining args are the bound values — evaluate each, type-check against SUB's `p_type[]`
4. Calculate record size: `14 + 2*bound_count + sum_of_value_sizes`
5. Generate code to:
   - Call `ACEalloc(size, 9)` for heap allocation
   - Fill magic, func_ptr, total_params, bound_count, return_type
   - Store bound arg types and values
   - Push the record address as the result

### Capturing Local Variables (the "closure" part)

When BIND is called inside a SUB:

```basic
SUB MakeAdder(LONGINT n)
  adder& = BIND(@AddN, n)      ' captures current value of n
  MakeAdder = adder&
END SUB
```

`n` is evaluated as a normal expression at BIND time — its current value is read from the stack frame and copied into the heap-allocated closure record. After the SUB returns and its stack frame is destroyed, the closure record persists on the heap with the captured value. This is value capture — subsequent changes to `n` (if any) would not be reflected.

### String Capture

Strings require special handling: the closure record must store a copy of the string content, not just the string address (which points into the SUB's BSS storage that may be reused). Allocate MAXSTRLEN bytes per captured string in the closure record and `strcpy` the content at BIND time.

### Memory Management

- Closure records allocated via `ACEalloc()` -> freed automatically at program exit by `free_alloc()`
- No individual free during execution (same as all other ACEalloc usage)
- If closures are created in a tight loop, memory will grow until exit — document this limitation
- Future enhancement: add `FREE closure_var` syntax for explicit deallocation

### Files Changed

| File | Change |
|------|--------|
| `src/ace/c/acedef.h` | Add `bindsym` to enum |
| `src/ace/c/lexvar.c` | Add `"BIND"` to `rword[]` |
| `src/ace/c/basfun.c` | Add BIND as a numeric function (~80 lines) |
| `src/ace/c/factor.c` | Extend INVOKE to handle closure records (~40 lines) |
| `src/ace/c/statement.c` | Extend INVOKE statement path for closure dispatch (~20 lines) |

---

## Verification Plan

### Phase 1 Tests

Create test files in `verify/tests/cases/closures/`:

- `funcptr_basic.b` — Assign `@SubName`, INVOKE it, check return value
- `funcptr_params.b` — INVOKE with SHORT, LONG, SINGLE, STRING params
- `funcptr_pass.b` — Pass function pointer as SUB argument, INVOKE inside callee

### Phase 2 Tests

- `bind_one_arg.b` — BIND one argument, INVOKE with remaining
- `bind_multi_arg.b` — BIND multiple arguments
- `bind_in_sub.b` — Create closure inside a SUB, return it, invoke from main
- `bind_types.b` — Bind different types (SHORT, LONG, SINGLE, STRING)

### Build Verification

```
cd src/make && make -f Makefile clean && make -f Makefile
```

Then test on Amiga emulator per CLAUDE.md instructions.

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Reserved word insertion breaks enum/array alignment | High | Carefully maintain sorted order in both `rword[]` and the enum; diff assembly output of existing programs before/after |
| INVOKE in expressions disrupts expression stack | Medium | Follow exact pattern of existing `factor.c` SUB call handling |
| Forbid/Permit around parameter passing | Medium | Mirror existing `load_params` pattern exactly |
| String capture memory usage | Low | Document MAXSTRLEN per string; this matches existing string behavior |
| No individual free for closures | Low | Same limitation as all ACEalloc usage; document it |

### Safety Net

1. **Before any change**: compile example programs (`examples/HelloWorld`, `examples/Screen`, `examples/SleepFor`) and save their `.s` assembly output
2. **After adding new keywords**: recompile the same programs and diff the `.s` output — must be byte-identical
3. **After adding INVOKE/BIND logic**: run existing test suite to confirm no regressions

## Phase State Files

At the end of each phase, write a state file to `specs/` that records what was completed and where the next phase should pick up. This allows a new session to resume without re-exploring the codebase.

- **After Phase 1**: Write `specs/closures-phase1-state.txt` — record which files were changed, which keywords were added, what the enum/array positions are, which tests pass, and what Phase 2 should start with.
- **After Phase 2**: Write `specs/closures-phase2-state.txt` — record the closure record layout as implemented, any deviations from the plan, and any follow-up work identified (e.g., FREE syntax, reference capture).

---

## Phase 3: Documentation

**Goal**: Update user-facing documentation to cover INVOKE and BIND.

### Files to Update

- **`docs/ace.txt`** — Add a section on function pointers and closures (near the existing sections on SUB, CALL, and VARPTR/@). Cover syntax, examples, value-capture semantics, and memory behavior.
- **`docs/ref.txt`** — Add reference entries for `INVOKE` and `BIND` keywords, including syntax diagrams, parameter descriptions, and return types. Follow the existing format of other keyword entries.

### Content to Document

- `INVOKE variable(args)` — syntax, usage as statement and in expressions, return value behavior
- `BIND(@SubName, args)` — syntax, closure record lifetime, value-capture semantics
- Passing function pointers and closures as SUB parameters
- Limitations: no reference capture, no individual free, memory growth if closures created in loops
- Examples: callback pattern, partial application, closure returning from a SUB

### State File

- **After Phase 3**: Write `specs/closures-phase3-state.txt` — record which doc sections were added and any remaining follow-up.

---

## Complexity Summary

- **Phase 1** (INVOKE): ~4 files, ~100 lines of new code. Low risk — extends existing patterns.
- **Phase 2** (BIND): ~5 files, ~150 lines of new code. Medium risk — new heap record format and dispatch logic.
- **Phase 3** (Docs): 2 files. Low risk — documentation only.
