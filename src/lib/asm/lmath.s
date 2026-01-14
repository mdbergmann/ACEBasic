* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
*
* Permission is granted to anyone to use this software for any purpose
* on any computer system, and to redistribute it freely, with the
* following restrictions:
* 1) No charge may be made other than reasonable charges for reproduction.
* 2) Modified versions must be clearly marked as such.
* 3) The authors are not responsible for any harmful consequences
*    of using this software, even if they result from defects in it.
**************************************************************************
;
; MODIFIED FOR USE WITH THE ACE BASIC COMPILER
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
; This code is used for the ACE Amiga BASIC compiler, with thanks to Sozobon.
;
; Minor modifications were necessary to accomodate the fact that ACE pushes
; operands for long division, multiplication and modulo arithmetic in reverse
; order to C. ace_ldiv and ace_lrem were later added (July 1994) to isolate
; this bletcherosity to ACE's "\" and "MOD" operators. ldiv[u] and lrem[u] 
; were then returned to their original state so as to be compatible with C 
; code linked to ACE programs (previously, operands had to be reversed in 
; such C code!). To avoid confusion, lmul and lmulu were also returned to
; their original state.
;
; Modified by: David J Benn
; 	 Date: 21st,22nd December 1992,
;	       1st March 1993,
;	       29th July 1994
;

	SECTION lmath_CODE

	PUBLIC	ace_ldiv
ace_ldiv:
	move.l	8(a7),d0
	bpl	ace_ld1
	neg.l	d0
ace_ld1:
	move.l	4(a7),d1
	bpl	ace_ld2
	neg.l	d1
	eor.b	#$80,8(a7)
ace_ld2:
	jsr	i_ldiv		/* d0 = d0/d1 */
	tst.b	8(a7)
	bpl	ace_ld3
	neg.l	d0
ace_ld3:
	rts

	PUBLIC	ldiv
ldiv:
	move.l	4(a7),d0
	bpl	ld1
	neg.l	d0
ld1:
	move.l	8(a7),d1
	bpl	ld2
	neg.l	d1
	eor.b	#$80,4(a7)
ld2:
	jsr	i_ldiv		/* d0 = d0/d1 */
	tst.b	4(a7)
	bpl	ld3
	neg.l	d0
ld3:
	rts

	PUBLIC	lmul
lmul:
	move.l	4(a7),d0
	bpl	lm1
	neg.l	d0
lm1:
	move.l	8(a7),d1
	bpl	lm2
	neg.l	d1
	eor.b	#$80,4(a7)
lm2:
	jsr	i_lmul		/* d0 = d0*d1 */
	tst.b	4(a7)
	bpl	lm3
	neg.l	d0
lm3:
	rts

	PUBLIC	ace_lrem
ace_lrem:
	move.l	8(a7),d0
	bpl	ace_lr1
	neg.l	d0
ace_lr1:
	move.l	4(a7),d1
	bpl	ace_lr2
	neg.l	d1
ace_lr2:
	jsr	i_ldiv		/* d1 = d0%d1 */
	move.l	d1,d0
	tst.b	8(a7)
	bpl	ace_lr3
	neg.l	d0
ace_lr3:
	rts

	PUBLIC	lrem
lrem:
	move.l	4(a7),d0
	bpl	lr1
	neg.l	d0
lr1:
	move.l	8(a7),d1
	bpl	lr2
	neg.l	d1
lr2:
	jsr	i_ldiv		/* d1 = d0%d1 */
	move.l	d1,d0
	tst.b	4(a7)
	bpl	lr3
	neg.l	d0
lr3:
	rts

	PUBLIC	ldivu
ldivu:
	move.l	4(a7),d0
	move.l	8(a7),d1
	jsr	i_ldiv
	rts

	PUBLIC	lmulu
lmulu:
	move.l	4(a7),d0
	move.l	8(a7),d1
	jsr	i_lmul
	rts

	PUBLIC	lremu
lremu:
	move.l	4(a7),d0
	move.l	8(a7),d1
	jsr	i_ldiv
	move.l	d1,d0
	rts

* A in d0, B in d1, return A*B in d0
i_lmul:
	move.l	d3,a2		/* save d3 */
	move.w	d1,d2
	mulu	d0,d2		/* d2 = Al * Bl */

	move.l	d1,d3
	swap	d3
	mulu	d0,d3		/* d3 = Al * Bh */

	swap	d0
	mulu	d1,d0		/* d0 = Ah * Bl */

	add.l	d3,d0		/* d0 = (Ah*Bl + Al*Bh) */
	swap	d0
	clr.w	d0		/* d0 = (Ah*Bl + Al*Bh) << 16 */

	add.l	d2,d0		/* d0 = A*B */
	move.l	a2,d3		/* restore d3 */
	rts

*A in d0, B in d1, return A/B in d0, A%B in d1
i_ldiv:
	tst.l	d1
	bne	nz1

*	divide by zero
	divu	#0,d0		/* cause trap */
	move.l	#$80000000,d0
	move.l	d0,d1
	rts
nz1:
	move.l	d3,a2		/* save d3 */
	cmp.l	d1,d0
	bhi	norm
	beq	is1
*	A<B, so ret 0, rem A
	move.l	d0,d1
	clr.l	d0
	move.l	a2,d3		/* restore d3 */
	rts
*	A==B, so ret 1, rem 0
is1:
	moveq.l	#1,d0
	clr.l	d1
	move.l	a2,d3		/* restore d3 */
	rts
*	A>B and B is not 0
norm:
	cmp.l	#1,d1
	bne	not1
*	B==1, so ret A, rem 0
	clr.l	d1
	move.l	a2,d3		/* restore d3 */
	rts
*  check for A short (implies B short also)
not1:
	cmp.l	#$ffff,d0
	bhi	slow
*  A short and B short -- use 'divu'
	divu	d1,d0		/* d0 = REM:ANS */
	swap	d0		/* d0 = ANS:REM */
	clr.l	d1
	move.w	d0,d1		/* d1 = REM */
	clr.w	d0
	swap	d0
	move.l	a2,d3		/* restore d3 */
	rts
* check for B short
slow:
	cmp.l	#$ffff,d1
	bhi	slower
* A long and B short -- use special stuff from gnu
	move.l	d0,d2
	clr.w	d2
	swap	d2
	divu	d1,d2		/* d2 = REM:ANS of Ahi/B */
	clr.l	d3
	move.w	d2,d3		/* d3 = Ahi/B */
	swap	d3

	move.w	d0,d2		/* d2 = REM << 16 + Alo */
	divu	d1,d2		/* d2 = REM:ANS of stuff/B */

	move.l	d2,d1
	clr.w	d1
	swap	d1		/* d1 = REM */

	clr.l	d0
	move.w	d2,d0
	add.l	d3,d0		/* d0 = ANS */
	move.l	a2,d3		/* restore d3 */
	rts
*	A>B, B > 1
slower:
	move.l	#1,d2
	clr.l	d3
moreadj:
	cmp.l	d0,d1
	bhi	adj		/* Was bhs - Jal */
	beq	adj
	add.l	d2,d2
	add.l	d1,d1
	bpl	moreadj
* we shifted B until its >A or sign bit set
* we shifted #1 (d2) along with it
adj:
	cmp.l	d0,d1
	bhi	ltuns
	or.l	d2,d3
	sub.l	d1,d0
ltuns:
	lsr.l	#1,d1
	lsr.l	#1,d2
	bne	adj
* d3=answer, d0=rem
	move.l	d0,d1
	move.l	d3,d0
	move.l	a2,d3		/* restore d3 */
	rts
	END
