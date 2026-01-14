Window 1, "Multiple Boxes (Press x to exit)", (0,0) - (400,300)
a = 195 : b = 145 : c = 205 : d = 155

For i = 1 to 100 Step 5
  Line(a,b)-(c,b)
  Line(c,b)-(c,d)
  Line(c,d)-(a,d)
  Line(a,d)-(a,b)
  a = a - i : b = b - i : c = c + i : d = d + i
Next i

Loop:
  I$ = INKEY$
  If I$ = "x" Then 
    Goto Quit
  End If
  Sleep
Goto Loop

Quit:
Window Close 1

