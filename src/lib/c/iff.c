/*
** IFF code for ACE **
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
**
**      Author: David J Benn, with thanks to Jeff Glatt for his
**		excellent ILBM.library (the one that CBM should
**		have adopted as a standard shared library).
**
**        Date: 27th February 1994,
**		4th April 1994,
**		3rd,5th,7th,10th,11th,19th,21st,28th August 1994,
**		10th,11th September 1994
*/

#include  <exec/types.h>
#include  <libraries/dos.h>
#include  <intuition/intuition.h>
#include  "ilbm_lib.h"

/* errors */
#define OPEN_ERR	500
#define CLOSE_ERR	501
#define READ_ERR	502
#define BAD_CHAN	503

#define MINCHANNEL	1
#define MAXCHANNEL	255

#define CLEARED_ANY_MEM 7L

/* globals */
char *ilbm = "ILBM";          	/* chunk identifiers */
char *acbm = "ACBM";

long 	rLen;               	/* bytes read from disc */
long 	icLen;              	/* chunk length */
UBYTE 	mybuf[300];       	/* buffer for headers and short chunks */

BOOL	first=TRUE;

struct	Library	*ILBMBase = NULL;

typedef	struct IFFpic{
	char 	*name;
	char	pictype[5];
	LONG	width;
	LONG	height;
	LONG	depth;
	struct	Window	*window;
	struct	Screen	*screen;
} IFFPIC;

IFFPIC	iffpic[MAXCHANNEL+1];		/* Need: 1..255 */

/* externals */
extern struct Screen *Screen_list[10];
extern LONG error_code;

/* function protos */
BOOL	bad_channel();
void	IFFPicOpen();
void	IFFPicRead();
void	IFFPicClose();
LONG	iff_func();
void	readiff();

/* external functions */
extern	void 	*alloc();
extern	void	stringcopy();
extern	LONG	stringcompare();
extern	ULONG	stringlength();
extern	LONG	LoadIFFToWindow();

/*--------Interface functions-------*/

BOOL bad(channel)
LONG channel;
{
/* Do we have a "bad" channel? */

	if (channel < MINCHANNEL  || channel > MAXCHANNEL) 
		return(TRUE);
	else
		return(FALSE);		
}

void IFFPicOpen(name,channel)
char *name;
LONG channel;
{
struct FileHandle *fHandle;
/* 
** Retrieve and store info' about an IFF picture file. 
*/
LONG i;
	if (first)
	{
		first = FALSE;

		for (i=1;i<MAXCHANNEL;i++)
		{	
			iffpic[i].name 	 	= NULL;
			iffpic[i].pictype[0] 	= '\0';
			iffpic[i].width		= 0;
			iffpic[i].height	= 0;
			iffpic[i].depth 	= 0;
			iffpic[i].screen 	= NULL;
			iffpic[i].window 	= NULL;
		}
	}

  	if (bad(channel))
		{ error_code = BAD_CHAN; return; }
  	else
  	{
		if (iffpic[channel].name != NULL)
			{ error_code = OPEN_ERR; return; }
	
		/* 
		** Read IFF header info' and store 
		** width, height and depth. 
		*/
		fHandle = (struct FileHandle *)Open(name,MODE_OLDFILE);
  		if (fHandle == NULL) 
		   { error_code = OPEN_ERR; return; }

  		rLen = Read(fHandle,&mybuf[0],12);

		/* ACBM or ILBM picture file? */
  		if (stringcompare(ilbm,&mybuf[0]+8) != 0 &&
  		    stringcompare(acbm,&mybuf[0]+8) != 0)
		{
			error_code = READ_ERR;
			return;		
		}
		
		iffpic[channel].pictype[0] = mybuf[8];
		iffpic[channel].pictype[1] = mybuf[9];
		iffpic[channel].pictype[2] = mybuf[10];
		iffpic[channel].pictype[3] = mybuf[11];
		iffpic[channel].pictype[4] = '\0';

  		rLen = Read(fHandle,&mybuf[0],8);

  		icLen=mybuf[7]+256*mybuf[6];

  		rLen = Read(fHandle,&mybuf[0],icLen);

		if (fHandle) Close(fHandle);

		iffpic[channel].width 	= mybuf[17] + 256*mybuf[16];
		iffpic[channel].height 	= mybuf[19] + 256*mybuf[18];
		iffpic[channel].depth 	= mybuf[8];   /* # of bitplanes */

		/* Store name */
		iffpic[channel].name = (char *)alloc(CLEARED_ANY_MEM,
						     stringlength(name)+1);

		if (iffpic[channel].name == NULL)
			{ error_code = OPEN_ERR; return; }

		stringcopy(iffpic[channel].name,name);
	}
}

