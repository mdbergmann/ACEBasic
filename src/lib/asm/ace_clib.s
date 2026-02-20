;
; ace_clib.s -- C library functions for ACE runtime.
;
; Replaces the sprintf, printf, fprintf, putchar, and fgetc functions
; that were previously provided by ami.lib.
;
; All I/O uses AmigaDOS file handles (_stdout/_stdin from startup.s).
; sprintf uses exec RawDoFmt() with a _stuffchar callback.
; printf/fprintf use RawDoFmt into a BSS buffer, then DOS Write().
; putchar uses DOS Write() for a single byte.
; fgetc uses DOS Read() for a single byte, returns byte or -1 (EOF).
;
; Author: ACE project
; Date: 2026-02-20
;

	; exports
	xdef	_sprintf
	xdef	_printf
	xdef	_fprintf
	xdef	_putchar
	xdef	_fgetc

	; imports from startup.s
	xref	_stdout
	xref	_DOSBase
	xref	_AbsExecBase

	; imports from amiga.lib (LVO offsets)
	xref	_LVORawDoFmt
	xref	_LVOWrite
	xref	_LVORead

	SECTION	ace_clib_code,CODE

;---------------------------------------------------------------------------
; int sprintf(char *dest, const char *fmt, ...)
;
; C calling convention: args on stack
;   4(sp) = dest pointer
;   8(sp) = format string pointer
;  12(sp) = first vararg
;
; Uses exec RawDoFmt() with _stuffchar callback that stores bytes
; sequentially into the destination buffer.
;---------------------------------------------------------------------------
_sprintf:
	movem.l	a2-a3/a6,-(sp)		; save registers (3 longs = 12 bytes)
	; stack offsets after push: +12 from original
	move.l	12+8(sp),a0		; a0 = format string
	lea	12+12(sp),a1		; a1 = pointer to first vararg
	lea	_stuffchar(pc),a2	; a2 = callback function
	move.l	12+4(sp),a3		; a3 = dest buffer (passed to callback)
	move.l	_AbsExecBase,a6
	jsr	_LVORawDoFmt(a6)
	movem.l	(sp)+,a2-a3/a6
	rts

;
; _stuffchar -- RawDoFmt callback.
; Called with each formatted character in d0.b
; a3 = current output position (auto-incremented by RawDoFmt).
;
_stuffchar:
	move.b	d0,(a3)+
	rts

;---------------------------------------------------------------------------
; int printf(const char *fmt, ...)
;
; C calling convention:
;   4(sp) = format string pointer
;   8(sp) = first vararg
;
; Format into _clib_buf, then Write to _stdout.
;---------------------------------------------------------------------------
_printf:
	movem.l	a2-a3/a6,-(sp)		; save registers (12 bytes)
	move.l	12+4(sp),a0		; a0 = format string
	lea	12+8(sp),a1		; a1 = pointer to first vararg
	lea	_stuffchar(pc),a2	; a2 = callback
	lea	_clib_buf,a3		; a3 = output buffer
	move.l	_AbsExecBase,a6
	jsr	_LVORawDoFmt(a6)

	; a3 now points past the null terminator
	; length = a3 - _clib_buf - 1 (exclude null)
	lea	_clib_buf,a0
	move.l	a3,d3
	sub.l	a0,d3
	subq.l	#1,d3			; don't write the null terminator
	ble.s	.done			; nothing to write

	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	a0,d2			; buffer address
	jsr	_LVOWrite(a6)

.done:	movem.l	(sp)+,a2-a3/a6
	rts

;---------------------------------------------------------------------------
; int fprintf(void *fh, const char *fmt, ...)
;
; C calling convention:
;   4(sp) = file handle (AmigaDOS)
;   8(sp) = format string pointer
;  12(sp) = first vararg
;---------------------------------------------------------------------------
_fprintf:
	movem.l	a2-a3/a6,-(sp)		; save registers (12 bytes)
	move.l	12+8(sp),a0		; a0 = format string
	lea	12+12(sp),a1		; a1 = pointer to first vararg
	lea	_stuffchar(pc),a2	; a2 = callback
	lea	_clib_buf,a3		; a3 = output buffer
	move.l	_AbsExecBase,a6
	jsr	_LVORawDoFmt(a6)

	; length = a3 - _clib_buf - 1
	lea	_clib_buf,a0
	move.l	a3,d3
	sub.l	a0,d3
	subq.l	#1,d3
	ble.s	.done

	move.l	_DOSBase,a6
	move.l	12+4(sp),d1		; file handle (from original args)
	move.l	a0,d2
	jsr	_LVOWrite(a6)

.done:	movem.l	(sp)+,a2-a3/a6
	rts

;---------------------------------------------------------------------------
; int putchar(int c)
;
; C calling convention: 4(sp) = character (as long)
; Writes single byte to _stdout via DOS Write().
;---------------------------------------------------------------------------
_putchar:
	move.l	a6,-(sp)
	; copy the byte into our single-byte buffer
	move.l	4+4(sp),d0		; get character
	move.b	d0,_clib_chbuf
	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_clib_chbuf,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)
	move.l	(sp)+,a6
	; return the character written
	move.l	4(sp),d0
	rts

;---------------------------------------------------------------------------
; int fgetc(long fh)
;
; C calling convention: 4(sp) = file handle (AmigaDOS)
; Returns byte read (0-255) in d0, or -1 on EOF/error.
;---------------------------------------------------------------------------
_fgetc:
	move.l	a6,-(sp)
	move.l	_DOSBase,a6
	move.l	4+4(sp),d1		; file handle
	move.l	#_clib_chbuf,d2		; buffer for 1 byte
	moveq	#1,d3
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	; d0 = number of bytes read (1 = ok, 0 or negative = EOF/error)
	tst.l	d0
	ble.s	.eof
	moveq	#0,d0
	move.b	_clib_chbuf,d0		; return the byte (unsigned)
	rts
.eof:	moveq	#-1,d0
	rts

;---------------------------------------------------------------------------
; Data
;---------------------------------------------------------------------------

	SECTION	ace_clib_mem,BSS

_clib_buf:	ds.b	1024		; format buffer for printf/fprintf
_clib_chbuf:	ds.b	4		; single-char buffer (aligned)

	END
