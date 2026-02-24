Hashmap Submodule for ACE BASIC
===============================

Designed by Manfred Bergmann, copyright 2026.

A string-keyed hashmap using open addressing with linear probing.
CLASS-based: multiple independent instances, each with own storage.
DJB2 hash, power-of-2 capacity, 70% max load factor, tombstone deletion.


Overview
--------

A hashmap stores key-value pairs where keys are strings and values can
be any of 6 types: STRING, LONGINT, SINGLE, ADDRESS (ref), boolean,
or null.

Example:

    #include <submods/hashmap.h>

    DECLARE CLASS Hashmap map
    HmMake(map, HM_MEDIUM)       ' 128 slots

    HmPut$(map, "name", "Alice")
    HmPut&(map, "age", 30)
    HmPut!(map, "score", 9.5)

    PRINT HmGet$(map, "name")    ' Alice
    PRINT HmGet&(map, "age")     ' 30
    PRINT HmHas(map, "name")     ' -1 (true)

    HmDel(map, "age")
    PRINT HmCount(map)           ' 2

    HmFree(map)

See test_core.b, test_typed.b, test_iter.b, test_foreach.b, and
test_builder.b for comprehensive examples.


Type Suffixes
-------------

Functions use type suffixes to indicate the data type:
  $  - STRING (up to HM_VAL_SIZE-1 = 255 characters)
  &  - LONGINT (32-bit integer)
  !  - SINGLE (32-bit float, Amiga FFP format)
  (none for Put/Get) - Ref, Bool, Null have named variants

Use HmType() to check the type of an entry at runtime:
  HmTypeStr  = 0    HmTypeLng  = 1    HmTypeSng  = 2
  HmTypeRef  = 3    HmTypeBool = 4    HmTypeNull = 5

HmType() returns -1 if the key is not found.


Capacity and Sizing
-------------------

Capacity must be a power of 2. Three presets are provided:
  HM_SMALL  = 32     (up to ~22 entries at 70% load)
  HM_MEDIUM = 128    (up to ~89 entries)
  HM_LARGE  = 512    (up to ~358 entries)

The maximum capacity is HM_LARGE (512). This limit comes from the
DIM...ADDRESS overlay bound (HM_MAX_BOUND = 511).

When the map reaches 70% capacity, Put operations return HM_ERR_FULL.
Updates to existing keys always succeed regardless of load factor.

Key strings are limited to HM_KEY_SIZE-1 = 63 characters.
String values are limited to HM_VAL_SIZE-1 = 255 characters.


Memory Management
-----------------

There are two ways to create a hashmap, each with different cleanup.

Method 1: DECLARE CLASS (stack/BSS struct)

    DECLARE CLASS Hashmap map
    HmMake(map, HM_MEDIUM)
    ' ... use map ...
    HmFree(map)                  ' Frees the 6 backing arrays

    The Hashmap struct itself lives in BSS (static storage).
    Only one call to HmFree is needed.

Method 2: Builder pattern (heap-allocated struct)

    HmNew(HM_MEDIUM)
    HmAdd$("name", "Alice")
    HmAdd&("age", 30)
    LONGINT map&
    map& = HmEnd

    ' To use the returned map, create a local CLASS reference:
    DECLARE CLASS Hashmap m
    m = map&
    PRINT HmGet$(m, "name")

    ' Cleanup requires TWO calls:
    HmFree(m)                    ' Frees the 6 backing arrays
    FREE map&                    ' Frees the 48-byte CLASS struct

    The builder ALLOCs a Hashmap struct on the heap (48 bytes).
    HmFree cannot free this struct because it does not know whether
    the struct was ALLOC'd (builder) or lives in BSS (DECLARE CLASS).
    Freeing a BSS address would crash, so HmFree only frees the
    backing arrays. The caller must FREE the struct separately.

Rules:

1. Always call HmFree before discarding a map. It frees 6 internal
   arrays (keys, vals, valsL, types, status, order).

