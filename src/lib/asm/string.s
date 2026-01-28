;
; string.s -- an ACE linked library module: string functions.
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
;	  5th,13th,29th,30th December 1992,
;	  6th,12th January 1993,
;	  7th,14th,16th,18th February 1993,
;	  1st,14th March 1993,
;	  9th,25th,30th May 1993,
;	  6th,29th June 1993,
;	  9th,11th October 1993,
;	  19th March 1994,
;	  12th,25th July 1994
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; misc. defines
MAXSTRINGSIZE 	equ 1024
VANILLAKEY    	equ $00200000
UserPort     	equ 86

Class		equ 0		; member in IntuiInfo structure
Code		equ 4		; member in IntuiInfo structure
				; (see intuievent.h)
pr_CLI		equ 172
cli_CommandName	equ 16

   	; string functions
	xdef	_htol
   	xdef  	_leftstr
   	xdef  	_rightstr
   	xdef  	_midstr
	xdef	_ucase
	xdef	_inputstring
	xdef	_hexstrlong
	xdef	_hexstrshort
	xdef	_octstr
	xdef	_binstr
	xdef	_strlong
	xdef	_strshort
	xdef	_inkey
	xdef	_spacestring
	xdef	_spc
	xdef	_stringstr
	xdef	_instr

   	; external references 
	xref	_strlen
	xref	_strcpy
	xref	_streq

	xref	_shortfmt
	xref	_longfmt
	xref	_shorthexfmt
	xref	_longhexfmt
	xref	_zerostr
	xref	_colonstr

	xref	_tmpstring
	xref	_deststraddr
	xref	_count
	xref	_ucasestring
	xref	_spacestraddress
	xref	_stringstraddress
	xref	_octdigit
	xref	_bindigit
	xref	_inkeybuf
	xref	_rawinpbuf
	xref	_rawinpaddr
	xref	_instrposn
	xref	_search_offset
	xref	_targetch
	xref	_x_string
	xref	_y_string
	xref	_x_strlen
	xref	_y_strlen

   	xref  	_putchar
	xref	_sprintf
	xref	_strval
  	xref  	_LVOSPFlt
	xref	_LVOSPAdd
   	xref  	_LVOSPDiv
   	xref  	_LVOSPTst
	xref	_LVOSPNeg
   	xref  	_LVOWrite
	xref	_LVORead
	xref	_LVOWaitForChar
	xref	_LVOExamine
	xref	_LVOUnLock
  	xref  	_DOSBase	
   	xref  	_MathBase
   	xref  	_stdout
	xref	_stdin
	xref	_turncursoron
	xref	_turncursoroff
        xref 	_AbsExecBase
	xref	_LVOFindTask
	xref	_Wdw
	xref	_Wdw_id
	xref	_IntuiMode
	xref	_GetIntuiEvent
	xref	_ClearIntuiEvent

	SECTION string_code,CODE

;*** STRING FUNCTIONS ***

;
; _htol - returns a LONG value in d0 from a HEX string pointed to by a1.
; _htol assumes that all digits are legal (1..9, a..f) and lowercase. 
;
_htol:
	moveq	#0,d0
_htoloop:
	cmpi.b	#0,(a1)
	beq.s	_quithtol		; EOS?

	cmpi.b	#57,(a1)		
	ble.s	_decdigit		; <= 9 ?

	; <= F -> hex digit
	move.b	(a1)+,d1		; hex digit
	ext.w	d1
	ext.l	d1
	sub.l	#87,d1
	lsl.l	#4,d0			
	add.l	d1,d0
	
	bra.s	_htoloop
	
_decdigit:
	move.b	(a1)+,d1		; decimal digit
	ext.w	d1
	ext.l	d1
	sub.l	#48,d1
	lsl.l	#4,d0			
	add.l	d1,d0
	
	bra.s	_htoloop
_quithtol:	
	rts

;
; LEFT$ function. expects string address in a0, sub-string address in a1
; and index in d0 (SHORT).
; returns address of sub-string in a0.
;
_leftstr:
	move.l	a1,a3		; save address of target sub-string
