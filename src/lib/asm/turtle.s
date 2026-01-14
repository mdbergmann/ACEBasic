;
; turtle.lib -- an ACE linked library module: turtle graphics functions.
; Copyright (C) 1998 David Benn
; 
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;
; Author: David J Benn
;   Date: 3rd July 1992,
;	  5th December 1992,
;	  14th February 1993,
;	  1st March 1993,
;	  19th March 1994
;

	; turtle graphics routines, 
	; functions & variables
	xdef	_back
	xdef	_forward
	xdef	_heading
	xdef	_home
	xdef	_pendown
	xdef	_penup
	xdef	_setheading
	xdef	_setxy
	xdef	_turn
	xdef	_turnleft
	xdef	_turnright
	xdef	_xcor
	xdef	_ycor

	; external ref's
	xref	_tg_initx
	xref	_tg_inity
	xref	_tg_xy_ratio
	xref	_radconv

	xref	_tg_degs
	xref	_tg_tx
	xref	_tg_ty
	xref	_tg_pen
	xref	_tg_distance
	xref	_tg_theta
	xref	_tg_temp
	xref	_tg_x
	xref	_tg_y
	
	xref	_MathBase
	xref	_MathTransBase
	xref	_GfxBase
	xref	_RPort
	xref	_LVODraw
	xref	_LVOMove
	xref	_LVOSPFlt
	xref	_LVOSPFix
	xref	_LVOSPMul
	xref	_LVOSPDiv
	xref	_LVOSPSin
	xref	_LVOSPCos

	SECTION turtle_code,CODE

; *** TURTLE GRAPHICS ROUTINES ***

;
; moveturtle - primitive used by forward and back.
;	     - expects distance in d0 (ffp) 
;	       and direction boolean in d1 (0=back, 1=forward).
;
;	     - d2 = angle (temporary store)
;
_moveturtle:
	; save d0 
	move.l	d0,_tg_distance

	cmpi.w	#1,d1
	beq.s	_forwardcalc	
	
	; reverse
	move.w	_tg_degs,d2
	add.w	#180,d2
	ext.l	d2
	divs	#360,d2
	swap	d2		; angle = (degs+180) % 360
	
	ext.l	d2
	move.l	_MathBase,a6
	move.l	d2,d0
	jsr	_LVOSPFlt(a6)	; angle = (float)angle

	move.l	_radconv,d1
	jsr	_LVOSPDiv(a6)	; theta = angle/radconv

	move.l	d0,_tg_theta

	bra.s	_calcxy		
	
_forwardcalc:	
	; forward	
	move.l	_MathBase,a6
	move.w	_tg_degs,d0
	ext.l	d0
	jsr	_LVOSPFlt(a6)	; degs = (float)degs

	move.l	_radconv,d1
	jsr	_LVOSPDiv(a6)	; theta = degs/radconv
	
	move.l	d0,_tg_theta

	move.l	d0,d1

_calcxy:
	; calculate x
	move.l	_tg_xy_ratio,d0	; X:Y ratio = 2.25 (assumes hi-res & is approx.)
	move.l	_tg_distance,d1
	jsr	_LVOSPMul(a6)	
	move.l	d0,_tg_temp
	
	move.l	_MathTransBase,a6
	move.l	_tg_theta,d0
	jsr	_LVOSPCos(a6)
	
	move.l	_MathBase,a6
	move.l	_tg_temp,d1
	jsr	_LVOSPMul(a6)
	
	jsr	_LVOSPFix(a6)	; x = (int)(2.25*dist*cos(theta))

	move.w	d0,_tg_x

	; calculate y
	move.l	_MathTransBase,a6
	move.l	_tg_theta,d0
	jsr	_LVOSPSin(a6)
	
	move.l	_MathBase,a6
	move.l	_tg_distance,d1
	jsr	_LVOSPMul(a6)
	
	jsr	_LVOSPFix(a6)	; y = (int)(dist*sin(theta))

	move.w	d0,_tg_y

	; next x and y are offset from tx and ty
	move.w	_tg_tx,d0
	move.w	_tg_x,d1
	add.w	d0,d1	
	move.w	d1,_tg_x	; x = tx+x

	move.w	_tg_ty,d0
	move.w	_tg_y,d1
	add.w	d0,d1	
	move.w	d1,_tg_y	; y = ty+y

	; if pen is up -> don't draw
	cmpi.b	#1,_tg_pen
	beq.s	_draw_to_new_pos

	; pen up -> don't draw, just move to x,y
	move.l	_GfxBase,a6
	move.l	_RPort,a1
	move.w	_tg_x,d0
	move.w	_tg_y,d1
	jsr	_LVOMove(a6)
	bra.s	_setnewtx_ty

