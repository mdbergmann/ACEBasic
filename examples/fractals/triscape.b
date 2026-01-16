{ Fractal landscapes.

  Author: David J Benn
    Date: 28th,29th August 1993

  I'd like to thank Paul McGuire for his MS-DOS program: FRMESH. I 
  experimented with FRMESH and used the accompanying documentation 
  when creating this program.

  Note: there seems to be a flaw in my algorithm which produces 
  gaps in between triangles sometimes. Am I not taking into account
  all new sub-triangles?

  The vertices A-F cited in this program are based upon the
  following hypothetical equilateral triangle:

		        A
		       /\
		      /  \
		    D/____\E
		    /\    /\
		   /  \  /  \
		  /    \/    \
		 B------------C	 
			F

  Usage: (shell/CLI (type "triscape ?") or Workbench)
  -----

  1. Select three points on screen with mouse to create a triangle.
  2. Press left mouse button for next generation. 
}

deflng a-z

const nil=0&, true=-1&, false=0&
const none=0, continue=1, quit=2
const PUBLIC=2
const aspect=.85

SINGLE distortion
distortion = .2		'..(20%)

STRUCT triangle_node
  SHORTINT x1
  SHORTINT y1
  SHORTINT x2
  SHORTINT y2
  SHORTINT x3
  SHORTINT y3
  ADDRESS  nxt
END STRUCT

DECLARE STRUCT triangle_node *T, *tri

SUB in_CLI
external stdout&
  if stdout<>0& then 
    in_CLI=true
  else
    in_CLI=false
  end if
END SUB

SUB pause
  time0=timer
  while timer < time0+0.1:wend
END SUB

SUB get_point(ADDRESS x, ADDRESS y)
  '..await left mouse button press
  while not mouse(0):wend
  '..get values
  *%x := mouse(1)
  *%y := mouse(2)
  line (*%x-3,*%y-3)-(*%x+3,*%y+3),2,b 
  '..await left mouse button release
  pause
  while mouse(0):wend
END SUB

SUB choice
  response=none
  repeat
    k$=ucase$(inkey$)
    if k$="Q" then response=quit
    if k$="C" then response=continue
  until response<>none
  choice = response
END SUB

SUB line_length(x1,y1,x2,y2)
  '..find two sides of the right angled triangle
  '..with (x1,y1)-(x2,y2) as its hypotenuse.
  t_rise = abs(y2-y1)
  t_run = abs(x2-x1)
  '..find length via Pythagoras' Theorem
  '..(a^2 = b^2 + c^2).
  line_length = SQR(t_rise*t_rise + t_run*t_run) 
END SUB

SUB max_length(ab,ac,bc,ADDRESS side_addr)
STRING side ADDRESS side_addr
  max = ab : side = "ab"
  if ac > max then max = ac : side = "ac"
  if bc > max then max = bc : side = "bc"
  max_length = max
END SUB

SUB show_triangle(ADDRESS T)
DECLARE STRUCT triangle_node *tri
SHORTINT colr
STRING side

  '..Display triangle filled with
  '..shade of gray corresponding to
  '..area of triangle. As triangle
  '..becomes smaller, shade becomes
  '..darker. 

  tri = T

  '..find area of triangle
  '..store vertices
  x1=tri->x1
  y1=tri->y1
  x2=tri->x2
  y2=tri->y2
  x3=tri->x3
  y3=tri->y3
  '..find length of each side
  ab_len = line_length(x1,y1,x2,y2)
  ac_len = line_length(x1,y1,x3,y3)
  bc_len = line_length(x2,y2,x3,y3)
  '..base is longest side
  t_base = max_length(ab_len,ac_len,bc_len,@side)
  '..find height	
  case
    side = "ab" : height = abs(y3-y1)
    side = "ac" : height = abs(y2-y3)
    side = "bc" : height = abs(y1-y2)
  end case
  '..calculate area
  t_area = .5 * t_base * height

  '..determine color on basis of area 
  '..(the smaller, the darker)
  case 
    t_area > 1000 : colr = 0
    t_area > 500  : colr = 1
    t_area > 200  : colr = 2
    t_area > 100  : colr = 3
    t_area > 50   : colr = 4
    t_area > 25   : colr = 5
    t_area > 10   : colr = 6
    t_area <= 10  : colr = 7
  end case
  
  '..draw filled triangle
  AREA (x1,y1)
  AREA (x2,y2)
  AREA (x3,y3)
  AREA (x1,y1)
  COLOR colr+5
  AREAFILL

  '..show triangle's borders 
  line (x1,y1)-(x2,y2),1
  line (x2,y2)-(x3,y3),1
  line (x3,y3)-(x1,y1),1
END SUB

SUB rnd_sign
  if rnd < .5 then
    rnd_sign = -1!
  else
    rnd_sign = 1!
  end if
END SUB

