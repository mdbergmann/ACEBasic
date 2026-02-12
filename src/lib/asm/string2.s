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
	xdef	_startswith
	xdef	_endswith
	xdef	_rinstr

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

;
; STARTSWITH(str$, prefix$) - Test if str$ starts with prefix$.
; a0 = str$, a1 = prefix$.
; Returns -1 (TRUE) in d0 if match, 0 (FALSE) otherwise.
;
_startswith:
.swloop:
	move.b	(a1),d1		; get prefix char
	tst.b	d1
	beq.s	.swtrue		; end of prefix = match

	move.b	(a0),d0		; get str char
	tst.b	d0
	beq.s	.swfalse	; str shorter than prefix

	cmp.b	d1,d0
	bne.s	.swfalse	; mismatch

	addq	#1,a0
	addq	#1,a1
	bra.s	.swloop

.swtrue:
	moveq	#-1,d0		; TRUE
	rts

.swfalse:
	moveq	#0,d0		; FALSE
	rts

;
; ENDSWITH(str$, suffix$) - Test if str$ ends with suffix$.
; a0 = str$, a1 = suffix$.
; Returns -1 (TRUE) in d0 if match, 0 (FALSE) otherwise.
;
_endswith:
	; get length of str$
	move.l	a0,d2		; save str$ ptr
	move.l	a1,d3		; save suffix$ ptr
	move.l	a0,a2
	jsr	_strlen
	move.l	d0,d4		; d4 = strlen(str$)

	; get length of suffix$
	move.l	d3,a2
	jsr	_strlen		; d0 = strlen(suffix$)

	; if suffix longer than str, false
	cmp.l	d4,d0
	bgt.s	.ewfalse

	; compare from offset = strlen(str) - strlen(suffix)
	move.l	d4,d1
	sub.l	d0,d1		; d1 = offset into str$
	move.l	d2,a0		; restore str$
	add.l	d1,a0		; a0 = str$ + offset
	move.l	d3,a1		; restore suffix$

.ewloop:
	move.b	(a1),d1
	tst.b	d1
	beq.s	.ewtrue		; end of suffix = match

	move.b	(a0),d0
	cmp.b	d1,d0
	bne.s	.ewfalse	; mismatch

	addq	#1,a0
	addq	#1,a1
	bra.s	.ewloop

.ewtrue:
	moveq	#-1,d0
	rts

.ewfalse:
	moveq	#0,d0
	rts

;
; RINSTR([offset,] str$, find$) - Reverse INSTR.
; a0 = str$, a1 = find$, d0 = offset (0 = search from end).
; Returns position (1-based) in d0, or 0 if not found.
;
_rinstr:
	move.l	d0,d5		; d5 = offset (0=from end)
	move.l	a0,d2		; d2 = str$ ptr saved
	move.l	a1,d3		; d3 = find$ ptr saved

	; get strlen(find$)
	move.l	a1,a2
	jsr	_strlen
	move.l	d0,d4		; d4 = findlen

	; if find$ is empty, return 0
	tst.l	d4
	beq.s	.rifail

	; get strlen(str$)
	move.l	d2,a2
	jsr	_strlen		; d0 = strlen(str$)

	; if str$ shorter than find$, fail
	cmp.l	d4,d0
	blt.s	.rifail

	; determine start position for search
	; startpos = last valid position = strlen - findlen
	move.l	d0,d6		; d6 = strlen
	sub.l	d4,d6		; d6 = max start index (0-based)

	; if offset > 0, limit start position
	tst.l	d5
	beq.s	.risearch	; 0 = from end, use max

	; offset is 1-based position, convert to 0-based
	subq.l	#1,d5
	cmp.l	d6,d5
	bgt.s	.risearch	; offset beyond max, use max
	move.l	d5,d6		; use offset as start

.risearch:
	; d6 = current search position (0-based), searching backward
	tst.l	d6
	blt.s	.rifail		; gone past start

	; compare find$ at str$[d6]
	move.l	d2,a0		; str$
	add.l	d6,a0		; str$ + pos
	move.l	d3,a1		; find$
	move.l	d4,d1		; findlen

.ricmploop:
	tst.l	d1
	beq.s	.rifound	; all chars matched

	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bne.s	.rinext		; mismatch

	subq.l	#1,d1
	bra.s	.ricmploop

.rifound:
	; found at d6 (0-based), return 1-based
	move.l	d6,d0
	addq.l	#1,d0
	rts

.rinext:
	subq.l	#1,d6
	bra.s	.risearch

.rifail:
	moveq	#0,d0
	rts

	END