_leftstrloop:
	cmpi.w	#0,d0		; transferred n bytes?
	ble.s	_leftstrquit	
	cmpi.b	#0,(a0)		; EOS?
	beq.s	_leftstrquit
	move.b	(a0)+,(a1)+	; copy a byte
	subq	#1,d0
	bra.s	_leftstrloop
_leftstrquit:
	move.b	#0,(a1)
	move.l	a3,a0		; return address of sub-string
	rts

;
; RIGHT$ function. expects string address in a0, sub-string address in a1 
; and index in d0 (SHORT).
; returns address of sub-string in a0.
;	
_rightstr:
	move.l	a1,a3	        ; get address of target sub-string
	move.w	d0,d1		; save length of sub-string
    	cmpi.w	#0,d0
	ble.s	_rightstrquit	; return NULL string if requested length <= 0
	move.l	a0,a2
	jsr	_strlen		; d0 = length of string pointed to by a2
	ext.l	d1		
	sub.l	d1,d0		; starting position = strlen-index
	cmpi.l	#0,d0		
	bgt.s	_rightstrpoint  ; index < strlen(string) -> okay
	moveq	#0,d0		; index >= strlen(string) so return whole string
_rightstrpoint:
	add.l	d0,a0		; point to it
_rightstrloop:
	cmpi.b	#0,(a0)		; EOS?
	beq.s	_rightstrquit
	move.b	(a0)+,(a1)+	; copy a byte
	subq	#1,d0
	bra.s	_rightstrloop
_rightstrquit:
	move.b	#0,(a1)
	move.l	a3,a0		; address of sub-string
	rts

;
; MID$ function. Expects string address in a0, sub-string address in a1,
; start posn in d0 and length of sub-string in d1 (both SHORT).
; returns address of sub-string in a0.
;
; MID$(X$,n[,m]) -> a0=X$,d0=n,d1=m
;	
_midstr:
	move.l	a1,a3		; save address of target sub-string
	move.w	d0,d2		; save start position (n)
	move.l	a0,a2
	jsr	_strlen		; d0 = length of string pointed to by a2
	cmpi.w	#-1,d1		
	bne.s	_midstr1
	move.w	d0,d1		; if m is -1 -> take FULL length of string 
_midstr1:
	ext.l	d2
	cmp.l	d0,d2		
	bgt.s	_midstrquit	; n > strlen(string)? -> quit
	cmpi.w	#0,d1
	bge.s	_midstrpoint	; negative? -> make zero
	moveq	#0,d1
_midstrpoint:
	add.l	d2,a0		; start at nth character
	subq	#1,a0		
_midstrloop:
	cmpi.w	#0,d1		
	beq.s	_midstrquit	; m characters copied?
	cmpi.b	#0,(a0)		
	beq.s	_midstrquit	; EOS?
	move.b	(a0)+,(a1)+	; copy a byte
	subq	#1,d1
	bra.s	_midstrloop
_midstrquit:
	move.b	#0,(a1)
	move.l	a3,a0		; return sub-string address
	rts
	
;
; UCASE$ - Convert lower case characters in string (a1) to upper case. 
;        - Destination string in a0.
;
_ucase:
	; store destination address
 	move.l	a0,_ucasestring

	; make a copy
	jsr	_strcpy

	; main loop
	movea.l	_ucasestring,a1
_ucaseloop:
	cmpi.b	#0,(a1)	
	beq.s	_ucaseexit	; EOS?
	cmpi.b  #97,(a1)	
	blt.s	_nextchar	; (a0) < 'a'?
	cmpi.b	#122,(a1)	
	bgt.s	_nextchar	; (a0) > 'z'?
	sub.b	#32,(a1)	; 'a'..'z' -> make 'A'..'Z'
_nextchar:
	addq	#1,a1
	bra.s	_ucaseloop
_ucaseexit:
	movea.l	_ucasestring,a0
	rts

;
; get a string from _stdin and return it's address in a0.
; expects target string address in a1. 
;
_inputstring:
        move.l  a1,a3		; save input string address

	jsr	_turncursoron

	; get the string
	cmpi.w	#0,_Wdw_id
	beq.s	_inputconstring	; if Wdw-id = 0 then window is CON: 
	jsr	_inputrawstring	; if Wdw-id <> 0 then window is RAW:
	bra.s	_exitinputstring

