;
; Data/BSS references for sound.s.
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
;   Date: 3rd April 1994
;

	; constants

SIN_wave_length EQU 16


	; sound xdefs & routines
	xdef	_initialise_waveform_data
	xdef	_waveformaddr0
	xdef	_waveformaddr1
	xdef	_waveformaddr2
	xdef	_waveformaddr3
	xdef	_wavelen0
	xdef	_wavelen1
	xdef	_wavelen2
	xdef	_wavelen3
	xdef	_sinwavedata


	SECTION sound_data_code,CODE

;
; initalise waveforms and waveform lengths.
;
_initialise_waveform_data:
	lea	_sinwavedata,a0

	move.l	a0,_waveformaddr0
	move.l	a0,_waveformaddr1
	move.l	a0,_waveformaddr2
	move.l	a0,_waveformaddr3
	
	move.w	#SIN_wave_length,_wavelen0
	move.w	#SIN_wave_length,_wavelen1
	move.w	#SIN_wave_length,_wavelen2
	move.w	#SIN_wave_length,_wavelen3

	rts

; *************************

	SECTION wave_data,DATA,CHIP

_sinwavedata:	dc.b  -90,-127,-90,0,90,127,90,0,-90,-127,-90,0,90,127,90,0
		dc.b  -90,-127,-90,0,90,127,90,0,-90,-127,-90,0,90,127,90,0


	SECTION sound_data_mem,BSS

; * wave *
_waveformaddr0:		ds.l 1
_waveformaddr1:		ds.l 1
_waveformaddr2:		ds.l 1
_waveformaddr3:		ds.l 1
_wavelen0:		ds.w 1
_wavelen1:		ds.w 1
_wavelen2:		ds.w 1
_wavelen3:		ds.w 1

	END
