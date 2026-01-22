;
; scrwin.s -- an ACE linked library module: screen and window functions.
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
;   Date: 3rd-30th November, 1st-13th December 1991,
;	  20th, 23rd,25th-27th January 1992, 
;         2nd,4th,6th,12th-19th,21st-24th,29th February 1992,
;	  1st,14th March 1992,
;	  4th,7th,21st,22nd,26th April 1992,
;	  2nd,3rd,5th,7th,8th,10th-17th May 1992,
;	  6th,8th,11th,12th,28th,30th June 1992,
;	  1st-3rd,13th,14th,18th-20th,22nd July 1992,
;	  9th August 1992,
;	  5th,12th,13th,19th December 1992,
;	  18th February 1993,
;	  1st March 1993,
;	  6th,12th June 1993,
;	  9th,10th,24th-26th,29th,31st October 1993,
;	  1st November 1993,
;	  25th December 1993,
;	  16th February 1994,
;	  6th,7th,19th March 1994,
;	  12th,25th,28th July 1994,
;	  10th,28th August 1994,
;	  11th September 1994
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; * CONSTANTS *
MAXSTRINGSIZE 	equ 1024
Width		equ 8
Height		equ 10
cp_x		equ 36
cp_y		equ 38
BitMap		equ 184
Depth		equ 5
Font		equ 52
tf_YSize	equ 20
tf_XSize	equ 24
lib_Version	equ 20
CTRL_C_BREAK	equ 4096
VANILLAKEY	equ $00200000
UserPort	equ 86

Class		equ 0		; member of IntuiInfo structure
Code		equ 4		; member of IntuiInfo structure
				; (see intuievent.h)

SCREEN_OPEN_ERR equ 600

; LVOs for AGA support (not in ami.lib)
_LVOOpenScreenTagList equ -612
_LVOSetRGB32 equ -852


	; window & screen routines
	xdef	_openscreen
	xdef	_closescreen
	xdef	_change_screen_depth
	xdef	_changetextcolor
	xdef	_palette
	xdef	_chipset
	xdef	_shortprints
	xdef	_longprints
	xdef	_singleprints
	xdef	_stringprints
	xdef	_horiz_tab
	xdef	_printsLF
	xdef	_printsTAB
	xdef	_printsSPC
	xdef	_cls
	xdef	_ptab
	xdef	_ctrl_c_test

   	; external references
	xref	_locate
	xref	_scroll_screen
	xref	_slash
	xref	_radconv
	xref	_longtemp
	xref	_formfeed
	xref	_forcebgndcolr
	xref	_textcolr
	xref	_raw
	xref	_Wdw_width_list
	xref	_Wdw_height_list
	xref	_fgdpen_list
	xref	_bgpen_list
	xref	_Wdw_list
	xref	_RPort_list
	xref	_stdout_list
	xref	_stdin_list
	xref	_mode_oldfile
	xref	_ScreenWdw
	xref	_ScreenRPort
	xref	_ScreenViewPort
	xref	_Screen_list
	xref	_newscreen
	xref	_newwindow
	xref	_horiz_tabstring
	xref	_NULL_string

	xref	_x1
	xref	_x2
	xref	_y1
	xref	_y2
	xref	_titleaddr
	xref	_tempstr
	xref	_rawname
	xref	_tempWdw_id
	xref	_screen_id
	xref	_rport_addr
	xref	_viewport_addr
	xref	_screen_addr
	xref	_scr_wdw_addr
	xref	_color_id
	xref	_red
	xref	_green
	xref	_blue
	xref	_strbuf
	xref	_max_line
	xref	_font_height
	xref	_wdth
	xref	_hgt
	xref	_horiz_pos

	; AGA screen support
	xref	_aga_modeid
	xref	_aga_taglist
	xref	_screen_depth_list
	
	xref	_putchar
	xref	_sprintf
	xref	_strcpy	
	xref	_strcat
	xref	_strlen
	xref	_strshort
	xref	_strlong
	xref	_strsingle
	xref	_IntuitionBase
 	xref  	_stdout
	xref	_stdin
	xref 	_AbsExecBase
	xref	_LVOSetSignal
	xref	_GfxBase
	xref	_LVOMove
	xref	_LVOText
	xref	_LVOSetAPen
	xref	_LVOSetRGB4
	xref	_LVOClearScreen
	xref	_LVOScrollRaster
	xref	_LVOOpenScreen
	; _LVOOpenScreenTagList defined locally (not in ami.lib)
	xref	_LVOCloseScreen
	xref	_LVOOpenWindow
	xref	_LVOCloseWindow
	xref	_LVOScreenToFront
	xref	_LVOScreenToBack
	xref	_DOSBase
	xref	_LVOWrite
	xref	_LVOOpen
	xref	_LVOClose
	xref	_MathBase
	xref	_MathTransBase
	xref	_LVOSPFix
	xref	_LVOSPMul
	xref	_RPort
	xref	_ViewPort
	xref	_Scrn
	xref	_Wdw
	xref	_Wdw_width
	xref	_Wdw_height
	xref	_Wdw_id
	xref	_WBWdw
	xref	_WBRPort
	xref	_WBViewPort
	xref	_WBScrn
	xref	_WBbgpen
	xref	_WBfgdpen
	xref	_IntuiMode
	xref	_fgdpen
	xref	_bgpen
	xref	_tg_initx
	xref	_tg_tx
	xref	_tg_inity
	xref	_tg_ty
	xref	_tg_degs
	xref	_tg_pen
	xref	_tg_xy_ratio
	xref	_cursorON
	xref	_turncursoron
	xref	_turncursoroff
	xref	_pos
	xref	_csrlin
	xref	_last_IDCMP_event
	xref	_only_shell_is_active
	xref	_check_for_open_window
	xref	_GetIntuiEvent
	xref	_ClearIntuiEvent

	xref	_error_code

	SECTION scrwin_code,CODE

