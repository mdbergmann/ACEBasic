;
; dispatch.s - Generic method dispatch runtime support
;
; _gm_dispatch:
;   Input:  a0 = dispatch table address
;           dispatch values on stack at 4(sp), 8(sp), etc.
;           For CLASS dispatch: value is descriptor pointer
;           For ATOM dispatch: value is direct hash
;   Output: a0 = resolved method address
;   Destroys: d0-d3, a0-a2
;
; Dispatch table layout:
;   dc.w  N           ; number of dispatched positions
;   dc.w  M           ; number of method entries
;   dc.w  pos0 [,pos1]; position indices (bit 15 set = ATOM)
;   ; M entries, each:
;   dc.l  hash0 [,hash1]  ; N hash values
;   dc.l  method_address   ; resolved method pointer
;
; Class descriptor layout:
;   dc.l  hash         ; FNV-1a hash of class name
;   dc.l  parent_ptr   ; pointer to parent descriptor, or 0
;

	xdef	_gm_dispatch
	xdef	_no_method_error

	xref	_stdout
	xref	_DOSBase
	xref	_LVOWrite
	xref	_EXIT_PROG

	SECTION dispatch_code,CODE

_gm_dispatch:
	move.w	(a0)+,d0	; d0.w = N (dispatch count)
	move.w	(a0)+,d3	; d3.w = M (entry count)

	; check for single dispatch (N=1) vs multi (N>1)
	cmp.w	#1,d0
	bne.s	.multi

	; --- N=1: read single position word, check bit 15 ---
	move.w	(a0)+,d1	; d1.w = position word
	btst	#15,d1
	bne.s	.single_atom

	; --- Single CLASS dispatch (N=1, bit 15=0) --- with parent walk
.single_class:
	movea.l	4(sp),a1	; a1 = descriptor pointer from stack
	movea.l	a0,a2		; a2 = save start of entries
	move.w	d3,d2		; d2 = save M
.sc_retry:
	move.l	(a1),d1		; d1 = hash from descriptor
	movea.l	a2,a0		; restart at first entry
	move.w	d2,d3		; restore M
.sc_check:
	cmp.l	(a0)+,d1
	beq.s	.sc_match
	addq.l	#4,a0		; skip method addr
	subq.w	#1,d3
	bne.s	.sc_check
	; miss - walk parent
	move.l	4(a1),d0	; parent descriptor ptr (use d-reg for flags)
	beq	_no_method_error	; NULL = no parent
	movea.l	d0,a1
	bra.s	.sc_retry
.sc_match:
	movea.l	(a0),a0
	rts

	; --- Single ATOM dispatch (N=1, bit 15=1) --- no parent walk
.single_atom:
	move.l	4(sp),d1	; d1 = direct hash value
.sa_check:
	cmp.l	(a0)+,d1
	beq.s	.sc_match	; reuse match handler
	addq.l	#4,a0		; skip method addr
	subq.w	#1,d3
	bne.s	.sa_check
	jmp	_no_method_error

	; --- Multi dispatch (N>1) --- convert CLASS descriptors, exact match only
.multi:
	; Read position words and convert CLASS descriptors on stack to hashes.
	; Position words tell us which stack slots are CLASS (need deref) vs ATOM.
	; Stack layout: 4(sp) = first dispatch value, 8(sp) = second, etc.
	; We convert CLASS descriptor pointers to their hash values in-place.
	move.w	d0,d2		; d2 = N (position counter)
.conv_loop:
	move.w	(a0)+,d1	; d1.w = position word
	btst	#15,d1
	bne.s	.conv_skip	; ATOM: already a hash, skip
	; CLASS: dereference descriptor pointer to get hash
	; stack offset = 4 + (position_index * 4)
	; but values are pushed in reverse order, so first dispatched = 4(sp)
	; We use loop index: first position word = slot at 4(sp), etc.
	; Actually, stack order is: values pushed in reverse param order,
	; so the first dispatched position ends up at 4(sp), second at 8(sp).
	; Loop index (N - d2) gives us which slot we're at.
	move.w	d0,d1
	sub.w	d2,d1		; d1 = N - d2 = slot index (0-based)
	lsl.w	#2,d1		; d1 = slot_index * 4
	addq.w	#4,d1		; d1 = 4 + slot_index * 4
	movea.l	0(sp,d1.w),a1	; a1 = descriptor pointer
	move.l	(a1),0(sp,d1.w)	; replace with hash from descriptor
.conv_skip:
	subq.w	#1,d2
	bne.s	.conv_loop

	; a0 now points to first entry (after N position words)
	; Fall through to N-way exact match (original algorithm)
.check_entry:
	lea	4(sp),a1	; a1 -> dispatch values on caller's stack
	move.w	d0,d2		; d2 = N (hash counter)

.compare_hash:
	move.l	(a1)+,d1	; caller's hash value
	cmp.l	(a0)+,d1	; compare with table hash
	bne.s	.mismatch
	subq.w	#1,d2
	bne.s	.compare_hash
	; all N hashes matched - load method address
	movea.l	(a0),a0
	rts

.mismatch:
	; skip remaining data for this entry: d2 longs
	; (d2 = N - successful_comparisons = remaining hashes + method addr)
	move.w	d2,d1
	lsl.w	#2,d1		; d1 = d2 * 4
	adda.w	d1,a0
	subq.w	#1,d3		; decrement entry count
	bne.s	.check_entry
	; no match found
	jmp	_no_method_error

_no_method_error:
	movem.l	d2-d3/a6,-(sp)
	movea.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_no_method_msg,d2
	moveq	#21,d3
	jsr	_LVOWrite(a6)
	movem.l	(sp)+,d2-d3/a6
	jmp	_EXIT_PROG

	SECTION dispatch_data,DATA

_no_method_msg:	dc.b	'NO APPLICABLE METHOD',10,0

	END
