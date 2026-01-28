;
; Double-precision math interface library for ACE.
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
; Register a6 is preserved and restored by each routine
; since Sozobon C uses this as a link register.
; 
; Author: David J Benn
;   Date: 11th February 1996,
;	  16th August 1996,
;	  29th September 1996,
;	  1st,18th October 1996
;

TRUE	equ	-1
FALSE	equ	0

	; Basic functions.
	xref	_LVOIEEEDPAbs
	xref	_LVOIEEEDPAdd
	xref	_LVOIEEEDPCeil
	xref	_LVOIEEEDPCmp
	xref	_LVOIEEEDPDiv
	xref	_LVOIEEEDPFix
	xref	_LVOIEEEDPFloor
	xref	_LVOIEEEDPFlt
	xref	_LVOIEEEDPMul
	xref	_LVOIEEEDPNeg
	xref	_LVOIEEEDPSub
	xref	_LVOIEEEDPTst

	; Transcendental functions.
	xref	_LVOIEEEDPAsin
	xref	_LVOIEEEDPAcos
	xref	_LVOIEEEDPAtan
	xref	_LVOIEEEDPSin
	xref	_LVOIEEEDPCos
	xref	_LVOIEEEDPTan
	xref	_LVOIEEEDPSincos
	xref	_LVOIEEEDPSinh
	xref	_LVOIEEEDPCosh
	xref	_LVOIEEEDPTanh
	xref	_LVOIEEEDPExp
	xref	_LVOIEEEDPFieee
	xref	_LVOIEEEDPLog
	xref	_LVOIEEEDPLog10
	xref	_LVOIEEEDPPow
	xref	_LVOIEEEDPSqrt
	xref	_LVOIEEEDPTieee

	; Miscellaneous external references.
	xref	_AbsExecBase
	xref	_LVOOpenLibrary
	xref	_LVOCloseLibrary

	xref	_MathTransBase
	xref	_LVOSPFieee	
	xref	_LVOSPTieee	

	; Exports.
	xdef	_MathIeeeDoubBasBase
	xdef	_MathIeeeDoubTransBase

	section	code, dp_code

;************************************

	PUBLIC	_dp_open
	;
	; Open IEEE DP libraries x 2.
	;
_dp_open:
	move.l	a6,_a6

	movea.l _AbsExecBase,a6		

	; Open basic library.
	movea.l	#_ieeedoubbaslibname,a1
	move.l	#34,d0
	jsr     _LVOOpenLibrary(a6)
	tst.l	d0
	beq.s	_abort_dp_open
	move.l	d0,_MathIeeeDoubBasBase

	; Open transcendental library.
	movea.l	#_ieeedoubtranslibname,a1
	move.l	#34,d0
	jsr     _LVOOpenLibrary(a6)
	tst.l	d0
	beq.s	_abort_dp_open
	move.l	d0,_MathIeeeDoubTransBase
	
	; Exit with success code (TRUE).
	move.l	#TRUE,d0	; okay.
	bra.s	_exit_dp_open

_abort_dp_open:
	move.l	#FALSE,d0	; error.

_exit_dp_open:
	movea.l	_a6,a6
	
	rts

;************************************

	PUBLIC	_dp_close
	;
	; Close IEEE DP libraries x 2.
	;
_dp_close:
	move.l	a6,_a6

	tst.l	_MathIeeeDoubBasBase
	beq.s	_exit_dp_close

	movea.l _AbsExecBase,a6

	move.l  _MathIeeeDoubBasBase,a1
	jsr     _LVOCloseLibrary(a6)

	tst.l	_MathIeeeDoubTransBase
	beq.s	_exit_dp_close

	move.l  _MathIeeeDoubTransBase,a1
	jsr     _LVOCloseLibrary(a6)

_exit_dp_close:
	movea.l	_a6,a6
	
	rts

;************************************

	PUBLIC	_dp_longint_to_double
	;
	; Convert LONGINT to DOUBLE.
	;
_dp_longint_to_double:
	move.l	a6,_a6

	move.l	8(sp),d0		; integer value.

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPFlt(a6)

	move.l	4(sp),a0		; address of double result.
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6
	
	rts

;************************************

	PUBLIC	_dp_double_to_longint
	;
	; Convert DOUBLE to LONGINT.
	;
_dp_double_to_longint:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of double.
	
	move.l	(a1)+,d0
	move.l	(a1),d1

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPFix(a6)

	move.l	4(sp),a0		; address of integer result.
	move.l	d0,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_single_to_double
	;
	; Convert SINGLE to DOUBLE.
	;
_dp_single_to_double:
	move.l	a6,_a6

	move.l	8(sp),d0		; single value.

	movea.l	_MathTransBase,a6
	jsr	_LVOSPTieee(a6)		; FFP -> IEEE SP
	movea.l	_MathIeeeDoubTransBase,a6	
	jsr	_LVOIEEEDPFieee(a6)	; IEEE SP -> IEEE DP

	move.l	4(sp),a0		; address of double result.
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6
	
	rts