;
; PTAB(n) - moves to nth pixel position in current output window.
;	  - d0 = n = x-position.
;
_ptab:
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	move.w	cp_y(a1),d1
	jsr	_LVOMove(a6)
		
	lea	_NULL_string,a0		; dummy string

	rts
	
;
; TAB(n) - moves cursor to nth column in current output window.
;	 - d0 = # of columns to move right. Control string returned in a0
;	   for use by _printstring. This is the NULL string if we're in
;	   IntuiMode since a LOCATE is performed.
;
_horiz_tab:
        subi.w	#1,d0			; shift back 1 column
	move.w	d0,_horiz_pos		; store it

   	; make sure not too high
	cmpi.w	#80,d0
	ble.s	_tab_mode
	move.w	#80,d0			; columns > 80 so columns=80 
	move.w	d0,_horiz_pos

_tab_mode:
	; are we in IntuiMode?
	cmpi.b	#1,_IntuiMode
	bne.s	_get_tab_digits		; NO -> DOS window TAB
	
	; YES -> re-LOCATE to nth column on current line
	addi.w	#1,_horiz_pos		; adjust for screen/window

	cmpi.w	#0,_horiz_pos
	blt.s	_exit_intuitab		; do nothing more if column<=0

	jsr	_csrlin
	move.w	_horiz_pos,d1
	jsr	_locate

_exit_intuitab:
	lea	_NULL_string,a0
	
	rts

_get_tab_digits:
	; convert column value to 2 ASCII digits and place in tab string
	ext.l	d0
	divu	#10,d0
	move.l	d0,_longtemp
	lea	_horiz_tabstring,a0
	add.w	#48,d0
	and.b	#$ff,d0
	move.b	d0,1(a0)
	move.l	_longtemp,d0
	swap	d0
	add.w	#48,d0
	and.b	#$ff,d0
	move.b	d0,2(a0)

	; move print position to leftmost column
	move.l	#13,-(sp)		; CR
	jsr	_putchar
	addq	#4,sp

	cmpi.w	#0,_horiz_pos
	ble.s	_quit_horiz_tab		; do nothing more if column<=0
		
	lea	_horiz_tabstring,a0	; control string to be printed  

_quit_horiz_tab:
	rts

;
; CLS - clear the screen (window).
;
_cls:
	; check whether in Screen Mode
	cmpi.b	#0,_IntuiMode
	beq.s	_wbscreencls	

	; clear a user-defined intuition window
	movea.l	_GfxBase,a6
	move.l	_RPort,a1
	move.w	#0,d0
	move.w	#0,d1
	jsr	_LVOMove(a6)

	move.l	_RPort,a1
	jsr	_LVOClearScreen(a6)
	
	move.w	#1,d0	
	move.w	#1,d1
	jsr	_locate

	rts

