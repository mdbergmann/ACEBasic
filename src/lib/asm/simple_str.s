;
; simple_string.s -- an ACE linked library module: simple string functions.
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
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

   	; simple string functions
   	xdef  	_strcpy
   	xdef  	_strcat
   	xdef  	_strlen
	xdef	_strcmp
   	xdef  	_streq
   	xdef  	_strne
   	xdef  	_strgt
   	xdef  	_strlt
   	xdef  	_strge
   	xdef  	_strle
   	xdef  	_asc
   	xdef  	_chrstring

	SECTION string_code,CODE

;*** SIMPLE STRING FUNCTIONS ***

;
; copy a source string (a1) to destination string (a0)
;
_strcpy:
        cmp.b     #0,(a1)
        beq.s   _quitstrcpy  ; source EOS?
        move.b    (a1)+,(a0)+  ; copy from source to dest
        bra.s     _strcpy  
_quitstrcpy: 
        move.b (a1),(a0)    ; copy the EOS marker!
        rts

;
; concatenate two strings (source = a1, dest = a0)
;
_strcat:
_findeos:
        cmp.b     #0,(a0)+     ; found dest EOS?
        bne.s   _findeos
        subq      #1,a0        ; backup to EOS
_concat:
        cmp.b     #0,(a1)
        beq.s   _quitstrcat  ; source EOS?
        move.b    (a1)+,(a0)+  ; copy from source to dest
        bra.s   _concat
_quitstrcat: 
        move.b (a1),(a0)    ; copy the EOS marker!
        rts

;
; find the length of the string pointed to by a2. d0=length (LONG).
;
_strlen:
	moveq	#0,d0
_strlenloop:
	cmpi.b	#0,(a2)+	
	beq.s	_strlenexit
	addq	#1,d0
	bra.s	_strlenloop
_strlenexit:
	rts
	
;
; - lexicographical comparison of two strings. a0=str1; a1=str2.
; - returns a value in d0 of (a0)-(a1) where (a0)<>(a1) or 0 if EOS reached.
;   (See "Amiga C for Beginners", pp 154,155, Abacus books)
;
_strcmp:
	move.b	(a0),d0
	move.b	(a1),d1
	cmp.b	d0,d1
	bne.s	_strcmpne	; (a0)<>(a1)

	cmpi.b	#0,(a0)		; EOS?
	beq.s	_strcmpeq
	
	addq	#1,a0		; a0++
	addq	#1,a1		; a1++
	
	bra.s	_strcmp

_strcmpeq:
	move.b	#0,d0		; (a0)=(a1)
	rts	
	
_strcmpne:
	move.b	(a0),d0
	sub.b	(a1),d0		; d0=(a0)-(a1)
	rts

;
; test for string equivalence [str1 = str2]. a0=str1; a1=str2.
;
_streq:
	jsr	_strcmp
	cmp.b	#0,d0
	beq.s	_streqT

	moveq	#0,d0		; str1<>str2
	rts

_streqT:
	moveq	#-1,d0		; str1=str2
	rts
		
;
; tests for string inequality. a0=str1; a1=str2.
; d0 contains boolean result.
;
_strne:
	jsr	_strcmp
	cmp.b	#0,d0
	bne.s	_strneT

	moveq	#0,d0		; str1=str2
	rts

_strneT:
	moveq	#-1,d0		; str1<>str2
	rts

;
; tests for str1 > str2. a0=str1; a1=str2.
; d0 contains boolean result.
;
_strgt:
	jsr	_strcmp
	cmp.b	#0,d0
	bgt.s	_strgtT

	moveq	#0,d0		; str1<=str2
	rts

_strgtT:
	moveq	#-1,d0		; str1>str2
	rts
	
;
; tests for str1 < str2. a0=str1; a1=str2.
; d0 contains boolean result.
;
_strlt:
	jsr	_strcmp
	cmp.b	#0,d0
	blt.s	_strltT

	moveq	#0,d0		; str1>=str2
	rts

_strltT:
	moveq	#-1,d0		; str1<str2
	rts

;
; tests for str1 >= str2. a0=str1; a1=str2.
; d0 contains boolean result.
;
_strge:
	jsr	_strcmp
	cmp.b	#0,d0
	bge.s	_strgeT

	moveq	#0,d0		; str1<str2
	rts

_strgeT:
	moveq	#-1,d0		; str1>=str2
	rts

;
; tests for str1 <= str2. a0=str1; a1=str2.
; d0 contains boolean result.
;
_strle:
	jsr	_strcmp
	cmp.b	#0,d0
	ble.s	_strleT

	moveq	#0,d0		; str1>str2
	rts

_strleT:
	moveq	#-1,d0		; str1<=str2
	rts

;
; CHR$ function. Assumes ASCII value in d0 and target string address in a0.
;
_chrstring:
   	move.b d0,(a0)+
   	move.b #0,(a0)
   	rts

;
; returns the ASCII value (in d0) of the first character pointed to by a2.
; (returns SHORT) 
;
_asc:
	move.b	(a2),d0
	ext.w	d0
   	cmpi.w	#0,d0
	bge.s	_exit_asc
	add.w	#256,d0		; make positive if necessary
_exit_asc:		
	rts

	END
