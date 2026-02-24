{*
** Header for Hashmap submodule
** Include this when using EXTERNAL hashmap
**
** String-keyed hashmap with open addressing and linear probing.
** CLASS-based: multiple independent instances, each with own storage.
** DJB2 hash, power-of-2 capacity, 70% max load factor.
**
** Usage:
**   #include <submods/hashmap.h>
**   EXTERNAL hashmap
**   DECLARE CLASS Hashmap map
**   HmMake(map, HM_MEDIUM)
**   HmPut$(map, "name", "Alice")
**   PRINT HmGet$(map, "name")
**   HmFree(map)
*}

#ifndef HASHMAP_H
#define HASHMAP_H

{* ============== Constants ============== *}

' Error codes
CONST HM_SUCCESS = 0
CONST HM_ERR_FULL = -1
CONST HM_ERR_NOTFOUND = -2
CONST HM_ERR_CAPACITY = -3

' Value type tags
CONST HmTypeStr = 0
CONST HmTypeLng = 1
CONST HmTypeSng = 2
CONST HmTypeRef = 3
CONST HmTypeBool = 4
CONST HmTypeNull = 5

' Capacity presets
CONST HM_SMALL = 32
CONST HM_MEDIUM = 128
CONST HM_LARGE = 512

' String buffer sizes per element
CONST HM_KEY_SIZE = 64
CONST HM_VAL_SIZE = 256

{* ============== CLASS Definition ============== *}

CLASS Hashmap
  ADDRESS keys
  ADDRESS vals
  ADDRESS valsL
  ADDRESS types
  ADDRESS status
  ADDRESS order
  LONGINT cap
  LONGINT count
  LONGINT orderCount
  LONGINT cursor
  LONGINT curIdx
END CLASS

{* ============== Factory & Cleanup ============== *}

' HmMake - Allocate backing arrays at given capacity (must be power of 2)
DECLARE SUB HmMake(Hashmap hm, LONGINT theCap&) EXTERNAL

' HmFree - Free all ALLOC'd backing arrays
DECLARE SUB HmFree(Hashmap hm) EXTERNAL

' HmClear - Reset all entries to empty (does not free arrays)
DECLARE SUB HmClear(Hashmap hm) EXTERNAL

{* ============== Core Operations ============== *}

' HmPut$ - Insert or update a string value. Returns HM_SUCCESS or HM_ERR_FULL.
DECLARE SUB SHORTINT HmPut$(Hashmap hm, theKey$, theVal$) EXTERNAL

' HmPut& - Insert or update a LONGINT value.
DECLARE SUB SHORTINT HmPut&(Hashmap hm, theKey$, LONGINT theVal&) EXTERNAL

' HmPut! - Insert or update a SINGLE value (raw bits stored in valsL).
DECLARE SUB SHORTINT HmPut!(Hashmap hm, theKey$, SINGLE theVal!) EXTERNAL

' HmPutRef - Insert or update an ADDRESS reference (CLASS instance pointer).
DECLARE SUB SHORTINT HmPutRef(Hashmap hm, theKey$, ADDRESS theRef&) EXTERNAL

' HmPutBool - Insert or update a boolean value (0 or 1).
DECLARE SUB SHORTINT HmPutBool(Hashmap hm, theKey$, SHORTINT theVal%) EXTERNAL

' HmPutNull - Insert or update a null entry (type tag only, no value).
DECLARE SUB SHORTINT HmPutNull(Hashmap hm, theKey$) EXTERNAL

' HmGet$ - Lookup string value by key. Returns "" if not found.
DECLARE SUB STRING HmGet$(Hashmap hm, theKey$) EXTERNAL

' HmGet& - Lookup LONGINT value by key. Returns 0 if not found.
DECLARE SUB LONGINT HmGet&(Hashmap hm, theKey$) EXTERNAL

' HmGet! - Lookup SINGLE value by key. Returns 0 if not found.
DECLARE SUB SINGLE HmGet!(Hashmap hm, theKey$) EXTERNAL

' HmGetRef - Lookup ADDRESS reference by key. Returns 0 if not found.
DECLARE SUB LONGINT HmGetRef(Hashmap hm, theKey$) EXTERNAL

' HmHas - Check if key exists. Returns -1 (true) or 0 (false).
DECLARE SUB SHORTINT HmHas(Hashmap hm, theKey$) EXTERNAL

' HmType - Get type tag for key. Returns -1 if not found.
DECLARE SUB SHORTINT HmType(Hashmap hm, theKey$) EXTERNAL

' HmDel - Delete entry by key. Returns HM_SUCCESS or HM_ERR_NOTFOUND.
DECLARE SUB SHORTINT HmDel(Hashmap hm, theKey$) EXTERNAL

{* ============== Info ============== *}

' HmCount - Number of entries currently stored
DECLARE SUB LONGINT HmCount(Hashmap hm) EXTERNAL

' HmCapacity - Current capacity of the hashmap
DECLARE SUB LONGINT HmCapacity(Hashmap hm) EXTERNAL

{* ============== Iteration ============== *}

' HmIterReset - Reset iterator to beginning
DECLARE SUB HmIterReset(Hashmap hm) EXTERNAL

' HmIterNext - Advance to next entry. Returns -1 (true) or 0 (false).
DECLARE SUB SHORTINT HmIterNext(Hashmap hm) EXTERNAL

' HmIterKey$ - Key at current iterator position
DECLARE SUB STRING HmIterKey$(Hashmap hm) EXTERNAL

' HmIterVal$ - String value at current position
DECLARE SUB STRING HmIterVal$(Hashmap hm) EXTERNAL

' HmIterVal& - LONGINT value at current position (also for bool/ref)
DECLARE SUB LONGINT HmIterVal&(Hashmap hm) EXTERNAL

' HmIterVal! - SINGLE value at current position
DECLARE SUB SINGLE HmIterVal!(Hashmap hm) EXTERNAL

' HmIterType - Type tag at current position
DECLARE SUB SHORTINT HmIterType(Hashmap hm) EXTERNAL

#endif
