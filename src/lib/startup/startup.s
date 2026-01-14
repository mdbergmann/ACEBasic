;
; startup.lib (linked library)
;
; startup and library management code for all ACE programs.
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
;   Date: 3rd,17th,24th,28th,30th November 1991,
;	  27th January 1992, 
; 	  2nd,4th,11th,14th-16th,29th February 1992,
;	  1st March 1992,
;	  26th April 1992,
;	  1st,2nd,11th,12th,15th May 1992,
;	  6th,7th,11th,28th,30th June 1992,
;	  4th,7th,16th July 1992
;	  5th,7th,8th,22nd December 1992,
;	  6th,11th,28th February 1993,
;	  1st March 1993,
;	  6th June 1993,
;	  9th,25th October 1993,
;	  27th December 1993,
;	  5th November 1995
;
; - Some routines in startup.lib open the shared libaries required by 
;   an ACE program along with retrieving DOS and Intuition data.
; - startup.lib also contains startup code for Workbench and Shell launched
;   programs.
; - If a library can't be opened or data can't be accessed, _starterr is set
;   to 1 so that upon return to the main ACE program an abort branch can be 
;   executed.
; - If _stdin or _stdout are zero, a WorkBench start is assumed.
;

; * CONSTANTS *
pr_CLI 		equ 	172
pr_MsgPort 	equ 	92
sm_ArgList	equ	36
wa_Lock		equ	0

	; * XDEFs *
	xdef	_DOSBase
	xdef    _MathBase
        xdef    _MathTransBase
        xdef    _MathIeeeSingTransBase
	xdef	_GfxBase
	xdef	_IntuitionBase
	xdef	_TransBase
	xdef	_SysBase

	xdef	_RPort
	xdef	_Wdw
	xdef	_Scrn
	xdef	_ViewPort
	xdef	_Wdw_width
	xdef	_Wdw_height
	xdef	_Wdw_id
	xdef	_WBWdw
	xdef	_WBRPort
	xdef	_WBViewPort
	xdef	_WBScrn
	xdef	_WBbgpen
	xdef	_WBfgdpen
	xdef	_IntuiMode

	xdef	_returncode

	xdef	_cursorON
	xdef	_cursorOFF
	xdef	_turncursoron
	xdef	_turncursoroff

	xdef	_cmdlen
	xdef	_cmdbuf
	xdef	_WBenchMsg
	xdef	_TaskAddress
	xdef	_startup
	xdef	_cleanup
	xdef	_starterr
	xdef	_stdout
	xdef	_stdin
	xdef	_openio
	xdef	_closeio
	xdef    _openmathffp
	xdef	_closemathffp
	xdef	_openmathtrans
	xdef	_closemathtrans
	xdef	_opengfx
	xdef	_closegfx
	xdef	_openintuition
	xdef	_closeintuition
	xdef	_opentranslator
	xdef	_closetranslator
	xdef	_fgdpen
	xdef	_bgpen

	; * XREFs needed by startup.lib *
	xref	_AbsExecBase
	xref	_LVOOpenLibrary
	xref	_LVOCloseLibrary
	xref	_LVOFindTask
	xref	_LVOWaitPort
	xref	_LVOGetMsg
	xref	_LVOReplyMsg
	xref	_LVOForbid
	xref	_LVOFreeMem

	xref	_LVOOutput
	xref	_LVOInput
       	xref	_LVOWrite
	xref	_LVOCurrentDir

	xref	_RPort_list
	xref	_Wdw_list
	xref	_Wdw_width_list
	xref	_Wdw_height_list
	xref	_stdout_list
	xref	_stdin_list
	xref	_fgdpen_list
	xref	_bgpen_list
	xref	_storewindowinfo
	xref	_tg_degs
	xref	_tg_tx
	xref	_tg_ty
	xref	_tg_initx
	xref	_tg_inity
	xref	_tg_pen
	xref	_LVOMove
	xref	_turncursoron
	xref	_turncursoroff

	xref	_argbuf

	xref	_initialise_waveform_data
	xref	_waveformaddr0
	xref	_waveformaddr1
	xref	_waveformaddr2
	xref	_waveformaddr3
	xref	_wavelen0
	xref	_wavelen1
	xref	_wavelen2
	xref	_wavelen3
	xref	_sinwavedata

