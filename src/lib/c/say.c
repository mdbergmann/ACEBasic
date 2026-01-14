/* <<ACE>> code for SAY command and SAY(n) function.
** Copyright (C) 1998 David Benn
** 
** This program is free software; you can redistribute it and/or
** modify it under the terms of the GNU General Public License
** as published by the Free Software Foundation; either version 2
** of the License, or (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

   Author: David J Benn
     Date: 6th-8th,10th,11th,14th March 1993,
	   10th January 1994,
	   20th March 1994,
	   2nd,3rd November 1995
*/

#include <exec/types.h>
#include <exec/exec.h>
#include <devices/narrator.h>

#define ERR 	    1
#define OK     	    0

#define STOP	    0
#define GO	    1

#define T	   -1L
#define F	    0L

#define SYNC	    0
#define ASYNC	    1
#define DEFSYNC     SYNC

#define DEFCHANNEL 10
#define DEFCNTL	    0

/* I/O structures */
struct MsgPort *WPort=NULL;
struct MsgPort *RPort=NULL;
struct narrator_rb *wmes=NULL;
struct mouth_rb *rmes=NULL;

/* audio channel data */
UBYTE audChanMasks[4];

/* default speech characteristics -- see devices/narrator.h */
SHORT defvoice[] = {DEFPITCH,DEFMODE,DEFRATE,DEFSEX,DEFFREQ,DEFVOL,
		    DEFCHANNEL,DEFSYNC,DEFCNTL};

/* mouth width and height */		
LONG mouth_x,mouth_y;

/* external functions */
ULONG	stringlength();

/* functions */
void cleanup_narrator()
{
 if (wmes)  CloseDevice(wmes);
 if (WPort) DeletePort(WPort);
 if (RPort) DeletePort(RPort);
 if (wmes)  DeleteExtIO(wmes);
 if (rmes)  DeleteExtIO(rmes);
}

void nullify_struct_ptrs()
{
 wmes=NULL;
 rmes=NULL;
 WPort=NULL;
 RPort=NULL;
}

UWORD aud_chan_masks(n)
LONG n;
{
 /* set the audio channel masks and return the number of masks
    (default is same as for n=10). */

 switch(n)
 {
  case 0  : audChanMasks[0]=1;  return(1); break;
  case 1  : audChanMasks[0]=2;  return(1); break;
  case 2  : audChanMasks[0]=4;  return(1); break;
  case 3  : audChanMasks[0]=8;  return(1); break;
  case 4  : audChanMasks[0]=3;  return(1); break;
  case 5  : audChanMasks[0]=5;  return(1); break;
  case 6  : audChanMasks[0]=10; return(1); break;
  case 7  : audChanMasks[0]=12; return(1); break;
  case 8  : audChanMasks[0]=2;  audChanMasks[1]=4;  return(2); break;
  case 9  : audChanMasks[0]=1;  audChanMasks[1]=8;  return(2); break;
  case 10 : audChanMasks[0]=3;  audChanMasks[1]=5;
	    audChanMasks[2]=10; audChanMasks[3]=12; return(4); break;  
  case 11 : audChanMasks[0]=1;  audChanMasks[1]=2;
	    audChanMasks[2]=4;  audChanMasks[3]=8;  return(4); break;
  default : audChanMasks[0]=3;  audChanMasks[1]=5;
	    audChanMasks[2]=10; audChanMasks[3]=12; return(4); break;
 }
}

