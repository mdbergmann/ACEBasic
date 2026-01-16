; subtract two short integers passed from ACE and return result in d0.

	xdef _subtract

	_subtract:
		move.w	4(sp),d0	; arg1
		move.w	6(sp),d1	; arg2
		sub.w	d1,d0		; arg1-arg2
		rts
	end