_wbscreencls:
	; first set the background colour 
	; (only necessary under 2.04)

	; check version (ExecBase->LibNode.lib_Version)
	movea.l	_AbsExecBase,a0
	move.w	lib_Version(a0),d0
	cmpi.w	#34,d0
	ble.s	_justclearscreen	; if Exec version <= 34, just do CLS

	lea	_forcebgndcolr,a0
	move.w	_bgpen,d0
	addi.b	#48,d0
	move.b	d0,2(a0)		; modify the CSI>[n]m string

	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_forcebgndcolr,d2	; force background colour to change
	move.l	#4,d3
	jsr	_LVOWrite(a6)

_justclearscreen:	
	; now clear the window!
	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_formfeed,d2		; form feed = CLS
	move.l	#1,d3
	jsr	_LVOWrite(a6)

	rts

;
; change color of text foreground and background (d0=fgnd, d1=bgnd).
;
_changetextcolor:
	; only do it if in a window!
	cmpi.b	#1,_IntuiMode
	beq.s	_exitchangetextcolor

	; convert colors to ASCII
	add.w	#48,d0
	add.w	#48,d1
	
	; change the color command string
	lea	_textcolr,a0
	move.b	d0,4(a0)
	move.b	d1,7(a0)

	; apply the text colors
	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_textcolr,d2
	move.l	#9,d3
	jsr	_LVOWrite(a6)

_exitchangetextcolor:
	rts

; _turncursoron removed - uses external definition from startup.s (xref at line 201)

;
; open a screen - d0=screen-id,d1=width,d2=height,d3=depth,d4=mode.
;
_openscreen:
	; store screen-id
	move.w	d0,_screen_id

	; check parameters
	cmpi.w	#1,d0		; screen-id < 1?
	blt	_quitopenscreen
	cmpi.w	#9,d0		; screen-id > 9?
	bgt	_quitopenscreen

	cmpi.w	#1,d1		; width < 1?
	blt	_quitopenscreen
	cmpi.w	#1280,d1	; width > 1280? (AGA super-hires support)
	bgt	_quitopenscreen

	cmpi.w	#1,d2		; height < 1?
	blt	_quitopenscreen
	cmpi.w	#512,d2		; height > 512?	 * this is arbitrarily large! *
	bgt	_quitopenscreen

	cmpi.w	#1,d3		; depth < 1?
	blt	_quitopenscreen
	cmpi.w	#8,d3		; depth > 8? (AGA 256-color support)
	bgt	_quitopenscreen

	cmpi.w	#1,d4		; mode < 1?
	blt	_quitopenscreen
	cmpi.w	#12,d4		; mode > 12? (AGA modes 7-12)
	bgt	_quitopenscreen

	; calculate place in screen lists
	move.w	_screen_id,d0
	mulu	#4,d0		; offset from start of screen lists

	move.l	#_ScreenWdw,d5
	add.l	d0,d5
	move.l	d5,_scr_wdw_addr

	move.l	#_ScreenRPort,d5
	add.l	d0,d5
	move.l	d5,_rport_addr

	move.l	#_ScreenViewPort,d5
	add.l	d0,d5
	move.l	d5,_viewport_addr

	move.l	#_Screen_list,d5
	add.l	d0,d5
	move.l	d5,_screen_addr
		
	; is this screen-id being used?
	movea.l	_screen_addr,a0
	move.l	(a0),d0
	cmpi.l	#0,d0
	bne	_quitopenscreen	; if not ZERO -> quit!

	; complete NewScreen and NewWindow structures.	

	lea	_newwindow,a0
	move.w	d1,4(a0)	; width
	move.w	d2,6(a0)	; height

	lea	_newscreen,a0
	move.w	d1,4(a0)	; width
	move.w	d2,6(a0)	; height
	move.w	d3,8(a0)	; depth

	; store depth in depth list for palette function
	move.w	_screen_id,d0
	subq.w	#1,d0		; screen_id is 1-based, list is 0-based
	mulu	#2,d0		; word offset
	lea	_screen_depth_list,a1
	move.w	d3,(a1,d0.w)	; store depth

	; screen mode
	cmpi.w	#1,d4
	bne.s	_hires1
	move.w	#0,12(a0)		; lo-res
	move.l	#$f0000140,_tg_xy_ratio	; ratio = 0.9375
	bra	_openthescreen
