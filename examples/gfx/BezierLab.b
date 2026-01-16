{*
** Bezier Curve Laboratory.
**
** Author: David J Benn
**   Date: 29th-31st October 1994,
**	   1st-5th November 1994
**
** Algorithm for CreateBezierSpline subprogram taken (and modified) from a C
** implementation by Doug McKenna in MacTech magazine, September 1994.  
*}

STRING version SIZE 20
version = "$VER: BezierLab 1.0 (05.11.94)"

{*
** Misc. Constants.
*}
CONST nominalIndex = 1
CONST default = -1&
CONST NULL = 0&
CONST true = -1&, false = 0&

CONST maxPoints = 16
CONST xmin = 10, xmax = 620
CONST ymin = 5, ymax = 170

{*
** Menu constants.
*}
CONST sDisable	= 0
CONST sEnable	= 1
CONST sCheck	= 2

CONST mProject		= 1
CONST iNew		= 1
CONST iAnimate		= 2
CONST iStop		= 3
CONST iFast		= 4
CONST iReposition	= 5
CONST iSep1.1		= 6
CONST iAbout		= 7
CONST iQuit		= 8

{*
** Types.
*}
STRUCT Point2D
  SHORTINT x
  SHORTINT y
END STRUCT

{*
** Globals.
*}
DIM ADDRESS path(maxPoints)
DECLARE STRUCT Point2D p0, c1, c2, p3
SHORTINT theMenu, theItem
SHORTINT c1_deltaX, c1_deltaY, c2_deltaX, c2_deltaY 
LONGINT animate, finished, fast_mode, reposition

{*
** Events.
*}
ON MENU GOSUB handle_menu
MENU ON

{*
** Subprograms.
*}
SUB SetUpMenus
	MENU mProject,0,sEnable,		"Project"
	MENU mProject,iNew,sEnable,		"  New", 	"N"
	MENU mProject,iAnimate,sEnable,		"  Animate", 	"A"
	MENU mProject,iStop,sEnable,		"  Stop", 	"S"
	MENU mProject,iFast,sCheck,		"  Fast", 	"F"
	MENU mProject,iReposition,sEnable,	"  Reposition",	"R"
	MENU mProject,iSep1.1,sDisable,		"-------------------"
	MENU mProject,iAbout,sEnable,		"  About..."
	MENU mProject,iQuit,sEnable,		"  Quit", 	"Q"
END SUB

SUB SetUpPathArray(ADDRESS path_array, SHORTINT numPoints)
{*
** Allocate memory for numPoints Point2D structures
** and initialise each array element with these.
*}
DIM ADDRESS path(nominalIndex) ADDRESS path_array 
DECLARE STRUCT Point2D *the_point
SHORTINT i

	FOR i=0 TO numPoints
	  the_point = ALLOC(SIZEOF(Point2D))
	  IF the_point <> NULL THEN 
	  	path(i) = the_point
	  ELSE
		MsgBox "Memory allocation failure. Aborting.", "Continue"
		EXIT SUB
	  END IF
	NEXT
END SUB

SUB SetInitialCurve(ADDRESS p0_struct, ADDRESS c1_struct, ~
	       	    ADDRESS c2_struct, ADDRESS p3_struct)
{*
** Randomly determine curve end points, tension points and
** motion direction values.
*}
SHARED c1_deltaX, c2_deltaX, c1_deltaY, c2_deltaY 
DECLARE STRUCT Point2D *p0, *c1, *c2, *p3

	'..Initialise point2D structures
	p0 = p0_struct
	c1 = c1_struct
	c2 = c2_struct
	p3 = p3_struct

	'..Set curve end-points.
	p0->x = CINT(RND*(xmax-xmin))+xmin : p0->y = CINT(RND*(ymax-ymin))+ymin
	p3->x = CINT(RND*(xmax-xmin))+xmin : p3->y = CINT(RND*(ymax-ymin))+ymin

	'..Set tension (control) points.
	c1->x = CINT(RND*(xmax-xmin))+xmin : c1->y = CINT(RND*(ymax-ymin))+ymin
	c2->x = CINT(RND*(xmax-xmin))+xmin : c2->y = CINT(RND*(ymax-ymin))+ymin

	'..Set random motion directions for each tension point.
	IF RND < .5 THEN c1_deltaX = -1 ELSE c1_deltaX = 1
	IF RND < .5 THEN c2_deltaX = -1 ELSE c2_deltaX = 1
	IF RND < .5 THEN c1_deltaY = -1 ELSE c1_deltaY = 1
	IF RND < .5 THEN c2_deltaY = -1 ELSE c2_deltaY = 1
