;
; Data/BSS references for file.s.
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
;	  13th May 1994
;

MAXSTRINGSIZE equ 1024

	xdef	_file_handle_list
	xdef	_line_end
	xdef	_quote_mark
	xdef	_comma
	xdef	_space
	xdef	_tab

	xdef	_fileinpstring
	xdef	_filecharcount
	xdef	_tempfinp
	xdef	_fstrbuf
	xdef	_filenum
	xdef	_eofhandle
	xdef	_filesize
	xdef	_filehandle
	xdef	_oldfilepos
	xdef	_filespec_ptr

	SECTION file_data,DATA

; * files *
_file_handle_list:	dcb.l 	255,0
_line_end:		dc.b  	10
_quote_mark:		dc.b	'"'
_comma:			dc.b	','
_space:			dc.b	' '
_tab:			dc.b	9,9
	
;************************

	SECTION file_mem,BSS

; * files *
_fileinpstring:		ds.b MAXSTRINGSIZE*32
_filecharcount:		ds.w 1
_tempfinp:		ds.b 1
_fstrbuf:		ds.b 40
_filenum:		ds.l 1
_eofhandle:		ds.l 1
_filesize:		ds.l 1
_filehandle:		ds.l 1
_oldfilepos:		ds.l 1
_filespec_ptr:		ds.l 1

	END
