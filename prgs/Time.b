Hour$ = Left$(Time$, 2)

If Hour$ < "12" Then
  Print "Good Morning World"
END IF
If Hour$ >= "12" Then
  Print "Good Afternoon World"
End If
