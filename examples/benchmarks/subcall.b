'..SUB call vs METHOD call benchmark.
'..Compares direct SUB calls against GENERIC METHOD dispatch.
'..The same operation (increment a counter) is performed via both
'..mechanisms to measure the overhead of runtime method dispatch.

CONST iterations = 50000

DEFLNG a-z
SINGLE t0, t1, tsub, tmethod

CLASS Counter
    LONGINT value
END CLASS

REM -- SUB version: direct call
SUB IncrSub(Counter c, LONGINT amount)
    c->value = c->value + amount
END SUB

REM -- METHOD version: dispatched via GENERIC
METHOD IncrMethod(Counter c, LONGINT amount)
    c->value = c->value + amount
END METHOD

GENERIC METHOD IncrMethod(CLASS, LONGINT)
    ON Counter
END GENERIC

REM -- main
DECLARE CLASS Counter cs
DECLARE CLASS Counter cm

PRINT "SUB call vs METHOD call benchmark"
PRINT "Iterations per run:"; iterations
PRINT

FOR r = 1 TO 5
    PRINT "Run"; r

    REM -- benchmark SUB calls
    cs->value = 0
    t0 = TIMER
    FOR i = 1 TO iterations
        IncrSub(cs, 1)
    NEXT
    t1 = TIMER
    tsub = t1 - t0

    REM -- benchmark METHOD calls
    cm->value = 0
    t0 = TIMER
    FOR i = 1 TO iterations
        IncrMethod(cm, 1)
    NEXT
    t1 = TIMER
    tmethod = t1 - t0

    PRINT "  SUB:   "; tsub; " seconds  (result:"; cs->value; ")"
    PRINT "  METHOD:"; tmethod; " seconds  (result:"; cm->value; ")"

    IF tsub > 0 THEN
        PRINT "  Ratio: "; tmethod / tsub; "x"
    END IF

    PRINT
NEXT
