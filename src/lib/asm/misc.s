;
; misc.s -- an ACE linked library module: miscellaneous functions.
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
;   Date: 3rd-30th November, 1st-13th December 1991,
;	  20th, 23rd,25th-27th January 1992, 
;         2nd,4th,6th,12th-19th,21st-24th,29th February 1992,
;	  1st,14th March 1992,
;	  4th,7th,21st,22nd,26th April 1992,
;	  2nd,3rd,5th,7th,8th,10th-17th May 1992,
;	  6th,8th,11th,12th,28th,30th June 1992,
;	  1st-3rd,13th,14th,18th-20th,22nd July 1992,
;	  9th August 1992,
;	  5th,6th December 1992,
;	  6th January 1993,
;	  7th,16th,18th February 1993,
;	  1st,7th March 1993,
;	  9th,25th,30th May 1993,
;	  12th,16th,29th June 1993,
;	  6th,25th September 1993,
;	  9th,11th,25th,28th October 1993,
;	  10th,15th November 1993
;	  5th December 1993,
;	  5th,7th,10th,12th-15th,23rd January 1994,
;	  6th February 1994,
;	  19th March 1994,
;	  3rd September 1994
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; * CONSTANTS *

PUBLIC		equ	1
CHIP 		equ	2
FAST		equ	4
LARGEST 	equ	131072
POTGO		equ	$dff034
POT1DAT		equ	$dff014
cp_x		equ	36
cp_y		equ	38
Font		equ	52
tf_YSize	equ	20
tf_XSize	equ	24
UserPort	equ	86
GZZMouseX	equ	108
GZZMouseY	equ	110
	
   	; miscellaneous functions
   	xdef  	_rnd
   	xdef  	_absw
   	xdef  	_absl
   	xdef  	_sgnw
   	xdef  	_sgnl
	xdef	_inputshort
	xdef	_inputlong
	xdef	_stick
	xdef	_strig
	xdef	_mouse
	xdef	_fre
	xdef	_potx
	xdef	_poty
	xdef	_err
	xdef	_testerror

	; miscellaneous routines
	xdef	_randomise
	xdef	_open_library
	xdef	_close_library
	xdef	_printLF
	xdef	_printspc
	xdef	_printqun
	xdef	_sleep

	; exportable symbols
	xdef	_error_code
	
   	; external references
	xref	_inputstring
	xref	_short_from_string
	xref	_long_from_string	
	xref	_strlen
	xref	_strip	
   	xref  	_RangeRand
	xref	_RangeSeed
	xref	_DOSBase
	xref	_LVODelay
	xref	_LVOWrite
	xref	_MathBase
	xref	_LVOSPFix
	xref	_LVOSPFlt
	xref	_LVOSPDiv
	xref	_LVOSPMul
	xref	_LVOSPSub
	xref	_LVOSPAdd
	xref	_LVOSPCmp
	xref 	_AbsExecBase
	xref	_LVOAvailMem
	xref	_LVOGetMsg
	xref	_LVOReplyMsg
	xref	_LVOWaitPort
	xref	_LVOOpenLibrary
	xref	_LVOCloseLibrary
	xref	_stdout
	xref	_IntuiMode
	xref	_Wdw
	xref	_TaskAddress
	xref	_Ustringinput

	SECTION misc_code,CODE

;
; short & long abs functions. assumes short/long value in d0.
;
_absw:
   	cmp.w #0,d0    ; num < 0?
   	bge.s _quitabsw
   	neg.w d0
_quitabsw:
   	rts

_absl:
   	cmp.l #0,d0
   	bge.s _quitabsl
   	neg.l d0
_quitabsl:
   	rts

;
; short & long sgn functions. assumes short/long value in d0.
; result returned in d0 (-1,0,1).
;
_sgnw:
	cmpi.w	#0,d0
	beq.s	_sgnwzero
	blt.s	_sgnwneg
	bra.s	_sgnwpos
_sgnwzero:
	moveq	#0,d0
	rts
_sgnwneg:
	moveq	#-1,d0
	rts
_sgnwpos:
	moveq	#1,d0
	rts

_sgnl:
	cmpi.l	#0,d0
	beq.s	_sgnlzero
	blt.s	_sgnlneg
	bra.s	_sgnlpos
