;
; scroll.s -- an ACE linked library module: scroll bits in a rastport.
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
Width		equ 8
Height		equ 10
Font		equ 52
tf_YSize	equ 20

	xdef	_scroll_screen

   	; external references
	xref	_pos	
	xref	_csrlin	
	xref	_locate
	xref	_windowfunc
	xref	_font_height
	xref	_max_line
	xref	_wdth
	xref	_hgt
	xref	_Wdw
	xref	_RPort
	xref	_GfxBase
	xref	_LVOScrollRaster

	SECTION scroll_code,CODE

;
; Scroll up one text line? Font and window height are taken into account.
;
_scroll_screen:
	move.l	a6,-(sp)	; store a6 (this routine called from C)
 
	; get Wdw height & max. lines
	move.w	#3,d0
	jsr	_windowfunc	; d0 = window height

	; find font height
	movea.l	_RPort,a0
	movea.l	Font(a0),a0
	move.w	tf_YSize(a0),d1
	move.w	d1,_font_height

	; determine maximum line
	divu	d1,d0
	subi.w	#2,d0
	move.w	d0,_max_line

_get_curr_line:
	; get current line
	jsr	_csrlin		; d0=current LINE 
	
	; current line > max-line?
	move.w	_max_line,d1	; d1=max-line
	cmp.w	d1,d0
	bgt.s	_do_scroll	; YES

	move.l	(sp)+,a6

	rts			; NO

_do_scroll:
	move.w	_font_height,-(sp)
	movea.l	_Wdw,a0
	move.w	Width(a0),_wdth
	move.w	Height(a0),_hgt
	
	; scroll screen up one character
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	moveq	#0,d0		; delta_x = 0
	move.w	(sp)+,d1	; delta_y = font height
	moveq	#0,d2
	moveq	#0,d3		; 0,0 = xmin,ymin
	move.w	_wdth,d4	
	move.w	_hgt,d5		; xmax,ymax
	jsr	_LVOScrollRaster(a6)
				
	; move print position to bottom line.
	jsr	_pos
	move.w	d0,d1		; d1=COLUMN
	move.w	_max_line,d0	; d0=LINE
	jsr	_locate

	move.l	(sp)+,a6
		
	rts

	END