END SUB

SUB CreateBezierSpline(ADDRESS p0_struct, ADDRESS c1_struct, ~
		       ADDRESS c2_struct, ADDRESS p3_struct, ~
		       ADDRESS path_array, SHORTINT numPoints)
{*
** Compute the path of a Bezier spline whose starting 
** and ending knot points are p0 and p3, and whose control 
** (tension) points are c1 and c2. The path should be stored
** in the array "path", which is expected to be able to hold
** (numPoints+1) elements, from 0 to numPoints inclusive. 
** numPoints should be a power of 2 between 2 and 32, inclusive.
** This routine can be easily generalised to 3D coordinates, and 
** is optimised for fast computation in (long) integers. 
** [Doug McKenna, MacTech, Sept. 1994, pg 72]
*}
DECLARE STRUCT Point2D *p0, *c1, *c2, *p3, *the_point
DIM ADDRESS path(nominalIndex) ADDRESS path_array
LONGINT i, ax,ay, bx,by, cx,cy, curx,cury
SHORTINT s1,s2,s3
SHORTINT old_lastX,old_lastY, new_lastX,new_lastY
SHORTINT old_currX, old_currY

	'..Deactivate event trapping.
	MENU STOP

	'..Initialise point2D structures
	p0 = p0_struct
	c1 = c1_struct
	c2 = c2_struct
	p3 = p3_struct

	curx = p0->x : cury = p0->y	'..Convert to longints
	
	'..Compute the integer Bezier spline cefficients, a, b and c
	cx = (c1->x - curx) : cx = cx + SHL(cx,1)  '..c=3*(c1-p0) 
	cy = (c1->y - cury) : cy = cy + SHL(cy,1)

	bx = (c2->x - c1->x)
	bx = bx + (SHL(bx,1) - cx)  '..b=3*(c2-c1)-c
	by = (c2->y - c1->y)
	by = by + (SHL(by,1) - cy)

	ax = (p3->x - curx) - cx - bx  '..a=(p3-p0)-c-b
	ay = (p3->y - cury) - cy - by
	
	CASE
	  numPoints = 32 : s1 = 5
	  numPoints = 16 : s1 = 4
	  numPoints =  8 : s1 = 3
	  numPoints =  4 : s1 = 2
	  default	 : s1 = 1
	END CASE

	s2 = s1+s1 : s3 = s2+s1  '..s2=2*s1 : s3=3*s1		

	{*
	** Scale operands up for later,
	** according to the degree in i 
	** in loop below.
	*}
	bx = SHL(bx,s1) : by = SHL(by,s1)
	cx = SHL(cx,s2) : cy = SHL(cy,s2)

	'..s3 is up to 15 bits worth of scaling.
	curx = SHL(curx,s3) : cury = SHL(cury,s3)

	{* 
	** Get i'th path point along curve from p0 to p3
	** (inclusive) and plot line segment from (i-1)'th 
	** point to i'th. Line segments associated with the
	** old curve are erased before each new segment is
	** plotted.
	*}
	'..Starting point.
	the_point = path(0) : the_point->x = p0->x : the_point->y = p0->y
	old_lastX = the_point->x : old_lastY = the_point->y
	new_lastX = the_point->x : new_lastY = the_point->y

	'..Create new curve while erasing old one.
	FOR i=1 TO numPoints
	  '..Get address of current point.
	  the_point = path(i)
	  '..Store current X and Y values.
	  old_currX = the_point->x : old_currY = the_point->y  
	  '..Calculate new coordinates.
	  the_point->x = SHR((i * (i * (i * ax + bx) + cx) + curx),s3)
	  the_point->y = SHR((i * (i * (i * ay + by) + cy) + cury),s3)
	  '..Erase old and draw new segment?	
	  IF old_currX <> the_point->x OR old_currY <> the_point->y OR ~
	     old_lastX <> new_lastX OR old_lastY <> new_lastY THEN
	    LINE (old_lastX, old_lastY)-(old_currX, old_currY),0
	    LINE (new_lastX, new_lastY)-(the_point->x, the_point->y),1
	  END IF
	  '..Store old coord's for start of next segment removal.
    	  old_lastX = old_currX : old_lastY = old_currY
	  '..Store new coord's for start of next new segment.
	  new_lastX = the_point->x : new_lastY = the_point->y
	NEXT

	'..Reactivate event trapping.
	MENU ON