_hires1:
	cmpi.w	#2,d4
	bne.s	_lores2
	move.w	#$8000,12(a0)		; hi-res
	move.l	#$f0000141,_tg_xy_ratio	; ratio = 1.875
	bra	_openthescreen
_lores2:
	cmpi.w	#3,d4
	bne.s	_hires2
	move.w	#4,12(a0)		; lo-res, interlaced
	move.l	#$f000013f,_tg_xy_ratio	; ratio = 0.46875
	bra	_openthescreen	
_hires2:
	cmpi.w	#4,d4
	bne.s	_ham
	move.w	#$8004,12(a0)		; hi-res, interlaced
	move.l	#$f0000140,_tg_xy_ratio	; ratio = 0.9375
	bra	_openthescreen
_ham:
	cmpi.w	#5,d4
	bne.s	_halfbrite
	move.w	#$800,12(a0)		; hold-and-modify
	move.l	#$f0000140,_tg_xy_ratio	; ratio = 0.9375
	bra	_openthescreen
_halfbrite:
	cmpi.w	#6,d4
	bne.s	_lores_aga
	move.w	#$80,12(a0)		; extra-halfbrite
	move.l	#$f0000140,_tg_xy_ratio	; ratio = 0.9375
	bra	_openthescreen

	; AGA modes (7-12) - use OpenScreenTagList for proper AGA support
_lores_aga:
	cmpi.w	#7,d4
	bne.s	_hires_aga
	move.l	#$00000000,_aga_modeid	; LORES_KEY
	move.l	#$f0000140,_tg_xy_ratio	; ratio = 0.9375
	bra	_openthescreen_aga
_hires_aga:
	cmpi.w	#8,d4
	bne.s	_superhires_aga
	move.l	#$00008000,_aga_modeid	; HIRES_KEY
	move.l	#$f0000141,_tg_xy_ratio	; ratio = 1.875
	bra	_openthescreen_aga
_superhires_aga:
	cmpi.w	#9,d4
	bne.s	_ham8_lores
	move.l	#$00008020,_aga_modeid	; SUPER_KEY
	move.l	#$f0000142,_tg_xy_ratio	; ratio = 3.75
	bra	_openthescreen_aga
_ham8_lores:
	cmpi.w	#10,d4
	bne.s	_ham8_hires
	move.l	#$00000800,_aga_modeid	; LORES + HAM
	move.l	#$f0000140,_tg_xy_ratio	; ratio = 0.9375
	bra	_openthescreen_aga
_ham8_hires:
	cmpi.w	#11,d4
	bne.s	_ham8_superhires
	move.l	#$00008800,_aga_modeid	; HIRES + HAM
	move.l	#$f0000141,_tg_xy_ratio	; ratio = 1.875
	bra	_openthescreen_aga
_ham8_superhires:
	; mode 12 - assume anything else is mode 12
	move.l	#$00008820,_aga_modeid	; SUPER + HAM
	move.l	#$f0000142,_tg_xy_ratio	; ratio = 3.75
	bra	_openthescreen_aga

_openthescreen:
	; open the screen
	movea.l	_IntuitionBase,a6
	lea	_newscreen,a0
	jsr	_LVOOpenScreen(a6)
	move.l	d0,_Scrn
	cmpi.l	#0,d0
	beq	_quitopenscreen	; quit if can't open screen!
	
	; open a borderless window 
	movea.l	_IntuitionBase,a6
	lea	_newwindow,a0
	move.l	_Scrn,30(a0)	; link to screen just opened
	jsr	_LVOOpenWindow(a6)
	move.l	d0,_Wdw
	cmpi.l	#0,d0
	beq	_quitopenscreen	; quit if can't open window!
	
	; update lists and set screen mode
	move.b	#1,_IntuiMode

	; store screen
	movea.l	_screen_addr,a0
	move.l	_Scrn,(a0)
	
	; store window
	movea.l	_scr_wdw_addr,a0
	move.l	_Wdw,(a0)

	movea.l	_rport_addr,a0
	movea.l	_Wdw,a1
	move.l	50(a1),(a0)
	move.l	50(a1),_RPort
	
	; store viewport
	movea.l	_viewport_addr,a0
	move.l	_Scrn,d0
	add.l	#44,d0
	move.l	d0,(a0)
	move.l	d0,_ViewPort

	; set first PRINT position in screen's default window
	moveq	#3,d0
	moveq	#1,d1
	jsr	_locate

	; set foreground pen in window
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	moveq	#1,d0
	jsr	_LVOSetAPen(a6)
	
	rts

