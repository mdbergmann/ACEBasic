Sub FindMax
  If (num1% > num2%) Then
    max% = num1%
  Else
    max% = num2%
  End If
End Sub

Input "Enter first number: ", num1%
Input "Enter second number: ", num2%

FindMax

Print "The maximum number is ", max%

End


