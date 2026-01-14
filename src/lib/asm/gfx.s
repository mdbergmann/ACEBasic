;
; gfx.s -- an ACE linked library module: graphics functions.
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
;	  5th,12th,13th December 1992,
;	  20th,21st January 1993,
;	  1st March 1993,
;	  19th March 1994
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

;* RastPort CONSTANTS *
AreaInfo	EQU	16
TmpRas		EQU	12
LinePtrn	EQU	34
AOlPen		EQU	27
Flags		EQU	32
linepatcnt	EQU	30
AreaPtrn	EQU	8
AreaPtSz	EQU	29

	; graphics routines
	xdef	_ellipse
	xdef	_paint
	xdef	_area
	xdef	_areafill
	xdef	_last_areaX
	xdef	_last_areaY
	xdef	_linepattern
	xdef	_areapattern

   	; external references
	xref	_radconv

	xref	_GfxBase
	xref	_RPort
	xref	_fgdpen
	xref	_LVOWritePixel
	xref	_LVODrawEllipse
	xref	_LVOSetAPen
	xref	_LVOInitArea
	xref	_LVOAllocRaster
	xref	_LVOFreeRaster
	xref	_LVOInitTmpRas
	xref	_LVOFlood
	xref	_LVOAreaDraw
	xref	_LVOAreaEnd
	xref	_LVOAreaMove
	xref	_windowfunc
	xref	_MathBase
	xref	_MathTransBase
	xref	_LVOSPFix
	xref	_LVOSPFlt
	xref	_LVOSPFloor
	xref	_LVOSPAdd
	xref	_LVOSPMul
	xref	_LVOSPDiv
	xref	_LVOSPCmp
	xref	_LVOSPCos
	xref	_LVOSPSin
	xref	_LVOSPLog

	SECTION graphics_code,CODE

