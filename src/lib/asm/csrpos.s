;
; csrpos.s -- an ACE linked library module: CSRLIN and POS.
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
;   Date: 19th March 1994
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; * CONSTANTS *

cp_x		equ	36
cp_y		equ	38
Font		equ	52
tf_YSize	equ	20
tf_XSize	equ	24
	
	; functions
	xdef	_pos
	xdef	_csrlin
	
   	; external references
	xref	_IntuiMode
	xref	_RPort

	SECTION csrpos_code,CODE

;
; POS - returns the cursor's column for the current screen.
;
_pos:
	cmpi.b	#1,_IntuiMode
	beq.s	_dopos

	; in a window, so return zero
	moveq	#0,d0
	rts
	
_dopos:
	movea.l	_RPort,a0
	move.w	cp_x(a0),d0
	ext.l	d0
	movea.l	Font(a0),a0
	move.w	tf_XSize(a0),d1
	divu	d1,d0
	addq	#1,d0	; COLUMN = x/font width + 1			
	rts			

;
; CSRLIN - returns the cursor's line for the current screen.
;
_csrlin:
	cmpi.b	#1,_IntuiMode
	beq.s	_docsrlin

	; in a window, so return zero
	moveq	#0,d0
	rts

_docsrlin:
	movea.l	_RPort,a0
	move.w	cp_y(a0),d0
	ext.l	d0
	movea.l	Font(a0),a0
	move.w	tf_YSize(a0),d1
	addq	#2,d0
	divu	d1,d0	; LINE = (y+2)/font height
	rts

	END