;
; Open an AGA screen using OpenScreenTagList for proper 256-color support.
; Uses SA_DisplayID tag to specify the AGA mode ID.
; _aga_modeid must be set before calling this routine.
; _newwindow must have width/height set (done by caller at lines 439-441).
;
_openthescreen_aga:
	; Build taglist for OpenScreenTagList
	; Read width, height, depth from _newscreen structure
	lea	_newscreen,a0
	lea	_aga_taglist,a1

	; SA_Width tag ($80000023)
	move.l	#$80000023,(a1)+	; SA_Width
	moveq	#0,d0
	move.w	4(a0),d0		; width from _newscreen
	move.l	d0,(a1)+

	; SA_Height tag ($80000024)
	move.l	#$80000024,(a1)+	; SA_Height
	moveq	#0,d0
	move.w	6(a0),d0		; height from _newscreen
	move.l	d0,(a1)+

	; SA_Depth tag ($80000025)
	move.l	#$80000025,(a1)+	; SA_Depth
	moveq	#0,d0
	move.w	8(a0),d0		; depth from _newscreen
	move.l	d0,(a1)+

	; SA_DisplayID tag ($80000032)
	move.l	#$80000032,(a1)+	; SA_DisplayID
	move.l	_aga_modeid,(a1)+

	; SA_Type tag ($8000002D)
	move.l	#$8000002D,(a1)+	; SA_Type
	move.l	#$000F,(a1)+		; CUSTOMSCREEN

	; TAG_DONE
	clr.l	(a1)+
	clr.l	(a1)

	; Open screen with OpenScreenTagList(NULL, taglist)
	movea.l	_IntuitionBase,a6
	sub.l	a0,a0			; NewScreen = NULL
	lea	_aga_taglist,a1		; TagList
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,_Scrn
	cmpi.l	#0,d0
	beq	_quitopenscreen		; quit if can't open screen!

	; Open borderless window (same as _openthescreen)
	movea.l	_IntuitionBase,a6
	lea	_newwindow,a0
	move.l	_Scrn,30(a0)		; link to screen just opened
	jsr	_LVOOpenWindow(a6)
	move.l	d0,_Wdw
	cmpi.l	#0,d0
	beq	_quitopenscreen		; quit if can't open window!

	; Update lists and set screen mode
	move.b	#1,_IntuiMode

	; Store screen
	movea.l	_screen_addr,a0
	move.l	_Scrn,(a0)

	; Store window
	movea.l	_scr_wdw_addr,a0
	move.l	_Wdw,(a0)

	movea.l	_rport_addr,a0
	movea.l	_Wdw,a1
	move.l	50(a1),(a0)
	move.l	50(a1),_RPort

	; Store viewport
	movea.l	_viewport_addr,a0
	move.l	_Scrn,d0
	add.l	#44,d0
	move.l	d0,(a0)
	move.l	d0,_ViewPort

	; Set first PRINT position in screen's default window
	moveq	#3,d0
	moveq	#1,d1
	jsr	_locate

	; Set foreground pen in window
	movea.l	_GfxBase,a6
	movea.l	_RPort,a1
	moveq	#1,d0
	jsr	_LVOSetAPen(a6)

	rts

_quitopenscreen:
	move.l	#SCREEN_OPEN_ERR,_error_code	; !! ERROR !!
	rts

