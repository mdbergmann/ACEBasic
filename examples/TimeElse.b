Hour$ = Left$(Time$, 2)

If Hour$ < "12" Then
  Print "Good Morning World"
Else
  Print "Good Afternoon World"
End If