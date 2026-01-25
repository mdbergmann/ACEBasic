;
; assert.s - ASSERT statement runtime support
;
; Parameters:
;   d0 = condition (0 = false/fail, non-zero = true/pass)
;   a0 = message string pointer (or NULL for default message)
;

	xdef	_assert

	xref	_stdout
	xref	_DOSBase
	xref	_LVOWrite
	xref	_strlen
	xref	_EXIT_PROG

	SECTION assert_code,CODE

_assert:
	; if condition (d0) is non-zero, just return
	tst.l	d0
	bne.s	_assert_ok

	; assertion failed - print message and halt
	movem.l	d2-d3/a2-a3/a6,-(sp)
	move.l	a0,a2			; message pointer for _strlen
	move.l	a0,a3			; save copy for Write call

	; print "ASSERT FAILED"
	movea.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_default_msg,d2
	moveq	#13,d3
	jsr	_LVOWrite(a6)

	; if message is not NULL, print ": " and message
	cmpa.l	#0,a2
	beq.s	_assert_newline

	; print ": "
	move.l	_stdout,d1
	move.l	#_separator,d2
	moveq	#2,d3
	jsr	_LVOWrite(a6)

	; get length of user message (_strlen expects a2)
	jsr	_strlen			; d0 = length

	; print user message
	move.l	d0,d3			; length
	move.l	_stdout,d1
	move.l	a3,d2			; message (a3 preserved, a2 was modified by _strlen)
	movea.l	_DOSBase,a6
	jsr	_LVOWrite(a6)

_assert_newline:
	; print newline
	move.l	_stdout,d1
	move.l	#_newline,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)

	movem.l	(sp)+,d2-d3/a2-a3/a6

	; exit program cleanly (like END/STOP)
	jmp	_EXIT_PROG

_assert_ok:
	rts

	SECTION assert_data,DATA

_default_msg:	dc.b	'ASSERT FAILED'
_separator:	dc.b	': '
_newline:	dc.b	10

	END
