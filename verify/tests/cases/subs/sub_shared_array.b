REM Test: SUB with SHARED array
REM A SUB can access array elements via SHARED

DIM nums%(4)
nums%(0) = 1
nums%(1) = 2
nums%(2) = 3
nums%(3) = 4
nums%(4) = 5
CALL PrintArray

SUB PrintArray
  SHARED nums%
  FOR i% = 0 TO 4
    PRINT nums%(i%)
  NEXT i%
END SUB
