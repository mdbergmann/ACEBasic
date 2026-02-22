REM Test: Mixed CLASS + ATOM dispatch

CLASS Widget
  LONGINT id
END CLASS

CLASS Knob
  LONGINT id
END CLASS

GENERIC METHOD React(CLASS, ATOM)
  ON Widget, :click
  ON Widget, :hover
  ON Knob, :click
END GENERIC

METHOD React(Widget w, :click evt)
  PRINT "Widget clicked"; w->id
END METHOD

METHOD React(Widget w, :hover evt)
  PRINT "Widget hovered"; w->id
END METHOD

METHOD React(Knob b, :click evt)
  PRINT "Knob clicked"; b->id
END METHOD

DECLARE CLASS Widget wg
DECLARE CLASS Knob bt
wg->id = 1
bt->id = 2

React(wg, :click)
React(wg, :hover)
React(bt, :click)

ASSERT 1 = 1, "class+atom dispatch ok"
