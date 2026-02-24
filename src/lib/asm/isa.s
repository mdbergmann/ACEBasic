;
; isa.s - ISA type check for TYPECASE
;
; _isa_check:
;   Input:  a0 = descriptor pointer (from offset 0 of class instance)
;           d0 = target hash (FNV-1a hash of class name)
;   Output: d0 = -1 (TRUE) if match, 0 (FALSE) if no match
;   Destroys: a0, d1
;

	xdef _isa_check

	SECTION isa_code,CODE

_isa_check:
.loop:
	cmp.l	(a0),d0		; compare target hash with descriptor hash
	beq.s	.match
	move.l	4(a0),d1	; parent descriptor pointer
	beq.s	.nomatch	; NULL = no parent, no match
	movea.l	d1,a0		; follow parent chain
	bra.s	.loop
.match:
	moveq	#-1,d0		; TRUE
	rts
.nomatch:
	moveq	#0,d0		; FALSE
	rts

	END
