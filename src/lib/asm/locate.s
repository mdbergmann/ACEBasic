;
; locate.s -- an ACE linked library module: LOCATE.
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
Font		equ 52
tf_YSize	equ 20
tf_XSize	equ 24

	xdef	_locate

	; external references	
	xref	_IntuiMode
	xref	_RPort
	xref	_GfxBase
	xref	_LVOMove
	xref	_DOSBase
	xref	_LVOWrite
	xref	_stdout
	xref	_longtemp
	xref	_locatestr

	SECTION locate_code,CODE

;
; LOCATE - places the cursor at LINE,COLUMN in the current window or screen.
; 	   d0=LINE; d1=COLUMN
;	
_locate:
	move.l	a6,-(sp)	; store a6 (LOCATE called within C function)

	; is line value too low?
	cmpi.w	#1,d0
	bge.s	_checklinehi
	move.w	#1,d0

_checklinehi:
	; is line value too high?
	cmpi.w	#56,d0			; arbitrarily high (for height of 400)
	ble.s	_checkcollo
	move.w	#56,d0

_checkcollo:
	; is column value too low?
	cmpi.w	#1,d1
	bge.s	_checkcolhi
	move.w	#1,d1
	
_checkcolhi:	
	; is column value too high?
	cmpi.w	#80,d1			
	ble.s	_changelocn
	move.w	#80,d1

_changelocn:
	; are we in screen or window mode?
	cmp.b	#0,_IntuiMode
	beq.s	_changewindowlocn

	; change screen location for PRINTS (and graphics commands).
	; (first gets font height and width)
	movea.l	_RPort,a0
	movea.l	Font(a0),a0
	move.w	tf_YSize(a0),d2	; height
	move.w	tf_XSize(a0),d3	; width

	mulu	d2,d0	
 	subi.w	#2,d0	; y=LINE*height - 2

	subi.w	#1,d1
	mulu	d3,d1	; x=(COLUMN-1)*width

	; swap d0 and d1
	move.w	d0,d2
	move.w	d1,d0
	move.w	d2,d1

	; move to new x,y
	movea.l	_RPort,a1
	movea.l	_GfxBase,a6
	jsr	_LVOMove(a6)

	move.l	(sp)+,a6

	rts
			
_changewindowlocn:
	; convert LINE value to 2 ASCII digits and place in locate string
	ext.l	d0
	divu	#10,d0
	move.l	d0,_longtemp
	lea	_locatestr,a0
	add.w	#48,d0
	and.b	#$ff,d0
	move.b	d0,1(a0)
	move.l	_longtemp,d0
	swap	d0
	add.w	#48,d0
	and.b	#$ff,d0
	move.b	d0,2(a0)

	; convert COLUMN value to 2 ASCII digits and place in locate string
	ext.l	d1
	divu	#10,d1
	move.l	d1,_longtemp
	lea	_locatestr,a0
	add.w	#48,d1
	and.b	#$ff,d1
	move.b	d1,4(a0)
	move.l	_longtemp,d1
	swap	d1
	add.w	#48,d1
	and.b	#$ff,d1
	move.b	d1,5(a0)

	; change cursor location
	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_locatestr,d2
	move.l	#7,d3
	jsr	_LVOWrite(a6)
	
	move.l	(sp)+,a6
	
	rts

	END
