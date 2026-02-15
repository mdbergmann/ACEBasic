REM Test: Typed arrays in struct members (BYTE/SHORT/LONG/SINGLE SIZE n)

STRUCT ArrayStruct
  BYTE buf SIZE 16
  LONGINT vals SIZE 4
  SHORTINT flags SIZE 8
  SINGLE coords SIZE 3
  STRING tag SIZE 32
  LONGINT scalar
END STRUCT

DECLARE STRUCT ArrayStruct s

REM -- Test BYTE array: write and read via PEEK/POKE --
POKE @s->buf, 65
POKE @s->buf + 1, 66
POKE @s->buf + 2, 67
ASSERT PEEK(@s->buf) = 65, "BYTE array element 0 should be 65"
ASSERT PEEK(@s->buf + 1) = 66, "BYTE array element 1 should be 66"
ASSERT PEEK(@s->buf + 2) = 67, "BYTE array element 2 should be 67"

REM -- Test LONGINT array: write and read via PEEKL/POKEL --
POKEL @s->vals, 100&
POKEL @s->vals + 4, 200&
POKEL @s->vals + 8, 300&
POKEL @s->vals + 12, 400&
ASSERT PEEKL(@s->vals) = 100, "LONGINT array element 0 should be 100"
ASSERT PEEKL(@s->vals + 4) = 200, "LONGINT array element 1 should be 200"
ASSERT PEEKL(@s->vals + 8) = 300, "LONGINT array element 2 should be 300"
ASSERT PEEKL(@s->vals + 12) = 400, "LONGINT array element 3 should be 400"

REM -- Test SHORTINT array: write and read via PEEKW/POKEW --
POKEW @s->flags, 1
POKEW @s->flags + 2, 0
POKEW @s->flags + 4, 1
ASSERT PEEKW(@s->flags) = 1, "SHORTINT array element 0 should be 1"
ASSERT PEEKW(@s->flags + 2) = 0, "SHORTINT array element 1 should be 0"
ASSERT PEEKW(@s->flags + 4) = 1, "SHORTINT array element 2 should be 1"

REM -- Test scalar member still works alongside arrays --
s->scalar = 42&
ASSERT s->scalar = 42, "Scalar member should be 42"

REM -- Test STRING SIZE still works (backward compat) --
s->tag = "hello"
ASSERT s->tag = "hello", "STRING SIZE member should work"

PRINT "struct_array: ALL PASSED"
