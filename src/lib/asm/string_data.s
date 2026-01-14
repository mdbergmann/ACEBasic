;
; Data/BSS references for string.s.
; Copyright (C) 1998 David Benn
; 
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;
; Author: David J Benn
;   Date: 19th March 1994,
;	  12th July 1994
;

MAXSTRINGSIZE equ 1024

	xdef	_shorthexfmt
	xdef	_longhexfmt
	xdef	_zerostr
	xdef	_colonstr
	
	xdef	_tmpstring
	xdef	_deststraddr
	xdef	_count
	xdef	_negate
	xdef	_argstring
	xdef	_ucasestring
	xdef	_spacestraddress
	xdef	_stringstraddress
	xdef	_octdigit
	xdef	_bindigit
	xdef	_inkeybuf
	xdef	_rawinpbuf
	xdef	_rawinpaddr
	xdef	_instrposn
	xdef	_search_offset
	xdef	_targetch
	xdef	_x_string
	xdef	_y_string
	xdef	_x_strlen
	xdef	_y_strlen

	SECTION string_data,DATA

; * general *
_shorthexfmt: 	dc.b '%x',0
_longhexfmt:	dc.b '%lx',0
_zerostr:	dc.b '0',0
_colonstr:	dc.b ':',0

; *************************

	SECTION string_mem,BSS

; * general *
_tmpstring:    		ds.b MAXSTRINGSIZE
_deststraddr:		ds.l 1
_count:	      		ds.l 1
_negate:      		ds.b 1

; * arg *
_argstring:		ds.l 1	; see _argbuf in startup.s

; * ucase *
_ucasestring:		ds.l 1

; * spacestring *	
_spacestraddress:	ds.l 1

; * stringstr *	
_stringstraddress:	ds.l 1

; * octstr *
_octdigit:		ds.b 11

; * binstr *
_bindigit:		ds.b 32
 
; * inkey *
_inkeybuf:		ds.b 2

; * RAW: input *
_rawinpbuf:		ds.b 1
_rawinpaddr:		ds.l 1

; * instr *
_instrposn:		ds.l 1
_search_offset:		ds.l 1
_targetch:		ds.b 1
_x_string:		ds.l 1
_y_string:		ds.l 1
_x_strlen:		ds.l 1
_y_strlen:		ds.l 1

	END
