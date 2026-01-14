;
; logic.s -- an ACE linked library object file: logic functions.
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
;	  5th,8th December 1992
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

	; logic functions
	xdef	_impw
	xdef	_impl
	xdef	_eqvw
	xdef	_eqvl

	SECTION logic_code,CODE

;*** LOGIC OPERATORS ***
   
;
; logical operator IMP: d0 = d1 imp d0
;
_impw:
   	not.w d1
      	or.w  d1,d0
        rts

_impl:
      	not.l d1
      	or.l  d1,d0
        rts

;
; logical operator EQV: d0 = d1 eqv d0
;
_eqvw:
        eor.w d1,d0
      not.w d0
      rts

_eqvl:
      eor.l d1,d0
      not.l d0
      rts

	END
