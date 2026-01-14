;
; time.s -- an ACE linked library module: time and date functions.
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
;	  5th December 1992,
;	  1st March 1993,
;	  19th March 1994
;
; registers d0-d6 and a0-a3 are modified by some of the following. BEWARE!
;
; a4,a5 are used by link/unlk.
; a6 is library base holder.
; a7 is stack pointer. 
; d7 is used for array index calculations.
;

; misc. defines
MAXSTRINGSIZE	EQU	1024

   	; time and date functions
	xdef	_timeofday
	xdef	_date
	xdef	_getday
	xdef	_timer
	xdef	_ontimerstart
 	xdef	_ontimer
	
   	; external references 
 	xref	_shortfmt
	xref	_longfmt

	xref	_sprintf
 	xref  	_DOSBase
	xref	_LVODateStamp	
	xref	_strcat
	xref	_strcpy
	xref	_MathBase
	xref	_LVOSPFlt
	xref	_LVOSPAdd
	xref	_LVOSPMul
	xref	_LVOSPDiv
	xref	_LVOSPCmp
	
	SECTION time_code,CODE

;*** TIME and DATE FUNCTIONS ***

;
; TIME$ - returns a pointer to a string containing the time in hh:mm:ss format
;	  in d0.
;
_timeofday:
	move.l	#_datestampholder,d1
	movea.l	_DOSBase,a6
	jsr	_LVODateStamp(a6)
	lea	_datestampholder,a1

	move.l	4(a1),d0
	divu	#60,d0
	move.w	d0,_todhrs		; hours = 0..23

	swap	d0
	move.w	d0,_todmins		; minutes = 0..59

	move.l	8(a1),d0
	divu	#50,d0
	move.w	d0,_todsecs		; seconds = 0..59

	move.w	_todhrs,-(sp)
	pea	_shortfmt
	pea	_todhrstr
	jsr	_sprintf
	add.l	#10,sp			; hours to string

	move.w	_todmins,-(sp)
	pea	_shortfmt
	pea	_todminstr
	jsr	_sprintf
	add.l	#10,sp			; minutes to string

	move.w	_todsecs,-(sp)
	pea	_shortfmt
	pea	_todsecstr
	jsr	_sprintf
	add.l	#10,sp			; seconds to string

	lea	_tmpstring,a2
	move.b	#0,(a2)		; EOS for _strcat

	cmpi.w	#10,_todhrs
	bge.s	_concathrs
	lea	_zerostr,a1
	movea.l	a2,a0		
	jsr	_strcat			; concatenate hours to tod string
_concathrs:
	lea	_todhrstr,a1
	movea.l	a2,a0
	jsr	_strcat

	lea	_colonstr,a1
	movea.l	a2,a0
	jsr	_strcat			; colon in hh:mm

	cmpi.w	#10,_todmins
	bge.s	_concatmins
	lea	_zerostr,a1
	movea.l	a2,a0		
	jsr	_strcat			; concatenate minutes to tod string
_concatmins:
	lea	_todminstr,a1
	movea.l	a2,a0
	jsr	_strcat

	lea	_colonstr,a1
	movea.l	a2,a0
	jsr	_strcat			; colon in mm:ss
	
	cmpi.w	#10,_todsecs
	bge.s	_concatsecs
	lea	_zerostr,a1
	movea.l	a2,a0		
	jsr	_strcat			; concatenate seconds to tod string
_concatsecs:
	lea	_todsecstr,a1
	movea.l	a2,a0
	jsr	_strcat
	
	movea.l	a2,a1
	lea	_timestring,a0
	jsr	_strcpy			; copy temp string to tod string

	move.l	#_timestring,d0		; address in d0

	rts

;
; DATE$ - returns pointer to a string containing the date in mm-dd-yyyy format
; 	  in d0. See rwm.c year_and_month() function.
;
_date:
	; initialise year, month and day of week
  	move.l	#1978,_year
	move.l	#1,_month
	move.l	#0,_day_of_week

	; get days
	move.l	#_datestampholder,d1
	movea.l	_DOSBase,a6
	jsr	_LVODateStamp(a6)
	lea	_datestampholder,a1
	move.l	(a1),_days

	; find the year