END SUB

SUB PlotCurve(ADDRESS p0_struct, ADDRESS path_array, SHORTINT numPoints, ~
	      SHORTINT color_id)
{*
** Plot current curve in the specified color.
*}
DECLARE STRUCT Point2D *p0, *the_point
DIM ADDRESS path(nominalIndex) ADDRESS path_array
SHORTINT i, lastX, lastY

	p0 = p0_struct

	COLOR color_id
	lastX = p0->x : lastY = p0->y

	FOR i=1 TO numPoints
	  the_point = path(i)
	  LINE (lastX, lastY)-(the_point->x, the_point->y)
	  lastX = the_point->x : lastY = the_point->y
	NEXT
END SUB

SUB ModifyTension(ADDRESS c1_struct, ADDRESS c2_struct)
{*
** Move both tension points to next location, possibly 
** changing the direction of motion of one or both
** tension points (horizontally and/or vertically).
*}
SHARED c1_deltaX, c1_deltaY, c2_deltaX, c2_deltaY 
DECLARE STRUCT Point2D *c1, *c2

	c1 = c1_struct
	c2 = c2_struct

	'..Move tension points.
	c1->x = c1->x + c1_deltaX
	c2->x = c2->x + c2_deltaX
	c1->y = c1->y + c1_deltaY
	c2->y = c2->y + c2_deltaY

	'..Reached a minimum or maximum?
	IF c1->x < xmin OR c1->x > xmax THEN c1_deltaX = -c1_deltaX
	IF c2->x < xmin OR c2->x > xmax THEN c2_deltaX = -c2_deltaX
	IF c1->y < ymin OR c1->y > ymax THEN c1_deltaY = -c1_deltaY
	IF c2->y < ymin OR c2->y > ymax THEN c2_deltaY = -c2_deltaY
END SUB

SUB MarkPoints(ADDRESS p0_struct, ADDRESS c1_struct, ~
	       ADDRESS c2_struct, ADDRESS p3_struct, ~
	       SHORTINT color_id)
{*
** Mark end and tension points.
*}
DECLARE STRUCT Point2D *p0, *c1, *c2, *p3

  	p0 = p0_struct
	c1 = c1_struct
	c2 = c2_struct
	p3 = p3_struct

  	PSET (p0->x,p0->y),color_id
  	PSET (c1->x,c1->y),color_id
  	PSET (c2->x,c2->y),color_id
  	PSET (p3->x,p3->y),color_id
END SUB

SUB AnimateMode(LONGINT activate)
{*
** Set or reset animate mode.
*}
SHARED animate
SHARED p0, c1, c2, p3

	IF activate THEN 
		'..Enable Animation Mode.
		animate = true
		MarkPoints(p0, c1, c2, p3, 0)
		MENU mProject,iAnimate,sDisable
		MENU mProject,iStop,sEnable
	ELSE
		'..Disable Animation Mode.
		animate = false
		MarkPoints(p0, c1, c2, p3, 2)
		MENU mProject,iAnimate,sEnable
		MENU mProject,iStop,sDisable
	END IF		
END SUB

SUB MakeNewCurve(ADDRESS p0_struct, ADDRESS c1_struct, ~
		 ADDRESS c2_struct, ADDRESS p3_struct, ~
		 ADDRESS path_array, SHORTINT numPoints)
{*
** Initialise and plot new Bezier curve and tension/end points.
*}

	AnimateMode(false)

	CLS

	SetInitialCurve(p0_struct, c1_struct, c2_struct, p3_struct)

	CreateBezierSpline(p0_struct, c1_struct, c2_struct, p3_struct, ~
			   path_array, numPoints)

	MarkPoints(p0_struct, c1_struct, c2_struct, p3_struct, 2)
END SUB

SUB ToggleFastMode
{*
** Switch between fast and slow modes.
*}
SHARED fast_mode

	IF fast_mode THEN 
		fast_mode=false 
		MENU mProject,iFast,sEnable
	ELSE 
		fast_mode=true
		MENU mProject,iFast,sCheck
	END IF
END SUB

