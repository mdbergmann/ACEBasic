JSON Submodule for ACE BASIC
============================

A JSON parser and generator for ACE BASIC. Parses JSON strings or files
into Hashmap (objects) and DynArray (arrays) structures, and generates
JSON output from those same structures.

Depends on the hashmap and dynarray submodules.


Overview
--------

Parse a JSON string, query the result via the Hashmap/DynArray API,
then free the tree when done:

    #include <submods/json.h>

    STRING src$ SIZE 4096
    LONGINT root&
    DECLARE CLASS Hashmap hm

    src$ = "{" + CHR$(34) + "city" + CHR$(34) + ":"
    src$ = src$ + CHR$(34) + "Berlin" + CHR$(34) + "}"

    root& = JsParse(src$)
    IF root& <> 0 THEN
      hm = root&
      PRINT HmGet$(hm, "city")   ' Berlin
      JsFree(root&)
    ELSE
      PRINT JsError$
    END IF

Build JSON programmatically and output it:

    DECLARE CLASS Hashmap hm
    HmMake(hm, HM_SMALL)
    HmPut$(hm, "city", "Berlin")
    HmPut&(hm, "pop", 3700000)
    HmPutBool(hm, "capital", -1)

    STRING result$ SIZE 4096
    result$ = JsToStr$(hm)
    ' -> {"city":"Berlin","pop":3700000,"capital":true}

    HmFree(hm)

See the test files for comprehensive examples of every feature.


Include and Link
----------------

    REM #using ace:submods/hashmap/hashmap.o
    REM #using ace:submods/dynarray/dynarray.o
    REM #using ace:submods/json/json.o

    #include <submods/json.h>


Parsing
-------

JsParse parses a JSON string and returns a LONGINT address (0 on error).
JsParseFile parses from an open file channel.

    root& = JsParse(src$)

    OPEN "I", #1, "data.json"
    root& = JsParseFile(1)
    CLOSE #1

Check JsRootType to determine whether the root is an object or array,
then cast to the appropriate CLASS:

    IF JsRootType = JsObject THEN
      DECLARE CLASS Hashmap hm
      hm = root&
      PRINT HmGet$(hm, "name")
      PRINT HmGet&(hm, "age")
    ELSEIF JsRootType = JsArray THEN
      DECLARE CLASS DynArray da
      da = root&
      PRINT DaGet$(da, 0)
    END IF

On parse failure, JsError$ returns a description of the error.


Supported Value Types
---------------------

The parser stores values using the native Hashmap/DynArray typed API:

  JSON type    Storage          Object put/get        Array append/get
  ---------    -------          ----------            ----------------
  string       STRING           HmPut$/HmGet$         DaAppend$/DaGet$
  integer      LONGINT          HmPut&/HmGet&         DaAppend&/DaGet&
  float        SINGLE           HmPut!/HmGet!         DaAppend!/DaGet!
  boolean      LONGINT (-1/0)   HmPutBool/HmGet&      DaAppendBool/DaGet&
  null         (type only)      HmPutNull             DaAppendNull
  object/array ADDRESS          HmPutRef/HmGetRef     DaAppendRef/DaGetRef

String escapes are handled in both parsing and generation:
  \"  \\  \/  \n  \r  \t  \b  \f

Use HmType / DaType to check the type tag of any entry at runtime.


Nested Structures
-----------------

Nested objects and arrays are stored as refs. Retrieve them with
HmGetRef / DaGetRef and cast to the appropriate CLASS:

    LONGINT child&
    child& = HmGetRef(hm, "address")
    DECLARE CLASS Hashmap inner
    inner = child&
    PRINT HmGet$(inner, "city")

TYPECASE can also be used to discriminate object vs array refs.
See test_parse_arr.b for examples.


Generating JSON
---------------

Build structures with the Hashmap/DynArray API, then generate output.

To string (max 4096 chars):

    result$ = JsToStr$(hm)

To file (compact, no whitespace):

    OPEN "O", #1, "out.json"
    JsWrite(hm, 1)
    CLOSE #1

To file (pretty-printed with 2-space indentation):

    OPEN "O", #1, "out.json"
    JsWriteFmt(hm, 1)
    CLOSE #1

Nested structures use HmPutRef / DaAppendRef:

    DECLARE CLASS DynArray nums
    DaMake(nums, DA_SMALL)
    DaAppend&(nums, 10)
    DaAppend&(nums, 20)

    HmMake(hm, HM_SMALL)
    HmPutRef(hm, "nums", nums)
    result$ = JsToStr$(hm)
    ' -> {"nums":[10,20]}

See test_gen.b and test_roundtrip.b for more examples.


Cleanup
-------

JsFree recursively frees a parsed JSON tree — all nested objects,
arrays, and their children. It is null-safe.

    root& = JsParse(src$)
    ' ... use the data ...
    JsFree(root&)

For manually built structures (not from JsParse), free them with
HmFree / DaFree as usual.

See test_free.b for cleanup examples.


Convenience Constructors
------------------------

JsMakeObj and JsMakeArr create JSON-ready containers:

    DECLARE CLASS Hashmap hm
    DECLARE CLASS DynArray da
    JsMakeObj(hm, 16)    ' object with capacity 16
    JsMakeArr(da, 8)      ' array with capacity 8


Constants
---------

Error codes:
  JS_SUCCESS       =  0    No error
  JS_ERR_SYNTAX    = -1    Syntax error
  JS_ERR_DEPTH     = -2    Nesting too deep
  JS_ERR_OVERFLOW  = -3    Input too large
  JS_ERR_IO        = -4    File I/O error

Root type:
  JsObject = 0    Root is a JSON object ({})
  JsArray  = 1    Root is a JSON array ([])

Limits:
  JS_MAX_INPUT = 8192    Max input size in bytes
  JS_MAX_DEPTH = 10      Max nesting depth


Building the Module
-------------------

On Amiga (or emulator):

    cd ACE:submods/json
    bas -mO json

This compiles json.b as a module, producing json.o.


Running Tests
-------------

On Amiga (or emulator):

    cd ACE:submods
    rx runner.rexx json

7 test suites covering parsing, generation, pretty-printing,
round-trip verification, cleanup, and TYPECASE discrimination.


Files
-----

json.b              - Library source code (~920 lines)
json.o              - Compiled module (after building)
make                - Build script
test_typecase.b     - TYPECASE discrimination on Hashmap/DynArray
test_parse_obj.b    - Parse objects: all scalar types, error cases
test_parse_arr.b    - Parse arrays: nesting, floats, deep structures
test_parse_misc.b   - Escape sequences, file input, edge cases
test_gen.b          - Generate compact JSON, escaping, nesting
test_roundtrip.b    - Pretty-printing, parse-generate-parse cycles
test_free.b         - Recursive free, convenience constructors
README.txt          - This file

include/submods/json.h - Header file with declarations


Function Reference
------------------

See include/submods/json.h for full declarations.

Parser:
  JsParse(src$)              Parse JSON string -> LONGINT (0 on error)
  JsParseFile(ch%)           Parse from open file channel -> LONGINT
  JsError$                   Last error message -> STRING
  JsRootType                 Root type -> JsObject or JsArray

Generator:
  JsWrite(root&, ch%)        Write compact JSON to file channel
  JsWriteFmt(root&, ch%)     Write pretty-printed JSON to file channel
  JsToStr$(root&)            Convert to compact JSON string (max 4096)

Cleanup:
  JsFree(root&)              Recursively free parsed JSON tree

Convenience:
  JsMakeObj(hm, cap&)        Initialize Hashmap for JSON use
  JsMakeArr(da, cap&)        Initialize DynArray for JSON use