_find_year:
	cmpi.l	#365,_days
	ble	_modify_feb	; days > 365? -> continue finding year
	
	; leap year?
	move.l	_year,d0
	jsr	_leap_year_check
	cmpi.b	#0,d0
	beq.s	_no_leap_year

	; decrement days by 366
	subi.l	#366,_days

	; update day of week
	move.l	#366,d1
	jsr	_change_day_of_week

	; increment year
	addi.l	#1,_year
	bra	_find_year
	
 _no_leap_year:
	; decrement days by 365
	subi.l	#365,_days

	; update day of week
	move.l	#365,d1
	jsr	_change_day_of_week
	
	; increment year
	addi.l	#1,_year
	bra	_find_year

	; calculate month
_modify_feb:
	; get address of february day holder
	move.l	#_days_in_month,d0
	add.l	#2,d0
	move.l	d0,a0

	; default is 28 days
	move.w	#28,(a0)

	; leap year?
	move.l	_year,d0
	jsr	_leap_year_check
	cmpi.b	#0,d0
	beq.s	_find_month

	; add a leap day
	move.w	#29,(a0)

_find_month:
	jsr	_days_in_this_month
	move.l	_days,d1
	cmp.l	d0,d1		; days (d1) > days in this month (d0) ?
	ble.s	_adjust_day_and_month

	; decrement # of days
	jsr	_days_in_this_month
	sub.l	d0,_days	; days -= days in this month
	
	; update day of week
	move.l	d0,d1		; d1 = days in this month
	jsr	_change_day_of_week

	; increment month
	addi.l	#1,_month	; month++
	bra.s	_find_month

_adjust_day_and_month:
	; final day of week update
	move.l	_days,d1
	jsr	_change_day_of_week

	cmpi.l	#2000,_year	; year < 2000?
	bge.s	_adjust_day_month
	addi.l	#1,_days	; days++

_adjust_day_month:
	jsr	_days_in_this_month
	move.l	_days,d1
	cmp.l	d0,d1		; days (d1) > days in this month (d0) ?
	ble.s	_adjust_month_and_year
	move.l	#1,_days	; days=1
	addi.l	#1,_month	; month++

_adjust_month_and_year:
	cmpi.l	#13,_month	; month=13 ?
	bne.s	_construct_datestring
	move.l	#1,_month	; month=1
	addi.l	#1,_year	; year++

_construct_datestring:
	; convert days,month,year to strings
	move.l	#_daystr,d1
	cmpi.l	#10,_days	; days < 10?
	bge.s	_makedaystring
	; '0' prefix
	move.l	d1,a0
	move.b	#48,(a0)
	add.l	#1,d1		; add 1 to start posn in day string

_makedaystring:
	move.l	_days,-(sp)
	pea	_longfmt
	move.l	d1,-(sp)	; address of day string
	jsr	_sprintf
	add.l	#12,sp

	; month string (as for days)
	move.l	#_monthstr,d1
	cmpi.l	#10,_month	; month < 10 ?
	bge.s	_makemonthstring
	; '0' prefix
	move.l	d1,a0
	move.b	#48,(a0)
	add.l	#1,d1

_makemonthstring:
	move.l	_month,-(sp)
	pea	_longfmt
	move.l	d1,-(sp)
	jsr	_sprintf
	add.l	#12,sp

	; year string
	move.l	_year,-(sp)
	pea	_longfmt
	pea	_yearstr
	jsr	_sprintf
	add.l	#12,sp

	; build whole date string
	lea	_tmpstring,a0
	move.b	#0,(a0)		; EOS for _strcat

	; month
	lea	_tmpstring,a0
	lea	_monthstr,a1
	jsr	_strcat		; MM

	lea	_tmpstring,a0
	lea	_dash,a1
	jsr	_strcat		; '-'

	; day
	lea	_tmpstring,a0
	lea	_daystr,a1
	jsr	_strcat		; DD

	lea	_tmpstring,a0
	lea	_dash,a1
	jsr	_strcat		; '-'

	; year
	lea	_tmpstring,a0
	lea	_yearstr,a1
	jsr	_strcat		; YYYY

	lea	_datestring,a0
	lea	_tmpstring,a1
	jsr	_strcpy

	move.l	#_datestring,d0
		
	rts	

;
; Leap Year? d0=year. Returns 0 or -1 in d0.
;
_leap_year_check:
	; divisible by 4?
	move.l	d0,d1
	divu	#4,d1
	swap	d1
	cmpi.w	#0,d1
	beq.s	_check100
	bra	_quitleapyearcheck

	; divisible by 100?
_check100:
	move.l	d0,d1
	divu	#100,d1
	swap	d1
	cmpi.w	#0,d1
	beq.s	_check400
	move.b	#-1,d0		; leap year
	rts
	
_check400:
	move.l	d0,d1
	divu	#400,d1
	swap 	d1
	cmpi.w	#0,d1
	bne.s	_quitleapyearcheck
	move.b	#-1,d0		; leap year
	rts