;
; opens the DOS library, gets stdio handles & sets up default sound waveform.
;
_openio:
	move.b	#0,_starterr
	        
	; open DOS library
	movea.l	#_doslib,a1
	move.l	#0,d0			; version = don't care
	movea.l _AbsExecBase,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	cmpi.l	#0,d0
	bne.s	_openio_ok
	move.b	#1,_starterr		; error
	rts

_openio_ok:	
	; get _stdout handle
	move.l	_DOSBase,a6		
	jsr	_LVOOutput(a6)
	move.l	d0,_stdout
	
	; get _stdin handle
	move.l	_DOSBase,a6
	jsr	_LVOInput(a6)
	move.l	d0,_stdin
	
_stdin_ok:
  	cmpi.l	#0,d0
	beq.s	_soundsetup		; no I/O handles, no cursor changes!

	jsr	_turncursoroff
     
_soundsetup:
        ; set up default waveform data for SOUND statement.
	jsr	_initialise_waveform_data
		
_quitopenio:
	rts

;
; closes DOS library.
;
_closeio:
	tst.l	_DOSBase
	beq.s	_quitcloseio
	
	move.l	_DOSBase,a1
	movea.l	_AbsExecBase,a6
	jsr	_LVOCloseLibrary(a6)

	cmpi.l	#0,_stdout
	beq.s	_quitcloseio		; don't turn cursor on if no stdout!
	
	jsr	_turncursoron

_quitcloseio:
	rts

;
; opens Motorola Fast-Floating-Point (FFP) math library.
;
_openmathffp:
	move.b	#0,_starterr

	movea.l #_mathffplib,a1
	move.l  #0,d0
	movea.l _AbsExecBase,a6
	jsr     _LVOOpenLibrary(a6)
	move.l  d0,_MathBase
	cmpi.l	#0,d0
	bne.s	_mathffp_ok
	move.b	#1,_starterr

_mathffp_ok:
        rts

;
; closes FFP library.
;
_closemathffp:
	tst.l	_MathBase
	beq.s	_quitclosemathffp

	move.l  _MathBase,a1
	movea.l _AbsExecBase,a6
	jsr     _LVOCloseLibrary(a6)

_quitclosemathffp:
	rts
       
;
; opens FFP and IEEE transendental function libraries.
;
_openmathtrans:
	move.b	#0,_starterr
	
	movea.l #_mathtranslib,a1
	move.l  #0,d0
	movea.l _AbsExecBase,a6
	jsr     _LVOOpenLibrary(a6)
	move.l  d0,_MathTransBase
	cmpi.l	#0,d0
	bne.s	_openieeesingtranslib
	move.b	#1,_starterr
	rts			; if we can't open FFP library -> abort!

_openieeesingtranslib:
	;
	; IEEE SP Transcendental library is currently only
	; used by the _power function. If it can't be opened,
	; FFP exponentiation function is used instead, so don't
	; set _starterr if we can't open mathieeesingtrans.library.
	; See ACE/src/lib/c/pow.c for more details.
	; 
	movea.l #_mathieeesingtranslib,a1
	move.l  #0,d0
	movea.l _AbsExecBase,a6
	jsr     _LVOOpenLibrary(a6)
	move.l  d0,_MathIeeeSingTransBase	

        rts

;
; close FFP transendental function library.
;
_closemathtrans:
	tst.l	_MathTransBase
	beq.s	_quitclosemathtrans

	move.l  _MathTransBase,a1
	movea.l _AbsExecBase,a6
	jsr     _LVOCloseLibrary(a6)

_quitclosemathtrans:
	rts

;
; open intuition library and get standard rastport.
;
_openintuition:
	move.b	#0,_starterr

	; open library
	movea.l	#_intuitionlib,a1
	move.l	#0,d0
	movea.l	_AbsExecBase,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IntuitionBase
	cmpi.l	#0,d0
	bne.s	_intuition_ok
	move.b	#1,_starterr		; error
	rts

_intuition_ok:
	; get window, rastport
	; and viewport
	movea.l	d0,a1
	movea.l	52(a1),a1		; ActiveWindow 
	move.l	a1,_Wdw
	cmpa.l	#0,a1
	bne.s	_Wdw_ok
	move.b	#1,_starterr		; error (no startup window -> shell/cli)
	rts

