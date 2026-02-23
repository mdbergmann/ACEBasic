REM Test: CLASS embedded in CLASS and CLASS pointer in CLASS

CLASS Inner
  LONGINT a
  LONGINT b
END CLASS

REM -- CLASS with embedded class member --
CLASS Outer
  Inner nested
  LONGINT c
END CLASS

REM -- CLASS with class pointer member --
CLASS Holder
  Inner *ref
  LONGINT tag
END CLASS

REM -- Test 1: embedded class in class --
DECLARE CLASS Outer o
o->nested->a = 10
o->nested->b = 20
o->c = 30

ASSERT o->nested->a = 10, "outer nested->a should be 10"
ASSERT o->nested->b = 20, "outer nested->b should be 20"
ASSERT o->c = 30, "outer c should be 30"

REM -- Test 2: both outer and inner have type IDs --
ASSERT PEEKL(o) <> 0, "outer type ID should be non-zero"

REM -- Test 3: class pointer in class --
DECLARE CLASS Holder h
DECLARE CLASS Inner i1
i1->a = 42
i1->b = 99
h->ref = i1
h->tag = 7

ASSERT h->ref->a = 42, "holder ref->a should be 42"
ASSERT h->ref->b = 99, "holder ref->b should be 99"
ASSERT h->tag = 7, "holder tag should be 7"

REM -- Test 4: class pointer via ALLOC --
h->ref = ALLOC(SIZEOF(Inner))
ASSERT h->ref <> 0, "alloc should succeed"
h->ref->a = 111
h->ref->b = 222
ASSERT h->ref->a = 111, "alloc ref->a should be 111"
ASSERT h->ref->b = 222, "alloc ref->b should be 222"

REM -- Test 5: independence - original instance unaffected --
ASSERT i1->a = 42, "i1->a still 42 after pointer change"
ASSERT i1->b = 99, "i1->b still 99 after pointer change"

PRINT "class_class_member: ALL PASSED"
