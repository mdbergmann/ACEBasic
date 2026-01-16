{*
** A program that implements the Binary Search Tree operations 
** from the text by Helman, Veroff and Carrano, "Intermediate Data
** Structures and Algorithms". 
**
** Pascal version modified by David Benn, May 3rd 1993
**
** Rewritten (and extended) in ACE BASIC for the Amiga, 
** June 19th,21st,22nd,30th, 
** July 3rd 1993
*}

const nil=0&
const true=-1&,false=0&
const down=0,lt=1,rt=2
const fast=1,slow=2
const moment=0.75

struct node
  single  item
  longint lchild
  longint rchild
end struct

declare  struct node *t
longint  opt,finished
shortint speed

SUB prepare_for_output
    window output 2
    locate 14,1
    for i%=1 to 70:print " ";:next
    locate csrlin,1
END SUB

SUB Leftmost(ADDRESS paddr,ADDRESS itemaddr)
declare struct node *p
declare struct node *delnode

	p = *&paddr
	if p <> nil then
		if p->lchild = nil then
			*!itemaddr := p->item
			delnode = p
			p = p->rchild
			*&paddr := p
		else
			Leftmost(@p->lchild,itemaddr)
		end if
	end if
END SUB

SUB Delitem(ADDRESS delptraddr)
declare struct node *delptr
declare struct node *p
single  replitem

	delptr = *&delptraddr
	if delptr <> nil then
		if (delptr->lchild = nil) and (delptr->rchild = nil) then
			{leaf}
			delptr = nil
			*&delptraddr := delptr
		else 
			if delptr->lchild = nil then
				{node with right child}
				p = delptr
				delptr = delptr->rchild
				*&delptraddr := delptr
			else 
				if delptr->rchild = nil then
					{node with left child}
      					p = delptr
					delptr = delptr->lchild
					*&delptraddr := delptr
				else
					{node with two children}
					Leftmost(@delptr->rchild,@replitem)
					delptr->item = replitem
				end if
			end if
		end if
	end if
END SUB

SUB Del(ADDRESS taddr,keyval)
declare struct node *t
	t = *&taddr
	if T <> nil then
		if keyval = T->item then
			Delitem(taddr)
		else 
			if keyval < T->item then
				Del(@T->lchild,keyval)
			else
				Del(@t->rchild,keyval)
			end if
		end if
	end if
END SUB

SUB DeleteItem(ADDRESS taddr)
	input "Enter item: ",item
	Del(taddr,item)
END SUB

SUB Insert(ADDRESS taddr,newitem)
declare struct node *t
	t = *&taddr
	if T = nil then
		T = Alloc(sizeof(node))
		T->item = newitem
		T->lchild = nil
		T->rchild = nil
		*&taddr := t
	else 
		if newitem < T->item then       
			Insert(@T->lchild, newitem) 
		else
			Insert(@T->rchild, newitem)  
		end if
	end if
END SUB

SUB InTree(ADDRESS taddr,single item)
'..determine whether a value exists in the tree
declare struct node *t
	t = *&taddr
	if t = nil then
		InTree = false
	else
		if t->item = item then
			InTree = true
		else
			if item < t->item then
				InTree(@t->lchild,item)
			else
				InTree(@t->rchild,item)
			end if
		end if
	end if		
END SUB

SUB InsertItem(ADDRESS taddr)
	input "Enter Item: ",item
	if not InTree(taddr,item) then call Insert(taddr,item)	
END SUB

SUB Traverse(ADDRESS taddr,shortint order)
'..preorder,inorder or postorder traversal
declare struct node *t
	t = taddr
	if t <> nil then
		if order=1 then print t->item;
		Traverse(t->lchild,order)
		if order=2 then print t->item;
		Traverse(t->rchild,order)
		if order=3 then print t->item;
	end if
END SUB

SUB ShowNodes(ADDRESS taddr)
	repeat
	  input "1=preorder  2=inorder  3=postorder ",order
	until order>=1 and order<=3
	prepare_for_output
	Traverse(taddr,order)
	window output 1
END SUB

