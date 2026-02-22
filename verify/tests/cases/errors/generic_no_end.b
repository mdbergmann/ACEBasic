REM Error test: GENERIC without END GENERIC (error 94)

CLASS Disc
  SINGLE radius
END CLASS

GENERIC METHOD Draw(CLASS)
  ON Disc