int setup_write_req(speech,voice)
UBYTE *speech;
SHORT *voice;
{
UWORD num_masks;

 if ((WPort=(struct MsgPort *)CreatePort(NULL,0L))==NULL) return(ERR);

 if ((wmes=(struct narrator_rb *)
    CreateExtIO(WPort,sizeof(struct narrator_rb)))==NULL) return(ERR);

 if (voice == NULL) voice=defvoice; /* default speech settings */

 wmes->message.io_Command=CMD_WRITE;
 wmes->message.io_Data=(APTR)speech;
 wmes->message.io_Length=stringlength(speech);
 
 num_masks=aud_chan_masks((LONG)voice[6]); /* set audChanMasks */
 wmes->ch_masks=audChanMasks;
 wmes->nm_masks=num_masks;

 if (OpenDevice("narrator.device",0L,wmes,0L) != 0) 
 {
	cleanup_narrator();
	nullify_struct_ptrs();
	return(ERR);
 }

 wmes->pitch=voice[0];
 wmes->mode=voice[1];
 wmes->rate=voice[2];
 wmes->sex=voice[3];
 wmes->sampfreq=voice[4];
 wmes->volume=voice[5];
 wmes->mouths=voice[7];  /* synchronous/asynchronous speech */
}

int setup_read_req()
{
 if ((RPort=(struct MsgPort *)CreatePort(NULL,0L))==NULL) return(ERR);

 if ((rmes=(struct mouth_rb *)
    CreateExtIO(RPort,sizeof(struct mouth_rb)))==NULL) return(ERR);

 rmes->voice.message.io_Device=wmes->message.io_Device;
 rmes->voice.message.io_Unit=wmes->message.io_Unit;
 rmes->width=0;
 rmes->height=0;
 rmes->voice.message.io_Command=CMD_READ;
 rmes->voice.message.io_Error=0;
}

void say_it(voice)
SHORT *voice;
{
 /* synchronous I/O */
 if (voice[7] == SYNC)
 {
  DoIO(wmes);
  cleanup_narrator();
  nullify_struct_ptrs();
 }
 else
  /* asynchronous I/O */
  BeginIO(wmes);
}

LONG read_mouth()
{
 /* return mouth width and height if asynchronous I/O active */
 if (rmes == NULL) return(F);

 if (rmes->voice.message.io_Error != ND_NoWrite) 
 {
  DoIO(rmes);
  mouth_x=(LONG)rmes->width;
  mouth_y=(LONG)rmes->height;
  return(T);
 }
 else
 {
  cleanup_narrator();
  nullify_struct_ptrs();
  return(F);
 }
}

LONG sayfunc(n)
LONG n;
{
 /* return data from active asynchronous speech */
 
 switch(n)
 {
  case 0  : return(read_mouth());  /* T or F */
	    break;

  case 1  : return(mouth_x);
	    break;

  case 2  : return(mouth_y);
	    break;
  
  default : return(F);
 }
}

void cleanup_last_say()
{
 /* wait for async I/O to cease then clean up */
 WaitIO(wmes);
 cleanup_narrator();
 nullify_struct_ptrs();
}

int check_for_async_speech(voice)
SHORT *voice;
{
 /* already active asynchronous speech I/O? */
 if (wmes) 
 {
  switch(voice[8])
  {
   case 0 : cleanup_last_say();
	    return(GO);
	    break;	/* wait for last SAY to finish then do current SAY */

   case 1 : AbortIO(wmes);
	    cleanup_last_say();
	    return(STOP);
	    break;	/* interrupt last SAY and don't do current SAY */

   case 2 : AbortIO(wmes);
	    cleanup_last_say();
	    return(GO);
	    break;	/* interrupt last SAY, then do current SAY */

   default : return(STOP); 
	     break;	/* unknown value -> just exit */
  }
 }
 else return(GO);
}

void say(voice,str)
SHORT *voice;
UBYTE *str;
{
 if (voice && check_for_async_speech(voice) == STOP) return;

 /* setup I/O requests */ 
 if (setup_write_req(str,voice)==ERR) return;
 if (setup_read_req()==ERR) return;

 /* carry out I/O */
 say_it(voice);
}

void cleanup_async_speech()
{
 /* used as a final check by an ACE program 
    in case there is any active asynchronous
    speech. */ 
 if (wmes) cleanup_last_say();
}
