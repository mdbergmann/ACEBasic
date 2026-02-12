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
	xdef	_reversestr
	xdef	_repeatstr
	xdef	_replacestr
	xdef	_lpadstr
	xdef	_rpadstr
	xdef	_fmtstr
	xdef	_setmidstr

	; external references
	xref	_strlen
	xref	_strcpy
	xref	_sprintf

	; BSS from string2_data.s
	xref	_fmtfmt
	xref	_fmtargs
	xref	_fmtspecbuf
	xref	_fmtsegbuf

MAXSTRINGSIZE	equ	1024

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

;
; REVERSE$(str$) - Reverse a string.
; a0 = destination buffer, a1 = source string.
; Returns destination address in a0.
;
_reversestr:
	move.l	a0,a3		; save dest address

	; get length of source
	move.l	a1,a2
	jsr	_strlen		; d0 = length

	; null-terminate dest at position d0
	move.l	a3,a0
	move.b	#0,0(a0,d0.l)

	; if empty, done
	tst.l	d0
	beq.s	.revdone

	; point a1 to last char of source
	move.l	a1,a0		; a0 = src start (reuse)
	add.l	d0,a0
	subq	#1,a0		; a0 = &src[len-1]

	; copy backward from src to forward in dest
	move.l	a3,a1		; a1 = dest start