_sgnlzero:
	moveq	#0,d0
	rts
_sgnlneg:
	moveq	#-1,d0
	rts
_sgnlpos:
	moveq	#1,d0
	rts

;
; input a short integer value and return it in d0.
; see lex.c insymbol() function re: technique.
; (a1 = input buffer)
;
_inputshort:
	move.l	a1,-(sp)
	jsr	_Ustringinput
	jsr	_short_from_string
	addq	#4,sp
	rts

;
; input a long integer value and return it in d0.
; see lex.c insymbol() function re: technique.
; (a1 = input buffer)
;
_inputlong:
	move.l	a1,-(sp)
	jsr	_Ustringinput
	jsr	_long_from_string
	addq	#4,sp
	rts

;
; STICK - returns in d0 the state of a joystick (only port 2 at the moment).
;	- a parameter in d0 determines the port and axis to be sampled.
;	
;	The hardware is directly accessed by this routine (_joy1dat = DFF00C)
;	(see Amiga Hardware Reference Manual, pg 220). 
;	A future version will use the gameport.device.  
;
_stick:
	cmpi.w	#0,d0
	beq.s	_stick0
	cmpi.w	#1,d0
	beq.s	_stick1
	cmpi.w	#2,d0
	beq.s	_stick2
	cmpi.w	#3,d0
	beq.s	_stick3

	moveq	#0,d0			; none of the above
	rts

_stick0:
	; game port 1 in x direction
	moveq	#0,d0
	rts

_stick1:
	; game port 1 in y direction
	moveq	#0,d0
	rts

_stick2:
	; game port 2 in x direction
	move.l	_joy1dat,a0

	move.w	(a0),d1
	andi.w	#2,d1
	cmpi.w	#2,d1
	beq.s	_stickpos	; right

	move.w	(a0),d1
	andi.w	#512,d1
	cmpi.w	#512,d1
	beq.s	_stickneg	; left

	moveq	#0,d0		; joystick not moving in x axis
	rts
	
_stick3:
	; game port 2 in y direction
	move.l	_joy1dat,a0

	move.w	(a0),d1
	andi.w	#512,d1
	move.w	(a0),d2
	andi.w	#256,d2
	eor.w	d2,d1

	cmpi.w	#256,d1
	beq.s	_stickpos	; up	

	move.w	(a0),d1
	andi.w	#2,d1
	move.w	(a0),d2
	andi.w	#1,d2
	eor.w	d2,d1

	cmpi.w	#1,d1
	beq.s	_stickneg	
	cmpi.w	#2,d1
	beq.s	_stickneg	; down

	moveq	#0,d0		; joystick not moving in y axis
	rts

_stickpos:
	moveq	#1,d0
	rts

_stickneg:
	moveq	#-1,d0
	rts

;
; STRIG - returns in d0 the state of a joystick's fire button
;          (only port 2 at the moment).
;	- a parameter in d0 determines the port to be sampled.
;	
;	The hardware is directly accessed by this routine (_data_reg_A=BFE001).
;	A future version will use the gameport.device.  
;
_strig:
	cmpi.w	#0,d0
	beq.s	_strig0
	cmpi.w	#1,d0
	beq.s	_strig1
	cmpi.w	#2,d0
	beq.s	_strig2
	cmpi.w	#3,d0
	beq.s	_strig3

	moveq	#0,d0			; none of the above
	rts

_strig0:
	; has joystick in port 1 fired since last strig(0)?
	moveq	#0,d0		
	rts
	
_strig1:
	; is joystick in port 1 currently firing?
	moveq	#0,d0		
	rts

_strig2:
	; has joystick in port 2 fired since last strig(2)?
	moveq	#0,d0		
	rts
	
_strig3:
	; is joystick in port 2 currently firing?
	move.l	_data_reg_A,a0
	move.b	(a0),d1
	cmpi.b	#124,d1
	beq.s	_firing
	
	moveq	#0,d0		; fire button not pressed
	rts

_firing:
	moveq	#-1,d0
	rts

;
; MOUSE - returns in d0 information about the mouse (see ace.doc).
;	- a parameter in d0 determines what information is returned.
;
;	A future version of MOUSE(0) may use the gameport.device/Intuition.
;	  
;
_mouse:
	cmpi.w	#0,d0
	beq.s	_mouse0
	cmpi.w	#1,d0
	beq.s	_mouse1
	cmpi.w	#2,d0
	beq.s	_mouse2

	moveq	#0,d0
	rts

