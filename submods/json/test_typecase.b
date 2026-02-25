REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/testkit/testkit.o

{*
** test_typecase.b - Phase 0: Verify CLASS descriptor stamping
** Tests that ALLOC'd Hashmap and DynArray instances (from builders)
** have proper descriptors for TYPECASE discrimination.
*}

#include <submods/hashmap.h>
#include <submods/dynarray.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Phase 0: TYPECASE Descriptor Stamping ==="
PRINT

TkInit

LONGINT hmAddr&, daAddr&

{* ============== Test 1: TYPECASE on builder Hashmap ============== *}

PRINT "-- Test 1: TYPECASE on builder Hashmap"
HmNew(HM_SMALL)
  HmAdd$("key", "val")
hmAddr& = HmEnd

DECLARE CLASS Hashmap hm
hm = hmAddr&

SHORTINT matched%
matched% = 0

TYPECASE hm
  CASE Hashmap
    matched% = 1
  CASE DynArray
    matched% = 2
  CASE ELSE
    matched% = -1
END TYPECASE

TkAssertEq%(matched%, 1, "builder Hashmap matches CASE Hashmap")

' Verify it still works as a Hashmap
TkAssertEqStr(HmGet$(hm, "key"), "val", "Hashmap data intact")

HmFree(hm)
FREE hmAddr&

{* ============== Test 2: TYPECASE on builder DynArray ============== *}

PRINT "-- Test 2: TYPECASE on builder DynArray"
DaNew(DA_SMALL)
  DaAdd$("hello")
daAddr& = DaEnd

DECLARE CLASS DynArray da
da = daAddr&

matched% = 0

TYPECASE da
  CASE Hashmap
    matched% = 1
  CASE DynArray
    matched% = 2
  CASE ELSE
    matched% = -1
END TYPECASE

TkAssertEq%(matched%, 2, "builder DynArray matches CASE DynArray")

' Verify it still works as a DynArray
TkAssertEqStr(DaGet$(da, 0), "hello", "DynArray data intact")

DaFree(da)
FREE daAddr&

{* ============== Test 3: Discriminate via common variable ============== *}

PRINT "-- Test 3: Discriminate Hashmap vs DynArray"
HmNew(HM_SMALL)
  HmAdd&("num", 42)
hmAddr& = HmEnd

DaNew(DA_SMALL)
  DaAdd&(99)
daAddr& = DaEnd

' Use Hashmap variable but assign DynArray address
DECLARE CLASS Hashmap probe
SHORTINT result%

' Test with Hashmap address
probe = hmAddr&
result% = 0
TYPECASE probe
  CASE Hashmap
    result% = 1
  CASE DynArray
    result% = 2
  CASE ELSE
    result% = -1
END TYPECASE
TkAssertEq%(result%, 1, "hmAddr matches Hashmap")

' Test with DynArray address
probe = daAddr&
result% = 0
TYPECASE probe
  CASE Hashmap
    result% = 1
  CASE DynArray
    result% = 2
  CASE ELSE
    result% = -1
END TYPECASE
TkAssertEq%(result%, 2, "daAddr matches DynArray")

' Cleanup
hm = hmAddr&
HmFree(hm)
FREE hmAddr&

da = daAddr&
DaFree(da)
FREE daAddr&

{* ============== Test 4: BSS-backed instances still work ============== *}

PRINT "-- Test 4: BSS-backed CLASS instances"
DECLARE CLASS Hashmap bssHm
DECLARE CLASS DynArray bssDa

HmMake(bssHm, HM_SMALL)
DaMake(bssDa, DA_SMALL)

' TYPECASE on BSS Hashmap
probe = bssHm
result% = 0
TYPECASE probe
  CASE Hashmap
    result% = 1
  CASE DynArray
    result% = 2
END TYPECASE
TkAssertEq%(result%, 1, "BSS Hashmap matches Hashmap")

' TYPECASE on BSS DynArray
probe = bssDa
result% = 0
TYPECASE probe
  CASE Hashmap
    result% = 1
  CASE DynArray
    result% = 2
END TYPECASE
TkAssertEq%(result%, 2, "BSS DynArray matches DynArray")

HmFree(bssHm)
DaFree(bssDa)

{* ============== Summary ============== *}
TkSummary
