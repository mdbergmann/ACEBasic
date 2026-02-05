' closure_callback.b - Test closure as callback (LMap-style)
' Callbacks must be INVOKABLE SUBs (return in d0)

DECLARE SUB LONGINT Transformer(LONGINT v) INVOKABLE
DECLARE SUB LONGINT MapValue(ADDRESS cb, LONGINT in) INVOKABLE

cb& = BIND(@Transformer)
result& = MapValue(cb&, 7)
ASSERT result& = 14, "Callback should double value"

PRINT "closure_callback: PASSED"

SUB LONGINT Transformer(LONGINT v) INVOKABLE
  Transformer = v * 2
END SUB

SUB LONGINT MapValue(ADDRESS cb, LONGINT in) INVOKABLE
  LONGINT res
  res = INVOKE cb(in)
  MapValue = res
END SUB