_inputconstring:
	move.l	_DOSBase,a6	
	move.l	_stdin,d1
	move.l	a3,d2		; get start address of input string	
	move.l	#MAXSTRINGSIZE-1,d3; allow the max string size. d0=actual.
	jsr	_LVORead(a6)
	move.l	a3,a0
	subq	#1,d0
	clr.b	0(a0,d0)	; append EOS character	

_exitinputstring:
	jsr	_turncursoroff

	move.l	a3,a0		; restore start address of input string 

	rts

;
; INPUT a string from a RAW: window. a3 points to input string.
; Destructive backspace (ASCII 8) is handled as expected, while
; all other characters are passed into the final string.
;
_inputrawstring:
	move.l	a3,_rawinpaddr	; save the address

_waitforinput:
	move.l	_DOSBase,a6
	move.l	_stdin,d1
	moveq	#1,d2
	jsr	_LVOWaitForChar(a6)
	cmpi.w	#0,d0
	beq.s	_waitforinput	

	; get pending character
	move.l	_DOSBase,a6
	move.l	_stdin,d1
	move.l	#_rawinpbuf,d2	  	; address of buffer	
	moveq	#1,d3			
	jsr	_LVORead(a6)		; read 1 character		

	; is it a destructive backspace? 
	cmpi.b	#8,_rawinpbuf
	bne.s	_displayrawchar		; no -> just display it	

	; BS: are we back at the start of the line?
	cmpa.l	_rawinpaddr,a3
	beq.s	_waitforinput		; yes -> can't delete any more!

_displayrawchar:
	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.l	#_rawinpbuf,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)		; display character

	; is it a destructive backspace? 
	cmpi.b	#8,_rawinpbuf
	bne.s	_addchartostring	; not BS, so keep it

	; delete last character
	suba.l	#1,a3			; otherwise, move back one character

	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.b	#32,_rawinpbuf
	move.l	#_rawinpbuf,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)		; write a space over last character
	
	move.l	_DOSBase,a6
	move.l	_stdout,d1
	move.b	#8,_rawinpbuf		
	move.l	#_rawinpbuf,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)		; move back to "wiped-out" character

	bra	_waitforinput		; then wait for next character

_addchartostring:
	; add to string
	cmpi.b	#13,_rawinpbuf		; carriage return? -> EOS
	beq.s	_exitrawinput

	move.b	_rawinpbuf,(a3)+	; add character to string

	bra	_waitforinput		; wait for next character
	
_exitrawinput:
	move.b	#0,(a3)
	move.l	_rawinpaddr,a3		; address of string

	move.l	#10,-(sp)
	jsr	_putchar		; Line Feed
	addq	#4,sp

	rts

;
; HEX$ - returns hexadecimal string form (a0) of short decimal value (d0).
;
_hexstrshort:
	move.l  a0,a3		; save destination string address
	move.w	d0,-(sp)	; push short value
	pea	_shorthexfmt	; push format string
	move.l	a0,-(sp)	; push destination string
	jsr	_sprintf
	add.l	#10,sp
	move.l	a3,a0		; restore destination string address
	rts
;
; HEX$ - returns hexadecimal string form (a0) of long decimal value (d0).
;
_hexstrlong:
	move.l  a0,a3		; save destination string address
	move.l	d0,-(sp)	; push long value
	pea	_longhexfmt	; push format string
	move.l	a0,-(sp)	; push destination string
	jsr	_sprintf
	add.l	#12,sp
	move.l	a3,a0		; restore destination string address
	rts
;
; OCT$ - returns octal string form (a0) of long decimal value (d0).
;
_octstr:
	move.l	a0,a3		; save address of dest string

	; if zero, make a string with 1 digit: "0"
	cmpi.l	#0,d0
	bne.s	_octnotzero
	move.b	#48,(a0)+	; string[0]='0'
	move.b	#0,(a0)		; EOS
	movea.l	a3,a0
	rts

_octnotzero:
	move.w	#0,d2		; cc=0
	lea	_octdigit,a0