;
; close a screen - d0=screen-id.
;
_closescreen:
	; store screen-id
	move.w	d0,_screen_id

	; check parameters
	cmpi.w	#1,d0		; screen-id < 1?
	blt	_quitclosescreen
	cmpi.w	#9,d0		; screen-id > 9?
	bgt	_quitclosescreen

	; calculate place in screen lists
	move.w	_screen_id,d0
	mulu	#4,d0		; offset from start of screen lists

	move.l	#_Screen_list,d5
	add.l	d0,d5
	movea.l	d5,a0

	; is screen-id being used?
	move.l	(a0),d0
	cmpi.l	#0,d0
	beq	_quitclosescreen	; if ZERO -> quit!
	
 	; close the window
	movea.l	_IntuitionBase,a6
	move.w	_screen_id,d0
	mulu	#4,d0
	move.l	#_ScreenWdw,d5
	add.l	d0,d5
	movea.l	d5,a1
	movea.l	(a1),a0
	jsr	_LVOCloseWindow(a6)

	; close the screen
	movea.l	_IntuitionBase,a6
	move.w	_screen_id,d0
	mulu	#4,d0
	move.l	#_Screen_list,d5
	add.l	d0,d5
	movea.l	d5,a1
	movea.l	(a1),a0
	jsr	_LVOCloseScreen(a6)
	
	; zero all list elements -> screen,rastport,viewport
	move.w	_screen_id,d0
	mulu	#4,d0		; offset from start of screen lists

	move.l	#_Screen_list,d5
	add.l	d0,d5
	movea.l	d5,a0
	move.l	#0,(a0)

	move.l	#_ScreenWdw,d5
	add.l	d0,d5
	movea.l	d5,a0
	move.l	#0,(a0)
	
	move.l	#_ScreenRPort,d5
	add.l	d0,d5
	movea.l	d5,a0
	move.l	#0,(a0)

	move.l	#_ScreenViewPort,d5
	add.l	d0,d5
	movea.l	d5,a0
	move.l	#0,(a0)

	; find open screen (starting from 9)
	move.w	#10,d1
_findopenscreen:
	sub.w	#1,d1		; start counter at 9
	cmpi.w	#0,d1
	beq	_foundwbscreen	; no open screens except Wb

	move.w	d1,d0
	mulu	#4,d0		; offset from start of screen lists
	
	move.l	#_Screen_list,d5
	add.l	d0,d5
	movea.l	d5,a0
	cmpi.l	#0,(a0)
	beq.s	_findopenscreen	; try next screen list position	
	
	; there is still an open screen -> update _Scrn,_RPort,_ViewPort 
	move.l	(a0),_Scrn

	move.l	#_ScreenWdw,d5
	add.l	d0,d5			; d0=offset from start of list
	movea.l	d5,a0
	move.l	(a0),_Wdw
	
	move.l	#_ScreenRPort,d5
	add.l	d0,d5			; d0=offset from start of list
	movea.l	d5,a0
	move.l	(a0),_RPort

	move.l	#_ScreenViewPort,d5
	add.l	d0,d5			; d0=offset from start of list
	movea.l	d5,a0
	move.l	(a0),_ViewPort

	; Is there an open window on this new screen?
	; If so, make the highest numbered one the current output window.
	jsr	_check_for_open_window

	bra.s	_quitclosescreen

_foundwbscreen:
	; only Wb screen open -> update _Scrn,_RPort,_ViewPort,_fgdpen,_bgpen
	; and reset _IntuiMode if only a shell/CLI is open.
	move.l	_WBWdw,_Wdw
	move.l	_WBRPort,_RPort
	move.l	_WBScrn,_Scrn
	move.l	_WBViewPort,_ViewPort
	move.l	_WBfgdpen,_fgdpen
	move.l	_WBbgpen,_bgpen	

	jsr	_only_shell_is_active
	cmpi.w	#0,d0
	beq.s	_quitclosescreen

	move.b	#0,_IntuiMode
		
_quitclosescreen:
	rts

;
; SCREEN FORWARD | BACK screen-id. 
;
; d0 = screen_id; d1 = forward/back (1 or 2).
;
_change_screen_depth:
	; check parameters
	cmpi.w	#1,d0		; screen-id < 1?
	blt	_quit_change_screen_depth
	cmpi.w	#9,d0		; screen-id > 9?
	bgt	_quit_change_screen_depth

	; calculate place in screen list
	mulu	#4,d0		; offset from start of screen lists

	move.l	#_Screen_list,d5
	add.l	d0,d5
	movea.l	d5,a0

	; is screen-id being used?
	move.l	(a0),d0
	cmpi.l	#0,d0
	beq.s	_quit_change_screen_depth	; store screen-id

	; change the screen's depth!
	cmpi.w	#1,d1
	bne.s	_test_for_screen_back_move
	movea.l	_IntuitionBase,a6
	movea.l	d0,a0
	jsr	_LVOScreenToFront(a6)		; SCREEN FRONT
	rts

_test_for_screen_back_move:
	cmpi.w	#2,d1
	bne.s	_quit_change_screen_depth
	movea.l	_IntuitionBase,a6
	movea.l	d0,a0
	jsr	_LVOScreenToBack(a6)		; SCREEN BACK
	
_quit_change_screen_depth:
	rts

