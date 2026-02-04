{*
** Test program for the Lisp-style List Library
*}

#include <submods/list.h>

EXTERNAL list

ADDRESS mylist, list2, list3, copy, reversed, cur
STRING s

PRINT "=== List Library Test ==="
PRINT

{* Test 1: Basic cons and car/cdr *}
PRINT "Test 1: Basic cons with integers"
mylist = LCons%(3, LNil)
mylist = LCons%(2, mylist)
mylist = LCons%(1, mylist)
PRINT "List (should be 1 2 3): ";
LDumpLn(mylist)
PRINT "Length (should be 3):"; LLen(mylist)
PRINT "First (should be 1):"; LCar%(mylist)
PRINT "Second (should be 2):"; LSecond%(mylist)
PRINT

{* Test 2: Builder pattern *}
PRINT "Test 2: Builder pattern"
LNew
LAdd%(10)
LAdd%(20)
LAdd%(30)
list2 = LEnd
PRINT "Built list (should be 10 20 30): ";
LDumpLn(list2)
PRINT

{* Test 3: Mixed types *}
PRINT "Test 3: Mixed types"
LNew
LAdd&(42&)
LAdd$("hello")
LAdd!(3.14!)
list3 = LEnd
PRINT "Mixed list: ";
LDumpLn(list3)
PRINT "Type of first (should be 2=LONG):"; LType(list3)
PRINT "Type of second (should be 4=STR):"; LType(LCdr(list3))
PRINT

{* Test 4: Iteration with type checking *}
PRINT "Test 4: Iterate with type checking"
cur = list3
WHILE NOT LNull(cur)
  IF LType(cur) = LTypeLng THEN
    PRINT "  LONG:"; LCar&(cur)
  ELSEIF LType(cur) = LTypeStr THEN
    PRINT "  STRING: "; LCar$(cur)
  ELSEIF LType(cur) = LTypeSng THEN
    PRINT "  SINGLE:"; LCar!(cur)
  END IF
  cur = LCdr(cur)
WEND
PRINT

{* Test 5: Copy semantics for strings *}
PRINT "Test 5: String copy semantics"
s = "original"
LNew
LAdd$(s)
list2 = LEnd
s = "changed"
PRINT "After changing source string to 'changed':"
PRINT "List still has: "; LCar$(list2)
LFree(list2)
PRINT

{* Test 6: Reverse *}
PRINT "Test 6: Non-destructive reverse"
reversed = LRev(mylist)
PRINT "Original: ";
LDumpLn(mylist)
PRINT "Reversed: ";
LDumpLn(reversed)
PRINT

{* Test 7: Copy *}
PRINT "Test 7: Deep copy"
copy = LCopy(mylist)
PRINT "Original: ";
LDumpLn(mylist)
PRINT "Copy: ";
LDumpLn(copy)
PRINT

{* Test 8: LNth *}
PRINT "Test 8: LNth (0-indexed)"
PRINT "mylist[0]:"; LCar%(LNth(mylist, 0))
PRINT "mylist[1]:"; LCar%(LNth(mylist, 1))
PRINT "mylist[2]:"; LCar%(LNth(mylist, 2))
PRINT "mylist[3] (should be nil):"; LNth(mylist, 3)
PRINT

{* Test 9: Snoc (append) *}
PRINT "Test 9: Snoc (append to end)"
list2 = LNil
list2 = LSnoc%(1, list2)
list2 = LSnoc%(2, list2)
list2 = LSnoc%(3, list2)
PRINT "Built with snoc (should be 1 2 3): ";
LDumpLn(list2)
LFree(list2)
PRINT

{* Test 10: Destructive reverse *}
PRINT "Test 10: Destructive reverse (LNrev)"
LNew
LAdd%(1)
LAdd%(2)
LAdd%(3)
list2 = LEnd
PRINT "Before LNrev: ";
LDumpLn(list2)
list2 = LNrev(list2)
PRINT "After LNrev: ";
LDumpLn(list2)
PRINT

{* Clean up *}
PRINT "Freeing memory..."
LFree(mylist)
LFree(list2)
LFree(list3)
LFree(copy)
LFree(reversed)

PRINT
PRINT "=== All tests complete ==="
