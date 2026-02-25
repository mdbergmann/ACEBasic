# DynArray

Growable, type-tagged, indexed collection for ACE BASIC. Supports strings, integers, floats, addresses, booleans, and nulls in the same array. CLASS-based — multiple independent instances, each with its own storage.

## Setup

Include the header and link the compiled module:

```basic
REM #using ace:submods/dynarray/dynarray.o
#include <submods/dynarray.h>
```

Build the module on the Amiga:

```
cd ace:submods/dynarray
execute make
```

The `make` script runs `bas -m dynarray` to produce `dynarray.o`.

## Basic Usage

```basic
DECLARE CLASS DynArray da
DaMake(da, DA_MEDIUM)       ' allocate with 64 slots

rc% = DaAppend$(da, "hello")
rc% = DaAppend&(da, 42)
rc% = DaAppend!(da, 3.14)

PRINT DaGet$(da, 0)         ' "hello"
PRINT DaGet&(da, 1)         ' 42
PRINT DaCount(da)            ' 3

DaFree(da)
```

## Capacity Presets

| Constant    | Slots |
|-------------|-------|
| `DA_SMALL`  | 16    |
| `DA_MEDIUM` | 64    |
| `DA_LARGE`  | 256   |
| `DA_MAX_CAP`| 2048  |

The array auto-grows by doubling when full, up to `DA_MAX_CAP`.

## Type Tags

Each element carries a type tag. Query with `DaType(da, idx)`:

| Constant     | Value | Stored via       |
|--------------|-------|------------------|
| `DaTypeStr`  | 0     | `DaAppend$`      |
| `DaTypeLng`  | 1     | `DaAppend&`      |
| `DaTypeSng`  | 2     | `DaAppend!`      |
| `DaTypeRef`  | 3     | `DaAppendRef`    |
| `DaTypeBool` | 4     | `DaAppendBool`   |
| `DaTypeNull` | 5     | `DaAppendNull`   |

## Error Codes

All mutating functions return a `SHORTINT` status:

| Constant         | Value | Meaning                     |
|------------------|-------|-----------------------------|
| `DA_SUCCESS`     | 0     | OK                          |
| `DA_ERR_FULL`    | -1    | At max capacity, cannot grow|
| `DA_ERR_BOUNDS`  | -2    | Index out of range          |

## API Summary

### Lifecycle

- `DaMake(da, capacity)` — allocate backing storage
- `DaFree(da)` — free all backing storage
- `DaClear(da)` — reset count to 0 (keeps allocation)

### Append / Get / Set

Type-suffixed: `$` for strings, `&` for LONGINT, `!` for SINGLE, plus `Ref`, `Bool`, `Null`.

- `DaAppend$(da, val$)`, `DaAppend&(da, val&)`, `DaAppend!(da, val!)`, `DaAppendRef(da, addr)`, `DaAppendBool(da, flag%)`, `DaAppendNull(da)`
- `DaGet$(da, idx)`, `DaGet&(da, idx)`, `DaGet!(da, idx)`, `DaGetRef(da, idx)`
- `DaSet$(da, idx, val$)`, `DaSet&(da, idx, val&)`, `DaSet!(da, idx, val!)`, `DaSetRef(da, idx, addr)`, `DaSetBool(da, idx, flag%)`, `DaSetNull(da, idx)`

### Info

- `DaCount(da)` — number of elements
- `DaCapacity(da)` — current allocated capacity
- `DaType(da, idx)` — type tag at index

### Remove

- `DaRemove(da, idx)` — remove element, shifts remaining left

### Iteration

```basic
DaIterReset(da)
WHILE DaIterNext(da)
  PRINT DaIterIdx(da); DaIterVal$(da)
WEND
```

- `DaIterReset(da)` — reset cursor to start
- `DaIterNext(da)` — advance; returns -1 (more) or 0 (done)
- `DaIterIdx(da)` — current index
- `DaIterVal$(da)`, `DaIterVal&(da)`, `DaIterVal!(da)`, `DaIterRef(da)`, `DaIterType(da)` — value/type at cursor

### Builder Pattern

Fluent construction without holding a variable:

```basic
DaNew(DA_SMALL)
rc% = DaAdd$("apple")
rc% = DaAdd$("banana")
LONGINT myArr&
myArr& = DaEnd

DECLARE CLASS DynArray da
da = myArr&
PRINT DaGet$(da, 0)    ' "apple"
DaFree(da)
FREE myArr&
```

Builder functions: `DaNew`, `DaAdd$`, `DaAdd&`, `DaAdd!`, `DaAddRef`, `DaAddBool`, `DaAddNull`, `DaEnd`.

### Search

- `DaIndexOf$(da, val$)` — first index of string, or -1
- `DaIndexOf&(da, val&)` — first index of LONGINT, or -1
- `DaContains$(da, val$)` — returns -1 (found) or 0
- `DaContains&(da, val&)` — returns -1 (found) or 0
- `DaReverse(da)` — reverse elements in place

### Higher-Order Functions

All callbacks use `INVOKABLE` SUBs passed via `BIND(@MySub)`.

**ForEach / Map** callback signature:

```basic
SUB ADDRESS MyCallback(LONGINT idx&, LONGINT rawVal&, ~
    ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  ' Use CSTR(strPtr) for string values
END SUB

DaForEach(da, BIND(@MyCallback))
```

**Filter** — copies matching elements into a destination array:

```basic
DaFilter(da, dest, BIND(@MyPredicate))
' predicate returns -1 (keep) or 0 (discard)
```

**Find** — returns index of first match, or -1:

```basic
idx& = DaFind(da, BIND(@MyPredicate))
```

**Reduce** — fold left with accumulator:

```basic
SUB ADDRESS MyFold(LONGINT acc&, LONGINT rawVal&, ~
    ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  MyFold = acc& + rawVal&
END SUB

total& = DaReduce(da, 0, BIND(@MyFold))
```

### Sort

**Convenience** — ascending sort by built-in comparators:

```basic
DaSortLng(da)     ' ascending numeric
DaSortStr(da)     ' ascending alphabetical
```

**Custom comparator** — for descending or mixed-type sorting:

```basic
SUB ADDRESS MyCmp(LONGINT rawA&, LONGINT rawB&, ~
    ADDRESS strPtrA, ADDRESS strPtrB, ~
    SHORTINT typA%, SHORTINT typB%) INVOKABLE
  ' Return: negative (a < b), 0 (equal), positive (a > b)
END SUB

DaSort(da, BIND(@MyCmp))
```

Uses Shellsort with Knuth gap sequence — efficient for typical collection sizes.

## String Size Limit

Each string slot is `DA_VAL_SIZE` (256) bytes. Strings longer than 255 characters will be truncated.

## Tests

See the test files for comprehensive usage examples:

| File            | Coverage |
|-----------------|----------|
| `test_core.b`   | Lifecycle, append, get, set, remove, type tags, auto-grow, mixed types (92 assertions) |
| `test_iter.b`   | Iterator reset/next/val, empty arrays, post-remove iteration (47 assertions) |
| `test_builder.b`| Builder pattern, sequential builds, mixed types (23 assertions) |
| `test_search.b` | IndexOf, Contains, Reverse, duplicates, edge cases (32 assertions) |
| `test_hof.b`    | ForEach, Filter, Find, Reduce, Map with callbacks (20 assertions) |
| `test_sort.b`   | SortLng, SortStr, custom comparators, duplicates, edge cases (40 assertions) |

Run all tests on the Amiga:

```
cd ace:verify/tests
rx runner.rexx dynarray
```

This compiles the module and runs all 6 test files via the test runner (254 assertions total).
