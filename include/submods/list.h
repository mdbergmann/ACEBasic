{*
** Header for Lisp-style List Library
** Include this when using EXTERNAL list
**
** Singly-linked lists with type tags supporting SHORTINT, LONGINT,
** SINGLE, STRING, and nested lists. Strings are copied on insertion.
**
** Usage:
**   #include <submods/list.h>
**   EXTERNAL list
**   ...
**   LInit              ' Must call before using library
**   lst = LCons%(1, LCons%(2, LNil))
**   PRINT LCar%(lst)
**   LFree(lst)
**   LCleanup           ' Call when done
*}

{* ============== Constants ============== *}

CONST LNil = 0

' Type tags (returned by LType)
CONST LTypeNil = 0
CONST LTypeInt = 1
CONST LTypeLng = 2
CONST LTypeSng = 3
CONST LTypeStr = 4
CONST LTypeList = 5

{* ============== Initialization ============== *}

' LInit - Open exec.library, must call before using any list functions
DECLARE SUB LInit EXTERNAL

' LCleanup - Close exec.library, call when done with lists
DECLARE SUB LCleanup EXTERNAL

{* ============== Cell Creation - Prepend (O(1)) ============== *}

' LCons - Create new cell with value, prepend to tail list
' Returns new list with value as first element
' Type suffixes: % SHORTINT, & LONGINT, ! SINGLE, $ STRING
DECLARE SUB ADDRESS LCons%(SHORTINT v, ADDRESS tail) EXTERNAL
DECLARE SUB ADDRESS LCons&(LONGINT v, ADDRESS tail) EXTERNAL
DECLARE SUB ADDRESS LCons!(SINGLE v, ADDRESS tail) EXTERNAL
DECLARE SUB ADDRESS LCons$(src$, ADDRESS tail) EXTERNAL
DECLARE SUB ADDRESS LConsList(ADDRESS ptr, ADDRESS tail) EXTERNAL

{* ============== Cell Creation - Append (O(n)) ============== *}