SUB plotHandles(SHORTINT color_id)
{*
** Plot end and tension point handles in the specified color.
*}
SHARED p0, c1, c2, p3

	LINE (p0->x-4,p0->y-2)-(p0->x+4,p0->y+2),color_id,b
	LINE (c1->x-4,c1->y-2)-(c1->x+4,c1->y+2),color_id,b
	LINE (c2->x-4,c2->y-2)-(c2->x+4,c2->y+2),color_id,b
	LINE (p3->x-4,p3->y-2)-(p3->x+4,p3->y+2),color_id,b
END SUB

SUB LONGINT inHandle(ADDRESS point_struct, SHORTINT point_num, ~
		     SHORTINT x, SHORTINT y)
{*
** Is x,y coordinate inside a handle?
*}
DECLARE STRUCT Point2D *the_point

	the_point = point_struct

	IF x >= the_point->x-4 AND x <= the_point->x+4 AND ~
	   y >= the_point->y-2 AND y <= the_point->y+2 THEN
		inHandle = point_num+1
	ELSE
		inHandle = 0
	END IF 
END SUB

SUB ToggleRepositionMode
{*
** Toggle repositioning mode.
*}
SHARED reposition, animate, fast_mode
SHARED p0, c1, c2, p3, path
SHORTINT n

	IF reposition THEN
		'..Switch off repositioning mode.
		reposition = false

		'..Reconfigure menu after leaving Reposition Mode.
		FOR n = iNew TO iQuit
		  MENU mProject,n,sEnable
		NEXT
		MENU mProject,iStop,sDisable
		IF fast_mode THEN MENU mProject,iFast,sCheck		
		MENU mProject,iSep1.1,sDisable
		
		'..Erase end and tension points/handles.
		PlotHandles(0)	
		PlotCurve(p0, @path, maxPoints, 1)
		MarkPoints(p0, c1, c2, p3, 2)	
	ELSE
		'..Switch on repositioning mode.
		reposition = true
		animate = false

		'..Disable all menu items except one.
		FOR n = iNew TO iQuit
	  	  MENU mProject,n,sDisable
		NEXT
		MENU mProject,iReposition,sCheck

		'..Draw end and tension points/handles.
		plotHandles(3)
		MarkPoints(p0, c1, c2, p3, 2)
	END IF
END SUB

SUB RepositionPoints(ADDRESS p0_struct, ADDRESS c1_struct, ~
		     ADDRESS c2_struct, ADDRESS p3_struct, ~
		     ADDRESS path_array, SHORTINT numPoints)
{*
** Allow user to reposition the end and tension points.
*}
SHARED reposition
DECLARE STRUCT Point2D *p0, *c1, *c2, *p3, *second_point, last_p0
DIM ADDRESS path(nominalIndex) ADDRESS path_array
SHORTINT n, mouseX,mouseY, oldMouseX,oldMouseY, pt
SINGLE time0

	'..Initialise structure variables.
  	p0 = p0_struct
	c1 = c1_struct
	c2 = c2_struct
	p3 = p3_struct

	'..Await left mouse button click.
	WHILE reposition AND NOT MOUSE(0):WEND
	'..Debounce button press.
	time0 = TIMER : WHILE reposition AND TIMER < time0+.1:WEND  
		
	oldMouseX = MOUSE(1) : oldMouseY = MOUSE(2)
	
  	IF reposition AND MOUSE(0) THEN
	  '..Is mouse pointer inside a handle?
	  pt = inHandle(p0, 0, oldMouseX, oldMouseY)
	  IF pt = 0 THEN pt = inHandle(c1, 1, oldMouseX, oldMouseY)
	  IF pt = 0 THEN pt = inHandle(c2, 2, oldMouseX, oldMouseY)
	  IF pt = 0 THEN pt = inHandle(p3, 3, oldMouseX, oldMouseY)

	  '..Remove end/tension points and handles then redraw curve.
	  PlotHandles(0)
	  MarkPoints(p0, c1, c2, p3, 0)
	  PlotCurve(p0, path_array, numPoints, 1)

	  WHILE reposition AND MOUSE(0) 
	    '..Compare new mouse position with old.
	    mouseX = MOUSE(1) : mouseY = MOUSE(2)

	    IF mouseX <> oldMouseX OR mouseY <> oldMouseY THEN
		'..Reached any limits?
		IF mouseX < xmin THEN mouseX = xmin
		IF mouseX > xmax THEN mouseX = xmax
		IF mouseY < ymin THEN mouseY = ymin
		IF mouseY > ymax THEN mouseY = ymax

		'..Save p0 (see below).
		last_p0->x = p0->x
		last_p0->y = p0->y

	      	'..Change coordinates?
	    	CASE
	      		pt = 1 : p0->x = mouseX : p0->y = mouseY
	      		pt = 2 : c1->x = mouseX : c1->y = mouseY
	      		pt = 3 : c2->x = mouseX : c2->y = mouseY
	      		pt = 4 : p3->x = mouseX : p3->y = mouseY
	    	END CASE

		{* 
		** Since p0 is treated as a special case by CreateBezierSpline
		** check to see whether it has been moved. If so, erase first curve
		** segment as it would otherwise be missed (by CreateBezierCurve).
		*}
		IF p0->x <> last_p0->x OR p0->y <> last_p0->y THEN
		  second_point = path(1)
		  LINE (last_p0->x,last_p0->y)-(second_point->x,second_point->y),0
		END IF

	      	'..Redraw curve.
	      	CreateBezierSpline(p0, c1, c2, p3, path_array, numPoints)

		'..Save last (used) mouse position.
		oldMouseX = mouseX : oldMouseY = mouseY
	    END IF
	  WEND

	  '..Refresh curve and redraw end and tension points/handles.
	  PlotCurve(p0, path_array, numPoints, 1)
	  plotHandles(3)
	  MarkPoints(p0, c1, c2, p3, 2)
	END IF	