_Wdw_ok:
	move.l	50(a1),_RPort		; Rastport of ActiveWindow
	
	; approx. size of window (Wb 2.04 shell)
	move.w	#640,_Wdw_width
	move.w	#100,_Wdw_height

	; get Wb screen
	movea.l	_IntuitionBase,a1
	movea.l	56(a1),a1		
	move.l	a1,_Scrn		; ActiveScreen
	move.l	a1,d0
	add.l	#44,d0
	move.l	d0,_ViewPort		; ViewPort is 44 bytes 
					; from start of screen structure.

	; store Wb globals
	move.l	_RPort,_WBRPort
	move.l	_ViewPort,_WBViewPort
	move.l	_Scrn,_WBScrn
	move.l	_Wdw,_WBWdw
	move.b	#0,_IntuiMode

	; number of Wb window (shell/cli)
	move.w	#0,_Wdw_id

	move.w	#1,_fgdpen		; current drawing pen color
	move.w	#0,_bgpen		; current background pen color
	move.w	#1,_WBfgdpen		
	move.w	#0,_WBbgpen		

	; in case _heading ONLY is 
	; called without any TG stuff!

	move.w	#270,_tg_degs		; initial heading is 270 degs (north)

	rts

;
; close intuition library.
;
_closeintuition:
	tst.l	_IntuitionBase
	beq.s	_quitcloseintuition

	move.l  _IntuitionBase,a1
	movea.l _AbsExecBase,a6
	jsr     _LVOCloseLibrary(a6)

_quitcloseintuition:
	rts

;
; open graphics library.
;
_opengfx:
	move.b	#0,_starterr

	; open library
	movea.l	#_gfxlib,a1
	move.l	#0,d0
	movea.l	_AbsExecBase,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	cmpi.l	#0,d0
	bne.s	_gfx_ok
	move.b	#1,_starterr		; error

_gfx_ok:
	; initialise turtle graphics 
	move.w	#270,_tg_degs		; initial heading is 270 degs (north)
	move.w	_tg_initx,_tg_tx	; initial x coordinate
	move.w	_tg_inity,_tg_ty	; initial y coordinate
	move.l	_GfxBase,a6
	move.l	_RPort,a1
	move.w	_tg_tx,d0
	move.w	_tg_ty,d1
	jsr	_LVOMove(a6)		; move to home position 
	move.b	#1,_tg_pen		; pen is initially down

	rts

;
; close graphics library.
;
_closegfx:
	tst.l	_GfxBase
	beq.s	_quitclosegfx

	move.l  _GfxBase,a1
	movea.l _AbsExecBase,a6
	jsr     _LVOCloseLibrary(a6)

_quitclosegfx:
	rts

;
; open translator library
;
_opentranslator:
	move.b	#0,_starterr

	movea.l	#_translatorlib,a1
	move.l	#0,d0
	movea.l	_AbsExecBase,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_TransBase
	cmpi.l	#0,d0
	bne.s	_translator_ok
	move.b	#1,_starterr		; error

_translator_ok:
	rts

;
; close translator library
;
_closetranslator:
	tst.l	_TransBase
	beq.s	_quitclosetranslator
	
	move.l  _TransBase,a1
	movea.l _AbsExecBase,a6
	jsr     _LVOCloseLibrary(a6)

_quitclosetranslator:
	rts

;
; Startup code for all ACE programs. 
;
_startup:
	; save d0 & a0 in case CLI
	; arg's required.
	move.l	d0,_cmdlen
	move.l	a0,_cmdbuf

	; make _SysBase available to ami.lib
	move.l	_AbsExecBase,_SysBase

	; open dos.library
	jsr	_openio
	tst.l	_DOSBase
	beq.s	_quitstartup	; _starterr will be set to 1

	; get task's address
	movea.l	_AbsExecBase,a6
	suba.l	a1,a1
	jsr	_LVOFindTask(a6)
	move.l	d0,_TaskAddress
	
	; look at Process structure
	; to determine whether
	; process started from Wb
	movea.l	d0,a4
	tst.l	pr_CLI(a4)		
	beq.s	_fromWb
	move.l	#0,_WBenchMsg	 ; no message
	rts			 ; Not started from Wb

