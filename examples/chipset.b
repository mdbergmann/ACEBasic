
'..Chipset detection example for ACE BASIC.
'..Demonstrates the CHIPSET function to detect Amiga graphics chipset.

DEFLNG c

c = CHIPSET

PRINT "Amiga Chipset Detection"
PRINT "======================"
PRINT

IF c = 0 THEN
  PRINT "OCS (Original Chip Set) detected"
  PRINT "Systems: A500, A1000, A2000"
  PRINT "Max colors: 32 (normal), 64 (EHB/HAM6)"
ELSEIF c = 1 THEN
  PRINT "ECS (Enhanced Chip Set) detected"
  PRINT "Systems: A600, A3000"
  PRINT "Max colors: 32 (normal), 64 (EHB/HAM6)"
ELSEIF c = 2 THEN
  PRINT "AGA (Advanced Graphics Architecture) detected"
  PRINT "Systems: A1200, A4000, CD32"
  PRINT "Max colors: 256 (normal), 262144 (HAM8)"
  PRINT
  PRINT "AGA screen modes 7-12 are available:"
  PRINT "  Mode 7: Lores 256-color"
  PRINT "  Mode 8: Hires 256-color"
  PRINT "  Mode 9: Super-hires"
  PRINT "  Mode 10: HAM8 lores"
  PRINT "  Mode 11: HAM8 hires"
  PRINT "  Mode 12: HAM8 super-hires"
END IF

PRINT
PRINT "CHIPSET function returned:"; c
