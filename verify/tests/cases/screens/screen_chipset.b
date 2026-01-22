REM Test: CHIPSET detection function
REM Returns 0=OCS, 1=ECS, 2=AGA

c = CHIPSET

PRINT "Chipset detection test"
IF c = 0 THEN PRINT "OCS detected (Original Chip Set)"
IF c = 1 THEN PRINT "ECS detected (Enhanced Chip Set)"
IF c = 2 THEN PRINT "AGA detected (Advanced Graphics Architecture)"
PRINT "CHIPSET returned:"; c