_octloop:
	cmpi.l	#0,d0
	beq.s	_reversedigits	; until num == 0
	
	; get remainder
	move.l	d0,d1		; num
	move.l	d0,d3		
	lsr.l	#3,d3		; num\8
	lsl.l	#3,d3		; quotient*8
	sub.l	d3,d1		; r=num-(quotient*8) = num % 8
		
	add.l	#48,d1		; ASCII = 48 + d1
	and.b	#$ff,d1		
	move.b	d1,(a0)+	; x[cc]=r
	addi.w	#1,d2		; cc++ (keep count of characters)

	lsr.l	#3,d0		; num \= 8
	
	bra.s	_octloop

_reversedigits:
	move.l	a3,a1		; string address

_makeoctstring:
	cmpi.w	#0,d2
	ble.s	_stripoctzeros	; while cc > 0

	subi.w	#1,d2		; --cc
	move.b	-(a0),(a1)+	; string[cc] = x[cc]

	bra.s	_makeoctstring

_stripoctzeros:
	move.b	#0,(a1)		; EOS
	move.l	a3,a1		; start of string 

_octstriploop:
	; strip leading zeros
	cmpi.b	#0,(a1)
	beq.s	_exitoctstr	; exit if EOS (null string?)

	cmpi.b	#48,(a1)
	bgt.s	_exitoctstr	; digit > 0? -> exit	

	adda.l	#1,a1

	bra.s	_octstriploop
		
_exitoctstr:		
	move.l	a1,a0		; return destination string address
	rts

;
; STR$ - returns string form (a0) of short decimal value (d0). 
;
_strshort:
	move.l  a0,a3		; save destination string address
	cmpi.w  #0,d0		
	blt.s	_strshortdo	; is value >= 0? 
	move.b	#32,(a0)+	; yes -> leading space
_strshortdo: 
	move.w	d0,-(sp)	; push short value
	pea	_shortfmt	; push format string
	move.l	a0,-(sp)	; push destination string
	jsr	_sprintf
	add.l	#10,sp
	move.l	a3,a0		; restore destination string address
	rts

;
; STR$ - returns string form (a0) of long decimal value (d0). 
;
_strlong:
	move.l  a0,a3		; save destination string address
	move.l  a0,a3		; save destination string address
	cmpi.l  #0,d0		
	blt.s	_strlongdo	; is value >= 0? 
	move.b	#32,(a0)+	; yes -> leading space
_strlongdo: 
	move.l	d0,-(sp)	; push long value
	pea	_longfmt	; push format string
	move.l	a0,-(sp)	; push destination string
	jsr	_sprintf
	add.l	#12,sp
	move.l	a3,a0		; restore destination string address
	rts

;
; INKEY$ - returns a single character string (address in d0) from stdin if 
;	   a character is pending or the NULL string if not. If IntuiMode
;	   is 1, the Window's IDCMP port is checked for a VANILLAKEY event.
;
_inkey:
	cmpi.b	#0,_IntuiMode
	beq	_stdinkey

	; check for Intuition event
	movea.l	_Wdw,a0
	move.l	UserPort(a0),-(sp) ; get window's UserPort (Wdw->UserPort)
	jsr	_GetIntuiEvent
	addq	#4,sp

	tst.l	d0
	bne.s	_checkforkey	; an event took place!
	bra.s	_quitintuiinkey ; no event took place

_checkforkey:
	movea.l	d0,a0		; pointer to IntuiInfo structure
			
	move.l	Class(a0),d1	; Message->Class
	andi.l	#VANILLAKEY,d1
	cmpi.l	#VANILLAKEY,d1
	beq.s	_getvanillakey

	; no vanilla key event -> quit
	bra.s	_quitintuiinkey 

_getvanillakey:
	; there's a vanilla key event
	move.w	Code(a0),d1	; Message->Code
	andi.b	#$ff,d1

	; construct string
	movea.l	#_inkeybuf,a0
	move.b	d1,(a0)+
	move.b	#0,(a0)

	; reply to message
	jsr	_ClearIntuiEvent

	; return address of string
	move.l	#_inkeybuf,d0	
	
	rts
	
_quitintuiinkey:
	; no event or no vanilla key -> return NULL string
	movea.l	#_inkeybuf,a0
	move.b	#0,(a0)

	move.l	#_inkeybuf,d0	; return address of string

	rts
						