.revloop:
	cmp.l	a1,a3		; safety check (shouldn't need)
	move.b	(a0),(a1)+	; dest[i] = src[len-1-i]
	subq	#1,a0
	subq.l	#1,d0
	bne.s	.revloop

.revdone:
	move.l	a3,a0
	rts

;
; REPEAT$(str$, count) - Repeat string N times.
; a0 = destination buffer, a1 = source string, d0 = count.
; Returns destination address in a0.
;
_repeatstr:
	move.l	a0,a3		; save dest address
	move.l	d0,d2		; d2 = count
	move.l	a1,d3		; d3 = source ptr saved

	; null-terminate dest
	move.b	#0,(a3)

	; if count <= 0, return empty
	tst.l	d2
	ble.s	.repdone

	; get source length
	move.l	a1,a2
	jsr	_strlen		; d0 = srclen
	move.l	d0,d4		; d4 = srclen

	; if source empty, return empty
	tst.l	d4
	beq.s	.repdone

	; calculate total length needed: srclen * count
	; cap at MAXSTRINGSIZE-1
	move.l	a3,a0		; a0 = dest write pointer
	moveq	#0,d5		; d5 = bytes written so far

.reploop:
	tst.l	d2
	beq.s	.repterm	; all repetitions done

	; check if we have room for another copy
	move.l	d5,d0
	add.l	d4,d0		; would-be new length
	cmpi.l	#MAXSTRINGSIZE-1,d0
	bgt.s	.repterm	; would exceed max, stop

	; copy source to dest
	move.l	d3,a1		; restore source ptr
.repcopy:
	move.b	(a1)+,d0
	tst.b	d0
	beq.s	.repnext
	move.b	d0,(a0)+
	addq.l	#1,d5
	bra.s	.repcopy

.repnext:
	subq.l	#1,d2
	bra.s	.reploop

.repterm:
	move.b	#0,(a0)		; null-terminate

.repdone:
	move.l	a3,a0
	rts

;
; REPLACE$(str$, find$, repl$) - Replace all occurrences of find$ with repl$.
; a0 = str$, a1 = find$, a2 = repl$, a3 = dest buffer.
; Returns dest address in a0.
;
_replacestr:
	; save all params to data regs (we need address regs for _strlen)
	move.l	a0,d2		; d2 = str$
	move.l	a1,d3		; d3 = find$
	move.l	a2,d4		; d4 = repl$ (use d4 since d3 is find)
	move.l	a3,d5		; d5 = dest

	; get find$ length
	move.l	a1,a2
	jsr	_strlen		; d0 = findlen
	move.l	d0,d6		; d6 = findlen

	; if find$ is empty, just copy str$ to dest
	tst.l	d6
	beq.s	.rjustcopy

	; walk str$, comparing at each position
	move.l	d2,a0		; a0 = current position in str$
	move.l	d5,a3		; a3 = current write position in dest
	moveq	#0,d1		; d1 = dest bytes written

.rwalk:
	tst.b	(a0)
	beq.s	.rdone		; EOS

	; try to match find$ at current position
	move.l	a0,a1		; a1 = str$ cursor
	move.l	d3,a2		; a2 = find$

.rcmploop:
	tst.b	(a2)
	beq.s	.rmatch		; end of find$ = full match

	tst.b	(a1)
	beq.s	.rnomatch	; str$ ended before full match

	cmpm.b	(a1)+,(a2)+
	beq.s	.rcmploop
	bra.s	.rnomatch

.rmatch:
	; found match - copy repl$ to dest
	move.l	d4,a2		; a2 = repl$
.rcopyrep:
	move.b	(a2)+,d0
	tst.b	d0
	beq.s	.radvance
	cmpi.l	#MAXSTRINGSIZE-1,d1
	bge.s	.rdone		; dest full
	move.b	d0,(a3)+
	addq.l	#1,d1
	bra.s	.rcopyrep

.radvance:
	; advance str$ past the matched find$
	add.l	d6,a0
	bra.s	.rwalk

.rnomatch:
	; no match - copy single char from str$
	cmpi.l	#MAXSTRINGSIZE-1,d1
	bge.s	.rdone
	move.b	(a0)+,(a3)+
	addq.l	#1,d1
	bra.s	.rwalk

.rjustcopy:
	; find$ empty - just copy str$
	move.l	d5,a0		; dest
	move.l	d2,a1		; src
	jsr	_strcpy
	move.l	d5,a0
	rts

.rdone:
	move.b	#0,(a3)		; null-terminate
	move.l	d5,a0		; return dest address
	rts

;
; LPAD$(str$, width, pad$) - Left-pad string to given width.
; a0 = str$, d0 = width, a1 = pad$, a2 = dest buffer.
; Returns dest address in a0.
;
_lpadstr:
	move.l	a2,a3		; save dest
	move.l	d0,d2		; d2 = target width
	move.l	a0,d3		; d3 = str$ saved
	move.l	a1,d4		; d4 = pad$ saved

	; get str$ length
	move.l	a0,a2
	jsr	_strlen		; d0 = strlen(str$)
	move.l	d0,d5		; d5 = srclen

	; if srclen >= width, just copy str$
	cmp.l	d2,d5
	bge.s	.lpcopy

	; get pad char (first char of pad$)
	move.l	d4,a1
	move.b	(a1),d1		; d1 = pad char
	tst.b	d1
	beq.s	.lpcopy		; empty pad string, just copy

	; fill (width - srclen) pad chars
	move.l	d2,d0
	sub.l	d5,d0		; d0 = pad count
	move.l	a3,a0		; a0 = dest write ptr

.lpfill:
	tst.l	d0
	beq.s	.lpcopyrest
	move.b	d1,(a0)+
	subq.l	#1,d0
	bra.s	.lpfill

.lpcopyrest:
	; now copy str$ after padding
	move.l	d3,a1		; a1 = str$
	jsr	_strcpy
	move.l	a3,a0		; return dest
	rts

.lpcopy:
	; just copy str$ to dest (no padding needed)
	move.l	a3,a0
	move.l	d3,a1
	jsr	_strcpy
	move.l	a3,a0
	rts

;
; RPAD$(str$, width, pad$) - Right-pad string to given width.
; a0 = str$, d0 = width, a1 = pad$, a2 = dest buffer.
; Returns dest address in a0.
;
_rpadstr:
	move.l	a2,a3		; save dest
	move.l	d0,d2		; d2 = target width
	move.l	a0,d3		; d3 = str$ saved
	move.l	a1,d4		; d4 = pad$ saved

	; copy str$ to dest first
	move.l	a3,a0
	move.l	d3,a1
	jsr	_strcpy

	; get dest length (= srclen)
	move.l	a3,a2
	jsr	_strlen		; d0 = current length
	move.l	d0,d5		; d5 = srclen

	; if srclen >= width, done
	cmp.l	d2,d5
	bge.s	.rpdone

	; get pad char
	move.l	d4,a1
	move.b	(a1),d1		; d1 = pad char
	tst.b	d1
	beq.s	.rpdone		; empty pad, done

	; fill pad chars from end of string to width
	move.l	a3,a0
	add.l	d5,a0		; a0 = &dest[srclen]
	move.l	d2,d0
	sub.l	d5,d0		; d0 = pad count

.rpfill:
	tst.l	d0
	beq.s	.rpterm
	move.b	d1,(a0)+
	subq.l	#1,d0
	bra.s	.rpfill

.rpterm:
	move.b	#0,(a0)		; null-terminate

.rpdone:
	move.l	a3,a0
	rts

;
; FMT$(format$, args...) - sprintf-style string formatting.
; a0 = dest buffer, a1 = format string, a2 = args array (longs), d0 = arg count.
; Supported: %d/%ld (decimal), %x/%lx (hex), %s (string), %c (char), %% (literal %).
; Width/padding supported via _sprintf delegation for integer types.
; Returns dest address in a0.
;
_fmtstr:
	move.l	a0,a3		; a3 = dest buffer (write ptr)
	move.l	a0,d5		; d5 = dest start (saved)
	; a1 = format string (read ptr)
	; a2 = args array base
	moveq	#0,d4		; d4 = current arg index (byte offset)
	move.l	d0,d6		; d6 = max arg count
	lsl.l	#2,d6		; d6 = max byte offset (count * 4)

.fmwalk:
	move.b	(a1)+,d0
	tst.b	d0
	beq	.fmdone		; EOS

	cmpi.b	#'%',d0
	beq.s	.fmpercent

	; regular char - copy to dest
	move.b	d0,(a3)+
	bra.s	.fmwalk

.fmpercent:
	; start of format specifier
	; build specifier in _fmtspecbuf, a0 tracks write position
	lea	_fmtspecbuf,a0
	move.b	#'%',(a0)+	; start with %

	; collect flags, width, etc.
.fmspec:
	move.b	(a1)+,d0
	tst.b	d0
	beq	.fmdone		; unexpected EOS

	; check for type character
	cmpi.b	#'d',d0
	beq.s	.fmint
	cmpi.b	#'u',d0
	beq.s	.fmint
	cmpi.b	#'x',d0
	beq.s	.fmint
	cmpi.b	#'X',d0
	beq.s	.fmint
	cmpi.b	#'s',d0
	beq.s	.fmstring
	cmpi.b	#'c',d0
	beq.s	.fmchar
	cmpi.b	#'%',d0
	beq.s	.fmlitpct

	; part of specifier (flags/width/l modifier) - copy and continue
	move.b	d0,(a0)+
	bra.s	.fmspec

.fmlitpct:
	; %% -> literal %
	move.b	#'%',(a3)+
	bra	.fmwalk

.fmchar:
	; %c -> single character from arg
	cmp.l	d6,d4
	bge	.fmwalk		; no more args
	move.l	0(a2,d4.l),d0	; get arg
	move.b	d0,(a3)+	; write char
	addq.l	#4,d4		; advance arg index
	bra	.fmwalk

.fmstring:
	; %s -> copy string from arg address
	cmp.l	d6,d4
	bge	.fmwalk		; no more args
	move.l	0(a2,d4.l),a0	; get string address
	addq.l	#4,d4		; advance arg index

	; copy string to dest
.fmscopy:
	move.b	(a0)+,d0
	tst.b	d0
	beq	.fmwalk		; done copying
	move.b	d0,(a3)+
	bra.s	.fmscopy

.fmint:
	; %d, %u, %x, %X -> format integer via _sprintf
	; a0 = current write position in _fmtspecbuf (after % and any flags/width)
	; d0 = type char
	move.b	d0,d3		; d3 = type char (d/u/x/X)

	; check if 'l' modifier already present (last written byte)
	cmpi.b	#'l',-1(a0)
	beq.s	.fmitype	; already has 'l'
	; insert 'l' before type
	move.b	#'l',(a0)+

.fmitype:
	move.b	d3,(a0)+	; type char
	move.b	#0,(a0)		; null-terminate specifier

	; check if we have an arg
	cmp.l	d6,d4
	bge	.fmwalk		; no more args

	; call _sprintf(_fmtsegbuf, specifier, value)
	; _sprintf clobbers d0-d1/a0-a1, so save a1 (format read ptr)
	move.l	a1,-(sp)		; save format ptr
	move.l	0(a2,d4.l),-(sp)	; value
	pea	_fmtspecbuf		; format spec
	pea	_fmtsegbuf		; output buffer
	jsr	_sprintf
	lea	12(sp),sp		; clean stack (3 args * 4)
	move.l	(sp)+,a1		; restore format ptr

	addq.l	#4,d4			; advance arg index

	; copy _fmtsegbuf to dest
	lea	_fmtsegbuf,a0
.fmicopy:
	move.b	(a0)+,d0
	tst.b	d0
	beq	.fmwalk
	move.b	d0,(a3)+
	bra.s	.fmicopy

.fmdone:
	move.b	#0,(a3)		; null-terminate dest
	move.l	d5,a0		; return dest start
	rts

;
; MID$(x$, pos, len) = rhs$ -- in-place string modification.
; a0 = target string, d0 = pos (1-based), d1 = len (-1 = use rhs len), a1 = rhs$.
; Overwrites bytes in target starting at pos. Does not change string length.
;
_setmidstr:
	; validate pos >= 1
	tst.l	d0
	ble.s	.smexit		; invalid pos

	; get target length
	move.l	a0,d2		; d2 = target ptr saved
	move.l	d0,d3		; d3 = pos saved
	move.l	d1,d4		; d4 = len saved
	move.l	a1,d5		; d5 = rhs ptr saved

	move.l	a0,a2
	jsr	_strlen		; d0 = target length
	move.l	d0,d6		; d6 = target length

	; validate pos <= target length
	cmp.l	d6,d3
	bgt.s	.smexit		; pos beyond string end

	; get rhs length
	move.l	d5,a2
	jsr	_strlen		; d0 = rhs length

	; determine copy count
	; if d4 == -1, use rhs length
	cmpi.l	#-1,d4
	bne.s	.smhavelen
	move.l	d0,d4		; use rhs length

.smhavelen:
	; copylen = min(d4, d0)  (min of requested len and rhs len)
	cmp.l	d4,d0
	bge.s	.smchkroom
	move.l	d0,d4		; rhs shorter than requested

.smchkroom:
	; also cap at remaining room: target_len - pos + 1
	move.l	d6,d0
	sub.l	d3,d0
	addq.l	#1,d0		; d0 = chars from pos to end of target
	cmp.l	d4,d0
	bge.s	.smcopy
	move.l	d0,d4		; cap at remaining room

.smcopy:
	; if nothing to copy, exit
	tst.l	d4
	beq.s	.smexit

	; point to target[pos-1]
	move.l	d2,a0
	add.l	d3,a0
	subq	#1,a0		; a0 = &target[pos-1]

	; copy d4 bytes from rhs to target
	move.l	d5,a1		; a1 = rhs

.smloop:
	move.b	(a1)+,(a0)+
	subq.l	#1,d4
	bne.s	.smloop

.smexit:
	rts

	END
