
	SECTION code,CODE

	jsr	_startup
	cmpi.b	#1,_starterr
	bne.s	_START_PROG
	rts
_START_PROG:
	move.l	sp,_initialSP
	movem.l	d1-d7/a0-a6,-(sp)
	jsr	_openmathffp
	cmpi.b	#1,_starterr
	bne.s	_mathffp_ok
	jmp	_ABORT_PROG
_mathffp_ok:
	jsr	_openmathtrans
	cmpi.b	#1,_starterr
	bne.s	_mathtrans_ok
	jmp	_ABORT_PROG
_mathtrans_ok:
	jsr	_openintuition
	cmpi.b	#1,_starterr
	bne.s	_intuition_ok
	jmp	_ABORT_PROG
_intuition_ok:
	jsr	_opengfx
	cmpi.b	#1,_starterr
	bne.s	_gfx_ok
	jmp	_ABORT_PROG
_gfx_ok:
	link	a4,#-378


_EXIT_PROG:
	unlk	a4
_ABORT_PROG:
	jsr	_free_alloc
	jsr	_closegfx
	jsr	_closeintuition
	jsr	_closemathtrans
	jsr	_closemathffp
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	_initialSP,sp
	jsr	_cleanup

	rts

	END
