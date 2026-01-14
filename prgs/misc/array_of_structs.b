'..An example of how to have an array of structures.

DEFLNG a-z

CONST records=3

STRUCT myStructDef
  STRING the_name
  SHORTINT age
END STRUCT

DECLARE STRUCT myStructDef *myStruct

DIM myStructs(records)

'..read records
FOR i=1 TO records
  PRINT
  INPUT "Enter name: ",nm$
  INPUT "Enter age: ",age
  myStruct = ALLOC(SIZEOF(myStructDef))
  IF myStruct = 0& THEN BEEP:STOP
  myStruct->the_name = nm$
  myStruct->age = age
  myStructs(i) = myStruct
NEXT

'..show records
PRINT
FOR i=1 TO records
  myStruct = myStructs(i)
  PRINT "Name: ";myStruct->the_name;TAB(20);"Age: ";myStruct->age
NEXT
