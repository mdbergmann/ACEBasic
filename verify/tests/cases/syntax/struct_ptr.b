REM Test: Typed struct pointers as struct members

REM -- Define inner struct --
STRUCT Inner
  LONGINT x
  LONGINT y
END STRUCT

REM -- Define outer struct with typed pointer member --
STRUCT Outer
  Inner *ptr
  LONGINT z
END STRUCT

REM -- Define struct with both embedded and pointer members --
STRUCT Mixed
  Inner embedded
  Inner *ptr
  LONGINT w
END STRUCT

DECLARE STRUCT Outer o
DECLARE STRUCT Mixed m
DECLARE STRUCT Inner i

REM -- Test 1: assign to and read from struct pointer member --
REM allocate an Inner struct and point to it
o->ptr = ALLOC(SIZEOF(Inner))
ASSERT o->ptr <> 0, "alloc should succeed"

REM -- Test 2: access through typed pointer chain --
o->ptr->x = 42&
o->ptr->y = 99&
o->z = 77&

ASSERT o->ptr->x = 42, "ptr->x should be 42"
ASSERT o->ptr->y = 99, "ptr->y should be 99"
ASSERT o->z = 77, "z should be 77"

REM -- Test 3: pointer to existing struct (use struct var directly) --
i->x = 111&
i->y = 222&
o->ptr = i
ASSERT o->ptr->x = 111, "ptr->x should be 111 via i"
ASSERT o->ptr->y = 222, "ptr->y should be 222 via i"

REM -- Test 4: mixed embedded + pointer struct --
m->embedded->x = 10&
m->embedded->y = 20&
m->ptr = ALLOC(SIZEOF(Inner))
m->ptr->x = 30&
m->ptr->y = 40&
m->w = 50&

ASSERT m->embedded->x = 10, "mixed embedded->x should be 10"
ASSERT m->embedded->y = 20, "mixed embedded->y should be 20"
ASSERT m->ptr->x = 30, "mixed ptr->x should be 30"
ASSERT m->ptr->y = 40, "mixed ptr->y should be 40"
ASSERT m->w = 50, "mixed w should be 50"

REM -- Test 5: reading pointer value without chaining --
ADDRESS addr
addr = o->ptr
ASSERT addr <> 0, "ptr value should be non-zero"

PRINT "struct_ptr: ALL PASSED"