SUB next_generation(ADDRESS T, SINGLE distortion)
DECLARE STRUCT triangle_node *tri, *new_tri
DIM a(2),b(2),c(2),d(2),e(2),f(2)
ADDRESS nxt_tri

  '..derive four new triangles from each 
  '..single triangle in the list.
  
  CLS

  color 3
  locate 26,35
  prints "Generating"
  color 2
  locate 28,25
  prints "press left mouse button to stop"

  ON MOUSE goto quit
  MOUSE ON

  tri = T

  WHILE tri <> nil
    '..next node in list
    nxt_tri = tri->nxt	

    '..vertices of triangle
    a(1) = tri->x1
    a(2) = tri->y1
    b(1) = tri->x2
    b(2) = tri->y2  
    c(1) = tri->x3
    c(2) = tri->y3  

    '..find length of each side of current triangle.
    abx_len = abs(tri->x1 - tri->x2)
    aby_len = abs(tri->y1 - tri->y2)	'..ab
    acx_len = abs(tri->x1 - tri->x3)
    acy_len = abs(tri->y1 - tri->y3)	'..ac
    bcx_len = abs(tri->x2 - tri->x3)
    bcy_len = abs(tri->y2 - tri->y3)	'..bc

    '..find midpoints of each side of current triangle.
    abx = (tri->x1 + tri->x2) \ 2
    aby = (tri->y1 + tri->y2) \ 2	'..ab
    acx = (tri->x1 + tri->x3) \ 2	
    acy = (tri->y1 + tri->y3) \ 2	'..ac
    bcx = (tri->x2 + tri->x3) \ 2
    bcy = (tri->y2 + tri->y3) \ 2	'..bc

    '..add a small +/- displacement to midpoint values.
    d(1) = abx + (rnd * distortion*abx_len * rnd_sign)
    d(2) = aby + (rnd * distortion*aby_len * rnd_sign) * aspect
    e(1) = acx + (rnd * distortion*acx_len * rnd_sign)
    e(2) = acy + (rnd * distortion*acy_len * rnd_sign) * aspect
    f(1) = bcx + (rnd * distortion*bcx_len * rnd_sign)
    f(2) = bcy + (rnd * distortion*bcy_len * rnd_sign) * aspect

    '..triangle 1.0 = ade
    tri->x1 = a(1)
    tri->y1 = a(2)
    tri->x2 = d(1)
    tri->y2 = d(2)
    tri->x3 = e(1)
    tri->y3 = e(2)
    
    '..triangle 1.1 = dbf
    new_tri = ALLOC(sizeof(triangle_node), PUBLIC)
    if new_tri = nil then next_generation=true:beep:exit sub
    tri->nxt = new_tri
    tri = tri->nxt
    tri->x1 = d(1)
    tri->y1 = d(2)
    tri->x2 = b(1)
    tri->y2 = b(2)
    tri->x3 = f(1)
    tri->y3 = f(2)

    '..triangle 1.2 = dfe
    new_tri = ALLOC(sizeof(triangle_node), PUBLIC)
    if new_tri = nil then next_generation=true:beep:exit sub
    tri->nxt = new_tri
    tri = tri->nxt
    tri->x1 = d(1)
    tri->y1 = d(2)
    tri->x2 = f(1)
    tri->y2 = f(2)
    tri->x3 = e(1)
    tri->y3 = e(2)

    '..triangle 1.3 = efc
    new_tri = ALLOC(sizeof(triangle_node), PUBLIC)
    if new_tri = nil then next_generation=true:beep:exit sub
    tri->nxt = new_tri
    tri = tri->nxt
    tri->x1 = e(1)
    tri->y1 = e(2)
    tri->x2 = f(1)
    tri->y2 = f(2)
    tri->x3 = c(1)
    tri->y3 = c(2)
    
    '..point to next triangle in list
    tri->nxt = nxt_tri 
    tri = tri->nxt
  WEND

  MOUSE OFF

  '..There was enough memory to
  '..create the next generation
  '..if we got this far (false = not finished! -- see main loop below).
  next_generation = false
END SUB


{ ** MAIN ** }

RANDOMIZE TIMER

'..CLI argument?
if argcount=1 then 
  if arg$(1) = "?" then 
    print "usage: ";arg$(0);" [distortion]"
    print "   eg: ";arg$(0);" .1"
    STOP
  else
    distortion = val(arg$(1))
  end if
end if

screen 1,640,425,4,4

font "topaz",8

palette 0,0,0,0		'..black
palette 1,1,1,1		'..white
palette 2,0,1,0		'..green
palette 3,1,0,0		'..red
palette 4,1,1,.13	'..yellow
palette 5,.93,.93,.93	'..gray 0 (light)
palette 6,.83,.83,.83	'..gray 1
palette 7,.73,.73,.73	'..gray 2
palette 8,.63,.63,.63	'..gray 3
palette 9,.53,.53,.53	'..gray 4
palette 10,.43,.43,.43	'..gray 5
palette 11,.33,.33,.33	'..gray 6
palette 12,.23,.23,.23	'..gray 7 (dark)

'..Create and display landscapes until user quits or memory runs out.

REPEAT
  '..create first node of list
  T = ALLOC(sizeof(triangle_node), PUBLIC)
  if T = nil then 
    screen close 1
    beep
    STOP
  else
    T->nxt = nil
  end if

  '..select three points
  CLS
  color 4
  locate 30,27
  prints "Select 3 points with mouse"
  get_point(@T->x1,@T->y1)  
  get_point(@T->x2,@T->y2)  
  get_point(@T->x3,@T->y3)  

  '..Create and display successive generations of triangles
  '..until user quits or no more memory can be allocated for 
  '..triangle list.

  finished=false

  REPEAT
    CLS
    color 1
    locate 44,1
    prints "Distortion:";
    color 4
    prints str$(distortion*100);"%"

    '..show current generation.
    tri = T
    WHILE tri <> nil
      show_triangle(tri)
      tri = tri->nxt
    WEND

    color 2
    locate 46,1
    prints "C to continue."
    color 3
    locate 48,1
    prints "Q to quit."
  
    '..continue?
    opt = choice
    if opt = continue then 
      finished = next_generation(T, distortion)    
    else    
      finished = true
    end if
  UNTIL finished

  QUIT:
    color 4
    locate 48,1
    prints "Q to quit program. R to restart."
    repeat
      k$ = ucase$(inkey$)
    until k$="Q" or k$="R"
    if k$="Q" then want_to_quit=true else want_to_quit=false
UNTIL want_to_quit

screen close 1

'..Memory allocated by ALLOC is freed at end of program run.
if in_CLI<>nil then print "Freeing allocated memory."
