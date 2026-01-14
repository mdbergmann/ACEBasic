Window 1, "Draw and Fill (Press x to exit)", (0,0) - (400,300)
a = 10 : b = 10 : c = 100 : d = 100

Line(a,b)-(c,b)
Line(c,b)-(c,d)
Line(c,d)-(a,d)
Line(a,d)-(a,b)

Area (10,150)
Area Step (0, 100)
Area Step (100, 0)
Area Step (0, -100)
Areafill

Loop:
  I$ = INKEY$
  If I$ = "x" Then 
    Goto Quit
  End If
  Sleep
Goto Loop

Quit:
Window Close 1

