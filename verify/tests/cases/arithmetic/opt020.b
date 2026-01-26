OPTION 2+
REM Test: 68020 native long multiply, divide, modulo

REM === Long Multiplication ===
a& = 100000
b& = 50
PRINT a& * b&

a& = -3
b& = 7
PRINT a& * b&

a& = -4
b& = -5
PRINT a& * b&

a& = 0
b& = 99999
PRINT a& * b&

a& = 1
b& = 77777
PRINT a& * b&

REM === Long Integer Division ===
a& = 100000
b& = 3
PRINT a& \ b&

a& = -21
b& = 7
PRINT a& \ b&

a& = 0
b& = 5
PRINT a& \ b&

a& = 77777
b& = 1
PRINT a& \ b&

REM === Long Modulo ===
a& = 17
b& = 5
PRINT a& MOD b&

a& = 100
b& = 7
PRINT a& MOD b&

a& = 100000
b& = 3
PRINT a& MOD b&

a& = 21
b& = 7
PRINT a& MOD b&

REM === Short multiply still works (sanity) ===
x% = 6
y% = 7
PRINT x% * y%

REM === Combined expressions ===
a& = 10000
b& = 3
c& = 7
PRINT (a& * b&) \ c&

a& = 100
b& = 7
c& = 3
PRINT (a& MOD b&) * c&
