'...Recursive factorial.

Defsng f,n,x

Sub fact(n)
  If n<2 Then fact=1 Else fact=n*fact(n-1)
End Sub

Repeat
  Print
  Repeat
    Input "Enter an integer (0 or higher, -1 to stop): ",x
  Until x>=-1
  If x<>-1 Then Print "-->>";fact(x)
Until x=-1