;************************************

	PUBLIC	_dp_double_to_single
	;
	; Convert DOUBLE to SINGLE.
	;
_dp_double_to_single:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of double.

	move.l	(a1)+,d0
	move.l	(a1),d1

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPTieee(a6)	; IEEE DP -> IEEE SP
	movea.l	_MathTransBase,a6
	jsr	_LVOSPFieee(a6)		; IEEE SP -> FFP

	move.l	4(sp),a0		; address of single result.
	move.l	d0,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_add
	;
	; Add two DOUBLE values (result = op1 + op2).
	;
_dp_add:
	move.l	a6,_a6

	move.l	12(sp),a2		; address of operand 2.
	move.l	8(sp),a1		; address of operand 1.

	move.l	(a2)+,d2
	move.l	(a2),d3			

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPAdd(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_sub
	;
	; Subtract two DOUBLE values (result = op1 - op2).
	;
_dp_sub:
	move.l	a6,_a6

	move.l	12(sp),a2		; address of operand 2.
	move.l	8(sp),a1		; address of operand 1.

	move.l	(a2)+,d2
	move.l	(a2),d3			

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPSub(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_mul
	;
	; Multiply two DOUBLE values (result = op1 * op2).
	;
_dp_mul:
	move.l	a6,_a6

	move.l	12(sp),a2		; address of operand 2.
	move.l	8(sp),a1		; address of operand 1.

	move.l	(a2)+,d2
	move.l	(a2),d3			

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPMul(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_div
	;
	; Divide two DOUBLE values (result = op1 / op2).
	;
_dp_div:
	move.l	a6,_a6

	move.l	12(sp),a2		; address of operand 2.
	move.l	8(sp),a1		; address of operand 1.

	move.l	(a2)+,d2
	move.l	(a2),d3			

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPDiv(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_cmp
	;
	; Compare two DOUBLE values.
	; Returns an integer:
	; 
	; 	+1 if op1 > op2
	; 	-1 if op1 < op2
	; 	 0 if op1 = op2
	;
_dp_cmp:
	move.l	a6,_a6

	move.l	12(sp),a2		; address of operand 2.
	move.l	8(sp),a1		; address of operand 1.

	move.l	(a2)+,d2
	move.l	(a2),d3			

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPCmp(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_pow
	;
	; Raise one DOUBLE to the power of another.
	; (result = op1 ^ op2).
	;
_dp_pow:
	move.l	a6,_a6

	move.l	12(sp),a2		; address of operand 2.
	move.l	8(sp),a1		; address of operand 1.

	move.l	(a1)+,d0
	move.l	(a1),d1		

	move.l	(a2)+,d2
	move.l	(a2),d3

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPPow(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_abs
	;
	; Return the absolute value of a DOUBLE.
	;
_dp_abs:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPAbs(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_neg
	;
	; Return the negated value of a DOUBLE.
	;
_dp_neg:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPNeg(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_ceil
	;
	; Return the least integer which is >= a DOUBLE.
	; Result is DOUBLE not LONGINT!
	;
_dp_ceil:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPCeil(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_floor
	;
	; Return the largest integer which is <= a DOUBLE.
	; Result is DOUBLE not LONGINT!
	;
_dp_floor:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubBasBase,a6
	jsr	_LVOIEEEDPFloor(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_sin
	;
	; Return the sine of a DOUBLE (radians).
	;
_dp_sin:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPSin(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_cos
	;
	; Return the cosine of a DOUBLE (radians).
	;
_dp_cos:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPCos(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_tan
	;
	; Return the tangent of a DOUBLE (radians).
	;
_dp_tan:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPTan(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_exp
	;
	; Return e to the power of a DOUBLE.
	;
_dp_exp:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPExp(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_log
	;
	; Return the natural logarithm (base e) of a DOUBLE.
	;
_dp_log:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPLog(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************

	PUBLIC	_dp_sqrt
	;
	; Return the square root of a DOUBLE.
	;
_dp_sqrt:
	move.l	a6,_a6

	move.l	8(sp),a1		; address of operand.

	move.l	(a1)+,d0
	move.l	(a1),d1	

	movea.l	_MathIeeeDoubTransBase,a6
	jsr	_LVOIEEEDPSqrt(a6)

	move.l	4(sp),a0		; address of result.	
	move.l	d0,(a0)+
	move.l	d1,(a0)

	movea.l	_a6,a6

	rts

;************************************
		
	section	data, dp_data

_ieeedoubbaslibname:	dc.b	'mathieeedoubbas.library',0
_ieeedoubtranslibname:	dc.b	'mathieeedoubtrans.library',0

_MathIeeeDoubBasBase:	dc.l 	0
_MathIeeeDoubTransBase:	dc.l 	0

;************************************

	section bss, dp_bss

_a6:			ds.l 1

;************************************

	END