_fromWb:
	; wait for Wb message
	movea.l	_AbsExecBase,a6
	lea	pr_MsgPort(a4),a0
	jsr	_LVOWaitPort(a6) ; wait for msg
	lea	pr_MsgPort(a4),a0
	jsr	_LVOGetMsg(a6)	 ; get msg
	move.l	d0,_WBenchMsg	 ; store msg	

	; make current directory
	; the working directory.
	movea.l	d0,a2
	move.l	sm_ArgList(a2),d0
	beq.s	_quitstartup
	movea.l	_DOSBase,a6
	movea.l	d0,a0
	move.l	wa_Lock(a0),d1		
	jsr	_LVOCurrentDir(a6)
	
_quitstartup:
	rts	

;
; Cleanup code for all ACE programs.
;
_cleanup:
	; free allocated argument buffer. 
	tst.l	_argbuf
	beq.s	_closedos	; if no memory allocated -> skip freemem
	movea.l	_AbsExecBase,a6
	movea.l	_argbuf,a1	; buffer address
	move.l	_cmdlen,d0	; # of bytes allocated (see arg.c)
	jsr	_LVOFreeMem(a6)
	
_closedos:
	; close dos.library
	jsr	_closeio	

	; if there is a Wb message, reply to it.
	tst.l	_WBenchMsg
	bne.s	_replytoWBMsg	

	; otherwise just exit with return code (CLI/shell start).
	move.l	_returncode,d0
	rts

_replytoWBMsg:
	; exit from a Wb launched program. 
	move.l	_AbsExecBase,a6
	jsr	_LVOForbid(a6)
	move.l	_WBenchMsg,a1
	jsr	_LVOReplyMsg(a6)
	rts

;
; turn cursor on.
;
_turncursoron:
	move.l	_stdout,d1
	move.l	#_cursorON,d2
	moveq	#3,d3
	move.l	_DOSBase,a6
	jsr	_LVOWrite(a6)
	rts

;
; turn cursor off.
;
_turncursoroff:
	move.l	_stdout,d1
	move.l	#_cursorOFF,d2
	moveq	#4,d3
	move.l	_DOSBase,a6
	jsr	_LVOWrite(a6)
	rts

;************************

	SECTION	startup_data,DATA

_version:	dc.b	'$VER: startup 1.12 (05.11.95)',0

_doslib:		dc.b	'dos.library',0
_mathffplib:    	dc.b	'mathffp.library',0
_mathtranslib:  	dc.b	'mathtrans.library',0
_mathieeesingtranslib: 	dc.b	'mathieeesingtrans.library',0
_gfxlib:		dc.b	'graphics.library',0
_intuitionlib:		dc.b	'intuition.library',0
_translatorlib: 	dc.b	'translator.library',0

_IntuiMode:	dc.b 	0

_returncode:	dc.l	0

_cursorOFF:	dc.b	$9b,$30,$20,$70
_cursorON:	dc.b	$9b,$20,$70

	SECTION startup_mem,BSS

_cmdlen:	ds.l 1
_cmdbuf:	ds.l 1
_starterr:	ds.b 1
_DOSBase:	ds.l 1
_stdout:	ds.l 1
_stdin:		ds.l 1

_MathBase:      	ds.l 1
_MathTransBase: 	ds.l 1
_MathIeeeSingTransBase: ds.l 1
_GfxBase:		ds.l 1
_IntuitionBase: 	ds.l 1
_TransBase:		ds.l 1
_SysBase:		ds.l 1

_RPort:		ds.l 1
_Wdw:		ds.l 1
_Scrn:		ds.l 1
_ViewPort:	ds.l 1
_Wdw_width:	ds.w 1
_Wdw_height:	ds.w 1
_Wdw_id:	ds.w 1
_WBWdw:		ds.l 1
_WBRPort:	ds.l 1
_WBViewPort:	ds.l 1
_WBScrn:	ds.l 1
_WBbgpen:	ds.w 1
_WBfgdpen:	ds.w 1

_fgdpen:	ds.w 1
_bgpen:		ds.w 1

_TaskAddress:	ds.l 1
_WBenchMsg:	ds.l 1

	END
