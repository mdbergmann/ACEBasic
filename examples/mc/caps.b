'...Calling machine language from ACE.

'...This routine does the same thing as UCASE$
'...and is taken from the AmigaBASIC manual 
'...(6-12) with two modifications: (i) the correct
'...array size is 26 not 27; (ii) ACE demands that
'...a MC routine's address be stored in a long
'...integer variable, not single-precision as
'...in the AmigaBASIC manual's example.
 
DIM code%(26)

FOR i=0 to 26
   READ code%(i)
NEXT

INPUT "Mixed case string";S$
Ucase& = VARPTR(code%(0))
length& = LEN(S$) : addr&=SADD(S$)

CALL Ucase&(length&,addr&)

PRINT "The converted string is:"
PRINT S$

DATA &H48e7,&Hc080,&H202f,&H0010,&H206f,&H0014
DATA &H4281,&H6000,&H001c,&H1230,&H0000,&H0c01
DATA &H0061,&H6d00,&H0010,&H0c01,&H007a,&H6e00
DATA &H0008,&H0230,&H00df,&H0000,&H51c8,&Hffe4
DATA &H4cdf,&H0103,&H4e75
