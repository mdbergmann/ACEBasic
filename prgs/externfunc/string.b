{*
** Get a string from an externally referenced C function.
**
** bas -O string string.o
*}

DECLARE FUNCTION STRING foo() EXTERNAL

PRINT foo
