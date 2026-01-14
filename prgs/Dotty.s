
	xref _OpenWdw
	xref _IntuitionBase
	xref _GfxBase
	xref _rnd
	xref _MathBase
	xref _LVOSPFlt
	xref _LVOSPMul
	xref _LVOSPFloor
	xref _LVOSPFix
	xref _round
	xref _LVOSetAPen
	xref _RPort
	xref _LVOMove
	xref _LVOWritePixel
	xref _fgdpen
	xref _inkey
	xref _DOSBase
	xref _strcpy
	xref _streq
	xref _CloseWdw
	xref _startup
	xref _cleanup
	xref _openmathffp
	xref _closemathffp
	xref _opengfx
	xref _closegfx
	xref _openintuition
	xref _closeintuition
	xref _starterr
	xdef _EXIT_PROG
	xref _free_alloc

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
	link	a4,#-12

	move.w	#1,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	_stringconst0
	move.w	#0,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	#0,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	#100,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	#100,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	#-1,-(sp)
	move.l	#0,-(sp)
	jsr	_OpenWdw
	add.l	#32,sp
LOOP:
	jsr	_rnd
	move.l	d0,-(sp)
	move.w	#100,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	_MathBase,a6
	jsr	_LVOSPFlt(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.l	(sp)+,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPMul(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.l	_MathBase,a6
	jsr	_LVOSPFloor(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.l	_MathBase,a6
	jsr	_LVOSPFlt(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,-4(a4)
	jsr	_rnd
	move.l	d0,-(sp)
	move.w	#100,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	_MathBase,a6
	jsr	_LVOSPFlt(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.l	(sp)+,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPMul(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.l	_MathBase,a6
	jsr	_LVOSPFloor(a6)
	jsr	_LVOSPFix(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.l	_MathBase,a6
	jsr	_LVOSPFlt(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,-8(a4)
	move.l	-4(a4),-(sp)
	move.l	(sp)+,d0
	jsr	_round
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.w	d0,-(sp)
	move.l	-8(a4),-(sp)
	move.l	(sp)+,d0
	jsr	_round
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.w	d0,-(sp)
	jsr	_rnd
	move.l	d0,-(sp)
	move.w	#6,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	_MathBase,a6
	jsr	_LVOSPFlt(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.l	(sp)+,d1
	movea.l	_MathBase,a6
	jsr	_LVOSPMul(a6)
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	jsr	_round
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	move.w	d0,-(sp)
	move.w	(sp)+,d0
	move.l	_RPort,a1
	move.l	_GfxBase,a6
	jsr	_LVOSetAPen(a6)
	move.w	(sp)+,d1
	move.w	(sp)+,d0
	move.l	a1,a3
	move.w	d0,d3
	move.w	d1,d4
	jsr	_LVOMove(a6)
	move.w	d4,d1
	move.w	d3,d0
	move.l	a3,a1
	jsr	_LVOWritePixel(a6)
	move.w	_fgdpen,d0
	move.l	_RPort,a1
	move.l	_GfxBase,a6
	jsr	_LVOSetAPen(a6)
	jsr	_inkey
	move.l	d0,-(sp)
	pea	_stringvar0
	move.l	(sp)+,-12(a4)
	move.l	(sp)+,a1
	move.l	-12(a4),a0
	jsr	_strcpy
	move.l	-12(a4),-(sp)
	pea	_stringconst1
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	jsr	_streq
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	cmpi.l	#0,d0
	bne.s	_lab0
	jmp	_lab1
_lab0:
	jmp	QUIT
_lab1:
	jmp	LOOP
QUIT:
	move.w	#1,-(sp)
	move.w	(sp)+,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	_CloseWdw
	addq	#4,sp
	jmp	_EXIT_PROG

_EXIT_PROG:
	unlk	a4
_ABORT_PROG:
	jsr	_free_alloc
	jsr	_closegfx
	jsr	_closeintuition
	jsr	_closemathffp
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	_initialSP,sp
	jsr	_cleanup

	rts

	SECTION data,DATA

_stringconst0:	dc.b "Press x to close",0
_stringconst1:	dc.b "x",0

	SECTION mem,BSS

_stringvar0:	ds.b 1024
_initialSP:	ds.l 1

	END
