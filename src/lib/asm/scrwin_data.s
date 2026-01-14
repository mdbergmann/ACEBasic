;
; Data/BSS references for scrwin.s.
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
;	  12th,24th,27th July 1994
;

MAXSTRINGSIZE equ 1024

	xdef	_slash
	xdef	_longtemp
	xdef	_formfeed
	xdef	_forcebgndcolr
	xdef	_textcolr
	xdef	_locatestr
	xdef	_raw
	xdef	_Wdw_width_list
	xdef	_Wdw_height_list
	xdef	_fgdpen_list
	xdef	_bgpen_list
	xdef	_Wdw_list
	xdef	_RPort_list
	xdef	_stdout_list
	xdef	_stdin_list
	xdef	_mode_oldfile
	xdef	_ScreenWdw
	xdef	_ScreenRPort
	xdef	_ScreenViewPort
	xdef	_Screen_list
	xdef	_newscreen
	xdef	_newwindow
	xdef	_horiz_tabstring
	xdef	_NULL_string

	xdef	_x1
	xdef	_x2
	xdef	_y1
	xdef	_y2
	xdef	_titleaddr
	xdef	_tempstr
	xdef	_rawname
	xdef	_tempWdw_id
	xdef	_screen_id
	xdef	_rport_addr
	xdef	_viewport_addr
	xdef	_screen_addr
	xdef	_scr_wdw_addr
	xdef	_color_id
	xdef	_red
	xdef	_green
	xdef	_blue
	xdef	_strbuf
	xdef	_max_line
	xdef	_font_height
	xdef	_wdth
	xdef	_hgt
	xdef	_horiz_pos

	SECTION scrwin_data,DATA

; * general *
_slash:		dc.b '/',0
_longtemp:	dc.l 1

; * cls *
_formfeed:	dc.b 12
_forcebgndcolr  dc.b $9b,'>',0,'m'

; * changetextcolor *
_textcolr:	dc.b $9b,'0;30;40m'

; * locate *
_locatestr:	dc.b $9b,$31,$31,$3b,$31,$31,$48

; * createwindow *
_raw:			dc.b  'RAW:',0
_Wdw_width_list:	dcb.w 10,0
_Wdw_height_list:	dcb.w 10,0
_fgdpen_list:		dcb.w 10,0
_bgpen_list:		dcb.w 10,0
_Wdw_list:		dcb.l 10,0
_RPort_list:		dcb.l 10,0
_stdout_list:		dcb.l 10,0
_stdin_list:		dcb.l 10,0
_mode_oldfile:		dc.l  1005

; * openscreen *
_ScreenWdw:		dcb.l 10,0
_ScreenRPort:		dcb.l 10,0
_ScreenViewPort:	dcb.l 10,0
_Screen_list:		dcb.l 10,0
_newscreen:
	dc.w 0		; left edge (0)
	dc.w 0		; top edge  (0)
	dc.w 0		; width  *
	dc.w 0		; height *
	dc.w 0		; depth  *
	dc.b 1		; detail pen 
	dc.b 0		; block pen 
	dc.w 0		; mode   *
	dc.w $000f	; screen type (custom)
	dc.l 0		; font (NULL)
	dc.l 0		; default title (NULL)
	dc.l 0		; gadgets (NULL)
	dc.l 0		; custom bit-map (NULL)

_newwindow:
	dc.w 0		; left edge (0)
	dc.w 0		; top edge  (0)
	dc.w 0		; width  *
	dc.w 0		; height *
	dc.b 1		; detail pen
	dc.b 0		; block pen
			; IDCMP flags: 	VANILLAKEY | INTUITICKS | MENUPICK |
			;		ACTIVEWINDOW | GADGETUP
	dc.l $00640140  
			; (see intuition/intuition.h)	

			; Flags: BACKDROP | GZZ | BORDERLESS | ACTIVATE
	dc.l $1D00
			; (see intuition/intuition.h)
	
	dc.l 0		; First Gadget
	dc.l 0		; CheckMark
	dc.l 0		; Title
	dc.l 0		; Pointer to Custom Screen * 
	dc.l 0		; BitMap
	dc.w 0		; MinWidth
	dc.w 0		; MinHeight
	dc.w 0		; MaxWidth
	dc.w 0		; MaxHeight
	dc.w $000f	; CUSTOMSCREEN (see intuition/screens.h) 		
		
; * tab *
_horiz_tabstring:	dc.b  $9b,$31,$31,$43,0
_NULL_string:		dc.b  0

;************************

	SECTION scrwin_mem,BSS

; * createwindow *
_x1:			ds.w 1
_x2:			ds.w 1
_y1:			ds.w 1
_y2:			ds.w 1
_titleaddr:		ds.l 1
_tempstr:		ds.l 128  ; arbitrarily large
_rawname:		ds.b MAXSTRINGSIZE

; * closewindow *
_tempWdw_id:		ds.w 1

; * openscreen *
_screen_id:		ds.w 1
_rport_addr: 		ds.l 1
_viewport_addr:		ds.l 1
_screen_addr:		ds.l 1
_scr_wdw_addr:		ds.l 1

; * palette *
_color_id:		ds.w 1
_red:			ds.l 1
_green:			ds.l 1
_blue:			ds.l 1

; * prints *
_strbuf:		ds.b 40
 
; * scroll *
_max_line:		ds.w 1
_font_height:		ds.w 1
_wdth:			ds.w 1
_hgt:			ds.w 1

;* tab *
_horiz_pos:		ds.w 1

	END