_mouse0:
	move.l	_data_reg_A,a0
	move.b	(a0),d1
	andi.w	#$40,d1
	cmpi.b	#$40,d1
	bne.s	_leftbutton
	
	moveq	#0,d0			; left mouse button not pressed
	rts

_leftbutton:
	moveq	#-1,d0			; left mouse button is being pressed
	rts

_mouse1:
	movea.l	_Wdw,a0
	move.w	GZZMouseX(a0),d0	; x-coordinate of mouse (Wdw)
	rts
	
_mouse2:
	movea.l	_Wdw,a0
	move.w	GZZMouseY(a0),d0	; y-coordinate of mouse (Wdw)
	rts

;
; FRE(n) - Gives info' about memory. d0=attribute. Returns long integer in d0.
; [attribute: -1=CHIP+FAST, 0=CHIP, 1=FAST, 2=LARGEST CHIP, 3=LARGEST FAST]
;
_fre:
	movea.l	_AbsExecBase,a6

	cmpi.w	#-1,d0
	beq.s	_frecf		; CHIP+FAST

	cmpi.w	#0,d0
	beq.s	_frec		; CHIP

	cmpi.w	#1,d0
	beq.s	_fref		; FAST

	cmpi.w	#2,d0
	beq.s	_frelc		; LARGEST CHIP

	cmpi.w	#3,d0
	beq.s	_frelf		; LARGEST FAST

	moveq	#0,d0		; illegal n
	rts

_frecf:
	move.l	#CHIP,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,d4
	move.l	#FAST,d1
	jsr	_LVOAvailMem(a6)
	add.l	d4,d0
	rts

_frec:
	move.l	#CHIP,d1
	jsr	_LVOAvailMem(a6)
	rts	

_fref:
	move.l	#FAST,d1
	jsr	_LVOAvailMem(a6)
	rts	

_frelc:
	move.l	#LARGEST,d1
	or.l	#CHIP,d1
	jsr	_LVOAvailMem(a6)
	rts	

_frelf:
	move.l	#LARGEST,d1
	or.l	#FAST,d1
	jsr	_LVOAvailMem(a6)
	rts	

;
; POTX(n) - returns A/D value of potentiometer-x (pin 5) of game controller.
;	  - d0=n (0 or 1) and short integer returned in d0.
;	  - in the current version, POTX(0) always returns 0 (game port 1).
;	  - the hardware is directly sampled.
;
_potx:
	cmpi.w	#0,d0
	beq.s	_potx0

	cmpi.w	#1,d0
	beq.s	_potx1

	move.w	#0,d0	; illegal n
	rts

_potx0:
	; game port 1
	move.w	#0,d0		
	rts

_potx1:
	; game port 2
	move.l	#POTGO,a0
	and.b	#1,(a0)
	movea.l	_DOSBase,a6
	move.l	#1,d1
	jsr	_LVODelay(a6)
	move.l	#POT1DAT,a0
	move.w	(a0),d0
	and.w	#$00ff,d0	; get low byte	
	rts

;
; POTY(n) - returns A/D value of potentiometer-y (pin 9) of game controller.
;	  - d0=n (0 or 1) and short integer returned in d0.
;	  - in the current version, POTY(0) always returns 0 (game port 1).
;	  - the hardware is directly sampled.
;
_poty:
	cmpi.w	#0,d0
	beq.s	_poty0

	cmpi.w	#1,d0
	beq.s	_poty1

	move.w	#0,d0	; illegal n
	rts

_poty0:
	; game port 1
	move.w	#0,d0		
	rts

_poty1:
	; game port 2
	move.l	#POTGO,a0
	and.b	#1,(a0)
	movea.l	_DOSBase,a6
	move.l	#1,d1
	jsr	_LVODelay(a6)
	move.l	#POT1DAT,a0
	move.w	(a0),d0
	and.w	#$ff00,d0	; get high byte
	lsr.w	#8,d0		; d0 \= 256
	rts	

