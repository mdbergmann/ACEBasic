;
; windowfunc.s -- an ACE linked library module: WINDOW(n).
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
;   Date: 19th March 1994,
;	  13th August 1994,
;	  12th March 1995
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; * CONSTANTS *
Width		equ 8
Height		equ 10
cp_x		equ 36
cp_y		equ 38
BitMap		equ 184
Depth		equ 5
Font		equ 52
tf_YSize	equ 20
tf_XSize	equ 24
lib_Version	equ 20

	xdef	_windowfunc

   	; external references
	xref	_Wdw_id
	xref	_Wdw
	xref	_RPort
	xref	_Scrn
	xref	_stdout
	xref	_fgdpen
	xref	_bgpen
	xref	_get_selected_wdw

	SECTION windowfunc_code,CODE

;
; WINDOW(n) - returns info' about the current output window. d0=n.
;	    - return value is a long integer in d0.	
;
_windowfunc:
	cmpi.w	#0,d0
	beq	_window0
	cmpi.w	#1,d0
	beq	_window1
	cmpi.w	#2,d0
	beq	_window2
	cmpi.w	#3,d0
	beq	_window3
	cmpi.w	#4,d0
	beq	_window4
	cmpi.w	#5,d0
	beq	_window5
	cmpi.w	#6,d0
	beq	_window6
	cmpi.w	#7,d0
	beq	_window7
	cmpi.w	#8,d0
	beq	_window8
	cmpi.w	#9,d0
	beq	_window9
	cmpi.w	#10,d0
	beq	_window10
	cmpi.w	#11,d0
	beq	_window11
	cmpi.w	#12,d0
	beq	_window12
	cmpi.w	#13,d0
	beq	_window13
	
	moveq	#0,d0
	rts			; none of the above

_window0:
	movem.l	d1-d7/a0-a6,-(sp)
	jsr	_get_selected_wdw
	movem.l	(sp)+,d1-d7/a0-a6
	rts

_window1:
	move.w	_Wdw_id,d0	; Wdw-id
	ext.l	d0
	rts

_window2:
	movea.l	_Wdw,a0
	move.w	Width(a0),d0	; current Wdw width
	ext.l	d0
	rts

_window3:
	movea.l	_Wdw,a0
	move.w	Height(a0),d0	; current Wdw height
	ext.l	d0
	rts

_window4:
	move.l	_RPort,a0
	move.w	cp_x(a0),d0	; next x coordinate to be used
	ext.l	d0	
	rts

_window5:
	move.l	_RPort,a0
	move.w	cp_y(a0),d0	; next y coordinate to be used
	ext.l	d0	
	rts

_window6:
	movea.l	_Scrn,a0
	adda.l	#BitMap,a0	; BitMap
	move.b	Depth(a0),d0	; depth
	ext.w	d0
	ext.l	d0
	moveq	#1,d1		
_calc_max_colr_id:
	lsl.l	#1,d1
	subq	#1,d0		
	cmpi.l	#0,d0
	bgt.s	_calc_max_colr_id
	subq	#1,d1
	move.l	d1,d0		; max-color-id = 2^depth - 1
	rts

_window7:
	move.l	_Wdw,d0		; Intuition Wdw address
	rts

_window8:
	move.l	_RPort,d0	; Intuition RPort address
	rts

_window9:
	move.l	_stdout,d0	; file handle	
	rts

_window10:
	move.w	_fgdpen,d0
	ext.l	d0		; foreground pen
	rts

_window11:
	move.w	_bgpen,d0
	ext.l	d0		; background pen
	rts

_window12:
	movea.l	_RPort,a0
	movea.l	Font(a0),a0
	move.w	tf_XSize(a0),d0	
	ext.l	d0		; font width
	rts

_window13:
	movea.l	_RPort,a0
	movea.l	Font(a0),a0
	move.w	tf_YSize(a0),d0	
	ext.l	d0		; font height
	rts

	END
