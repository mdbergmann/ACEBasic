' Test that bsdsocket.bmap was generated correctly
' by compiling a program that declares the library
LIBRARY "bsdsocket.library"
DECLARE FUNCTION socket& LIBRARY bsdsocket
PRINT "bsdsocket.library BMAP OK"
LIBRARY CLOSE "bsdsocket.library"
