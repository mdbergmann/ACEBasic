Dim name$(10)

For i = 1 To 5
  Input"Enter user name: ", name$(i)
Next i

Print "Hello, ",
For i = 1 To 5
  Print name$(i),
Next i