void IFFPicRead(screen_id,channel)
LONG screen_id,channel;
{
/*
** Read IFF picture onto specified screen.
*/
  	if (bad(channel))
		{ error_code = BAD_CHAN; return; }
  	else
  	{
		if (iffpic[channel].name == NULL)
			{ error_code = BAD_CHAN; return; }	

 		readiff(screen_id,channel);
	}
}

void IFFPicClose(channel)
LONG channel;
{
/* 
** Clean up IFF channel.
*/

  	if (bad(channel))
		{ error_code = BAD_CHAN; return; }
  	else
  	{
		if (iffpic[channel].name == NULL)
			{ error_code = CLOSE_ERR; return; }

		/*
		** Close screen and window opened by
		** ILBM.library?
		*/
		if (iffpic[channel].window)
		{
			CloseWindow(iffpic[channel].window);
		}

		if (iffpic[channel].screen)
		{
			CloseScreen(iffpic[channel].screen);
		}
	
		/*
		** Clear all fields of IFFPic structure.
		*/
		iffpic[channel].name 	= NULL;
		iffpic[channel].pictype[0] = '\0';
		iffpic[channel].width 	= 0;
		iffpic[channel].height 	= 0;
		iffpic[channel].depth 	= 0;
		iffpic[channel].screen 	= NULL;
		iffpic[channel].window 	= NULL;
	}
}

LONG iff_func(n,channel)
LONG n,channel;
{
/*
** Return info' about IFF picture on channel N.
*/

  	if (bad(channel))
		{ error_code = BAD_CHAN; return; }

	if (iffpic[channel].name == NULL)
		{ error_code = READ_ERR; return; }
	
	switch(n)
	{
		case 0	:	return((LONG)&iffpic[channel].pictype[0]);  
				break;

		case 1	:	return(iffpic[channel].width);	break;

		case 2	:	return(iffpic[channel].height);	break;

		case 3	:	return(iffpic[channel].depth);	break;

		case 4	:	/* hold-and-modify (HAM) */
				if (iffpic[channel].depth == 6) return(5L);
				else
				/* hi-res interlaced */
				if (iffpic[channel].width > 320 &&
				    iffpic[channel].height > 200) return(4L);
				else
				/* lo-res interlaced */
				if (iffpic[channel].width <= 320 &&
				    iffpic[channel].height > 200) return(3L);
				else
				/* hi-res */
				if (iffpic[channel].width > 320 &&
				    iffpic[channel].height <= 200) return(2L);
				else
				/* lo-res */
				    return(1L);
				break;
					
		default	:	return(0L);
				break;
	}
}

void	readiff(screen_id,channel)
LONG	screen_id,channel;
{
/*
** Read and display an IFF image.
*/
ILBMFrame *picframe;
struct Screen *screen;

    /* 
    ** Open ILBM library. Look in LIBS: then in RAM:ILBMtmp.
    */
    ILBMBase = (struct Library *)OpenLibrary("ilbm.library",0L);

    if (ILBMBase == NULL) ILBMBase = (struct Library *)
				     OpenLibrary("ram:ILBMtmp/ilbm.library",0L);

    if (ILBMBase == NULL) { error_code = READ_ERR; return; }

    /* 
    ** Setup ILBMFrame structure. 
    */
    if (screen_id == -1L || (screen_id >= 1 && screen_id <= 9))
    {
    	picframe = (ILBMFrame *)alloc(CLEARED_ANY_MEM,sizeof(ILBMFrame));
    	if (picframe == NULL) 
        { 
		error_code = READ_ERR;
		if (ILBMBase) CloseLibrary(ILBMBase);
		return;
	}
	
	if (screen_id != -1L)
	{
		/* 
		** Use supplied screen and its default window
		** otherwise let ILBM.library define its own.
		*/
		screen = Screen_list[screen_id];
    		picframe->iScreen = screen;
     		picframe->iWindow = screen->FirstWindow;
	}

    	/*
	** Read and display picture! 
	*/
    	if (LoadIFFToWindow(iffpic[channel].name,picframe) != 0)
       		error_code=READ_ERR;

	/*
	** Store address of window and screen opened by ILBM.library? 
	** [see also IFFPicClose()].
	*/
	if (screen_id == -1L)
	{
		/*
		** Yes.
		*/
		iffpic[channel].screen = picframe->iScreen;
		iffpic[channel].window = picframe->iWindow;
	}
	else
	{
		/* 
		** No! User is responsible for cleaning up
		** open screen and window.
		*/
		iffpic[channel].screen = NULL;
		iffpic[channel].window = NULL;
	}
    }
    else
	error_code = READ_ERR;

    if (ILBMBase) CloseLibrary(ILBMBase);
}
