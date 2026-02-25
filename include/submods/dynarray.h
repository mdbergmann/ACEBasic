{*
** Header for DynArray submodule
** Include this when using EXTERNAL dynarray
**
** Growable, type-tagged, indexed collection.
** CLASS-based: multiple independent instances, each with own storage.
** Auto-grow (doubles capacity), contiguous elements, shift-on-remove.
**
** Usage:
**   #include <submods/dynarray.h>
**   DECLARE CLASS DynArray da
**   DaMake(da, DA_MEDIUM)
**   DaAppend$(da, "hello")
**   PRINT DaGet$(da, 0)
**   DaFree(da)
*}

#ifndef DYNARRAY_H
#define DYNARRAY_H

{* ============== Constants ============== *}

' Error codes
CONST DA_SUCCESS    = 0
CONST DA_ERR_FULL   = -1
CONST DA_ERR_BOUNDS = -2

' Capacity presets
CONST DA_SMALL  = 16
CONST DA_MEDIUM = 64
CONST DA_LARGE  = 256
CONST DA_MAX_CAP   = 2048
CONST DA_MAX_BOUND = 2047

' Value type tags
CONST DaTypeStr  = 0
CONST DaTypeLng  = 1
CONST DaTypeSng  = 2
CONST DaTypeRef  = 3
CONST DaTypeBool = 4
CONST DaTypeNull = 5

' String buffer size per element
CONST DA_VAL_SIZE = 256

{* ============== CLASS Definition ============== *}

CLASS DynArray
  ADDRESS vals          ' ALLOC'd string buffer (DA_VAL_SIZE per slot)
  ADDRESS valsL         ' ALLOC'd LONGINT buffer (4 bytes per slot)
  ADDRESS types         ' ALLOC'd type tags (SHORTINT, 2 bytes per slot)
  LONGINT cap           ' Current allocated capacity
  LONGINT count         ' Number of elements stored
  LONGINT cursor        ' Iterator position (-1 = before first)
END CLASS

{* ============== Factory & Cleanup ============== *}

' DaMake - Allocate backing arrays at given capacity
DECLARE SUB DaMake(DynArray da, LONGINT initCap&) EXTERNAL

' DaFree - Free all ALLOC'd backing arrays
DECLARE SUB DaFree(DynArray da) EXTERNAL

' DaClear - Reset count to 0 (does not free arrays)
DECLARE SUB DaClear(DynArray da) EXTERNAL

{* ============== Append ============== *}

' DaAppend$ - Append a string value. Returns DA_SUCCESS or DA_ERR_FULL.
DECLARE SUB SHORTINT DaAppend$(DynArray da, theVal$) EXTERNAL

' DaAppend& - Append a LONGINT value.
DECLARE SUB SHORTINT DaAppend&(DynArray da, LONGINT theVal&) EXTERNAL

' DaAppend! - Append a SINGLE value (raw bits stored in valsL).
DECLARE SUB SHORTINT DaAppend!(DynArray da, SINGLE theVal!) EXTERNAL

' DaAppendRef - Append an ADDRESS reference.
DECLARE SUB SHORTINT DaAppendRef(DynArray da, ADDRESS theRef&) EXTERNAL

' DaAppendBool - Append a boolean value (0 or 1).
DECLARE SUB SHORTINT DaAppendBool(DynArray da, SHORTINT theVal%) EXTERNAL

' DaAppendNull - Append a null entry (type tag only).
DECLARE SUB SHORTINT DaAppendNull(DynArray da) EXTERNAL

{* ============== Get ============== *}

' DaGet$ - Get string value at index. Returns "" if OOB.
DECLARE SUB STRING DaGet$(DynArray da, LONGINT idx&) EXTERNAL

' DaGet& - Get LONGINT value at index. Returns 0 if OOB.
DECLARE SUB LONGINT DaGet&(DynArray da, LONGINT idx&) EXTERNAL

' DaGet! - Get SINGLE value at index. Returns 0 if OOB.
DECLARE SUB SINGLE DaGet!(DynArray da, LONGINT idx&) EXTERNAL

' DaGetRef - Get ADDRESS reference at index. Returns 0 if OOB.
DECLARE SUB LONGINT DaGetRef(DynArray da, LONGINT idx&) EXTERNAL

' DaType - Get type tag at index. Returns -1 if OOB.
DECLARE SUB SHORTINT DaType(DynArray da, LONGINT idx&) EXTERNAL

{* ============== Set ============== *}

' DaSet$ - Set string value at index. Returns DA_ERR_BOUNDS if OOB.
DECLARE SUB SHORTINT DaSet$(DynArray da, LONGINT idx&, theVal$) EXTERNAL

' DaSet& - Set LONGINT value at index.
DECLARE SUB SHORTINT DaSet&(DynArray da, LONGINT idx&, LONGINT theVal&) EXTERNAL

' DaSet! - Set SINGLE value at index.
DECLARE SUB SHORTINT DaSet!(DynArray da, LONGINT idx&, SINGLE theVal!) EXTERNAL

' DaSetRef - Set ADDRESS reference at index.
DECLARE SUB SHORTINT DaSetRef(DynArray da, LONGINT idx&, ADDRESS theRef&) EXTERNAL

' DaSetBool - Set boolean value at index.
DECLARE SUB SHORTINT DaSetBool(DynArray da, LONGINT idx&, SHORTINT theVal%) EXTERNAL

' DaSetNull - Set null at index.
DECLARE SUB SHORTINT DaSetNull(DynArray da, LONGINT idx&) EXTERNAL

{* ============== Remove ============== *}

