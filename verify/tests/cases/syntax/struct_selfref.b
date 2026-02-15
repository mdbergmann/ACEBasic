REM Test: Self-referential struct pointers (linked list)

REM -- Define self-referential struct --
STRUCT Node
  LONGINT num
  Node *nxt
END STRUCT

DECLARE STRUCT Node n1
DECLARE STRUCT Node n2
DECLARE STRUCT Node n3

REM -- Build a linked list --
n1->num = 10&
n2->num = 20&
n3->num = 30&

n1->nxt = n2
n2->nxt = n3
n3->nxt = 0&

REM -- Test 1: direct access --
ASSERT n1->num = 10, "n1->num should be 10"
ASSERT n2->num = 20, "n2->num should be 20"
ASSERT n3->num = 30, "n3->num should be 30"

REM -- Test 2: chained access through self-ref pointer --
ASSERT n1->nxt->num = 20, "n1->nxt->num should be 20"
ASSERT n1->nxt->nxt->num = 30, "n1->nxt->nxt->num should be 30"

REM -- Test 3: null check on last node --
ASSERT n3->nxt = 0, "n3->nxt should be null"

REM -- Test 4: assign through chain --
n1->nxt->num = 25&
ASSERT n2->num = 25, "n2->num should be 25 after chain assign"

n1->nxt->nxt->num = 35&
ASSERT n3->num = 35, "n3->num should be 35 after chain assign"

PRINT "struct_selfref: ALL PASSED"
