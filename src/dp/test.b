{*
** Test of Double-Precision math library for ACE.
** 
** See comments in dp_main.s and dp_val.c for more.
*}

#include "dp.h"

{* Preliminaries *}

Address d1,d2,d3,dr
Longint n,n1,n2,nr
Single s,sr

'..Open the DP libraries.
If Not dp_open Then 
  Print "Unable to open DP libraries!"
  Stop
End If

'..Allocate memory for DP variables.
d = dp_new
d1 = dp_new
d2 = dp_new
d3 = dp_new
dr = dp_new
If d = NULL Or d1 = NULL Or d2 = NULL Or dr = NULL Then
  Print "Unable to allocate DOUBLE variables."
  Stop
End If

{* A bunch of tests *}

'..LONGINT <-> DOUBLE.
n = 1234567
dp_longint_to_double(dr,n)
dp_double_to_longint(@nr,dr)
Print "LONGINT <-> DOUBLE:";nr

'..SINGLE <-> DOUBLE.
s = 56.75
dp_single_to_double(dr,s)
dp_double_to_single(@sr,dr)
Print "SINGLE <-> DOUBLE:";sr

'..Make some of DP values we can use.
dp_longint_to_double(d1,21&)
dp_longint_to_double(d2,3&)
dp_single_to_double(d3,-34.78)
Print "d1 = 21  d2 = 3  d3 = -34.78"

'..Addition.
dp_add(dr,d1,d2)
dp_double_to_longint(@nr,dr)
Print "d1+d2 ";nr

'..Subtraction.
dp_sub(dr,d1,d2)
dp_double_to_longint(@nr,dr)
Print "d1-d2 ";nr

'..Multiplication.
dp_mul(dr,d1,d2)
dp_double_to_longint(@nr,dr)
dp_double_to_single(@sr,dr)
Print "d1*d2 ";nr;sr

'..Division.
dp_div(dr,d1,d2)
dp_double_to_longint(@nr,dr)
dp_double_to_single(@sr,dr)
Print "d1/d2 ";nr;sr

'..Exponentiation.
dp_pow(dr,d1,d2)
dp_double_to_longint(@nr,dr)
dp_double_to_single(@sr,dr)
Print "d1^d2 ";nr;sr

'..Comparison.
dp_cmp(@nr,d1,d2)
Print "d1<=>d2 ";nr

'..Absolute value.
dp_abs(dr,d3)
dp_double_to_single(@sr,dr)
Print "ABS d3";sr

'..Negation.
dp_neg(dr,d3)
dp_double_to_single(@sr,dr)
Print "-d3 ";sr

'..Least integer >= argument.
dp_ceil(dr,d3)
dp_double_to_longint(@nr,dr)
Print "CEIL d3 ";nr

'..Largest integer <= argument.
dp_floor(dr,d3)
dp_double_to_longint(@nr,dr)
Print "FLOOR d3 ";nr

'..Sin, cos, tan, natural log, exp, square root.
dp_sin(dr,d1)
dp_double_to_single(@sr,dr)
Print "SIN d1 ";sr

dp_cos(dr,d1)
dp_double_to_single(@sr,dr)
Print "COS d1 ";sr

dp_tan(dr,d1)
dp_double_to_single(@sr,dr)
Print "TAN d1 ";sr

dp_log(dr,d1)
dp_double_to_single(@sr,dr)
Print "LOG d1 ";sr

dp_exp(dr,d1)
dp_double_to_single(@sr,dr)
Print "EXP d1 ";sr

dp_sqrt(dr,d1)
dp_double_to_single(@sr,dr)
Print "SQR d1 ";sr

dp_val(dr,"-12.5e2")
dp_double_to_single(@sr,dr)
Print "String Parse: ";sr

'..Clean up.
dp_close
