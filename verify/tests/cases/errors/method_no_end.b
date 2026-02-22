REM Error test: METHOD without END METHOD (error 90)

CLASS Disc
  SINGLE radius
END CLASS

METHOD Draw(Disc c)
  PRINT "hello"
