REM Test: ATOM dispatch and mixed CLASS+ATOM dispatch

REM -- ATOM-only dispatch with return values
GENERIC LONGINT METHOD Process(ATOM)
    ON `ok
    ON `fail
    ON `retry
END GENERIC

METHOD LONGINT Process(`ok result)
    Process = 1
END METHOD

METHOD LONGINT Process(`fail result)
    Process = -1
END METHOD

METHOD LONGINT Process(`retry result)
    Process = 0
END METHOD

REM -- ATOM literal dispatch
LONGINT pv
pv = Process(`ok)
ASSERT pv = 1, "Process(`ok) should return 1"
pv = Process(`fail)
ASSERT pv = -1, "Process(`fail) should return -1"
pv = Process(`retry)
ASSERT pv = 0, "Process(`retry) should return 0"

REM -- ATOM variable dispatch
ATOM status
status = `ok
pv = Process(status)
ASSERT pv = 1, "Process(status=`ok) should return 1"
status = `fail
pv = Process(status)
ASSERT pv = -1, "Process(status=`fail) should return -1"

REM -- Mixed CLASS + ATOM dispatch with return values
CLASS Widget
    LONGINT id
END CLASS

CLASS Knob
    LONGINT id
END CLASS

GENERIC LONGINT METHOD React(CLASS, ATOM)
    ON Widget, `click
    ON Widget, `hover
    ON Knob, `click
END GENERIC

METHOD LONGINT React(Widget w, `click evt)
    React = 10 + w->id
END METHOD

METHOD LONGINT React(Widget w, `hover evt)
    React = 20 + w->id
END METHOD

METHOD LONGINT React(Knob b, `click evt)
    React = 30 + b->id
END METHOD

DECLARE CLASS Widget wg
DECLARE CLASS Knob bt
wg->id = 1
bt->id = 2

LONGINT rv
rv = React(wg, `click)
ASSERT rv = 11, "Widget click should return 11"
rv = React(wg, `hover)
ASSERT rv = 21, "Widget hover should return 21"
rv = React(bt, `click)
ASSERT rv = 32, "Knob click should return 32"

PRINT "generic_atom: ALL PASSED"