END SUB

SUB AboutBox
SHORTINT buttonX, buttonY

	WINDOW 9,"About this program...",(220,25)-(420,175),2
	buttonX = SCREEN(5) : buttonY = SCREEN(6)
	buttonTxt$ = "Continue"
	GADGET 255,ON,buttonTxt$,(100-(buttonX*LEN(buttonTxt$))\2-4,125-buttonY\2-2)- ~
			       	 (100+(buttonX*LEN(buttonTxt$))\2+4,125+buttonY\2+2), ~
				 BUTTON
	COLOR 1
	LOCATE 2
	RESTORE
	REPEAT
	  READ text$
	  IF text$ <> "END" THEN 
	    CASE
		text$ = "BezierLab" : FONT "diamond",20 : STYLE 4
		text$ = "for Karen" 	: FONT "ruby",8 : STYLE 2
		default   		: FONT "opal",12 : STYLE 0
	    END CASE
	    PRINT PTAB(100-(WINDOW(12)*LEN(text$))\2);text$
	  END IF
	UNTIL text$ = "END"
	DATA "BezierLab","","","version 1.0","","by David J Benn"
	DATA "","for Karen","END"
	GADGET WAIT 255
	GADGET CLOSE 255
	WINDOW CLOSE 9
END SUB

SUB Quit
{*
** Exit program? 
*}
SHARED finished

  IF MsgBox("Really leave BezierLab?","Yes","No") THEN finished = true
END SUB

{*
** Main.
*}
WINDOW 1,"Bezier Curve Laboratory",(0,10)-(640,200),22

SetUpMenus
SetUpPathArray(@path, maxPoints)

RANDOMIZE TIMER

MakeNewCurve(p0, c1, c2, p3, @path, maxPoints)

finished = false
fast_mode = true
reposition = false

REPEAT
  IF animate THEN 
  	ModifyTension(c1, c2)
  	CreateBezierSpline(p0, c1, c2, p3, @path, maxPoints)
  ELSE
	IF reposition THEN
		RepositionPoints(p0, c1, c2, p3, @path, maxPoints)
	END IF	
  END IF

  IF NOT fast_mode THEN SLEEP FOR .02
UNTIL finished

MENU OFF

WINDOW CLOSE 1
END

{*
** Event handlers.
*}
handle_menu:
  theMenu = MENU(0)
  theItem = MENU(1)
  
  IF theMenu = mProject THEN
    	CASE 
		theItem = iNew	   	: MakeNewCurve(p0, c1, c2, p3, @path, maxPoints)
		theItem = iAnimate 	: AnimateMode(true)
		theItem = iStop    	: AnimateMode(false)
		theItem = iFast    	: ToggleFastMode
		theItem = iReposition 	: ToggleRepositionMode
		theItem = iAbout   	: AboutBox
		theItem = iQuit	   	: Quit 
  	END CASE
  END IF
RETURN
