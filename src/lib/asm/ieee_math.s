;
; ieee_math.s -- Bridge VBCC internal softfloat names to Amiga IEEE SP LVOs.
;
; VBCC compiles C float operations to internal function calls (__ieeedivl,
; __ieeeaddl, etc.). These stubs bridge those names to the mathieeesingbas
; library via direct LVO calls through _MathIeeeSingBasBase.
;
; All stubs use C calling convention (args on stack, result in d0).
; VBCC m68k scratch regs: d0, d1, a0, a1, a6 -- all safe to clobber.
;
; Author: ACE project
; Date: 2026-02-20
;

	; exports -- arithmetic (two args: 4(sp)=arg1, 8(sp)=arg2)
	xdef	___ieeeaddl
	xdef	___ieeesubl
	xdef	___ieeemull
	xdef	___ieeedivl

	; exports -- unary (one arg: 4(sp)=arg)
	xdef	___ieeenegl

	; exports -- fix/flt (long)
	xdef	___ieeefltsl
	xdef	___ieeefixlsl

	; exports -- fix/flt (short/byte variants, same implementation)
	xdef	___ieeefltswl
	xdef	___ieeefltsbl
	xdef	___ieeefixlsw
	xdef	___ieeefixlsb

	; exports -- comparisons
	xdef	___ieeecmplge
	xdef	___ieeecmplgt
	xdef	___ieeecmplle
	xdef	___ieeecmpllt
	xdef	___ieeecmpleq
	xdef	___ieeecmplneq
	xdef	___ieeecmpl
	xdef	___ieeetstl

	; imports -- library base (opened by startup.s)
	xref	_MathIeeeSingBasBase

	; imports -- LVO offsets (from amiga.lib)
	xref	_LVOIEEESPAdd
	xref	_LVOIEEESPSub
	xref	_LVOIEEESPMul
	xref	_LVOIEEESPDiv
	xref	_LVOIEEESPNeg
	xref	_LVOIEEESPFlt
	xref	_LVOIEEESPFix
	xref	_LVOIEEESPCmp
	xref	_LVOIEEESPTst

	SECTION	ieee_math_code,CODE

;---------------------------------------------------------------------------
; Arithmetic -- two-arg functions: 4(sp)=arg1, 8(sp)=arg2, result in d0
;---------------------------------------------------------------------------

___ieeeaddl:
	move.l	4(sp),d0
	move.l	8(sp),d1
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPAdd(a6)
	rts

___ieeesubl:
	move.l	4(sp),d0
	move.l	8(sp),d1
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPSub(a6)
	rts

___ieeemull:
	move.l	4(sp),d0
	move.l	8(sp),d1
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPMul(a6)
	rts

___ieeedivl:
	move.l	4(sp),d0
	move.l	8(sp),d1
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPDiv(a6)
	rts

;---------------------------------------------------------------------------
; Unary -- one-arg functions: 4(sp)=arg, result in d0
;---------------------------------------------------------------------------

___ieeenegl:
	move.l	4(sp),d0
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPNeg(a6)
	rts

;---------------------------------------------------------------------------
; Fix/Flt -- VBCC sign-extends all integer args to 32 bits on the stack,
; so short and byte variants are identical to the long variants.
;---------------------------------------------------------------------------

___ieeefltsl:
___ieeefltswl:
___ieeefltsbl:
	move.l	4(sp),d0
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPFlt(a6)
	rts

___ieeefixlsl:
___ieeefixlsw:
___ieeefixlsb:
	move.l	4(sp),d0
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPFix(a6)
	rts

;---------------------------------------------------------------------------
; Comparisons -- call IEEESPCmp via LVO, then convert result to boolean.
;
; IEEESPCmp(d0, d1) returns:  -1 if d0 < d1,  0 if d0 == d1,  +1 if d0 > d1
; VBCC comparison stubs must return:  0 (false) or 1 (true)
;
; C calling convention: args on stack [4(sp)=arg1, 8(sp)=arg2]
;---------------------------------------------------------------------------

; Helper macro: call IEEESPCmp with args from stack
_docmp	MACRO
	move.l	4(sp),d0	; arg1
	move.l	8(sp),d1	; arg2
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPCmp(a6)
	ENDM

___ieeecmplge:
	_docmp
	bge.s	.true
	moveq	#0,d0
	rts
.true:	moveq	#1,d0
	rts

___ieeecmplgt:
	_docmp
	bgt.s	.true
	moveq	#0,d0
	rts
.true:	moveq	#1,d0
	rts

___ieeecmplle:
	_docmp
	ble.s	.true
	moveq	#0,d0
	rts
.true:	moveq	#1,d0
	rts

___ieeecmpllt:
	_docmp
	blt.s	.true
	moveq	#0,d0
	rts
.true:	moveq	#1,d0
	rts

___ieeecmpleq:
	_docmp
	beq.s	.true
	moveq	#0,d0
	rts
.true:	moveq	#1,d0
	rts

___ieeecmplneq:
	_docmp
	bne.s	.true
	moveq	#0,d0
	rts
.true:	moveq	#1,d0
	rts

;---------------------------------------------------------------------------
; __ieeecmpl -- three-way comparison, return -1/0/+1 as-is
;---------------------------------------------------------------------------
___ieeecmpl:
	_docmp
	rts

;---------------------------------------------------------------------------
; __ieeetstl -- test sign/zero of single float, return -1/0/+1
; IEEESPTst(d0) -- single arg on stack
;---------------------------------------------------------------------------
___ieeetstl:
	move.l	4(sp),d0
	move.l	_MathIeeeSingBasBase,a6
	jsr	_LVOIEEESPTst(a6)
	rts

	END
