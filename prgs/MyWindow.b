Window 1, "MyWindow", (0,0) - (100,100)
Loop:
  x = Int(Rnd * 100)
  y = Int(Rnd * 100)
  Pset(x,y),Rnd*6
  I$ = INKEY$
  If I$ = "x" Then 
    Goto Quit
  End If
  Sleep
Goto Loop
Quit:
Window Close 1

