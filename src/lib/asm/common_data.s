;
; Data references common to several modules.
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
;   Date: 19th,25th March 1994
;

	xdef	_shortfmt
	xdef	_longfmt
	xdef	_radconv

	SECTION common_data,DATA

_shortfmt:		dc.b 	'%d',0
_longfmt:		dc.b 	'%ld',0
_radconv:		dc.l	$e52ee146

	END
