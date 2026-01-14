Window 1, "MyWindow", (0,0) - (200,200)

Color 4, 0
Line(10,10)-(100,100)
Color 2, 0
Line(10,100)-(100,10)

Loop:
  I$ = INKEY$
  If I$ = "x" Then 
    Goto Quit
  End If
  Sleep
Goto Loop

Quit:
Window Close 1

