;
; string2_data.s -- Data/BSS references for string2.s.
;
; Author: ACE Contributors
;   Date: 2026-02-12
;

MAXSTRINGSIZE equ 1024

	xdef	_fmtfmt
	xdef	_fmtargs
	xdef	_fmtspecbuf
	xdef	_fmtsegbuf

	SECTION string2_mem,BSS

; * FMT$ *
_fmtfmt:	ds.l 1			; format string address
_fmtargs:	ds.l 8			; up to 8 arguments (4 bytes each)
_fmtspecbuf:	ds.b 20			; format specifier buffer (e.g., "%08lx")
_fmtsegbuf:	ds.b MAXSTRINGSIZE	; segment output buffer

	END
