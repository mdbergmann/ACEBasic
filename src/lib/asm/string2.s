;
; string2.s -- ACE linked library module: additional string functions.
;
; Author: ACE Contributors
;   Date: 2026-02-12
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer.
; d7 is used for array index calculations.
;

	; string functions
	xdef	_ltrimstr
	xdef	_rtrimstr
	xdef	_trimstr

	; external references
	xref	_strlen
	xref	_strcpy

	SECTION string2_code,CODE

;
; LTRIM$(str$) - Remove leading whitespace (spaces and tabs).
; a0 = destination buffer, a1 = source string.
; Returns destination address in a0.
;
_ltrimstr:
	move.l	a0,a3		; save dest address

	; skip leading spaces (32) and tabs (9)
.skipws:
	move.b	(a1),d0
	cmpi.b	#32,d0		; space?
	beq.s	.skipnext
	cmpi.b	#9,d0		; tab?
	beq.s	.skipnext
	bra.s	.copyleft	; non-whitespace found

.skipnext:
	addq	#1,a1
	bra.s	.skipws

.copyleft:
	; a1 now points to first non-ws char (or EOS)
	move.l	a3,a0		; restore dest
	jsr	_strcpy		; copy remaining string
	move.l	a3,a0		; return dest address
	rts

;
; RTRIM$(str$) - Remove trailing whitespace (spaces and tabs).
; a0 = destination buffer, a1 = source string.
; Returns destination address in a0.
;
_rtrimstr:
	move.l	a0,a3		; save dest address

	; first copy source to dest
	jsr	_strcpy

	; find length of dest string
	move.l	a3,a2		; a2 = dest for _strlen
	jsr	_strlen		; d0 = length

	; if empty string, done
	tst.l	d0
	beq.s	.rtrimdone

	; point to last character
	move.l	a3,a0
	add.l	d0,a0
	subq	#1,a0		; a0 = &dest[len-1]

	; walk backward removing trailing ws
.rtrloop:
	cmp.l	a3,a0		; past start of string?
	blt.s	.rtrempty

	move.b	(a0),d0
	cmpi.b	#32,d0		; space?
	beq.s	.rtrnext
	cmpi.b	#9,d0		; tab?
	beq.s	.rtrnext
	bra.s	.rtrterm	; non-ws found, terminate after it

.rtrnext:
	subq	#1,a0
	bra.s	.rtrloop

.rtrempty:
	; entire string was whitespace
	move.b	#0,(a3)
	bra.s	.rtrimdone

.rtrterm:
	; a0 points to last non-ws char, null-terminate after it
	move.b	#0,1(a0)

.rtrimdone:
	move.l	a3,a0		; return dest address
	rts

;
; TRIM$(str$) - Remove leading and trailing whitespace.
; a0 = destination buffer, a1 = source string.
; Returns destination address in a0.
;
_trimstr:
	move.l	a0,a3		; save dest address

	; skip leading whitespace
.tskipws:
	move.b	(a1),d0
	cmpi.b	#32,d0		; space?
	beq.s	.tskipnext
	cmpi.b	#9,d0		; tab?
	beq.s	.tskipnext
	bra.s	.tcopystr

.tskipnext:
	addq	#1,a1
	bra.s	.tskipws

.tcopystr:
	; copy from first non-ws char
	move.l	a3,a0
	jsr	_strcpy

	; now trim trailing whitespace
	move.l	a3,a2
	jsr	_strlen		; d0 = length

	tst.l	d0
	beq.s	.ttrimdone

	; point to last character
	move.l	a3,a0
	add.l	d0,a0
	subq	#1,a0

.ttrloop:
	cmp.l	a3,a0
	blt.s	.ttrempty

	move.b	(a0),d0
	cmpi.b	#32,d0
	beq.s	.ttrnext
	cmpi.b	#9,d0
	beq.s	.ttrnext
	bra.s	.ttrterm

.ttrnext:
	subq	#1,a0
	bra.s	.ttrloop

.ttrempty:
	move.b	#0,(a3)
	bra.s	.ttrimdone

.ttrterm:
	move.b	#0,1(a0)

.ttrimdone:
	move.l	a3,a0
	rts

	END
