;
; file.s -- an ACE linked library module: file functions.
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
;	  5th,21st December 1992,
;	  5th,6th,12th January 1993,
;	  7th,14th-16th,18th February 1993,
;	  1st March 1993,
;	  9th-11th May 1993,
;	  10th June 1993,
;	  26th September 1993,
;	  19th March 1994,
;	  10th April 1994,
;	  13th May 1994,
;	  10th,15th,17th March 1996
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; error codes
BFN	equ	52	; Bad File Number
BFM	equ	54	; Bad File Mode

; miscellaneous defines
MAXSTRINGSIZE 		equ 	1024
OFFSET_END		equ	1
OFFSET_BEGINNING	equ	-1
MODE_OLDFILE		equ	1005
MODE_NEWFILE		equ	1006
MODE_READWRITE		equ	1004
ACCESS_READ		equ	-2	

	; file routines
	xdef	_openfile
	xdef	_closefile

	xdef	_writeshort
	xdef	_writelong
	xdef	_writesingle
	xdef	_writestring	; WRITE# / PRINT#

	xdef	_fprintshort
	xdef	_fprintlong
	xdef	_fprintsingle	; PRINT#

	xdef	_writecomma
	xdef	_writequote
	xdef	_write_eoln
	xdef	_writeSPC
	xdef	_writeTAB	; WRITE# / PRINT# 

	xdef	_inputstrfromfile
	xdef	_line_input

	xdef	_finputstring
	xdef	_finputsingle
	xdef	_finputshort
	xdef	_finputlong	; INPUT#

	xdef	_eoftest
	xdef	_lof
	xdef	_handle

	xdef	_kill
	xdef	_rename
	xdef	_chdir

   	; external references
	xref	_shortfmt
	xref	_longfmt
	xref	_file_handle_list
	xref	_line_end
	xref	_quote_mark
	xref	_comma
	xref	_space
	xref	_tab

	xref	_fileinpstring
	xref	_filecharcount
	xref	_tempfinp
	xref	_fstrbuf
	xref	_filenum
	xref	_eofhandle
	xref	_filesize
	xref	_filehandle
	xref	_oldfilepos
	xref	_filespec_ptr

	xref	_error_code

	xref	_strlen
	xref	_sprintf
	xref	_fgetchars
	xref	_fgetline
	xref	_fgetseqfld
	xref	_strshort
	xref	_strlong
	xref	_strsingle
	xref	_val
	xref	_short_from_string
	xref	_long_from_string
   	xref  	_LVOWrite
	xref	_LVORead
	xref	_LVOOpen
	xref	_LVOClose
	xref	_LVOSeek
	xref	_LVODeleteFile
	xref	_LVORename
	xref	_LVOLock
	xref	_LVOUnLock
	xref	_LVOCurrentDir
	xref	_LVOIoErr

  	xref  	_DOSBase	

	SECTION file_code,CODE

; *** FILE ROUTINES ***

;
; Ask DOS whether an error has occurred since the last I/O operation.
;
_IoErr_poll:
	move.l	d0,-(sp)

	cmpi.l	#0,d0
	bgt.s	_quit_IoErr_poll  ; Last operation was successful

	; Last operation was unsuccessful -> get error code
	movea.l	_DOSBase,a6
	jsr	_LVOIoErr(a6)
	move.l	d0,_error_code

_quit_IoErr_poll:	
	move.l	(sp)+,d0
	rts