' LSnoc - Append value to end of list (slow for long lists)
' Returns the list with new element at end
DECLARE SUB ADDRESS LSnoc%(SHORTINT v, ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LSnoc&(LONGINT v, ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LSnoc!(SINGLE v, ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LSnoc$(src$, ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LSnocList(ADDRESS ptr, ADDRESS lst) EXTERNAL

{* ============== Accessors ============== *}

' LCar - Get value of first cell (head of list)
' Use matching type suffix for the cell's type
DECLARE SUB SHORTINT LCar%(ADDRESS lst) EXTERNAL
DECLARE SUB LONGINT LCar&(ADDRESS lst) EXTERNAL
DECLARE SUB SINGLE LCar!(ADDRESS lst) EXTERNAL
DECLARE SUB STRING LCar$(ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LCar(ADDRESS lst) EXTERNAL

' LCdr/LRest - Get tail of list (everything after first element)
' Returns LNil if list is empty or has one element
DECLARE SUB ADDRESS LCdr(ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LRest(ADDRESS lst) EXTERNAL

{* ============== Convenience Accessors ============== *}

' LFirst - Alias for LCar (get first element)
DECLARE SUB SHORTINT LFirst%(ADDRESS lst) EXTERNAL
DECLARE SUB LONGINT LFirst&(ADDRESS lst) EXTERNAL
DECLARE SUB SINGLE LFirst!(ADDRESS lst) EXTERNAL
DECLARE SUB STRING LFirst$(ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LFirst(ADDRESS lst) EXTERNAL

' LSecond - Get second element (equivalent to LCar(LCdr(lst)))
DECLARE SUB SHORTINT LSecond%(ADDRESS lst) EXTERNAL
DECLARE SUB LONGINT LSecond&(ADDRESS lst) EXTERNAL
DECLARE SUB SINGLE LSecond!(ADDRESS lst) EXTERNAL
DECLARE SUB STRING LSecond$(ADDRESS lst) EXTERNAL
DECLARE SUB ADDRESS LSecond(ADDRESS lst) EXTERNAL

{* ============== Predicates & Info ============== *}

' LNull - Returns true (-1) if list is empty (LNil), false (0) otherwise
DECLARE SUB SHORTINT LNull(ADDRESS lst) EXTERNAL

' LType - Returns type tag of first cell (LTypeInt, LTypeLng, etc.)
DECLARE SUB SHORTINT LType(ADDRESS lst) EXTERNAL

' LLen - Returns number of elements in list
DECLARE SUB LONGINT LLen(ADDRESS lst) EXTERNAL

{* ============== Builder Pattern ============== *}

' Builder pattern for creating lists in natural order:
'   LNew             ' Start new list
'   LAdd%(1)         ' Add elements in order
'   LAdd%(2)
'   lst = LEnd       ' Get completed list

DECLARE SUB LNew EXTERNAL
DECLARE SUB LAdd%(SHORTINT v) EXTERNAL
DECLARE SUB LAdd&(LONGINT v) EXTERNAL
DECLARE SUB LAdd!(SINGLE v) EXTERNAL
DECLARE SUB LAdd$(src$) EXTERNAL
DECLARE SUB LAddList(ADDRESS ptr) EXTERNAL
DECLARE SUB ADDRESS LEnd EXTERNAL

{* ============== List Operations - Non-destructive ============== *}

' LAppend - Concatenate two lists, returns new list (shares tail with b)
DECLARE SUB ADDRESS LAppend(ADDRESS a, ADDRESS b) EXTERNAL

' LRev - Return reversed copy of list (original unchanged)
DECLARE SUB ADDRESS LRev(ADDRESS lst) EXTERNAL

' LCopy - Return deep copy of list
DECLARE SUB ADDRESS LCopy(ADDRESS lst) EXTERNAL

' LNth - Return nth cell (0-indexed), LNil if n >= length
DECLARE SUB ADDRESS LNth(ADDRESS lst, SHORTINT n) EXTERNAL

{* ============== List Operations - Destructive ============== *}

' LNconc - Destructively append b to end of a (modifies a)
DECLARE SUB LNconc(ADDRESS a, ADDRESS b) EXTERNAL

' LNrev - Destructively reverse list in place, returns new head
DECLARE SUB ADDRESS LNrev(ADDRESS lst) EXTERNAL

' LFree - Free all cells in list (recursively frees nested lists and strings)
' WARNING: Do not separately free nested lists that are part of another list
DECLARE SUB LFree(ADDRESS lst) EXTERNAL

{* ============== Debugging ============== *}

' LDump/LDumpLn - Print list contents (LDumpLn adds newline)
DECLARE SUB LDump(ADDRESS lst) EXTERNAL
DECLARE SUB LDumpLn(ADDRESS lst) EXTERNAL

{* ============== Higher-Order Functions ============== *}
{*
** Generic higher-order functions - work with all list types.
** Callbacks receive (carValue, typeTag) to handle any element type.
**
** IMPORTANT: Callbacks must be:
**   1. Declared with INVOKABLE keyword
**   2. Passed using BIND(@callback)
**
** Example:
**   SUB ADDRESS DoubleIt(ADDRESS val, SHORTINT tag) INVOKABLE
**     DoubleIt = val * 2
**   END SUB
**   ...
**   mapped = LMap(lst, BIND(@DoubleIt))
**
** Type interpretation for carValue (ADDRESS):
**   LTypeInt (1): SHORTINT value stored as ADDRESS
**   LTypeLng (2): LONGINT value stored as ADDRESS
**   LTypeSng (3): SINGLE (FFP) bit pattern - use POKEL/PEEKL to convert
**   LTypeStr (4): Pointer to null-terminated string - use CSTR()
**   LTypeList (5): Pointer to nested list
*}

' LMap - Apply function to each element, return NEW list
' fn signature: SUB ADDRESS fn(ADDRESS carValue, SHORTINT typeTag) INVOKABLE
' Pass callback as: BIND(@fn)
' Callback returns new carValue (same type as input).
' Original list unchanged. Caller must free returned list.
DECLARE SUB ADDRESS LMap(ADDRESS lst, ADDRESS fun) EXTERNAL

' LFilter - Return NEW list with elements where predicate is true
' fn signature: SUB SHORTINT fn(ADDRESS carValue, SHORTINT typeTag) INVOKABLE
' Pass callback as: BIND(@fn)
' Callback returns non-zero to keep element.
' Original list unchanged. Caller must free returned list.
DECLARE SUB ADDRESS LFilter(ADDRESS lst, ADDRESS fun) EXTERNAL

' LReduce - Fold list into single value using accumulator
' fn signature: SUB ADDRESS fn(ADDRESS acc, ADDRESS carValue, SHORTINT typeTag) INVOKABLE
' Pass callback as: BIND(@fn)
' Callback returns new accumulator value.
DECLARE SUB ADDRESS LReduce(ADDRESS lst, ADDRESS fun, ADDRESS initial) EXTERNAL

' LForEach - Call function for each element (side effects only)
' fn signature: SUB fn(ADDRESS carValue, SHORTINT typeTag) INVOKABLE
' Pass callback as: BIND(@fn)
DECLARE SUB LForEach(ADDRESS lst, ADDRESS fun) EXTERNAL

{* ============== Destructive Higher-Order Functions ============== *}

' LNmap - Apply function IN PLACE (modifies original list)
' fn signature: SUB ADDRESS fn(ADDRESS carValue, SHORTINT typeTag) INVOKABLE
' Pass callback as: BIND(@fn)
' Callback returns new carValue (same type).
' No new list created - original cells modified.
DECLARE SUB LNmap(ADDRESS lst, ADDRESS fun) EXTERNAL

' LNfilter - Filter list IN PLACE, freeing removed cells
' fn signature: SUB SHORTINT fn(ADDRESS carValue, SHORTINT typeTag) INVOKABLE
' Pass callback as: BIND(@fn)
' Callback returns non-zero to keep element.
' Returns new head (may differ if first elements removed).
' WARNING: Original list variable may become invalid - use returned head!
DECLARE SUB ADDRESS LNfilter(ADDRESS lst, ADDRESS fun) EXTERNAL
