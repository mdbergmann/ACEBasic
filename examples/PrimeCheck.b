Sub PrimeCheck
  For j = 2 To Sqr( i )
    If ((i Mod j) = 0) Then
      isPrime$ = "False"
      Goto EndLoop
    End If
  Next j
EndLoop:
End Sub

Input "Enter a number: ", i
isPrime$ = "true"
Call PrimeCheck
If (isPrime$ = "true") Then
  Print i, " is a prime number"
Else
  Print i, " is not a prime number"
End If
End

