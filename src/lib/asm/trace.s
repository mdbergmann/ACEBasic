;
; trace.s - SUB call/return tracing runtime support
;
; Provides trace output to T:ace_trace.log for debugging.
; All public functions check _trace_enabled before writing.
;
; Register usage notes:
;   _trace_write clobbers: d0-d3, a0, a1, a3, a6
;   Safe across _trace_write: a2, a4, a5 (a2 is saved by caller's movem)
;   _sprintf clobbers: d0-d1, a0-a1 (standard C convention)
;

	SECTION trace_code,CODE

;----- _trace_open -----
; Open T:ace_trace.log for writing, enable tracing by default
_trace_open:
	movem.l	d0-d3/a0-a1/a6,-(sp)
	move.l	_DOSBase,a6
	move.l	#_trace_filename,d1
	move.l	#1006,d2		; MODE_NEWFILE
	jsr	_LVOOpen(a6)
	move.l	d0,_trace_fh
	move.w	#1,_trace_enabled	; tracing ON by default
	clr.w	_trace_depth
	movem.l	(sp)+,d0-d3/a0-a1/a6
	rts

;----- _trace_close -----
_trace_close:
	movem.l	d0-d1/a6,-(sp)
	move.l	_trace_fh,d1
	beq.s	.done
	move.l	_DOSBase,a6
	jsr	_LVOClose(a6)
	clr.l	_trace_fh
.done:
	movem.l	(sp)+,d0-d1/a6
	rts

;----- _trace_enter -----
; a0 = name string
_trace_enter:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	tst.w	_trace_enabled
	beq.s	.skip
	move.l	_trace_fh,d1
	beq.s	.skip
	move.l	a0,a2			; save name in a2 (safe across writes)
	bsr	_trace_indent
	lea	_trace_arrow_in,a0
	bsr	_trace_write
	move.l	a2,a0			; restore name
	bsr	_trace_write
	lea	_trace_lparen,a0
	bsr	_trace_write
.skip:
	; always increment depth (keeps depth in sync even when
	; tracing is toggled mid-execution)
	addq.w	#1,_trace_depth
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_param_long -----
; d0.l = value
_trace_param_long:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	; d0 still has the value (not clobbered by tst.w or move.l to d1)
	lea	_trace_buf,a0
	bsr	_trace_ltoa		; convert d0 to string at _trace_buf
	lea	_trace_buf,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_param_short -----
; d0.w = value
_trace_param_short:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	; d0 still has the value
	ext.l	d0			; sign-extend to long
	lea	_trace_buf,a0
	bsr	_trace_ltoa
	lea	_trace_buf,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_param_single -----
; d0 = FFP float (raw 32 bits)
; Display as hex since FFP->decimal is complex.
_trace_param_single:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	; d0 still has the value
	lea	_trace_buf,a0
	move.b	#'$',(a0)+
	bsr	_trace_hex32
	move.b	#0,(a0)
	lea	_trace_buf,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_param_str -----
; a0 = string pointer
_trace_param_str:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	move.l	a0,a2			; save string ptr in a2 (safe across writes)
	lea	_trace_quote,a0
	bsr	_trace_write
	move.l	a2,a0			; restore string ptr
	bsr	_trace_write_trunc
	lea	_trace_quote,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_param_sep -----
_trace_param_sep:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	lea	_trace_comma,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_end_params -----
_trace_end_params:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	lea	_trace_rparen_nl,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_exit_long -----
; a0 = name, d0 = return value
_trace_exit_long:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	subq.w	#1,_trace_depth
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	; a0 = name, d0 = value (both still valid)
	move.l	a0,a2			; save name in a2
	; Convert value to string first (while d0 is still valid)
	lea	_trace_buf,a0
	bsr	_trace_ltoa		; _trace_buf now has value string
	; Now write everything
	bsr	_trace_indent
	lea	_trace_arrow_out,a0
	bsr	_trace_write
	move.l	a2,a0			; restore name
	bsr	_trace_write
	lea	_trace_equals,a0
	bsr	_trace_write
	lea	_trace_buf,a0		; value string prepared earlier
	bsr	_trace_write
	lea	_trace_nl,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_exit_short -----
; a0 = name, d0.w = return value
_trace_exit_short:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	subq.w	#1,_trace_depth
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	move.l	a0,a2			; save name
	ext.l	d0			; sign-extend
	lea	_trace_buf,a0
	bsr	_trace_ltoa
	bsr	_trace_indent
	lea	_trace_arrow_out,a0
	bsr	_trace_write
	move.l	a2,a0
	bsr	_trace_write
	lea	_trace_equals,a0
	bsr	_trace_write
	lea	_trace_buf,a0
	bsr	_trace_write
	lea	_trace_nl,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_exit_single -----
; a0 = name, d0 = FFP value
_trace_exit_single:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	subq.w	#1,_trace_depth
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	move.l	a0,a2			; save name
	; Convert FFP to hex while d0 is valid
	lea	_trace_buf,a0
	move.b	#'$',(a0)+
	bsr	_trace_hex32
	move.b	#0,(a0)
	; Now write
	bsr	_trace_indent
	lea	_trace_arrow_out,a0
	bsr	_trace_write
	move.l	a2,a0
	bsr	_trace_write
	lea	_trace_equals,a0
	bsr	_trace_write
	lea	_trace_buf,a0
	bsr	_trace_write
	lea	_trace_nl,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_exit_str -----
; a0 = name, a1 = string return value
_trace_exit_str:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	subq.w	#1,_trace_depth
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	move.l	a0,a2			; save name in a2
	move.l	a1,-(sp)		; save string ptr on stack
	bsr	_trace_indent
	lea	_trace_arrow_out,a0
	bsr	_trace_write
	move.l	a2,a0			; restore name
	bsr	_trace_write
	lea	_trace_equals,a0
	bsr	_trace_write
	lea	_trace_quote,a0
	bsr	_trace_write
	move.l	(sp)+,a0		; restore string ptr
	bsr	_trace_write_trunc
	lea	_trace_quote,a0
	bsr	_trace_write
	lea	_trace_nl,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;----- _trace_exit_void -----
; a0 = name (no return value)
_trace_exit_void:
	movem.l	d0-d3/a0-a3/a6,-(sp)
	subq.w	#1,_trace_depth
	tst.w	_trace_enabled
	beq.s	.done
	move.l	_trace_fh,d1
	beq.s	.done
	move.l	a0,a2			; save name
	bsr	_trace_indent
	lea	_trace_arrow_out,a0
	bsr	_trace_write
	move.l	a2,a0
	bsr	_trace_write
	lea	_trace_nl,a0
	bsr	_trace_write
.done:
	movem.l	(sp)+,d0-d3/a0-a3/a6
	rts

;===== Internal helpers =====

;----- _trace_indent -----
; Write (depth * 2) spaces to trace file
; Uses a2 as loop counter (safe: saved by callers, not used by _trace_write)
_trace_indent:
	move.w	_trace_depth,d3
	beq.s	.idone
	; Use stack to preserve counter across _trace_write calls
.iloop:
	move.w	d3,-(sp)		; save counter
	lea	_trace_spaces,a0
	bsr	_trace_write
	move.w	(sp)+,d3		; restore counter
	subq.w	#1,d3
	bne.s	.iloop
.idone:
	rts

;----- _trace_write -----
; Write null-terminated string at a0 to trace file
; Clobbers: d0-d3, a0, a1, a3, a6
_trace_write:
	move.l	a0,a3			; save start
	moveq	#0,d3
.wlen:
	tst.b	(a0)+
	beq.s	.wgo
	addq.l	#1,d3
	bra.s	.wlen
.wgo:
	tst.l	d3
	beq.s	.wdone
	move.l	_DOSBase,a6
	move.l	_trace_fh,d1
	move.l	a3,d2			; buffer
	jsr	_LVOWrite(a6)
.wdone:
	rts

;----- _trace_write_trunc -----
; Write string at a0, max 64 chars
; Clobbers: d0-d3, a0, a1, a3, a6
_trace_write_trunc:
	move.l	a0,a3
	moveq	#0,d3
.tlen:
	tst.b	(a0)+
	beq.s	.tgo
	addq.l	#1,d3
	cmpi.l	#64,d3
	blt.s	.tlen
.tgo:
	tst.l	d3
	beq.s	.tdone
	move.l	_DOSBase,a6
	move.l	_trace_fh,d1
	move.l	a3,d2
	jsr	_LVOWrite(a6)
.tdone:
	rts

;----- _trace_ltoa -----
; Convert signed long in d0 to decimal string at a0
; Uses _sprintf for correct 32-bit conversion
; Preserves a2 (caller may use it)
_trace_ltoa:
	move.l	a0,a3			; save buffer start
	tst.l	d0
	bpl.s	.pos
	neg.l	d0
	move.b	#'-',(a0)+
.pos:
	move.l	d0,-(sp)		; push long value
	pea	_trace_longfmt		; push "%lu"
	move.l	a0,-(sp)		; push destination
	jsr	_sprintf
	add.l	#12,sp
	move.l	a3,a0			; return start
	rts

;----- _trace_hex32 -----
; Convert unsigned long in d0 to 8 hex chars at a0
; a0 is advanced past the hex digits (NOT null-terminated)
; Clobbers: d1, d2
_trace_hex32:
	moveq	#7,d2
.hloop:
	rol.l	#4,d0
	move.l	d0,d1
	andi.l	#$0F,d1
	cmpi.b	#10,d1
	blt.s	.hdig
	addq.b	#7,d1			; 'A'-'0'-10 = 7
.hdig:
	add.b	#'0',d1
	move.b	d1,(a0)+
	dbf	d2,.hloop
	rts

;===== Data section =====

	SECTION trace_data,DATA

_trace_filename:  dc.b	"T:ace_trace.log",0
_trace_arrow_in:  dc.b	"-> ",0
_trace_arrow_out: dc.b	"<- ",0
_trace_lparen:    dc.b	"(",0
_trace_rparen_nl: dc.b	")",10,0
_trace_comma:     dc.b	", ",0
_trace_equals:    dc.b	" = ",0
_trace_quote:     dc.b	34,0		; double quote
_trace_nl:        dc.b	10,0
_trace_spaces:    dc.b	"  ",0
_trace_longfmt:   dc.b	"%lu",0

;===== BSS section =====

	SECTION trace_bss,BSS

_trace_fh:	ds.l 1
_trace_enabled:	ds.w 1
_trace_depth:	ds.w 1
_trace_buf:	ds.b 256

;===== XDEFs =====

	xdef	_trace_open
	xdef	_trace_close
	xdef	_trace_enabled
	xdef	_trace_enter
	xdef	_trace_param_long
	xdef	_trace_param_short
	xdef	_trace_param_single
	xdef	_trace_param_str
	xdef	_trace_param_sep
	xdef	_trace_end_params
	xdef	_trace_exit_void
	xdef	_trace_exit_long
	xdef	_trace_exit_short
	xdef	_trace_exit_single
	xdef	_trace_exit_str

;===== XREFs =====

	xref	_DOSBase
	xref	_LVOOpen
	xref	_LVOClose
	xref	_LVOWrite
	xref	_sprintf

	END
