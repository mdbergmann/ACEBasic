;
; ffp.s -- an ACE linked library module: fast-floating-point functions.
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
;	  5th December 1992,
;	  14th,18th,19th February 1993,
;	  1st March 1993,
;	  11th October 1993
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; * CONSTANTS *
MAXSTRINGSIZE	EQU	1024

   	; ffp functions 
   	xdef  	_round
   	xdef  	_absf
  	xdef  	_sgnf
	xdef	_inputsingle
	xdef	_modffp
	xdef	_fix
	xdef	_decimal_places

   	; external references
	xref	_val
   	xref  	_putchar
	xref	_strsingle
	xref	_Ustringinput

  	xref  	_LVOSPFix
	xref	_LVOSPFlt
	xref	_LVOSPFloor
	xref	_LVOSPCeil
	xref	_LVOSPAdd
	xref	_LVOSPSub
	xref	_LVOSPMul
   	xref  	_LVOSPDiv
   	xref  	_LVOSPAbs
   	xref  	_LVOSPTst
	xref	_LVOSPCmp
   	xref  	_MathBase

	SECTION ffp_code,CODE

;*** FAST-FLOATING-POINT FUNCTIONS ***

;
; Rounds the single-precision value in d0. Returns a long integer in d0.
;

_round:
	move.l	d0,_fnum	; save number 

	move.l	d0,d1
	jsr	_sgnf
	move.l	d0,_sign	; get the sign of fnum

	move.l	_fnum,d0
	jsr	_absf		
	move.l	d0,_fnum	; fnum = ABS(fnum)	

	move.l	_MathBase,a6

	move.l	_fnum,d0
	jsr	_LVOSPFix(a6)
	jsr	_LVOSPFlt(a6)	; take integer portion of fnum

	move.l	d0,d1		; d1 = INT(fnum)
	move.l	_fnum,d0
	jsr	_LVOSPSub(a6)	; d0 = fnum [d0] - INT(fnum) [d1]

	move.l	#$80000040,d1	; 0.5
	jsr	_LVOSPCmp(a6)	; (fnum - INT(fnum)) [d0] >= 0.5 [d1] ?

	bge.s	_round_up

	; round down
	move.l	_fnum,d0
	jsr	_LVOSPFloor(a6)
	jsr	_LVOSPFix(a6)
	bra.s	_check_sign

_round_up:
	move.l	_fnum,d0
	jsr	_LVOSPCeil(a6)
	jsr	_LVOSPFix(a6)
		
_check_sign:
	cmpi.l	#-1,_sign
	bne.s	_exitround

	neg.l	d0		; negate value if sign = -1

_exitround:		
   	rts

;
; ffp abs function. assumes ffp value in d0.
;  
_absf:
   	move.l  _MathBase,a6  
   	jsr	_LVOSPAbs(a6)
   	rts

;
; ffp sgn function. d1=fnum. d0=result (-1,0,1).
;
_sgnf:
	move.l	_MathBase,a6
	jsr	_LVOSPTst(a6)
	rts

;
; input a single-precision FFP value and return it in d0.
; (a1 = input buffer)
;
_inputsingle:
	move.l	a1,-(sp)
	jsr	_Ustringinput
	jsr	_val
	addq	#4,sp
	rts

;
; ffp modulo. d0=ffp dividend, d1=ffp divisor. returns d0 mod d1 in d0. 
;
_modffp:
 	move.l d0,_ffpdividend
 	move.l d1,_ffpdivisor

 	movea.l _MathBase,a6

 	jsr _LVOSPDiv(a6) 	; quotient=dividend/divisor
 	jsr _LVOSPFix(a6) 	; quotient=(long)quotient
 	jsr _LVOSPFlt(a6) 	; quotient=(single)quotient
 	move.l _ffpdivisor,d1
 	jsr _LVOSPMul(a6) 	; d0=quotient*divisor
 	move.l d0,d1  
 	move.l _ffpdividend,d0
 	jsr _LVOSPSub(a6) 	; d0=dividend-(quotient*divisor)

 	rts 

;
; FIX n	- Change the number of places to round FFP values to. d0=n.
;	- This value is used by arnd() and may be +ve or -ve (!). 
;
_fix:
	move.l	d0,_decimal_places	
	rts

;************************

	SECTION ffp_data,DATA

_decimal_places:	dc.l 8
	
	SECTION ffp_mem,BSS

_ffpdividend:		ds.l 1
_ffpdivisor:		ds.l 1
_fnum:			ds.l 1
_sign:			ds.l 1
_tmpstring:    		ds.b MAXSTRINGSIZE

	END
