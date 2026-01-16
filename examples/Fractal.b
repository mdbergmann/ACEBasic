x = 100
y = 100

For i = 1 to 100000
  r = rnd * 3
  ux = 150
  uy = 30

  If ( r = 1 ) Then
    ux = 30
    uy = 1000
  EndIf

  If ( r = 2 ) Then
    ux = 1000
    uy = 1000
  EndIf

  x = ( x + ux ) / 2
  y = ( y + uy ) / 2

  Pset(x,y), 1
Next i