_draw_to_new_pos:
	; pen down -> draw a line!
	move.l	_GfxBase,a6
	move.l	_RPort,a1
	move.w	_tg_x,d0
	move.w	_tg_y,d1
	jsr	_LVODraw(a6)
		
_setnewtx_ty:
	move.w	_tg_x,_tg_tx
	move.w	_tg_y,_tg_ty
	
	rts
		
;
; rotate - primitive used by setheading, turn, turnleft and turnright.
;	 - expects degrees in d0 (SIGNED short integer).
;
_rotate:
	ext.l	d0
	divs	#360,d0		; MUST be signed division
	swap	d0		; degs = d0 % 360

        cmpi.w	#0,d0
	bge.s	_storeheading
	add.w	#360,d0		; if d0 < 0 -> d0=360+d0
_storeheading:
	move.w	d0,_tg_degs	
	rts

;
; back - move turtle back by value in d0 (ffp).
;
_back:
	move.w	#0,d1
	jsr	_moveturtle
	rts

;
; forward - move turtle forward by value in d0 (ffp).
;
_forward:
	move.w	#1,d1
	jsr	_moveturtle
	rts

;
; heading - return current turtle heading in d0.
;
_heading:
	move.w	_tg_degs,d0
	rts

;
; home - move turtle to home position, drawing a line if pen down. 
;      - a special case of setxy.
;
_home:
	move.w	_tg_initx,d0
	move.w	_tg_inity,d1
	jsr	_setxy	
	rts
	
;
; pendown - put the turtle's pen down.
;
_pendown:
	move.b	#1,_tg_pen
	rts

;
; penup - lift the turtle's pen up.
;
_penup:
	move.b	#0,_tg_pen
	rts

;
; setheading - change turtle's heading to value in d0 (degrees).
;	
_setheading:
	jsr	_rotate
	rts

;
; setxy - change the drawing coordinates to d0,d1.
;	- expects x in d0 and y in d1.
;
_setxy:
	move.w	d0,_tg_tx
	move.w	d1,_tg_ty

	cmpi.b	#1,_tg_pen
	beq.s	_drawpath	; if pen down -> draw!

	; pen up -> just move to x,y
	move.l	_GfxBase,a6
	move.l	_RPort,a1
;	move.w	_tg_tx,d0
;	move.w	_tg_ty,d1
	jsr	_LVOMove(a6)
	bra	_exitsetxy

_drawpath:
	; pen down -> draw line
	move.l	_GfxBase,a6
	move.l	_RPort,a1
;	move.w	_tg_tx,d0
;	move.w	_tg_ty,d1
	jsr	_LVODraw(a6)
	
_exitsetxy:	
	rts

;
; turn - rotate turtle by d0 degrees from current heading. 
;
_turn:
	add.w	_tg_degs,d0
	jsr	_rotate
	rts
;
; turnleft - rotate turtle d0 degrees to the left from current heading. 
;
_turnleft:
	move.w	_tg_degs,d1
	sub.w	d0,d1
	move.w	d1,d0
	jsr	_rotate
	rts
;
; turnright - rotate turtle d0 degrees to the right from current heading. 
;
_turnright:
	add.w	_tg_degs,d0
	jsr	_rotate
	rts

;
; xcor - returns the turtle's x-coordinate in d0.
;
_xcor:
	move.w	_tg_tx,d0
	rts

;
; ycor - returns the turtle's y-coordinate in d0.
;
_ycor:
	move.w	_tg_ty,d0
	rts

	END