_stdinkey:	
	move.l	_DOSBase,a6

	; check for pending character(s)
	move.l	_stdin,d1
	moveq	#1,d2			; wait 1 microsecond
	jsr	_LVOWaitForChar(a6)
	cmpi.w	#0,d0
	bne.s	_readinkey

	move.l	#_inkeybuf,a0		
	move.b	#0,(a0)			; NULL string

	move.l	#_inkeybuf,d0		; return address of string
	
	rts

_readinkey:
	; read one character
	move.l	_stdin,d1
	move.l	#_inkeybuf,d2
	moveq	#1,d3
	jsr	_LVORead(a6)
		
	move.l	#_inkeybuf,a0		
	addq	#1,a0
	move.b	#0,(a0)			; EOS

	move.l	#_inkeybuf,d0		; return address of string

	rts

;
; SPACE$(n) - returns the address of a string (in d0) with n spaces. d0=n.
;	    - destination string address in a0.
;
_spacestring:
	move.l	a0,_spacestraddress

	cmpi.w	#0,d0
	ble.s	_quitspacestring	; n <= 0 -> quit

	cmpi.w	#MAXSTRINGSIZE,d0
	blt.s	_buildspacestring
	move.w	#MAXSTRINGSIZE-1,d0	; n >= MAXSTRINGSIZE -> clip

_buildspacestring:
	move.b	#32,(a0)+
	subq.w	#1,d0
	cmpi.w	#0,d0
	bgt.s	_buildspacestring
		
_quitspacestring:
	move.b	#0,(a0)
	move.l	_spacestraddress,d0

	rts

;
; SPC(n) - returns the address of a string (in d0) with n spaces. d0=n.
;	 - destination string address in a0.
;
_spc:
	move.l	a0,_spacestraddress

	cmpi.w	#0,d0
	ble.s	_quitspcstring		; n <= 0 -> quit

	cmpi.w	#255,d0
	blt.s	_buildspcstring
	move.w	#255,d0			; n >= MAXSTRINGSIZE -> clip

_buildspcstring:
	move.b	#32,(a0)+
	subq.w	#1,d0
	cmpi.w	#0,d0
	bgt.s	_buildspcstring
		
_quitspcstring:
	move.b	#0,(a0)
	move.l	_spacestraddress,d0

	rts

;
; STRING$(n,m) - returns the address of a string (in d0) with n characters
;		 of ASCII value m. d0=n, d1=m.
;	       - destination string address in a0.
;
_stringstr:
	move.l	a0,_stringstraddress

	cmpi.w	#0,d0
	ble.s	_quitstringstr		; n <= 0 -> quit

	cmpi.w	#MAXSTRINGSIZE,d0
	blt.s	_buildstringstr
	move.w	#MAXSTRINGSIZE-1,d0	; n >= MAXSTRINGSIZE -> clip

_buildstringstr:
	move.b	d1,(a0)+
	subq.w	#1,d0
	cmpi.w	#0,d0
	bgt.s	_buildstringstr
		
_quitstringstr:
	move.b	#0,(a0)
	move.l	_stringstraddress,d0

	rts

;
; INSTR([I,],X$,Y$) - returns the first occurrence of Y$ in X$.
;		    - the search starts from MID$(X$,I,1).
;		    - if I is not specified, it takes on a value of 1.
;		    - the result is returned in d0. 
;		    - d0=I, a0=X$, a1=Y$.
;
_instr:
	; result in case of error
	move.l	#0,_instrposn

	; store the parameters
	move.l	d0,_search_offset	; I
	move.l	a0,_x_string		; X$
	move.l	a1,_y_string		; Y$
	move.b	(a1),_targetch		; first character of Y$

	; is I < 1 ?
	cmpi.l	#1,_search_offset
	blt	_quitinstr		; I <= 0 -> result=0

	; find length of X$
	movea.l	_x_string,a2
	jsr	_strlen
	move.l	d0,_x_strlen

	; is X$="" ? 
	cmpi.l	#0,d0
	beq	_quitinstr		; X$="" -> result=0

	; is I > len(X$) ?
	move.l	_search_offset,d1
	cmp.l	d0,d1
	bgt	_quitinstr		; I > LEN(X$) -> result=0

	; find length of Y$
	movea.l	_y_string,a2
	jsr	_strlen
	move.l	d0,_y_strlen

	; is len(Y$) > len(X$) ?
	move.l	_x_strlen,d0
	move.l	_y_strlen,d1
	cmp.l	d0,d1
	bgt	_quitinstr		; len(Y$) > len(X$) -> result=0
	
	; is Y$="" ?
	cmpi.l	#0,_y_strlen
	bne.s	_search_x_for_y		

	move.l	_search_offset,_instrposn
	bra.s	_quitinstr		; Y$="" -> result=I	