SUB GraphTree(ADDRESS taddr)
'..postorder traversal showing tree structure
declare struct node *t
shared  speed
	t = taddr
	if T <> nil then
		'..pause?
		if speed=slow and t->lchild then 
		  time0=timer
		  while timer < time0+moment:wend
		end if

		{left subtree}
		setheading 135
		if t->lchild then pendown:forward 20
		GraphTree(T->lchild)
		setheading 135
		if t->lchild then penup:back 20 

		'..pause?
		if speed=slow and t->rchild then 
		  time0=timer
		  while timer < time0+moment:wend
		end if

		{right subtree}
		setheading 45
		if t->rchild then pendown:forward 20
		GraphTree(T->rchild)
		setheading 45
		if t->rchild then penup:back 20

		'..pause?
		if speed=slow then 
		  time0=timer
		  while timer < time0+moment:wend
		end if

		{visit node}
		num$=str$(T->item)
		if sgn(T->item) <> -1 then num$=right$(num$,len(num$)-1)
		'..position number centrally
		halfnumlen%=len(num$)\2
		penup
		setxy xcor-halfnumlen%*8,ycor 
		color 3
		prints num$
		color 2
		setxy xcor+halfnumlen%*8,ycor
		pendown
	end if

END SUB                                          

SUB ShowTree(ADDRESS t)
shared speed
	window output 2
	color 2,1
	cls
	setheading 90
	penup
	setxy 320,20
	pendown
	GraphTree(t)
	window output 1
END SUB

SUB TreeDisplaySpeed
shared speed
	repeat
 	  input "1=fast  2=slow ",speed
	until speed=fast or speed=slow
END SUB

SUB kill_tree(ADDRESS t)
' make tree empty
	*&t := nil
END SUB

SUB max(x,y)
	if x > y then
		max = x
	else
		max = y
	end if
END SUB

SUB height(ADDRESS taddr)
' recursively determine height of tree
declare struct node *t
	t = taddr
	if t <> nil then
		height = max(height(t->lchild), height(t->rchild)) + 1
	else
		height = 0
	end if
END SUB

SUB maxitem(ADDRESS taddr)
' return maximum item in tree (rightmost node)
declare struct node *t
  t = taddr
  if t = nil then
     maxitem = 0
  else
     if t->rchild = nil then
        maxitem = t->item
     else
        maxitem = maxitem(t->rchild)
     end if
  end if 
END SUB

SUB nodes(ADDRESS taddr)
' return no. of nodes in tree
declare struct node *t
  t = taddr
  if t <> nil then
	nodes = nodes(t->lchild) + nodes(t->rchild) + 1
  else
 	nodes = 0
  end if
END SUB

SUB SelectMenu(ADDRESS opt)
    repeat
	CLS
	print "1.  Insert node"
	print "2.  Delete node"               
	print "3.  Print node values
	print "4.  Show height of tree"
	print "5.  Find maximum value"
	print "6.  Count nodes in tree"
	print "7.  Delete all nodes"
	print "8.  Change tree display speed"
        print "0.  Quit"
        input "Make choice (0..8) ",choice
    until choice >= 0 and choice <= 8
    *&opt:=choice
END SUB

SUB DoOption(longint opt,ADDRESS taddr,longint finished)
declare struct node *t
shared  speed
	  t = *&taddr
	  if opt>=4 and opt<=6 then call prepare_for_output
	  CASE 
		opt=1  : InsertItem(@t)
		opt=2  : DeleteItem(@t)
		opt=3  : ShowNodes(t)
		opt=4  : print "Height of tree is";height(t)
		opt=5  : print "Maximum item is";maxitem(t)
		opt=6  : print "Number of nodes in tree is";nodes(t)
		opt=7  : kill_tree(@t)
		opt=8  : TreeDisplaySpeed
		opt=0  : *&finished := true
	  END CASE
	  if opt>=4 and opt<=6 then window output 1
	  if opt=1 or opt=2 or opt=7 then call ShowTree(t)
	  *&taddr := t
END SUB

{main}
window 2,"BST Output",(0,0)-(640,150),6
font "topaz",8
color 2,1
cls
window 1,"BST",(0,150)-(640,255),6
font "topaz",8
color 1

{create empty tree}
t=nil

speed=fast
finished=false

repeat
  SelectMenu(@opt)
  DoOption(opt,@t,@finished)
until finished

window close 1
window close 2
