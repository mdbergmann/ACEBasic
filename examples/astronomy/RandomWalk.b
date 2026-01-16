{*
** Random Walk
** ===========
** The idea here is to simulate the process by which a particle
** in the sun (or other star) eventually moves to the surface by 
** randomly colliding with neighbouring particles. The claim is
** that such a particle will _always_ reach the surface and escape.
** This program conducts an experiment to test this claim.
**
** This program was suggested in a lecture given by Joss 
** Bland-Hawthorn at an astronomy seminar called "Colours 
** of the Stars" on May 10th and 11th 1997 at the University of Adelaide.
**
** Author: David Benn
**   Date: June 15 1997,
**	   July 20 1997 
*}

Const RADCONV=57.295779
Const iGenerate=1, iWalk=2, iClear=3, iSetStars=4, iSetRadius=5, iAbout=6, iQuit=7
Const TRUE=-1&, FALSE=0&, having_fun=TRUE
Const x_origin=320, y_origin=100 
Const LEFT=0, UP=0, RIGHT=1, DOWN=1
Const STAR_PARTICLE=1, MOVING_PARTICLE=2

{*
** Globals.
*}
Longint Stars, Radius
Stars = 2000 : Radius = 75

{* 
** Subprogram declarations.
*}
Declare Sub Quit
Declare Sub HandleMenu
Declare Sub GenerateStar
Declare Sub RandomWalk
Declare Sub Longint ParticleCollision(Shortint x, Shortint y)
Declare Sub Longint BeyondSurface(Shortint x, Shortint y)

{* 
** Main.
*}
Randomize Timer

'..Open window.
Window 1,"Random Walk",(0,0)-(640,200)

'..Set up menus.
Menu 1,0,1,"Project"
Menu 1,iGenerate,1,"Generate",		"G"
Menu 1,iWalk,1,"Walk",			"W"
Menu 1,iClear,1,"Clear",		"C"
Menu 1,iSetStars,1,"Set Stars...",	"S"
Menu 1,iSetRadius,1,"SetRadius...",	"R"
Menu 1,iAbout,1,"About...",		"A"
Menu 1,iQuit,1,"Quit",			"Q"

'..Set up event handlers.
On Window Call Quit : Window On
On Break Call Quit : Break On
On Menu Call HandleMenu : Menu On

While having_fun
  Sleep
Wend

End

{* 
** Subprogram definitions.
*}
Sub Quit
{*
** Close window and exit program.
*}
  Window Close 1
  Stop
End Sub

Sub Longint GetPositiveInt(String prompt, String reqTitle, Longint default)
{*
** Return an integer which is greater than zero
** via an input requester. If zero is returned
** from the requester, assume the cancel button
** has been clicked and return the default value.
*}
Longint n

  Repeat
    n = InputBox(prompt, reqTitle, Mid$(Str$(default),2))
  Until n >= 0 

  If n = 0 Then GetPositiveInt = default Else GetPositiveInt = n
End Sub

Sub HandleMenu
{*
** Handle menu choice.
*}
Shared Stars, Radius
Shortint theItem

  If Menu(0) = 1 Then
    theItem = Menu(1)
    Case
      theItem = iGenerate : GenerateStar
      theItem = iWalk     : RandomWalk
      theItem = iClear    : Cls
      theItem = iSetStars : Stars = GetPositiveInt("Enter number of stars:","Set Stars",Stars)
      theItem = iSetRadius: Radius = GetPositiveInt("Enter radius:","Set Radius",Radius)
      theItem = iAbout    : MsgBox "Random Walk - David Benn 1997","Ok"
      theItem = iQuit     : Quit
    End Case
  End If
End Sub

Sub GenerateStar
{*
** Generate a random circular area of stars
** and fill x,y arrays with points.
*}
Shared Stars, Radius
Single theta
Shortint i,x,y

  For i=1 to Stars
    theta = (Rnd*360)/RADCONV
    x = x_origin + Rnd*Radius*Cos(theta)
    y = y_origin + Rnd*Radius*Sin(theta)
    Pset(x,y),STAR_PARTICLE
  Next i
End Sub

Sub RandomWalk
{*
** Choose a particle at random and let it move
** at random. The process stops when the particle
** reaches the star's surface.
*}
Shared Radius
Single theta
Shortint x,y
Shortint x_dir,y_dir

  '..Create a particle to move.
  theta = (Rnd*360)/RADCONV
  x = x_origin + Rnd*Radius*Cos(theta)
  y = y_origin + Rnd*Radius*Sin(theta)
  Pset(x,y),MOVING_PARTICLE

  '..Random walk.
  x_dir = Rnd*2 : y_dir = Rnd*2	  {* random x and y direction *}
  Repeat
    '..Prepare to move particle by erasing it. First make sure
    '..that we're not erasing another particle after a collision.
    If Point(x,y) = MOVING_PARTICLE Then Pset(x,y),0

    '..Move particle. 
    If x_dir = LEFT Then --x Else ++x    
    If y_dir = UP Then --y Else ++y 

    {* 
    ** If the particle collides with another,
    ** randomly change its direction, otherwise
    ** just plot it. Don't want to plot it if
    ** there's been a collision otherwise we'll
    ** lose a particle. Actually, may _want_ to
    ** do so sometimes since some collisions
    ** will result in fusion! See commented line
    ** in first case below.
    *}
    If ParticleCollision(x,y) Then
	x_dir = Rnd*2 : y_dir = Rnd*2 
      	{* If Rnd*5 = 4 Then Pset(x(p),y(p)),MOVING_PARTICLE -- fusion? -- *} 
    Else
	Pset(x,y),MOVING_PARTICLE
    End If
    
    Sleep For 0.1
  Until BeyondSurface(x,y)
  
  '..Escaped!
  Say Translate$("The particle has escaped.")
End Sub

Sub Longint ParticleCollision(Shortint x, Shortint y)
{*
** Return T or F indicating whether particle has collided
** with another.
*}
  If Point(x,y) = STAR_PARTICLE Then 
	ParticleCollision = TRUE 
  Else
  	ParticleCollision = FALSE 
  End If
End Sub

Sub Longint BeyondSurface(Shortint x, Shortint y)
{*
** Return T or F indicating whether particle has reached
** beyond the star's surface.
*}
Shared Radius
  If x < x_origin - Radius Or x > x_origin + Radius Or ~
     y < y_origin - Radius Or y > y_origin + Radius Then
    BeyondSurface = TRUE
  Else
    BeyondSurface = FALSE
  End If
End Sub