_search_x_for_y:
      	; compare first character only
	movea.l	_x_string,a0		; A=address of first character in X$
	adda.l	_search_offset,a0	; A=A+I	
	suba.l	#1,a0			; A=A+I-1 (adjust to start at 0th byte)
	move.b	(a0),d0
	move.b	_targetch,d1		; get first character from Y$
	cmp.b	d0,d1
	beq.s	_check_whole_string	; first characters match
	bra.s	_inc_search_offset	; try next character

_check_whole_string:		
	; get MID$(X$,I,len(Y$))
	movea.l	_x_string,a0	
	lea	_tmpstring,a1
	move.l	_search_offset,d0
	move.l	_y_strlen,d1
	jsr	_midstr			; a0 = MID$(X$,I,len(Y$)) -> _streq

	; is MID$(X$,I,len(Y$)) = Y$ ?
	movea.l	_y_string,a1
	jsr	_streq
	cmpi.l	#0,d0
	beq.s	_inc_search_offset	; MID$(X$,I,len(Y$)) <> Y$ -> ++I
	
	; found it!
	move.l	_search_offset,_instrposn
	bra.s	_quitinstr
	
_inc_search_offset:
	add.l	#1,_search_offset
	move.l	_x_strlen,d0
	move.l	_search_offset,d1
	cmp.l	d0,d1
	ble.s	_search_x_for_y		
		
_quitinstr:
	move.l	_instrposn,d0
		
	rts

;
; BIN$ - returns binary string form (a0) of long decimal value (d0).
;
_binstr:
 	move.l 	a0,a3  		; save address of dest string

	; if zero, make a string with 1 digit: "0"
	cmpi.l 	#0,d0
	bne.s 	_binnotzero
	move.b 	#48,(a0)+ 	; string[0]='0'
	move.b	#0,(a0)		; EOS
	movea.l	a3,a0
	rts

_binnotzero:
 	move.w 	#0,d2  		; cc=0
 	lea 	_bindigit,a0

_binloop:
 	cmpi.l 	#0,d0
 	beq.s 	_revdigits 	; until num == 0
 
 	; get remainder
 	move.l 	d0,d1  		; num
 	move.l 	d0,d3  
 	lsr.l 	#1,d3  		; num\2
 	lsl.l 	#1,d3  		; quotient*2
 	sub.l 	d3,d1  		; r=num-(quotient*2) = num % 2
  
 	add.l 	#48,d1 		; ASCII = 48 + d1
 	and.b 	#$ff,d1  
 	move.b 	d1,(a0)+ 	; x[cc]=r
 	addi.w 	#1,d2  		; cc++ (keep count of characters)

 	lsr.l 	#1,d0  		; num \= 2
 
 	bra.s 	_binloop

_revdigits:
 	move.l 	a3,a1  ; string address

_makebinstring:
 	cmpi.w 	#0,d2
 	ble.s 	_stripbinzeros 	; while cc > 0

 	subi.w 	#1,d2  ; --cc
 	move.b 	-(a0),(a1)+ 	; string[cc] = x[cc]

 	bra.s 	_makebinstring
	
_stripbinzeros:
 	move.b 	#0,(a1)  	; EOS
 	move.l 	a3,a1  		; start of string 
	
_binstriploop:
 	; strip leading zeros
 	cmpi.b 	#0,(a1)
 	beq.s 	_exitbinstr 	; exit if EOS (null string?)

 	cmpi.b 	#48,(a1)
 	bgt.s 	_exitbinstr 	; digit > 0? -> exit 

 	adda.l 	#1,a1

 	bra.s 	_binstriploop
  
_exitbinstr:  
 	move.l 	a1,a0  		; return destination string address
	rts

	END
