#include <SUBmods/ListBox.h>

CONST MAXITEMS = 10

DIM STRING theItems(MAXITEMS) SIZE LISTBOX_ITEM_STRINGSIZE
FOR i=1 TO MAXITEMS:READ theItems(i):NEXT
DATA "This is the first string"
DATA "And this is the second one"
DATA "Three"
DATA "Four I think"
DATA "Five pigs in a ..."
DATA "Six salmons in a salmon box"
DATA "Seven of what?"
DATA "Eight and I'm tired"
DATA "Nine time for bed"
DATA "Ten strings this is the last one"
PRINT ListBox(@theItems, MAXITEMS, "String List", "Select a string")