_quitleapyearcheck:
	move.b	#0,d0		; not a leap year
	rts

;
; Return # of days in this month.
;
_days_in_this_month:
	move.l	_month,d0
	sub.l	#1,d0
	lsl.l	#1,d0		; index *= 2
	move.l	#_days_in_month,d1
	add.l	d0,d1
	move.l	d1,a0
	move.w	(a0),d0		; days_in_month[month-1]
	ext.l	d0		

	rts

;
; Update the day of week to be within the range 0..6. 
;
_change_day_of_week:
	move.l	_day_of_week,d0
	add.l	d1,d0
	divu	#7,d0
	swap	d0
	ext.l	d0
	move.l	d0,_day_of_week	
	rts

;
; Return day of week in d0 as a number from 0..6 where 0=Sunday.
; DATE$ must be called first to update _day_of_week variable.
;
_getday:
	move.l	_day_of_week,d0
	rts

;
; TIMER - returns a single-precision value in d0 corresponding to seconds 
;         elapsed since midnight. 
;
_timer:
	move.l	#_datestampholder,d1
	movea.l	_DOSBase,a6
	jsr	_LVODateStamp(a6)
	lea	_datestampholder,a1			

	movea.l	_MathBase,a6

	move.l	4(a1),d0		
	jsr	_LVOSPFlt(a6)		
	move.l	d0,_mins		; minutes since midnight

	move.l	8(a1),d0
	jsr	_LVOSPFlt(a6)
	move.l	d0,_ticks		; ticks in current minute

	move.l	_mins,d0		
	move.l	#$f0000046,d1		; ffp 60
	jsr	_LVOSPMul(a6)		; seconds since midnight (_mins*60)
	move.l	d0,_minsecs

	move.l	_ticks,d0		
	move.l	#$c8000046,d1		; ffp 50 (50 ticks per sec)
	jsr	_LVOSPDiv(a6)		; seconds in current minute (_ticks/50)
	move.l	d0,_ticksecs
	
	move.l	_minsecs,d0
	move.l	_ticksecs,d1
	jsr	_LVOSPAdd(a6)		; total seconds elapsed since
					; midnight including current minute
	rts
			
;
; Initialises timer event trapping with a start time. 
;
_ontimerstart:
	jsr	_timer
	move.l	d0,_last_time	
	rts

;
; Determines whether a timer event is due. d0=timer event interval.
; A boolean result is returned in d0. 
;
_ontimer:
	; calculate target time
	movea.l	_MathBase,a6
	move.l	_last_time,d1
	jsr	_LVOSPAdd(a6)
	move.l	d0,_target_time	; target_time = last_time + interval

	; get current time
	jsr	_timer	
	move.l	d0,_curr_time	; store current time

	; is an event due?
	movea.l	_MathBase,a6
	move.l	_target_time,d1	
	jsr	_LVOSPCmp(a6)	; curr_time (d0) >= target_time (d1)?
	bge.s	_target_time_reached

	moveq	#0,d0		; timer event NOT due
	rts

_target_time_reached:
	; update last time an event occurred
	move.l	_curr_time,_last_time

	moveq	#-1,d0		; timer event due
	rts

;*****************************

	SECTION time_data,DATA

; * general *
_zerostr:	dc.b '0',0
_colonstr:	dc.b ':',0

; * date *
_dash: 		dc.b '-',0
_days_in_month: dc.w 31,28,31,30,31,30,31,31,30,31,30,31

; *************************

	SECTION time_mem,BSS

; * general *
_tmpstring:    		ds.b MAXSTRINGSIZE
_datestampholder:	ds.l 3

; * timeofday *
_tmpaddr:		ds.l 1
_todhrs:		ds.w 1
_todmins:		ds.w 1
_todsecs:		ds.w 1
_todhrstr:		ds.b 3
_todminstr:		ds.b 3
_todsecstr:		ds.b 3
_timestring:		ds.b 9

; * date *
_days:			ds.l 1
_month:			ds.l 1
_year:			ds.l 1
_daystr:		ds.b 3
_monthstr:		ds.b 3
_yearstr:		ds.b 5
_datestring:		ds.b 11
_day_of_week:		ds.l 1

; * timer *
_mins:			ds.l 1
_ticks:			ds.l 1
_minsecs:		ds.l 1
_ticksecs:		ds.l 1

; * ontimer *
_last_time:		ds.l 1
_curr_time:		ds.l 1
_target_time:		ds.l 1
 
	END
