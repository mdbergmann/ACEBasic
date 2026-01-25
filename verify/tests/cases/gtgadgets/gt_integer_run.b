' GadTools INTEGER_KIND runtime test
' Creates an integer gadget, sets number via SETATTR, reads back.
'
' Expected log (RAM:gt_integer_run.log):
'   PASS: integer created
'   PASS: number= 99
'   DONE

WINDOW 1,"Integer Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_integer_run.log"

GADGET 1,1,"Count:",(10,20)-(200,34),INTEGER_KIND,GTIN_Number=0,GTIN_MaxChars=10

PRINT #1,"PASS: integer created"

GADGET SETATTR 1,GTIN_Number=99

x& = GADGET GETATTR(1,GTIN_Number)
PRINT #1,"PASS: number=";x&

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