2. For builder-created maps, also FREE the returned ADDRESS.
   Forgetting this leaks 48 bytes per map.

3. After HmFree, the map is invalid. Do not call any Hm* functions
   on it (except HmMake to reinitialize).

4. HmClear resets all entries but keeps the backing arrays allocated.
   Use this to reuse a map without reallocating.


Error Handling
--------------

Put functions return a SHORTINT status code:
  HM_SUCCESS    =  0   Operation succeeded
  HM_ERR_FULL   = -1   Map is at 70% load, cannot insert new key
  HM_ERR_NOTFOUND = -2  Key not found (returned by HmDel)

Get functions return a default value when the key is not found:
  HmGet$  returns ""
  HmGet&  returns 0
  HmGet!  returns 0
  HmGetRef returns 0

Use HmHas to distinguish "key not found" from "key exists with
default value" (e.g., a LONGINT entry that is legitimately 0).


Iteration
---------

Entries are iterated in insertion order. Deleted entries are skipped.
Updating an existing key does not change its position in the order.

Cursor-based iteration:

    HmIterReset(map)
    WHILE HmIterNext(map)
      PRINT HmIterKey$(map); " = ";
      IF HmIterType(map) = HmTypeStr THEN
        PRINT HmIterVal$(map)
      ELSEIF HmIterType(map) = HmTypeLng THEN
        PRINT HmIterVal&(map)
      END IF
    WEND

The iterator state is stored in the Hashmap instance (cursor, curIdx).
Call HmIterReset to restart iteration from the beginning.

Higher-order iteration with HmForEach:

    SUB ADDRESS PrintEntry(ADDRESS kPtr, LONGINT rawVal&, ~
                           ADDRESS sPtr, SHORTINT typ%) INVOKABLE
      PRINT CSTR(kPtr); " (type "; typ%; ")"
    END SUB

    HmForEach(map, BIND(@PrintEntry))

Callback signature:
  SUB ADDRESS cb(ADDRESS keyPtr, LONGINT rawVal&,
                 ADDRESS strPtr, SHORTINT typ%) INVOKABLE

  keyPtr  - Pointer to key string (use CSTR(keyPtr))
  rawVal& - Raw LONGINT value (for Lng, Ref, Bool types)
  strPtr  - Pointer to string value (use CSTR(strPtr))
  typ%    - Type tag (HmTypeStr, HmTypeLng, etc.)

The callback must be declared INVOKABLE and passed via BIND(@MySub).
See test_foreach.b for complete examples.


Builder Pattern
---------------

The builder provides a fluent API for constructing hashmaps:

    HmNew(HM_SMALL)
    HmAdd$("greeting", "hello")
    HmAdd&("count", 42)
    HmAddBool("active", -1)
    HmAddNull("empty")
    LONGINT map&
    map& = HmEnd

Only one builder can be active at a time. Nested builders are
supported if inner builders complete before outer ones resume
(the inner HmEnd returns before the outer HmAdd continues).

See test_builder.b for nested builder and error propagation examples.


Nested Hashmaps
---------------

Use HmPutRef / HmGetRef to store references to other hashmaps:

    DECLARE CLASS Hashmap outer, inner
    HmMake(outer, HM_SMALL)
    HmMake(inner, HM_SMALL)

    HmPut$(inner, "city", "Berlin")
    HmPutRef(outer, "address", inner)

    ' Retrieve the nested map
    DECLARE CLASS Hashmap got
    got = HmGetRef(outer, "address")
    PRINT HmGet$(got, "city")         ' Berlin

    ' Free inner map first, then outer
    HmFree(inner)
    HmFree(outer)

HmPutRef stores the ADDRESS of the inner map's CLASS instance.
The hashmap does not manage the lifetime of referenced objects.
The caller is responsible for freeing nested maps.

See test_typed.b for a complete nested hashmap example.


Building the Module
-------------------

On Amiga (or emulator):

    cd ACE:submods/hashmap
    bas -m hashmap

This compiles hashmap.b as a module, producing hashmap.o


Running Tests
-------------