;
; OPEN mode,[#]filenumber,filespec - open a file. 
;				   - a0=mode string; d0=filenumber; 
;				     a1=filespec string.
;
_openfile:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_get_filehandle
	moveq	#0,d0
	rts

_get_filehandle:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	beq.s	_whichopenmode	; if file handle not used -> continue

	move.l	#BFN,_error_code

	rts

_whichopenmode:
	; determine open mode
	cmpi.b	#79,(a0)	; "O" ?
	beq.s	_openforoutput
	cmpi.b	#111,(a0)	; "o" ?
	beq.s	_openforoutput
	
	cmpi.b	#73,(a0)	; "I" ?
	beq.s	_openforinput
	cmpi.b	#105,(a0)	; "i" ?
	beq.s	_openforinput

 	cmpi.b	#82,(a0)	; "R" ?
	beq.s	_openforrandom
 	cmpi.b	#114,(a0)	; "r" ?
	beq.s	_openforrandom

 	cmpi.b	#65,(a0)	; "A" ?
	beq.s	_openforappend
 	cmpi.b	#97,(a0)	; "a" ?
	beq.s	_openforappend

	move.l	#BFM,_error_code

	rts

_openforoutput:
	move.l	_DOSBase,a6
	move.l	a1,d1			; filespec
	move.l	#MODE_NEWFILE,d2	; create a new file
	jsr	_LVOOpen(a6)
	move.l	d0,(a3)			; store file handle
	jsr	_IoErr_poll
	rts

_openforinput:
	move.l	_DOSBase,a6
	move.l	a1,d1			; filespec
	move.l	#MODE_OLDFILE,d2	; open an existing file
	jsr	_LVOOpen(a6)
	move.l	d0,(a3)			; store file handle
	jsr	_IoErr_poll
	rts

_openforrandom:
	move.l	_DOSBase,a6
	move.l	a1,d1			; filespec
	move.l	#MODE_READWRITE,d2	; create a new file
	jsr	_LVOOpen(a6)
	move.l	d0,(a3)			; store file handle
	jsr	_IoErr_poll
	rts

_openforappend:
	move.l	_DOSBase,a6

	move.l	a1,_filespec_ptr	; save filespec pointer

	move.l	a1,d1			; filespec
	move.l	#MODE_OLDFILE,d2	; Test whether file exists
	jsr	_LVOOpen(a6)
	move.l	d0,(a3)			; store file handle
	
	cmpi.l	#0,d0			; if handle = NULL then  
	bne.s	_seek_to_end_of_file	; open a new file first
					; else just seek to end 
					; of existing file + 1 byte.

	move.l	_filespec_ptr,d1	; filespec
	move.l	#MODE_NEWFILE,d2	; Create a new file	
	jsr	_LVOOpen(a6)
	move.l	d0,(a3)			; store file handle
	jsr	_IoErr_poll
	
	rts
	
_seek_to_end_of_file:
	; set file pointer to EOF
	move.l	d0,d1			; file handle
	move.l	#0,d2			; position=0 bytes from end
	move.l	#1,d3			; offset from end
	jsr	_LVOSeek(a6)
	jsr	_IoErr_poll

	rts
		
;
; CLOSE [#]filenumber[,[#]filenumber..] - close a file. d0=filenumber.
;
_closefile:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_closefile_gethandlestore
	moveq	#0,d0
	rts

_closefile_gethandlestore:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_close_the_file	; if file handle is used -> continue
	move.l	#BFN,_error_code
	rts

_close_the_file:
	movea.l	_DOSBase,a6
	move.l	(a3),d1		; file handle
	jsr	_LVOClose(a6)

	; zero the filehandle
	move.l	#0,(a3)

	rts

;
; write a short integer to a file. d0=filenumber. d1=short integer.
;
_writeshort:
	move.l	d0,_filenum	; save filenumber

	; convert short to a string
	move.w	d1,-(sp)
	pea	_shortfmt
	move.l	#_fstrbuf,-(sp)
	jsr	_sprintf
	add.l	#10,sp

	lea	_fstrbuf,a0
	move.l	_filenum,d0
	jsr	_writestring	; write to file

	rts

;
; write a long integer to a file. d0=filenumber; d1=long integer.
;
_writelong:
	move.l	d0,_filenum	; save filenumber

	; convert long to a string
	move.l	d1,-(sp)
	pea	_longfmt
	move.l	#_fstrbuf,-(sp)
	jsr	_sprintf
	add.l	#12,sp

	lea	_fstrbuf,a0
	move.l	_filenum,d0
	jsr	_writestring	; write to file

	rts

;
; write a single-precision value to a file. d0=filenumber; d1=FFP value.
;
_writesingle:
	move.l	d0,_filenum	; save filenumber

	; convert FFP to a string
	move.l	d1,-(sp)	; FFP value	
	jsr	_strsingle
	addq	#4,sp
	move.l	d0,a0		; fnumbuf string address		

	cmpi.b	#32,(a0)
	bne.s	_write_ffp_str
	adda.l	#1,a0		; if ffp string starts with space -> ignore it

_write_ffp_str:
	move.l	_filenum,d0	; d0=filenumber; a0=string
	jsr	_writestring	; write to file

	rts

;
; PRINT # - write a short integer to a file. d0=short integer; d1=filenumber. 
;
_fprintshort:
	; save filenumber.
	move.l	d1,_filenum
	
	; convert short to string +/- leading space.
	lea	_fstrbuf,a0
	jsr	_strshort	; a0=string.

	; write the string: d0=filenumber; a0=string.
	move.l	_filenum,d0	
	jsr	_writestring

	rts

;
; PRINT # - write a long integer to a file. d0=long integer; d1=filenumber. 
;
_fprintlong:
	; save filenumber.
	move.l	d1,_filenum
	
	; convert long to string +/- leading space.
	lea	_fstrbuf,a0
	jsr	_strlong	; a0=string.

	; write the string: d0=filenumber; a0=string.
	move.l	_filenum,d0	
	jsr	_writestring

	rts

;
; PRINT # - write a FFP value to a file. d0=FFP value; d1=filenumber. 
;
_fprintsingle:
	; save filenumber.
	move.l	d1,_filenum
	
	; convert FFP to string +/- leading space.
	move.l	d0,-(sp)
	jsr	_strsingle	; a0=string.
	addq	#4,sp
	move.l	d0,a0

	; write the string: d0=filenumber; a0=string.
	move.l	_filenum,d0	
	jsr	_writestring

	rts
		
;
; write a string to a file. d0=filenumber; a0=string.
;
_writestring:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_writestring_gethandlestore
	moveq	#0,d0		
	rts

_writestring_gethandlestore:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4	  	; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_write_the_string ; if file handle is used -> continue
	move.l	#BFN,_error_code
	rts

_write_the_string:
	move.l	_DOSBase,a6
	move.l	(a3),d1		; file handle
	move.l	a0,d2		; string address
	move.l	a0,a2
	jsr	_strlen
	cmpi.l	#0,d0
	bne.s	_do_writestring
	addq.l	#1,d0		; allow CHR$(0)!!! (some prgs use this)
_do_writestring:
	move.l	d0,d3		; length of string
	jsr	_LVOWrite(a6)
	jsr	_IoErr_poll
	
	rts

;
; write a comma to delimit items. d0=filenumber. 
;
_writecomma:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_writecomma_gethandlestore
	moveq	#0,d0
	rts

_writecomma_gethandlestore:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_write_the_comma ; if file handle is used -> continue
	move.l	#BFN,_error_code
	rts

_write_the_comma:
	move.l	_DOSBase,a6
	move.l	(a3),d1		; file handle
	move.l	#_comma,d2	; string address
	moveq	#1,d3		; length of string
	jsr	_LVOWrite(a6)
	jsr	_IoErr_poll
		
	rts

;
; write a quotation mark (") to a file to signal the start or end of a string. 
; d0=filenumber. 
;
_writequote:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_writequote_gethandlestore
	moveq	#0,d0
	rts

_writequote_gethandlestore:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_write_the_quote ; if file handle is used -> continue
	move.l	#BFN,_error_code
	rts

_write_the_quote:
	move.l	_DOSBase,a6
	move.l	(a3),d1		; file handle
	move.l	#_quote_mark,d2	; string address
	moveq	#1,d3		; length of string
	jsr	_LVOWrite(a6)
	jsr	_IoErr_poll
		
	rts

;
; write a LF to a file to signal eoln. d0=filenumber. 
;
_write_eoln:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_write_eoln_gethandlestore
	moveq	#0,d0
	rts

_write_eoln_gethandlestore:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		 ; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_write_the_eoln  ; if file handle is used -> continue
	move.l	#BFN,_error_code
	rts

_write_the_eoln:
	move.l	_DOSBase,a6
	move.l	(a3),d1		; file handle
	move.l	#_line_end,d2	; string address
	move.l	#1,d3		; length of string
	jsr	_LVOWrite(a6)
	jsr	_IoErr_poll
		
	rts

;
; write a space to a file. d0=filenumber. 
;
_writeSPC:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_writeSPC_gethandlestore
	moveq	#0,d0
	rts

_writeSPC_gethandlestore:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_write_the_SPC ; if file handle is used -> continue
	move.l	#BFN,_error_code
	rts

_write_the_SPC:
	move.l	_DOSBase,a6
	move.l	(a3),d1		; file handle
	move.l	#_space,d2	; string address
	moveq	#1,d3		; length of string
	jsr	_LVOWrite(a6)
	jsr	_IoErr_poll
		
	rts

;
; write a TAB to a file. d0=filenumber. 
;
_writeTAB:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_writeTAB_gethandlestore
	moveq	#0,d0
	rts

_writeTAB_gethandlestore:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_write_the_TAB ; if file handle is used -> continue
	move.l	#BFN,_error_code
	rts

_write_the_TAB:
	move.l	_DOSBase,a6
	move.l	(a3),d1		; file handle
	move.l	#_tab,d2	; string address
	moveq	#2,d3		; length of string
	jsr	_LVOWrite(a6)
	jsr	_IoErr_poll
		
	rts

;
; INPUT$(X,[#]filenumber) - input X characters from a file.
;			  - d1=X, d0=filenumber.
;
_inputstrfromfile:
	; get address of buffer.
	lea	_fileinpstring,a0	; this means a 32K limit!!!

	; ++d1 -> fgetchars() returns n-1 characters.
	addq	#1,d1

	; is X reasonable (ie: X > 0) ?
	; (X should have no upper limit since INPUT$ 
	;  may be used to read a whole file).
	cmpi.l	#0,d1
	bgt.s	_filenumcheck_inputstrfromfile	

	move.b	#0,(a0)
	rts				; X <= 0? -> return NULL string.

_filenumcheck_inputstrfromfile:
	; legal file number?
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_inputstrfromfile_get_handle

	move.b	#0,(a0)
	rts				; return NULL string.
 
_inputstrfromfile_get_handle:
	lsl.l	#2,d0			; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		 	; find start of long in list.
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_do_inputstrfromfile  	; if file handle is used -> continue.

	move.b	#0,(a0)
	move.l	#BFN,_error_code
	rts				; return NULL string.

_do_inputstrfromfile:
	; call fgetchars() -- (see fgets.c)
	move.l	(a3),-(sp)		; push the filehandle.
	move.l	d1,-(sp)		; push max_chars to read.
	move.l	a0,-(sp)		; push buffer address.
	jsr	_fgetchars		; returns X chars or NULL string.
	add.l	#12,sp
	jsr	_IoErr_poll

	move.l	#_fileinpstring,d0

	rts

;
; LINE INPUT #filenumber;string-variable - read a line from filenumber'th file. 
;					 - d0=filenumber, a0=string-variable.
;
_line_input:
	; legal file number?
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_line_input_get_handle

	move.b	#0,(a0)
	rts				; return NULL string.
 
_line_input_get_handle:
	lsl.l	#2,d0			; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		 	; find start of long in list.
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_do_line_input  	; if file handle is used -> continue.

	move.b	#0,(a0)
	move.l	#BFN,_error_code
	rts				; return NULL string.

_do_line_input:
	; call fgetline() -- (see fgets.c)
	move.l	(a3),-(sp)		; push the filehandle.
	move.l	#MAXSTRINGSIZE,-(sp)	; want to read MAXSTRINGSIZE-1 chars. 
	move.l	a0,-(sp)		; push buffer address.
	jsr	_fgetline		; returns line of chars or NULL string.
	add.l	#12,sp
	jsr	_IoErr_poll
	rts

;
; INPUT# - input a string from a file. d0=filenumber; a0=temporary string.
;
_finputstring:
	; store string address.
	move.l	a0,-(sp)

	; legal file number?
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_finputstring_get_handle

	move.b	#0,(a0)
	addq	#4,sp			; pop string address
	rts				; return NULL string.
 
_finputstring_get_handle:
	lsl.l	#2,d0			; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		 	; find start of long in list.
	move.l	d4,a3
	cmpi.l	#0,(a3)
	bne.s	_do_finputstring  	; if file handle is used -> continue.

	move.b	#0,(a0)
	addq	#4,sp			; pop string address

	move.l	#BFN,_error_code
	rts				; return NULL string.

_do_finputstring:
	move.l	(a3),-(sp)		; push file handle.
	move.l	#MAXSTRINGSIZE,-(sp)	; want to read MAXSTRINGSIZE-1 chars.
	move.l	a0,-(sp)		; push temp string address.
	jsr	_fgetseqfld		; returns sequential field in string.
	add.l	#12,sp			
	jsr	_IoErr_poll
	move.l	(sp)+,a0		; return string start address.

	rts	

;
; INPUT# - input a FFP value from a file. d0=filenumber; a0=temporary string.
;	  - FFP value returned in d0.
;
_finputsingle:
	jsr	_finputstring
	move.l	a0,-(sp)
	jsr	_val
	addq	#4,sp
	rts
	
;
; INPUT# - input a short integer from a file. d0=filenumber; a0=temp string.
;	  - short integer value returned in d0.
;
_finputshort:
	jsr	_finputstring
	move.l	a0,-(sp)
	jsr	_short_from_string
	addq	#4,sp
	rts

;
; INPUT# - input a long integer from a file. d0=filenumber; a0=temp string.
;	  - long integer value returned in d0.
;
_finputlong:
	jsr	_finputstring
	move.l	a0,-(sp)
	jsr	_long_from_string
	addq	#4,sp
	rts

;
; EOF(n) - d0=n=filenumber. returns -1 if EOF reached, and 0 if not (d0).
;
_eoftest:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_eof_get_handle
	rts			; return TRUE
	
_eof_get_handle:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a0
	move.l	d4,_eofhandle	; store file handle
	cmpi.l	#0,(a0)
	bne.s	_do_eof_test	; if file handle is used -> continue

	moveq	#-1,d0		; unused file number, so return TRUE
	move.l	#BFN,_error_code
	rts

_do_eof_test:
	move.l 	(a0),d1		; file handle
	move.l 	#1,d2		; seek 1 byte from...
	move.l	#0,d3		; current position
	move.l	_DOSBase,a6
	jsr	_LVOSeek(a6)

 	cmpi.l	#-1,d0		; -1 = seek error
	bne.s	_lastfileposn	
	
	rts			; return TRUE (EOF reached)

_lastfileposn:
	; return to pre-seek position
	move.l	_eofhandle,a0
	move.l 	(a0),d1		; file handle
	move.l 	#-1,d2		; seek -1 bytes from...
	move.l	#0,d3		; current position
	move.l	_DOSBase,a6
	jsr	_LVOSeek(a6)
	
	moveq	#0,d0		 		
	rts			; return FALSE

;
; LOF(n) - returns the length of an opened file in d0. n=d0=file number. 
;
_lof:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_lof_get_handle
	moveq	#0,d0
	rts			; return length of 0

_lof_get_handle:
	lsl.l	#2,d0		; filenumber x 4.			
	move.l	#_file_handle_list,d4
	add.l	d0,d4		; find start of long in list
	move.l	d4,a0
	cmpi.l	#0,(a0)
	bne.s	_get_lof	; if file handle is used -> continue
	moveq	#0,d0		; unused file number, so return length=0.
	move.l	#BFN,_error_code
	rts

_get_lof:
	move.l	(a0),_filehandle
	movea.l	_DOSBase,a6

	; seek 0 bytes from EOF
	; to get old position in file.
	move.l	_filehandle,d1
	moveq	#0,d2
	move.l	#OFFSET_END,d3
	jsr	_LVOSeek(a6)
	move.l	d0,_oldfilepos	; store file position before LOF(n) called.

	; seek 0 bytes from EOF again
	; because the first time the old 
	; position was returned. 
	move.l	_filehandle,d1
	moveq	#0,d2
	move.l	#OFFSET_END,d3
	jsr	_LVOSeek(a6)
	move.l	d0,_filesize	; store the file length.

	; now return to the position
	; in the file prior to the above
	; two seeks.
	move.l	_filehandle,d1
	move.l	_oldfilepos,d2
	move.l	#OFFSET_BEGINNING,d3
	jsr	_LVOSeek(a6)

	move.l	_filesize,d0	; return length of file in d0.

	rts
	
;
; HANDLE(n) - returns the file handle of the nth file number. d0=n.
;
_handle:
	jsr	_gencheckfilenum
	cmpi.l	#-1,d0
	bne.s	_retrieve_handle
	moveq	#0,d0
	rts			; return 0

_retrieve_handle:
	lsl.l	#2,d0		; filenumber x 4.		
	move.l	#_file_handle_list,d4
	add.l	d0,d4	 	; find start of long in list
	movea.l	d4,a0
	move.l	(a0),d0		; d0=filehandle

	rts

;
; Check for legal filenumber. 	Return -1 in d0 if not in range 0..254,
; 				otherwise just return filenumber.
;
_gencheckfilenum:
	subi.l	#1,d0		; 1..255 -> 0..254

	; check whether within bounds
	cmpi.l	#0,d0
	bge.s	_gencheckhifilenum
	moveq	#-1,d0		; return -1 for non-existent file.
	move.l	#BFN,_error_code
	rts			; filenumber < 0? -> exit

_gencheckhifilenum:
	cmpi.l	#254,d0
	ble.s	_exitgencheckfilenum
	moveq	#-1,d0		; return -1 for non-existent file.
	move.l	#BFN,_error_code

_exitgencheckfilenum:
	rts			

;
; KILL <filespec> - deletes file(s) or directory(ies).
;		  - d1 = filespec.
;
_kill:
	movea.l	_DOSBase,a6
	jsr	_LVODeleteFile(a6)
	jsr	_IoErr_poll
	rts

;
; NAME <filespec1> AS <filespec2> - renames a file or directory.
;				  - d1 = filespec1, d2 = filespec2.
;
_rename:
	movea.l	_DOSBase,a6
	jsr	_LVORename(a6)
	jsr	_IoErr_poll
	rts

;
; CHDIR <dirname> - changes current directory to <dirname>.
;		  - d1 = dirname.
;
_chdir:
	; get a read lock on dirname (d1)
	movea.l	_DOSBase,a6
	move.l	#ACCESS_READ,d2
	jsr	_LVOLock(a6)
	jsr	_IoErr_poll

	tst.l	d0
	beq.s	_quitchdir	; quit if requested lock is zero

	; change directory
	move.l	d0,d1		; pass lock in d1
	jsr	_LVOCurrentDir(a6)

	tst.l	d0
	beq.s	_quitchdir	; quit if old lock is zero

	; free old lock
	move.l	d0,d1
	jsr	_LVOUnLock(a6)

_quitchdir:		
	rts

	END

