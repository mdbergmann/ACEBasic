REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/testkit/testkit.o

{*
** DynArray Phase 3: Builder Tests
** Tests DaNew/DaAdd*/DaEnd, empty builder, mixed types,
** multiple sequential builders, cleanup.
*}

#include <submods/dynarray.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== DynArray Phase 3: Builder Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: Basic string builder --- *}
PRINT "--- Basic string builder ---"
DaNew(DA_SMALL)
rc% = DaAdd$("alpha")
TkAssertEq%(rc%, 0, "add alpha ok")
rc% = DaAdd$("beta")
TkAssertEq%(rc%, 0, "add beta ok")
rc% = DaAdd$("gamma")
TkAssertEq%(rc%, 0, "add gamma ok")

LONGINT addr1&
addr1& = DaEnd

TkAssertNeq&(addr1&, 0, "DaEnd returns non-zero")

DECLARE CLASS DynArray d1
d1 = addr1&
TkAssertEq&(DaCount(d1), 3, "builder count = 3")
TkAssertEqStr(DaGet$(d1, 0), "alpha", "builder 0 = alpha")
TkAssertEqStr(DaGet$(d1, 1), "beta", "builder 1 = beta")
TkAssertEqStr(DaGet$(d1, 2), "gamma", "builder 2 = gamma")

DaFree(d1)
FREE addr1&

{* --- Test 2: Mixed types builder --- *}
PRINT "--- Mixed types builder ---"
DaNew(DA_SMALL)
rc% = DaAdd$("hello")
rc% = DaAdd&(42)
rc% = DaAdd!(2.718)
rc% = DaAddRef(55555)
rc% = DaAddBool(-1)
rc% = DaAddNull

LONGINT addr2&
addr2& = DaEnd

DECLARE CLASS DynArray d2
d2 = addr2&
TkAssertEq&(DaCount(d2), 6, "mixed builder count = 6")
TkAssertEqStr(DaGet$(d2, 0), "hello", "mixed 0 = hello")
TkAssertEq&(DaGet&(d2, 1), 42, "mixed 1 = 42")
TkAssertEqFloat(DaGet!(d2, 2), 2.718, "mixed 2 = 2.718")
TkAssertEq&(DaGetRef(d2, 3), 55555, "mixed 3 = 55555")
TkAssertEq&(DaGet&(d2, 4), 1, "mixed 4 = 1 (bool)")
TkAssertEq%(DaType(d2, 5), DaTypeNull, "mixed 5 type = null")

DaFree(d2)
FREE addr2&

{* --- Test 3: Empty builder --- *}
PRINT "--- Empty builder ---"
DaNew(DA_SMALL)

LONGINT addr3&
addr3& = DaEnd

DECLARE CLASS DynArray d3
d3 = addr3&
TkAssertEq&(DaCount(d3), 0, "empty builder count = 0")

DaFree(d3)
FREE addr3&

{* --- Test 4: Sequential builders --- *}
PRINT "--- Sequential builders ---"
DaNew(DA_SMALL)
rc% = DaAdd$("first")
LONGINT addrA&
addrA& = DaEnd

DaNew(DA_SMALL)
rc% = DaAdd$("second")
LONGINT addrB&
addrB& = DaEnd

DECLARE CLASS DynArray dA
DECLARE CLASS DynArray dB
dA = addrA&
dB = addrB&

TkAssertEqStr(DaGet$(dA, 0), "first", "seq A = first")
TkAssertEqStr(DaGet$(dB, 0), "second", "seq B = second")
TkAssertEq&(DaCount(dA), 1, "seq A count = 1")
TkAssertEq&(DaCount(dB), 1, "seq B count = 1")

DaFree(dA)
FREE addrA&
DaFree(dB)
FREE addrB&

{* --- Test 5: Builder with iteration --- *}
PRINT "--- Builder + iteration ---"
DaNew(DA_SMALL)
rc% = DaAdd$("x")
rc% = DaAdd$("y")
rc% = DaAdd$("z")

LONGINT addr5&
addr5& = DaEnd

DECLARE CLASS DynArray d5
d5 = addr5&

DaIterReset(d5)
SHORTINT hasNext%
LONGINT iterCount&
iterCount& = 0

hasNext% = DaIterNext(d5)
WHILE hasNext%
  iterCount& = iterCount& + 1
  hasNext% = DaIterNext(d5)
WEND

TkAssertEq&(iterCount&, 3, "builder iter count = 3")

DaFree(d5)
FREE addr5&

{* --- Test 6: Builder capacity preserved --- *}
PRINT "--- Builder capacity ---"
DaNew(DA_LARGE)
rc% = DaAdd$("one")

LONGINT addr6&
addr6& = DaEnd

DECLARE CLASS DynArray d6
d6 = addr6&
TkAssertEq&(DaCapacity(d6), 256, "builder cap = DA_LARGE")
TkAssertEq&(DaCount(d6), 1, "builder count = 1")

DaFree(d6)
FREE addr6&

{* ============== Summary ============== *}
TkSummary
