'..a linked list using ACE structures.

DEFLNG a-z

STRUCT node
 STRING nm
 ADDRESS nxt
END STRUCT

DECLARE STRUCT node *head,*new.item,*curr,*temp

SUB make.node
 make.node = ALLOC(SIZEOF(node))
END SUB

'..create head of list
head = make.node
IF head = NULL THEN
  PRINT "head node can't be allocated!"
  STOP
END IF

head->nm = ""
head->nxt = NULL
curr = head

'..create list
REPEAT
 INPUT "type a name (or QUIT): ";x$
 new.item = make.node
 IF new.item <> NULL THEN
  new.item->nm = x$
  new.item->nxt = NULL

  curr->nxt = new.item
  curr = curr->nxt
 ELSE
  PRINT "new node can't be allocated!"
 END IF
UNTIL UCASE$(x$) = "QUIT" OR new.item=NULL

'..traverse list
CLS
curr = head->nxt
WHILE curr <> NULL
  IF UCASE$(curr->nm) <> "QUIT"  THEN PRINT curr->nm
  curr = curr->nxt
WEND
