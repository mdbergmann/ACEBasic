;
; sound.s - an ACE linked library module: sound routines. 
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
;   Date: 15th,16th May 1992,
;         6th,30th June 1992,
;	  4th,5th,6th,7th,19th,22nd July 1992
;	  9th August 1992,
;	  5th December 1992,
;	  1st March 1993,
;	  31st October 1993,
;	  3rd April 1994
;

	; sound xdefs

	xdef	_sound
	xdef	_wave
  	xdef	_beep


	; * XREFS *

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

	; dos library
	xref	_DOSBase
	xref	_LVODelay

	; math library 
	xref	_MathBase
	xref	_LVOSPFix
	xref	_LVOSPMul
	xref	_LVOSPCmp
	
	SECTION sound_code,CODE

; *** SOUND ROUTINES ***

;
; SOUND - play a sound. d0=period; d1=duration (ffp); d2=volume; d3=voice.
;	- the hardware is programmed directly.
;
_sound:
	; save parameters
	move.w	d0,_period		; 124..32767
	move.l  d1,_duration		; 0..999 (somewhat arbitrary)
	move.w	d2,_volume		; 0..64
	move.w	d3,_voice		; 0..3
 	
	; check parameters -> quit if any are out of range
	
	; period 
	cmpi.w	#124,_period
	blt	_quitsound		; can't be > 32767 by virtue of
					; being a short integer

	; duration	
	move.l	_MathBase,a6	
	move.l	_duration,d0
	move.l	#0,d1
	jsr	_LVOSPCmp(a6)		; duration < 0?
	blt	_quitsound
	move.l	_duration,d0
	move.l	#$f9c0004a,d1		
	jsr	_LVOSPCmp(a6)		; duration > 999?
	bgt	_quitsound
	
	; volume 
	cmpi.w	#0,_volume
	blt	_quitsound
	cmpi.w	#64,_volume
	bgt	_quitsound

	; which audio channel?
	cmpi.w	#0,d3
	bne.s	_aud1

	; audio channel 0
	move.l	_dmactrl,a1
	move.w	#1,(a1)			; disable DMA
	move.l	_audio0,a0
	move.l	_waveformaddr0,(a0)	; address of waveform table
	move.w	_wavelen0,4(a0)		; # of words in table
	move.w	_period,6(a0)		; period (read in rate)
	move.w	_volume,8(a0)		; volume
	move.w	#$8201,(a1)		; enable DMA (start sound)
	jsr	_sound_delay
	move.l	_dmactrl,a1		; putchar may have corrupted a1
	move.w	#1,(a1)
	rts

_aud1:
	cmpi.w	#1,d3
	bne.s	_aud2
	move.l	_dmactrl,a1
	move.w	#2,(a1)
	move.l	_audio1,a0
	move.l	_waveformaddr1,(a0)
	move.w	_wavelen1,4(a0)
	move.w	_period,6(a0)		
	move.w	_volume,8(a0)
	move.w	#$8202,(a1)
	jsr	_sound_delay
	move.l	_dmactrl,a1
	move.w	#2,(a1)
	rts

_aud2:
	cmpi.w	#2,d3
	bne.s	_aud3
	move.l	_dmactrl,a1
	move.w	#4,(a1)
	move.l	_audio2,a0
	move.l	_waveformaddr2,(a0)
	move.w	_wavelen2,4(a0)
	move.w	_period,6(a0)		
	move.w	_volume,8(a0)
	move.w	#$8204,(a1)
	jsr	_sound_delay
	move.l	_dmactrl,a1
	move.w	#4,(a1)
	rts
		
_aud3:
	cmpi.w	#3,d3
	bne	_quitsound
	move.l	_dmactrl,a1
	move.w	#8,(a1)
	move.l	_audio3,a0
	move.l	_waveformaddr3,(a0)
	move.w	_wavelen3,4(a0)
	move.w	_period,6(a0)		
	move.w	_volume,8(a0)	
	move.w	#$8208,(a1)
	jsr	_sound_delay
	move.l	_dmactrl,a1
	move.w	#8,(a1)
	rts
	
_sound_delay:
	move.l	_MathBase,a6
	move.l	_duration,d1		; duration
	move.l	#$afced942,d0		; 2.747
	jsr	_LVOSPMul(a6)		; ticks = duration*2.747
	jsr	_LVOSPFix(a6)		; ticks = (int)ticks
	move.l	_DOSBase,a6
	move.l	d0,d1			; ticks
	jsr	_LVODelay(a6)
	rts		

_quitsound:			
	rts

;
; WAVE - create a new waveform table for SOUND command.
;	 d0=voice; a0=address of waveform table; d1=length of waveform table.
;
_wave:
	; halve # of bytes in waveform table to give # of words
	divu	#2,d1	

	; is it a SIN wave? (address=0)
	cmpa.l	#0,a0
	bne.s	_which_audio		; -> NO
	lea	_sinwavedata,a0		; -> YES
	move.w	#16,d1			; length of sine waveform table
	
_which_audio:
	; which audio channel?
	cmpi.w	#0,d0
	bne.s	_waud1
	move.l	a0,_waveformaddr0
	move.w	d1,_wavelen0
	rts

_waud1:
	cmpi.w	#1,d0
	bne.s	_waud2
	move.l	a0,_waveformaddr1
	move.w	d1,_wavelen1
	rts

_waud2:
	cmpi.w	#2,d0
	bne.s	_waud3
	move.l	a0,_waveformaddr2
	move.w	d1,_wavelen2
	rts

_waud3:
	cmpi.w	#3,d0
	bne.s	_quitwave
	move.l	a0,_waveformaddr3
	move.w	d1,_wavelen3
	rts

_quitwave:	
	rts

;
; BEEP - issues a 0.12 second pulse through voice 0.
;      - save and restore all registers since this
;        routine can be called from C (see Ustringprint).
;
_beep:
	movem.l	d1-d7/a0-a6,-(sp)
	move.w	#505,d0		
	move.l	#$8ccccd42,d1	; duration of 0.12 seconds.
	move.w	#64,d2		; full volume
	move.w	#0,d3		; voice 0
	jsr	_sound
	movem.l	(sp)+,d1-d7/a0-a6
	rts

; *************************

	SECTION sound_data,DATA

; * sound & wave *
_audio0:		dc.l  $dff0a0
_audio1:		dc.l  $dff0b0
_audio2:		dc.l  $dff0c0
_audio3:		dc.l  $dff0d0
_dmactrl:		dc.l  $dff096

; *************************

	SECTION sound_mem,BSS

; * sound *
_period:		ds.w 1
_duration:		ds.l 1
_volume:		ds.w 1
_voice:			ds.w 1

	END
