REM Test: RINSTR, STARTSWITH, ENDSWITH functions

REM STARTSWITH - basic match
ASSERT STARTSWITH("Hello World", "Hello"), "starts with Hello"

REM STARTSWITH - no match
ASSERT STARTSWITH("Hello World", "World") = 0, "does not start with World"

REM STARTSWITH - empty prefix always matches
ASSERT STARTSWITH("Hello", ""), "empty prefix matches"

REM STARTSWITH - prefix longer than string
ASSERT STARTSWITH("Hi", "Hello") = 0, "prefix longer than string"

REM ENDSWITH - basic match
ASSERT ENDSWITH("Hello World", "World"), "ends with World"

REM ENDSWITH - no match
ASSERT ENDSWITH("Hello World", "Hello") = 0, "does not end with Hello"

REM ENDSWITH - empty suffix always matches
ASSERT ENDSWITH("Hello", ""), "empty suffix matches"

REM ENDSWITH - suffix longer than string
ASSERT ENDSWITH("Hi", "Hello") = 0, "suffix longer than string"

REM RINSTR - find last occurrence
ASSERT RINSTR("abcabc", "bc") = 5, "RINSTR find last bc"

REM RINSTR - find from start (only one occurrence)
ASSERT RINSTR("hello world", "world") = 7, "RINSTR find world"

REM RINSTR - not found
ASSERT RINSTR("hello", "xyz") = 0, "RINSTR not found"

REM RINSTR - with offset
ASSERT RINSTR(3, "abcabc", "bc") = 2, "RINSTR with offset"

REM RINSTR - single char
ASSERT RINSTR("abcabc", "c") = 6, "RINSTR single char"

REM STARTSWITH - exact match (string equals prefix)
ASSERT STARTSWITH("hello", "hello"), "starts exact match"

REM ENDSWITH - exact match (string equals suffix)
ASSERT ENDSWITH("hello", "hello"), "ends exact match"

REM STARTSWITH - empty string
ASSERT STARTSWITH("", "") , "starts empty both"
ASSERT STARTSWITH("", "a") = 0, "starts empty str"

REM ENDSWITH - empty string
ASSERT ENDSWITH("", ""), "ends empty both"
ASSERT ENDSWITH("", "a") = 0, "ends empty str"

REM RINSTR - empty find string returns 0
ASSERT RINSTR("hello", "") = 0, "RINSTR empty find"

REM RINSTR - single char string
ASSERT RINSTR("a", "a") = 1, "RINSTR single char str"
ASSERT RINSTR("a", "b") = 0, "RINSTR single no match"
