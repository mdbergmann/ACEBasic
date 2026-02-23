REM -- test_method_trace.b: METHOD tracing test --
REM Compile with: bas -Et test_method_trace
REM Trace output goes to T:ace_trace.log

OPTION t+

CLASS Disc
    SINGLE radius
END CLASS

CLASS Box
    LONGINT w
    LONGINT h
END CLASS

METHOD Draw(Disc s)
    PRINT "Draw Disc r="; s->radius
END METHOD

METHOD Draw(Box s)
    PRINT "Draw Box"; s->w; "x"; s->h
END METHOD

METHOD LONGINT GetSize(Disc s)
    GetSize = 1
END METHOD

METHOD LONGINT GetSize(Box s)
    GetSize = s->w * s->h
END METHOD

GENERIC METHOD Draw(CLASS)
    ON Disc
    ON Box
END GENERIC

GENERIC LONGINT METHOD GetSize(CLASS)
    ON Disc
    ON Box
END GENERIC

DECLARE CLASS Disc d
DECLARE CLASS Box b

d->radius = 3.0
b->w = 10
b->h = 20

REM -- traced calls --
Draw(d)
Draw(b)

LONGINT result
result = GetSize(d)
PRINT "Disc size:"; result
result = GetSize(b)
PRINT "Box size:"; result

REM -- also test SUB with trace --
SUB LONGINT BoxArea(Box obj)
    BoxArea = obj->w * obj->h
END SUB

result = BoxArea(b)
PRINT "BoxArea:"; result

REM -- test TRON/TROFF in method context --
TROFF
Draw(d)
TRON
Draw(b)
TROFF

PRINT "Done."
