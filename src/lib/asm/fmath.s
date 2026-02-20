;
; fmath.s -- an ACE linked library module: single-precision float functions.
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

   	; float math functions
   	xdef  	_round
   	xdef  	_absf
  	xdef  	_sgnf
	xdef	_inputsingle
	xdef	_modfloat
	xdef	_truncfix
	xdef	_fix
	xdef	_decimal_places

   	; external references
	xref	_val
	xref	_Ustringinput

  	xref  	_LVOIEEESPFix
	xref	_LVOIEEESPFloor
	xref	_LVOIEEESPCeil
	xref	_LVOIEEESPAdd
	xref	_LVOIEEESPSub
	xref	_LVOIEEESPMul
   	xref  	_LVOIEEESPDiv
   	xref  	_LVOIEEESPAbs
   	xref  	_LVOIEEESPTst
   	xref  	_MathBase

	SECTION fmath_code,CODE

;*** SINGLE-PRECISION FLOAT FUNCTIONS ***

;
; Rounds the single-precision value in d0 to the nearest integer
; (round half away from zero). Returns a long integer in d0.
;

_round:
	move.l	d0,_fnum	; save original float

	jsr	_sgnf		; d0 = sign (-1, 0, 1)
	move.l	d0,_sign

	move.l	_fnum,d0
	jsr	_absf		; d0 = abs(fnum)

	move.l	_MathBase,a6
	move.l	#$3F000000,d1	; 0.5 IEEE
	jsr	_LVOIEEESPAdd(a6)	; d0 = abs(fnum) + 0.5
	jsr	_LVOIEEESPFloor(a6)	; d0 = floor(abs(fnum) + 0.5)
	jsr	_LVOIEEESPFix(a6)	; d0 = (long) result

	cmpi.l	#-1,_sign
	bne.s	_exitround
	neg.l	d0		; negate if original was negative

_exitround:
   	rts

;
; Truncate float toward zero and return as long integer.
; Input: d0 = IEEE SP float
; Output: d0 = long integer (truncated toward zero)
; FIX(3.7)=3, FIX(-3.7)=-3
;
_truncfix:
	move.l	_MathBase,a6
	tst.l	d0		; IEEE 754: bit 31 = sign
	bmi.s	_truncfix_neg
	jsr	_LVOIEEESPFloor(a6)	; positive: floor
	jsr	_LVOIEEESPFix(a6)
	rts
_truncfix_neg:
	jsr	_LVOIEEESPCeil(a6)	; negative: ceil
	jsr	_LVOIEEESPFix(a6)
	rts

;
; float abs function. assumes float value in d0.
;
_absf:
   	move.l  _MathBase,a6
   	jsr	_LVOIEEESPAbs(a6)
   	rts

;
; float sgn function. d0=fnum. d0=result (-1,0,1).
;
_sgnf:
	move.l	_MathBase,a6
	jsr	_LVOIEEESPTst(a6)
	rts

;
; input a single-precision float value and return it in d0.
; (a1 = input buffer)
;
_inputsingle:
	move.l	a1,-(sp)
	jsr	_Ustringinput
	jsr	_val
	addq	#4,sp
	rts

;
; float modulo. d0=dividend, d1=divisor. returns d0 mod d1 in d0.
; Uses truncation toward zero for the quotient.
;
_modfloat:
 	move.l d0,_floatdividend
 	move.l d1,_floatdivisor

 	movea.l _MathBase,a6

 	jsr _LVOIEEESPDiv(a6) 	; d0 = dividend/divisor
	; truncate toward zero (floor for positive, ceil for negative)
	tst.l d0		; IEEE 754: bit 31 = sign
	bmi.s _modfloat_neg
	jsr _LVOIEEESPFloor(a6)
	bra.s _modfloat_cont
_modfloat_neg:
	jsr _LVOIEEESPCeil(a6)
_modfloat_cont:
 	move.l _floatdivisor,d1
 	jsr _LVOIEEESPMul(a6) 	; d0=trunc(quotient)*divisor
 	move.l d0,d1
 	move.l _floatdividend,d0
 	jsr _LVOIEEESPSub(a6) 	; d0=dividend-trunc(quotient)*divisor

 	rts

;
; FIX n	- Change the number of decimal places for float formatting. d0=n.
;
_fix:
	move.l	d0,_decimal_places
	rts

;************************

	SECTION fmath_data,DATA

_decimal_places:	dc.l 8

	SECTION fmath_mem,BSS

_floatdividend:		ds.l 1
_floatdivisor:		ds.l 1
_fnum:			ds.l 1
_sign:			ds.l 1
_tmpstring:    		ds.b MAXSTRINGSIZE

	END
