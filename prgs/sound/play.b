{ 
  << play a sound file! >>

  Currently handles IFF 8SVX format.
  If format is unknown, a default 
  sampling rate is assumed. 

  USAGE 
  -----
  CLI/Shell: 	Play [<file> [<sampling rate>]] | ?

  Author: David J Benn
    Date: 6th,7th April,16th May,
	  30th June,
	  1st,3rd,4th,8th,28th July 1992,
	  6th,21st,25th January 1993,
	  3rd February 1993,
	  10th July 1993,
	  3rd January 1994,
	  20th March 1996
}

declare function _Read&	library

longint offset&,samples_per_second&
string  path$

SUB parse_sample(f$)
shared offset&,samples_per_second&
const default_rate=10000&

 { if IFF 8SVX sample, return
   offset from start of file to
   sample data and sampling rate in
   samples per second. }

 open "I",1,f$

 '..skip FORM#### ?
 dummy$=input$(8,#1)

 '..8SVX ?
 x$=input$(4,#1)
 if x$="8SVX" then
   sample_format$="IFF 8SVX"

   '..skip VHDR###
   dummy$=input$(8,#1)

   '..skip ULONGs x 3 
   dummy$=input$(12,#1)

   '..get sampling rate bytes
   hi%=asc(input$(1,#1))  '..high byte
   lo%=asc(input$(1,#1))  '..low byte
   samples_per_second&=hi%*256 + lo%

   '..find BODY

   '..skip rest of Voice8Header structure
   dummy$=input$(6,#1)

   offset&=40  '..bytes up to this point
   repeat 
    repeat
      x$=input$(1,#1)
      offset&=offset&+1
    until x$="B" and not eof(1)
    if not eof(1) then
      body$=input$(3,#1)
      offset&=offset&+3
    end if
   until body$="ODY" and not eof(1) 

   if not eof(1) then
     x$=input$(4,#1)  '..skip ####   
     offset&=offset&+4
   else
     print "Error in file format!"
     stop
   end if
   close 1
 else
   close 1
   sample_format$="unknown"
   offset&=0
   if argcount<>2 then samples_per_second&=default_rate
 end if

 '.. give info about sample
 print "Sound file format is ";sample_format$;"."

 if sample_format$="unknown" then
   if argcount<>2 then
     print "Playback rate is";samples_per_second&;"Hz."
   end if
 else 
   print "Sample was recorded at";samples_per_second&;"Hz."
 end if

END SUB


SUB play_sound(f$)
shared offset&,samples_per_second&
const maxsample=131070
const channel=1
const CHIP=0, MAXCHIP=2

dim   wave_ptr&(100)

 print 
 print "*** ACE sound player ***"
 
'..file sample_size?
open "I",1,f$
sample_size&=lof(1)
close 1

if sample_size&<>0 then
  print f$;" contains";sample_size&;"bytes."
else
  print "Can't open ";f$;"."
  stop
end if

parse_sample(f$)

'..get the sample bytes
buffer&=Alloc(sample_size&,CHIP) '...sample_size& bytes of CHIP RAM
if buffer& = NULL then 
  avail&=fre(MAXCHIP)  '..max. contiguous CHIP RAM
  print "Largest contiguous CHIP RAM is";avail&;"bytes." 
  stop
end if

open "I",1,f$  
fh&=handle(1)
if fh&=0 then
  print "Can't open ";f$;"."
  stop 
end if
bytes&=_Read(fh&,buffer&,sample_size&)
close 1

'..calculate period
if argcount<>2 then 
  per& = 3579546 \ samples_per_second&  
else
  sample_rate_requested&=clng(val(arg$(2)))
  per& = 3579546 \ sample_rate_requested&
  print "Requested sampling rate is";sample_rate_requested&;"Hz."
end if
  
'...setup waveform table for voice 0
sz&=sample_size&-offset&

if sz& <= maxsample then
  '..play it in one go
  wave channel,buffer&+offset&,sz&
  dur&=.279365*per&*bytes&/1e6*18.2
  sound per&,dur&,,channel
else
  segments&=sz&\maxsample
  buf&=buffer&+offset&

  '..get the segment pointers
  for i&=0 to segments&
    wave_ptr&(i&)=buf&+maxsample*i&
  next

  '..play sample in segments
  for i&=0 to segments&
    if sz& >= maxsample then 
       wave channel,wave_ptr&(i&),maxsample 
       bytes&=maxsample
    else 
       wave channel,wave_ptr&(i&),sz&
       bytes&=sz&
    end if
    dur&=.279365*per&*bytes&/1e6*18.2
    sound per&,dur&,,channel
    sz&=sz&-maxsample
  next   
end if

END SUB


{ ** main ** }

if argcount=0 then
  path$ = FileBox$("Choose a sound sample")
else
  if arg$(1)="?" then
    print "usage: ";arg$(0);" [<file> [<sampling rate>]] | ?"
    stop
  else
    path$ = arg$(1)
  end if
end if

if path$<>"" then 
  play_sound(path$)
else
  dummy = MsgBox("No sound file selected.","OK")
end if