On Amiga (or emulator):

    cd ACE:submods/hashmap
    bas test_core hashmap.o
    test_core

    bas test_typed hashmap.o
    test_typed

    bas test_iter hashmap.o
    test_iter

    bas test_foreach hashmap.o
    test_foreach

    bas test_builder hashmap.o
    test_builder

5 test suites, 216 total assertions.


Using in Your Programs
----------------------

1. Include the header:

    #include <submods/hashmap.h>

2. Compile your program, linking the module:

    bas myprogram ace:submods/hashmap/hashmap.o

   Or use REM #using at the top of your .b file:

    REM #using hashmap.o

   (requires hashmap.o to be in the same directory or on the path)


Files
-----

hashmap.b         - Library source code (~790 lines, 38 SUBs)
hashmap.o         - Compiled module (after building)
test_core.b       - Phase 1 tests: core operations (49 assertions)
test_typed.b      - Phase 2 tests: typed values (54 assertions)
test_iter.b       - Phase 3 tests: iteration (70 assertions)
test_foreach.b    - Phase 3b tests: HmForEach (13 assertions)
test_builder.b    - Phase 3c tests: builder pattern (30 assertions)
README.txt        - This file

include/submods/hashmap.h - Header file with declarations


Function Reference
------------------

See include/submods/hashmap.h for declarations and inline documentation.

Factory & Cleanup:
  HmMake(hm, cap&)           Initialize with power-of-2 capacity
  HmFree(hm)                 Free all backing arrays
  HmClear(hm)                Reset entries, keep arrays allocated

Put (insert or update):
  HmPut$(hm, key$, val$)     String value     -> HM_SUCCESS or HM_ERR_FULL
  HmPut&(hm, key$, val&)     LONGINT value    -> HM_SUCCESS or HM_ERR_FULL
  HmPut!(hm, key$, val!)     SINGLE value     -> HM_SUCCESS or HM_ERR_FULL
  HmPutRef(hm, key$, ref&)   ADDRESS value    -> HM_SUCCESS or HM_ERR_FULL
  HmPutBool(hm, key$, val%)  Boolean (0 or 1) -> HM_SUCCESS or HM_ERR_FULL
  HmPutNull(hm, key$)        Null (type only) -> HM_SUCCESS or HM_ERR_FULL

Get (lookup):
  HmGet$(hm, key$)           -> STRING ("" if not found)
  HmGet&(hm, key$)           -> LONGINT (0 if not found)
  HmGet!(hm, key$)           -> SINGLE (0 if not found)
  HmGetRef(hm, key$)         -> LONGINT/ADDRESS (0 if not found)

Query:
  HmHas(hm, key$)            -> -1 (true) or 0 (false)
  HmType(hm, key$)           -> type tag (0-5) or -1 if not found
  HmDel(hm, key$)            -> HM_SUCCESS or HM_ERR_NOTFOUND
  HmCount(hm)                -> number of entries
  HmCapacity(hm)             -> current capacity

Iteration (insertion order):
  HmIterReset(hm)            Reset iterator to beginning
  HmIterNext(hm)             Advance; -1 (has entry) or 0 (done)
  HmIterKey$(hm)             Key at current position
  HmIterVal$(hm)             String value at current position
  HmIterVal&(hm)             LONGINT value at current position
  HmIterVal!(hm)             SINGLE value at current position
  HmIterType(hm)             Type tag at current position

Higher-order:
  HmForEach(hm, fun)         Call fun for each entry (BIND + INVOKABLE)

Builder:
  HmNew(cap&)                Start builder with given capacity
  HmAdd$(key$, val$)         Add string entry
  HmAdd&(key$, val&)         Add LONGINT entry
  HmAdd!(key$, val!)         Add SINGLE entry
  HmAddRef(key$, ref&)       Add ADDRESS entry
  HmAddBool(key$, val%)      Add boolean entry
  HmAddNull(key$)            Add null entry
  HmEnd                      -> LONGINT (ADDRESS of completed Hashmap)