;
; RND function. Returns pseudo-random number between 0 and 1 in d0. 
; 		Makes use of amiga.lib RangeRand() function.
;
_rnd:
	move.l	#$ffff,-(sp)		; max value+1 = 65535
	jsr	_RangeRand		; returns random # in d0 (0..65534)
	addq	#4,sp
	cmpi.l	#0,d0
	bne.s	_0_to_1			
	moveq	#1,d0			; if zero returned, make d0=1
_0_to_1:	
	move.l	_MathBase,a6
	jsr	_LVOSPFlt(a6)
	move.l	#$ffff0050,d1   	; div by 65535.0 for 0 < value < 1
	jsr	_LVOSPDiv(a6)
	rts

;
; RANDOMIZE - Changes amiga.lib's _RangeSeed with value in d0.
;  	      [see also factor() in ace.c]
;
_randomise:
	cmpi.l	#0,d0
	bge.s	_randseed
	neg.l	d0			; make sure it's positive
_randseed:
	move.l	d0,_RangeSeed
	jsr	_rnd			; call RND once to avoid the same
					; first value always being generated
					; (bug in RangeRand?).
	rts

;
; print a line-feed.
;
_printLF:
	move.l	_stdout,d1
	move.l	#_LF,d2
	moveq	#1,d3
	movea.l	_DOSBase,a6
	jsr	_LVOWrite(a6)
	rts

;
; print a single space.
;
_printspc:
	move.l	_stdout,d1
	move.l	#_SPC,d2
	moveq	#1,d3
	movea.l	_DOSBase,a6
	jsr	_LVOWrite(a6)

	rts

;
; print a question mark (for INPUT).
;
_printqun:
	move.l	_stdout,d1
	move.l	#_QUN,d2
	moveq	#2,d3
	movea.l	_DOSBase,a6
	jsr	_LVOWrite(a6)

	rts

;
; SLEEP - wait for mouse/keyboard activity or a menu/gadget event.
;	  (ie: an Intuition event!)
;
_sleep:	
	; this routine gets called from C (menu.c)
	movem.l	d0-d7/a0-a6,-(sp)	
				
	; IntuiMode?
	cmp.b	#1,_IntuiMode
	bne.s	_quitsleep
	
	movea.l	_AbsExecBase,a6

;_reply_to_pending_msg:
;	movea.l	_Wdw,a0
;	movea.l	UserPort(a0),a0
;	jsr	_LVOGetMsg(a6)
;	tst.l	d0
;	beq.s	_intui_wait
;	movea.l	d0,a1
;	jsr	_LVOReplyMsg(a6)
;	bra.s	_reply_to_pending_msg
	
_intui_wait:
	; wait on IDCMP UserPort	
	movea.l	_Wdw,a0
	movea.l	UserPort(a0),a0

	jsr	_LVOWaitPort(a6)

_quitsleep:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
		
;
; open a shared library - a1=address of library name.
;			- return library base in d0.
;
_open_library:
	moveq	#0,d0		; don't care which version
	movea.l	_AbsExecBase,a6
	jsr	_LVOOpenLibrary(a6)
	rts

;
; close a shared library - a1=library base.
;
_close_library:
	cmpa.l	#0,a1
	beq.s	_quit_close_library
	movea.l	_AbsExecBase,a6
	jsr	_LVOCloseLibrary(a6)
_quit_close_library:
	rts

;
; ERR - return error code from last I/O operation and clear error code.
;
_err:
	move.l	_error_code,d0		; return error code
	move.l	#0,_error_code		; reset error code
	rts

;
; ON ERROR - return true or false depending upon whether an I/O 
;   	     error condition has been logged by an ACE function
;	     (see serial and file functions).
;
_testerror:
	moveq	#0,d0
	cmpi.l	#0,_error_code		; is error code = 0?
	bne.s	_quit_testerror		; No -> indicate error present
	rts
_quit_testerror:
	moveq	#1,d0			; error condition present
	rts

;*****************************

	SECTION misc_data,DATA

; * stick *
_joy1dat:	dc.l 	$dff00c

; * strig & mouse *
_data_reg_A:	dc.l 	$bfe001

; * printLF/SPC/QUN *
_LF:		dc.b	10
_SPC:		dc.b	32
_QUN:		dc.b	63,32

; * err & testerror *
_error_code:	dc.l	0

;************************

	SECTION misc_mem,BSS

; * long/shortinput *
_negate:      		ds.b 1

	END