;
; ELLIPSE - draw a circle or ellipse. 
;	    d0=x,d1=y,d2=radius,d3=start,d4=end,d5=aspect.
;
;	  - if full ellipse (0-359 degs) -> use DrawEllipse()
;	    otherwise use my own ellipse algorithm (ie: for arcs).
;
_ellipse:
	; store parameters
	move.l	d0,_x
	move.l	d1,_y
	move.l	d2,_radius
	move.l	d3,_startangle
	move.l	d4,_endangle
	move.l	d5,_aspect
	
	; * is it a full ellipse? *
	
	; start angle=0? (start must = 0 AND end must = 359)
	cmpi.l	#0,d3
	bne	_do_my_ellipse		; start <> 0 -> use my algorithm
	
	; end angle=359?
	movea.l	_MathBase,a6
	move.l	d4,d0
	move.l	#$b3800049,d1		; 359 (FFP)
	jsr	_LVOSPCmp(a6)
	bne	_do_my_ellipse		; end <> 359 -> use my algorithm

	; * use faster DrawEllipse() *
	
	; make x and y integers
	move.l	_x,d0
	jsr	_LVOSPFix(a6)
	move.l	d0,_x
	
	move.l	_y,d0
	jsr	_LVOSPFix(a6)
	move.l	d0,_y
	
	; calculate x radius and coerce
	move.l	_radius,d0
	move.l	_aspect,d1
	jsr	_LVOSPDiv(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,_xradius

	; coerce radius 
	move.l	_radius,d0
	jsr	_LVOSPFix(a6)
	cmpi.l	#0,d0
	bne.s	_store_radius
	add.l	#1,_radius		; vertical radius must be > 0
_store_radius:
	move.l	d0,_radius

	; draw ellipse
	movea.l	_GfxBase,a6	
	move.l	_RPort,a1
	move.l	_x,d0
	and.w	#$ffff,d0
	move.l	_y,d1
	and.w	#$ffff,d1
	move.l	_xradius,d2
	and.w	#$ffff,d2
	move.l	_radius,d3
	and.w	#$ffff,d3
	jsr	_LVODrawEllipse(a6)

	rts
	
_do_my_ellipse:	
	; calculate x-radius based upon aspect and radius
	move.l	_radius,d0
	move.l	_aspect,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPDiv(a6)
	move.l	d0,_xradius

	; initial loop value 
	move.l	_startangle,_theta

_plotellipse:
	; calculate x-point (x-point = x + xradius*cos(theta/radconv)
	move.l	_theta,d0
	move.l	_radconv,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPDiv(a6)
	movea.l	_MathTransBase,a6
	jsr	_LVOSPCos(a6)
	move.l	_xradius,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPMul(a6)
	move.l	_x,d1
	jsr	_LVOSPAdd(a6)
	jsr	_LVOSPFix(a6)
;	and.w	#$ffff,d0
	move.w	d0,_outx

	; calculate y-point (y-point = y + radius*sin(theta/radconv)
	move.l	_theta,d0
	move.l	_radconv,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPDiv(a6)
	movea.l	_MathTransBase,a6
	jsr	_LVOSPSin(a6)
	move.l	_radius,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPMul(a6)
	move.l	_y,d1
	jsr	_LVOSPAdd(a6)
	jsr	_LVOSPFix(a6)
;	and.w	#$ffff,d0
	move.w	d0,_outy
	
	; plot point
	movea.l	_RPort,a1
	move.w	_outx,d0
	move.w	_outy,d1
	movea.l	_GfxBase,a6
	jsr	_LVOWritePixel(a6)

	; increment angle by .5
 	move.l	_theta,d0
	move.l	#$80000040,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPAdd(a6)
	move.l	d0,_theta

	; still more to do?  (is theta <= endangle?)
	move.l	_theta,d0
	move.l	_endangle,d1
	jsr	_LVOSPCmp(a6)
	ble	_plotellipse

	rts

;
; RASSIZE 	- d0=x,d1=y
;		- result returned in d0
;		- see graphics/gfx.h
;
_rassize:
	add.l	#15,d0
	asr.l	#3,d0
	and.w	#$fffe,d0
	and.w	#$ffff,d1
	mulu	d1,d0	
	rts

;
; PAINT. d0=X,d1=Y,d2=paintcolor-id,d3=bordercolor-id.
;
_paint:
	; store coordinates.
	move.w	d0,_paint_x
	move.w	d1,_paint_y
	
	; store old fgdpen
	move.w	_fgdpen,_oldfgdpen
		
	; check colours
	cmpi.w	#-1,d2
	bne.s	_checkbordercolr
	move.w	_fgdpen,d2	; if paintcolor-id=-1 
				; -> paintcolor-id=_fgdpen	

_checkbordercolr:
	cmpi.w	#-1,d3
	bne.s	_storecolrs
	move.w	d2,d3		; if bordercolor-id=-1 
				; -> bordercolor-id=_fgdpen

_storecolrs:
	move.w	d2,_paintcolr
	move.w	d3,_bordercolr
	
	; initialise a vector collection matrix.
;	movea.l	_GfxBase,a6
;	lea	_ainfo,a0
;	lea	_areabuf,a1
;	move.w	#160,d0		; ???
;	jsr	_LVOInitArea(a6)
;	movea.l	_RPort,a0
;	move.l	#_ainfo,AreaInfo(a0)
	
	; allocate space for a bitplane
	move.w	#2,d0
	jsr	_windowfunc
	move.l	d0,_WdwWidth	; get width of current window

	move.w	#3,d0
	jsr	_windowfunc
	move.l	d0,_WdwHeight	; get height of current window

	movea.l	_GfxBase,a6
	move.l	_WdwWidth,d0
	move.l	_WdwHeight,d1
	jsr	_LVOAllocRaster(a6)
	move.l	d0,_tbuf	; store planeptr
	cmpi.l	#0,d0
	beq	_quitpaint	; quit if can't allocate space.

	; initialise area of local memory for Flood()
	movea.l	_GfxBase,a6
	lea	_tras,a0
	move.l	_tbuf,a1
	move.l	_WdwWidth,d0
	move.l	_WdwHeight,d1
	jsr	_rassize
	jsr	_LVOInitTmpRas(a6)
	movea.l	_RPort,a0
	move.l	#_tras,TmpRas(a0)	; store pointer to TmpRas

	; set border and foreground pens
	move.l	_RPort,a0

	move.b	AOlPen(a0),_oldbordercolr
	move.w	_bordercolr,d0
	and.b	#$ff,d0
	move.b	d0,AOlPen(a0)	 ; set outline pen
	ori.w	#$0008,Flags(a0) ; set areaoutline flag 
				 ; (see graphics/gfxmacros.h)

	move.w	_paintcolr,d0
	and.b	#$ff,d0
	move.l	_RPort,a1
	movea.l	_GfxBase,a6
	jsr	_LVOSetAPen(a6)

	; flood area enclosed by bordercolr
	movea.l	_GfxBase,a6
	move.l	_RPort,a1
	move.l	#0,d2		; mode=fill all adjacent pixels 
				; searching for border.
	move.w	_paint_x,d0
	move.w	_paint_y,d1
	jsr	_LVOFlood(a6)

	; reset foreground pen
	move.w	_oldfgdpen,d0
	and.b	#$ff,d0
	move.l	_RPort,a1
	movea.l	_GfxBase,a6
	jsr	_LVOSetAPen(a6)

	; reset border color
	movea.l	_RPort,a0	
	move.b	_oldbordercolr,AOlPen(a0) ; set outline pen
	ori.w	#$0008,Flags(a0)  	  ; set areaoutline flag 
				  	  ; (see graphics/gfxmacros.h)

	; free TmpRas memory
	movea.l	_GfxBase,a6
	move.l	_tbuf,a0
	move.l	_WdwWidth,d0
	move.l	_WdwHeight,d1
	jsr	_LVOFreeRaster(a6)
	
_quitpaint:
	movea.l	_RPort,a0
	move.l	#0,TmpRas(a0)
	rts	

;
; AREA - d0=x,d1=y.
;
_area:
	; 20 points already?
	move.l	_areaptcount,d2
	cmpi.l	#20,d2
	beq	_quitarea

	; store x,y
	move.w	d0,_areaX
	move.w	d1,_areaY
	
	; has at least 1 point already been defined?
	cmpi.l	#1,_areaptcount
	bge.s	_add_coord_to_area	; yes -> just add point to area info

	; initialise rastport's AreaInfo structure
	movea.l	_GfxBase,a6
	lea	_areainfo,a0
	lea	_areabuffer,a1
	move.w	#21,d0		; 20 points (need 20 + 1 for this to work)
	jsr	_LVOInitArea(a6)
	movea.l	_RPort,a0
	move.l	#_areainfo,AreaInfo(a0)	; Rastport->AreaInfo = areainfo
	
	; first point of area
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	move.w	_areaX,d0
	move.w	_areaY,d1
	jsr	_LVOAreaMove(a6)

	bra.s	_increment_pt_count			
	
_add_coord_to_area:
	; add point to area info
   	; (if no room left for another point, AreaDraw will return -1)
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	move.w	_areaX,d0
	move.w	_areaY,d1
	jsr	_LVOAreaDraw(a6)

_increment_pt_count:
	; was AreaDraw/Move was successful?
  	cmpi.l	#0,d0
	bne.s	_quitarea	

	; increment point counter
	add.l	#1,_areaptcount		

	; store last X & Y
	move.w	_areaX,_last_areaX
	move.w	_areaY,_last_areaY

_quitarea:
	rts

;
; AREAFILL - d0=mode.
;
_areafill:
;	bra	_quitareafill

	; save current pen
	move.w	_fgdpen,_oldfgdpen

	; check mode (0=fill normally; 1=fill with inverted color)
	cmpi.w	#0,d0
	beq.s	_justfillarea
	
	; change foreground pen to max-color-id - fdgpen
	move.l	#6,d0
	jsr	_windowfunc	; d0 = max-color-id for Rasport
	
	move.w	_fgdpen,d1
	ext.l	d1
	sub.l	d1,d0		; d0 = d0 - _fgdpen

	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	jsr	_LVOSetAPen(a6)
	
_justfillarea:
	; have at least 2 points been defined?
	cmpi.l	#2,_areaptcount
	blt	_quitareafill	; no -> go no further

	; initialise rastport's TmpRas structure	
	move.w	#2,d0
	jsr	_windowfunc
	move.l	d0,_WdwWidth	; get width of current window

	move.w	#3,d0
	jsr	_windowfunc
	move.l	d0,_WdwHeight	; get height of current window

	movea.l	_GfxBase,a6
	move.l	_WdwWidth,d0
	move.l	_WdwHeight,d1
	jsr	_LVOAllocRaster(a6)
	cmpi.l	#0,d0
	beq	_quitareafill
	move.l	d0,_TRBuf	; store pointer to buffer

	movea.l	_GfxBase,a6
	move.l	_WdwWidth,d0
	move.l	_WdwHeight,d1
	jsr	_rassize	; result in d0 = plane size in bytes (not bits!)
	lea	_tmpras,a0
	movea.l	_TRBuf,a1
	jsr	_LVOInitTmpRas(a6)
	movea.l	_RPort,a0
	move.l	#_tmpras,TmpRas(a0)	; Rastport->TmpRas = tmpras	

	; ** fill defined area! **
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	jsr	_LVOAreaEnd(a6)

	; restore old fgnd color
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	move.w	_oldfgdpen,d0
	ext.l	d0
	jsr	_LVOSetAPen(a6)
	move.w	_oldfgdpen,_fgdpen

	; free buffer
	movea.l	_GfxBase,a6
	movea.l	_TRBuf,a0
	move.l	_WdwWidth,d0
	move.l	_WdwHeight,d1	
	jsr	_LVOFreeRaster(a6)
		
_quitareafill:
	; get ready for next area
	move.l	#0,_areaptcount	; # of points = 0
	movea.l	_RPort,a0
	move.l	#0,TmpRas(a0)	; Rp->TmpRas = NULL
	move.l	#0,AreaInfo(a0)	; Rp->AreaInfo = NULL
	rts

;
; PATTERN - linepattern: d0=line-pattern.
;			 d1=RESTORE flag.
;
;	  - see graphics/gfxmacros.h: SetDrPt()
;
_linepattern:
	; get current RastPort
	movea.l	_RPort,a1

	; new line pattern or restore default?
	cmpi.l	#0,d1
	beq.s	_newlinepattern

	; restore default
	move.w	#$ffff,LinePtrn(a1)
	bra.s	_finishlinepattern

_newlinepattern:
	move.w	d0,LinePtrn(a1)

_finishlinepattern:
	ori.w	#$0001,Flags(a1)
	move.b	#15,linepatcnt(a1)

	rts

;
; PATTERN - areapattern: a0=address of area-pattern array.
;			 d0=size of area-pattern array.
;			 d1=RESTORE flag.
;
;	  - see graphics/gfxmacros.h: SetAfPt()  
;	    and "Inside Amiga Graphics", pp 116,117
;
_areapattern:
	; new area pattern or restore default?
	cmpi.l	#0,d1
	beq.s	_newareapattern

	; restore default
	movea.l	_RPort,a1
	move.l	#_default_area_pat,AreaPtrn(a1)
	move.b	#0,AreaPtSz(a1)	; height = 2^0 = 1 (ie: height in short words)
	bra.s	_exitareapattern

_newareapattern:
	move.l	a0,AreaPtrn(a1)	; address of area pattern array	

	; find Log2(size): LogE(areapat_size) / LogE(2)
	movea.l	_MathBase,a6
	jsr	_LVOSPFlt(a6)	; d0 = (float)d0
	movea.l	_MathTransBase,a6
	jsr	_LVOSPLog(a6)
	move.l	d0,-(sp)	; save result of LogE(size)

	move.l	#$80000042,d0	; 2.0
	jsr	_LVOSPLog(a6)

	move.l	d0,d1		; LogE(2)
	move.l	(sp)+,d0	; LogE(size)
	movea.l	_MathBase,a6
	jsr	_LVOSPDiv(a6)

	jsr	_LVOSPFloor(a6)	; round it
	jsr	_LVOSPFix(a6)	; d0 = (long)d0

	movea.l	_RPort,a1
	move.b	d0,AreaPtSz(a1)	; height = 2^d0			
		
_exitareapattern:
	rts

;*********************************

	SECTION graphics_data,DATA

; * paint *
_tras:			
	dc.l 0
	dc.l 0

_ainfo:	
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.w 0
	dc.w 0
	dc.w 0
	dc.w 0

; * area *
_areainfo:
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.w 0
	dc.w 0
	dc.w 0
	dc.w 0
	
_tmpras:	
	dc.l 0
	dc.l 0

_areaptcount:	dc.l 0	; has an area been started?		

; * pattern *
_default_area_pat:	dc.w $ffff

;************************

	SECTION graphics_mem,BSS

; * general *
_WdwWidth:		ds.l 1
_WdwHeight:		ds.l 1

; * ellipse *
_x:			ds.l 1
_y:			ds.l 1
_radius:		ds.l 1
_xradius:		ds.l 1
_startangle:		ds.l 1
_endangle:		ds.l 1
_aspect:		ds.l 1
_theta:			ds.l 1
_outx:			ds.w 1
_outy:			ds.w 1

; * paint *
_areabuf:		ds.w 800
_tbuf:			ds.l 1
_paintcolr:		ds.w 1
_bordercolr:		ds.w 1
_oldbordercolr:		ds.b 1
_paint_x:		ds.w 1
_paint_y:		ds.w 1
_oldfgdpen:		ds.w 1
_border:		ds.w 1

; * area *
_areabuffer:		ds.w 53		; buffer for 20+1 SHORT points (21x2.5)
_areaX:			ds.w 1
_areaY:			ds.w 1
_last_areaX:		ds.w 1	  	
_last_areaY:		ds.w 1  	; _last_areaX/Y	for use by AREA STEP...
_TRBuf:			ds.l 1

	END