;
; define palette for current viewport. d0=color-id,d1=red,d2=green,d3=blue.
; Supports AGA 256-color modes (depth > 6) using SetRGB32.
;
_palette:
	; store color-id
	move.w	d0,_color_id

	; check for legal color-id
	cmpi.w	#0,d0
	blt	_quitpalette	; color-id < 0?

	cmpi.w	#255,d0
	bgt	_quitpalette	; color-id > 255?

	; store RGB values.
	move.l	d1,_red
	move.l	d2,_green
	move.l	d3,_blue

	; check current screen depth to decide SetRGB4 vs SetRGB32
	move.w	_screen_id,d0
	subq.w	#1,d0		; 0-based index
	mulu	#2,d0		; word offset
	lea	_screen_depth_list,a0
	move.w	(a0,d0.w),d0	; get depth
	cmpi.w	#6,d0
	bgt	_use_rgb32	; depth > 6 -> use SetRGB32

	; --- SetRGB4 path (depth <= 6, colors 0-63) ---
	; Convert single-precision RGB values (0-1) to integers (0-15).

	movea.l	_MathBase,a6

	move.l	_red,d0
	move.l	#$f0000044,d1	; 15
	jsr	_LVOSPMul(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,_red

	move.l	_green,d0
	move.l	#$f0000044,d1	; 15
	jsr	_LVOSPMul(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,_green

	move.l	_blue,d0
	move.l	#$f0000044,d1	; 15
	jsr	_LVOSPMul(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,_blue

	; change colormap values with SetRGB4
	movea.l	_GfxBase,a6
	movea.l	_ViewPort,a0
	move.w	_color_id,d0
	move.l	_red,d1
	and.b	#$ff,d1
	move.l	_green,d2
	and.b	#$ff,d2
	move.l	_blue,d3
	and.b	#$ff,d3
	jsr	_LVOSetRGB4(a6)
	bra	_quitpalette

_use_rgb32:
	; --- SetRGB32 path (depth > 6, colors 0-255) ---
	; Convert single-precision RGB values (0-1) to 32-bit values.
	; SetRGB32 expects color in upper 8 bits, replicated.

	movea.l	_MathBase,a6

	move.l	_red,d0
	move.l	#$ff000048,d1	; 255 in FFP
	jsr	_LVOSPMul(a6)
	jsr	_LVOSPFix(a6)
	; shift left 24 bits and replicate for SetRGB32
	move.l	d0,d1
	lsl.l	#8,d0
	or.l	d1,d0
	lsl.l	#8,d0
	or.l	d1,d0
	lsl.l	#8,d0
	or.l	d1,d0
	move.l	d0,_red

	move.l	_green,d0
	move.l	#$ff000048,d1	; 255 in FFP
	jsr	_LVOSPMul(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,d1
	lsl.l	#8,d0
	or.l	d1,d0
	lsl.l	#8,d0
	or.l	d1,d0
	lsl.l	#8,d0
	or.l	d1,d0
	move.l	d0,_green

	move.l	_blue,d0
	move.l	#$ff000048,d1	; 255 in FFP
	jsr	_LVOSPMul(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,d1
	lsl.l	#8,d0
	or.l	d1,d0
	lsl.l	#8,d0
	or.l	d1,d0
	lsl.l	#8,d0
	or.l	d1,d0
	move.l	d0,_blue

	; change colormap values with SetRGB32
	movea.l	_GfxBase,a6
	movea.l	_ViewPort,a0
	move.w	_color_id,d0
	ext.l	d0		; extend to long for SetRGB32
	move.l	_red,d1
	move.l	_green,d2
	move.l	_blue,d3
	jsr	_LVOSetRGB32(a6)
		
_quitpalette:
	rts

;
; print a short integer on current screen. d0=short integer to be printed.
;
_shortprints:
	lea	_strbuf,a0
	jsr	_strshort
	jsr	_stringprints
		
	rts

;
; print a long integer on current screen. d0=long integer to be printed.
;
_longprints:
	lea	_strbuf,a0
	jsr	_strlong
	jsr	_stringprints

	rts

;
; print a single-precision value on current screen. 
; d0=single-precision float to be printed.
;
_singleprints:
	move.l	d0,-(sp)
	jsr	_strsingle
	addq	#4,sp
	move.l	d0,a0
	jsr	_stringprints
	
	rts

;
; print a string on current screen. a0=string to be printed.
;
_stringprints:
	; find length of string
	movea.l	a0,a2
	jsr	_strlen		; d0=length 
	and.w	#$ffff,d0

	; print it
	movea.l	_RPort,a1
	movea.l _GfxBase,a6
	jsr	_LVOText(a6)	
	
	rts

;
; print a line feed in current screen using locate,
; scrolling if necessary.
;
_printsLF:
	jsr	_csrlin
	addq	#1,d0	; d0=LINE
	
	move.w	#1,d1	; d1=COLUMN

	jsr	_locate
	jsr	_scroll_screen

	rts

;
; print a BASIC TAB in current Intuition window using LOCATE.
; 
; *note* that this is not the same as the CON/RAW window comma-TAB
; used by print which consists of CHR$(9) x 2.
; 
_printsTAB:
	jsr	_csrlin	 ; d0=LINE
	move.w	d0,-(sp) ; store LINE
	
	jsr	_pos
	move.w	d0,d1

_seekintuitabpos:
	; find the next tab position (every 10 character positions)
	add.w	#1,d1	 ; d1=COLUMN
	move.w	d1,d2
	ext.l	d2
	divu	#10,d2
	swap	d2	 ; d2 MOD 10 
	cmpi.w	#0,d2	
	bne.s	_seekintuitabpos

	move.w	(sp)+,d0 ; pop LINE

	jsr	_locate

	rts

;
; print a single space in current screen using locate.
;
_printsSPC:
	jsr	_csrlin	 ; d0=LINE
	move.w	d0,-(sp) ; store LINE

	jsr	_pos
	move.w	d0,d1
	addq	#1,d1	 ; d1=COLUMN
	move.w	(sp)+,d0 ; pop LINE

	jsr	_locate

	rts

;
; Test for a control-c break. Return 0L or non-zero value in d0. 
;
_ctrl_c_test:
	cmpi.b	#1,_IntuiMode
	beq.s	_intui_ctrl_c_test

	; DOS window ctrl-c signal test
	movea.l	_AbsExecBase,a6
	moveq	#0,d0
	move.l	#CTRL_C_BREAK,d1
	jsr	_LVOSetSignal(a6)
	andi.l	#CTRL_C_BREAK,d0	; Quit with 0 or 4096
	rts

_intui_ctrl_c_test:
	; Test for ASCII 3 from IDCMP for current window
	movea.l	_Wdw,a0
	move.l	UserPort(a0),-(sp)
	jsr	_GetIntuiEvent
	addq	#4,sp
	tst.l	d0
	beq.s	_exit_ctrl_c_test	; No message! Quit with 0

	movea.l	d0,a0			; pointer to IntuiInfo structure
	move.l	Class(a0),d1		; Message->Class
	andi.l	#VANILLAKEY,d1
	cmpi.l	#VANILLAKEY,d1
	beq.s	_get_vanilla_key	; No vanillakey event: quit
	moveq	#0,d0			; Quit with 0
	rts

_get_vanilla_key:
	moveq	#0,d0			; assume it's not ASCII 3 -> 0 result
	move.w	Code(a0),d1		; Message->Code
	cmpi.w	#3,d1
	bne.s	_exit_ctrl_c_test
	jsr	_ClearIntuiEvent
	moveq	#1,d0			; Quit with 1 -> it's an ASCII 3!
				
_exit_ctrl_c_test:
	rts

;
; _chipset - detect Amiga chipset type.
;          - returns: 0=OCS, 1=ECS, 2=AGA in d0.
;          - queries GfxBase->ChipRevBits0 (offset 236 / $ec)
;
_chipset:
	movea.l	_GfxBase,a0
	move.b	$ec(a0),d0	; GfxBase->ChipRevBits0

	; Check for AGA (GFXB_AA_ALICE = bit 2, GFXB_AA_LISA = bit 3)
	btst	#2,d0		; AA_ALICE?
	bne.s	_is_aga
	btst	#3,d0		; AA_LISA?
	bne.s	_is_aga

	; Check for ECS (GFXB_HR_AGNUS = bit 0, GFXB_HR_DENISE = bit 1)
	btst	#0,d0		; HR_AGNUS?
	bne.s	_is_ecs
	btst	#1,d0		; HR_DENISE?
	bne.s	_is_ecs

	; OCS
	moveq	#0,d0
	rts

_is_ecs:
	moveq	#1,d0
	rts

_is_aga:
	moveq	#2,d0
	rts

	END
