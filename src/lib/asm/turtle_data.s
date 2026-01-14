;
; Data/BSS references for turtle.s.
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
;   Date: 19th March 1994
;

	xdef	_tg_initx
	xdef	_tg_inity
	xdef	_tg_xy_ratio

	xdef	_tg_degs
	xdef	_tg_tx
	xdef	_tg_ty
	xdef	_tg_pen
	xdef	_tg_distance
	xdef	_tg_theta
	xdef	_tg_temp
	xdef	_tg_x
	xdef	_tg_y

	SECTION turtle_data,DATA

; * turtle graphics *
_tg_initx:		dc.w 0
_tg_inity:		dc.w 0
_tg_xy_ratio:		dc.l $f0000141  ; 1.875 (hi-res, non-interlaced)

;************************

	SECTION turtle_mem,bss

; * turtle graphics *
_tg_degs:		ds.w 1
_tg_tx:			ds.w 1
_tg_ty:			ds.w 1
_tg_pen:		ds.b 1
_tg_distance:		ds.l 1
_tg_theta:		ds.l 1
_tg_temp:		ds.l 1
_tg_x:			ds.w 1
_tg_y:			ds.w 1

	END