' DaRemove - Remove element at index, shift remaining left.
DECLARE SUB SHORTINT DaRemove(DynArray da, LONGINT idx&) EXTERNAL

{* ============== Info ============== *}

' DaCount - Number of elements currently stored
DECLARE SUB LONGINT DaCount(DynArray da) EXTERNAL

' DaCapacity - Current capacity of the array
DECLARE SUB LONGINT DaCapacity(DynArray da) EXTERNAL

{* ============== Iteration (Phase 2) ============== *}

' DaIterReset - Reset iterator to beginning
DECLARE SUB DaIterReset(DynArray da) EXTERNAL

' DaIterNext - Advance to next element. Returns -1 (true) or 0 (false).
DECLARE SUB SHORTINT DaIterNext(DynArray da) EXTERNAL

' DaIterIdx - Index at current iterator position
DECLARE SUB LONGINT DaIterIdx(DynArray da) EXTERNAL

' DaIterVal$ - String value at current position
DECLARE SUB STRING DaIterVal$(DynArray da) EXTERNAL

' DaIterVal& - LONGINT value at current position
DECLARE SUB LONGINT DaIterVal&(DynArray da) EXTERNAL

' DaIterVal! - SINGLE value at current position
DECLARE SUB SINGLE DaIterVal!(DynArray da) EXTERNAL

' DaIterRef - ADDRESS reference at current position
DECLARE SUB LONGINT DaIterRef(DynArray da) EXTERNAL

' DaIterType - Type tag at current position
DECLARE SUB SHORTINT DaIterType(DynArray da) EXTERNAL

{* ============== Builder (Phase 3) ============== *}

' DaNew - Start building a new dynarray with given capacity
DECLARE SUB DaNew(LONGINT initCap&) EXTERNAL

' DaAdd$ - Add string to builder
DECLARE SUB SHORTINT DaAdd$(theVal$) EXTERNAL

' DaAdd& - Add LONGINT to builder
DECLARE SUB SHORTINT DaAdd&(LONGINT theVal&) EXTERNAL

' DaAdd! - Add SINGLE to builder
DECLARE SUB SHORTINT DaAdd!(SINGLE theVal!) EXTERNAL

' DaAddRef - Add ADDRESS reference to builder
DECLARE SUB SHORTINT DaAddRef(ADDRESS theRef&) EXTERNAL

' DaAddBool - Add boolean to builder
DECLARE SUB SHORTINT DaAddBool(SHORTINT theVal%) EXTERNAL

' DaAddNull - Add null to builder
DECLARE SUB SHORTINT DaAddNull EXTERNAL

' DaEnd - Finalize builder, return ADDRESS of completed DynArray
DECLARE SUB LONGINT DaEnd EXTERNAL

{* ============== Search & Mutate (Phase 4) ============== *}

' DaIndexOf$ - Linear scan for string value. Returns index or -1.
DECLARE SUB LONGINT DaIndexOf$(DynArray da, theVal$) EXTERNAL

' DaIndexOf& - Linear scan for LONGINT value. Returns index or -1.
DECLARE SUB LONGINT DaIndexOf&(DynArray da, LONGINT theVal&) EXTERNAL

' DaContains$ - Check if string value exists. Returns -1 (true) or 0 (false).
DECLARE SUB SHORTINT DaContains$(DynArray da, theVal$) EXTERNAL

' DaContains& - Check if LONGINT value exists. Returns -1 (true) or 0 (false).
DECLARE SUB SHORTINT DaContains&(DynArray da, LONGINT theVal&) EXTERNAL

' DaReverse - Reverse elements in place.
DECLARE SUB DaReverse(DynArray da) EXTERNAL

{* ============== Higher-Order Functions (Phase 5) ============== *}

' DaForEach - Call callback for each element.
' Callback: SUB ADDRESS cb(LONGINT idx&, LONGINT rawVal&,
'              ADDRESS strPtr, SHORTINT typ%) INVOKABLE
DECLARE SUB DaForEach(DynArray da, ADDRESS fun) EXTERNAL

' DaFilter - Copy matching elements to dest array.
' Predicate: return -1 (keep) or 0 (discard).
DECLARE SUB DaFilter(DynArray da, DynArray dest, ADDRESS predFun) EXTERNAL

' DaFind - Return first matching index or -1.
DECLARE SUB LONGINT DaFind(DynArray da, ADDRESS predFun) EXTERNAL

' DaReduce - Fold left with accumulator.
' Fold callback: SUB ADDRESS cb(LONGINT acc&, LONGINT rawVal&,
'                   ADDRESS strPtr, SHORTINT typ%) INVOKABLE
DECLARE SUB LONGINT DaReduce(DynArray da, LONGINT init&, ADDRESS foldFun) EXTERNAL

' DaMap - Transform elements into dest array via callback.
DECLARE SUB DaMap(DynArray da, DynArray dest, ADDRESS mapFun) EXTERNAL

{* ============== Sort (Phase 6) ============== *}

' DaSort - Shellsort with comparator callback.
' Comparator: SUB ADDRESS CmpFun(LONGINT rawA&, LONGINT rawB&,
'                ADDRESS strPtrA, ADDRESS strPtrB,
'                SHORTINT typA%, SHORTINT typB%) INVOKABLE
' Return: negative (a < b), 0 (equal), positive (a > b)
DECLARE SUB DaSort(DynArray da, ADDRESS cmpFun) EXTERNAL

' DaSortStr - Ascending string sort (convenience)
DECLARE SUB DaSortStr(DynArray da) EXTERNAL

' DaSortLng - Ascending LONGINT sort (convenience)
DECLARE SUB DaSortLng(DynArray da) EXTERNAL

#endif
