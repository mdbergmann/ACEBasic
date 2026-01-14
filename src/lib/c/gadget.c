/*
** ACE linked-library module: Gadgets.
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
** Author: David J Benn
**   Date: 1st,2nd,4th,6th-9th November 1993,
**	   5th,25th December 1993,
**	   7th March 1994,
**	   30th April 1994,
**	   6th May 1994,
**	   20th,21st,24th,25th,30th June 1994,
**	   6th,7th,10th,12th,24th,29th July 1994,
**	   26th-28th August 1994,
**	   3rd,10th September 1994,
**	   27th February 1995,
**	   11th,12th March 1995,
**	   6th,7th November 1995
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include "intuievent.h"

#define CLEARED_ANY_MEM    7L

#define	MAXCHARS 	   1024L

#define MAXGADGET 	   255
#define CLOSEGAD	   256L

#define FontWidth	   (Scrn->RastPort.Font->tf_XSize)
#define FontHeight	   (Scrn->RastPort.Font->tf_YSize)

#define RAISED 		   1L
#define STRGADBOX	   3L

/* type declarations */
typedef	union  gadinfo_type {
			struct	StringInfo stringinfo;
			struct	PropInfo   propinfo;
		       } GADINFO;

typedef struct gadget_type {
			BOOL	used/*,selected*/;
			ULONG	type,style;
			ULONG	maxval;
			SHORT 	gadpairs[10];
			SHORT 	bb_x1, bb_y1, bb_x2, bb_y2;
			WORD	render_buffer[4];
			struct	Border 	  gadborder;
			struct	IntuiText gadtext;
			struct	Gadget	  gad;
			GADINFO gadinfo;	
		    } GAD;

/* globals */
static	BOOL	first_creation=TRUE;
static	GAD 	gadlist[MAXGADGET+1];
static	ULONG	gadnum=0;

/* external variables */
extern	struct 	Screen	 *Scrn;
extern	struct 	Window	 *Wdw;
extern	struct	RastPort *RPort;
extern	struct	Library  *DiskfontBase;
	
/* external functions */
extern 	LONG	stringcompare();
extern 	LONG	long_from_string();
extern 	ULONG	stringlength();
extern	void	stringcopy();
extern	void	*alloc();
extern	void	set_wdw_close_num();
extern	void	BevelBox();

/* functions */	
UBYTE *FontOK(fontName,fontSize,textStyle,theText,textLength,fontHeight)
UBYTE *fontName;
ULONG fontSize,textStyle;
UBYTE *theText;
SHORT *textLength,*fontHeight;
{
/*
** Determine whether requested font can be used. If so,
** textLength is set to the number of pixels which would
** be occupied by the specified text, fontHeight is set to
** the height of the requested font, and a pointer to the 
** full name of the font is returned.
*/
UBYTE *tmp,*font;
ULONG oldStyle;
struct TextAttr theFont;
struct TextFont *oldFont,*newFont;

	DiskfontBase = (struct Library *)
			OpenLibrary("diskfont.library",0L);

	if (DiskfontBase && fontName != NULL)
	{
		/* append ".font" to name if not present */
		font = (UBYTE *)alloc(CLEARED_ANY_MEM,stringlength(fontName)+6);
					
		stringcopy(font,fontName);
		tmp = font;
		while (*tmp && *tmp != '.') tmp++;
		if (stringcompare(*tmp,".font") != 0) stringcopy(tmp,".font");

		/* set up TextAttr structure */
		theFont.ta_Name 	= (STRPTR)font;
		theFont.ta_YSize	= (UWORD)fontSize;
		theFont.ta_Style	= (UBYTE)textStyle;
		theFont.ta_Flags	= FPF_DISKFONT;

		/* attempt to open font */
		newFont = (struct TextFont *)OpenDiskFont(&theFont);	

		/* 
		** Set new font, set length and height parameters, 
		** set old font again, close font under test. Style
		** may also need to be restored if newFont's differs
		** from oldFont's.
		*/
		if (newFont) 
		{
			oldFont = RPort->Font;
			oldStyle = RPort->AlgoStyle;
			SetFont(RPort,newFont);

			*textLength = (WORD)TextLength(RPort,theText,
						       stringlength(theText));
			*fontHeight = RPort->Font->tf_YSize;

			SetFont(RPort,oldFont);
			SetSoftStyle(RPort,oldStyle,0xFFFF);
			CloseFont(newFont);
		}

		/* cleanup */
		CloseLibrary(DiskfontBase);

		/* font is OK */
		return font;
	}
	else
		/* font is not OK */
		return NULL;
}

void CreateBoolGadget(textstyle,fontsize,fontname,gadstyle,
		      bottom,right,top,left,gadval,status,id)
ULONG textstyle,fontsize;
UBYTE *fontname;
ULONG gadstyle,bottom,right,top,left,gadval,status,id;
{
/* create a boolean gadget */
SHORT width,height,text_left,text_top,gad_center_X,gad_center_Y;
SHORT text_length,font_height;
struct TextAttr theFont;
UBYTE *realName;

	/* width and height of gadget */
	width 	= right-left;
	height 	= bottom-top;

	/* text font,style,position */
	gad_center_X  	= width/2; 
	gad_center_Y  	= height/2; 
	
	if (realName = FontOK(fontname,fontsize,textstyle,(UBYTE *)gadval,
			      &text_length,&font_height))
	{
		/*
		** Font can be used.
		*/
		theFont.ta_Name  = (STRPTR)realName;
		theFont.ta_YSize = (UWORD)fontsize;
		theFont.ta_Style = (UBYTE)textstyle;
		theFont.ta_Flags = FPF_DISKFONT;

		gadlist[id].gadtext.ITextFont = &theFont;
	
		text_left = gad_center_X - text_length/2; 
		text_top  = gad_center_Y - font_height/2;
	}
	else
	{
		/*
		** Font not specified or invalid.
		*/
		gadlist[id].gadtext.ITextFont = NULL;

		text_left = gad_center_X - (FontWidth*stringlength((UBYTE *)gadval))/2; 
		text_top  = gad_center_Y - FontHeight/2;
	}

	/* border point pairs */
	gadlist[id].gadpairs[0] = 0;
	gadlist[id].gadpairs[1] = 0;
	gadlist[id].gadpairs[2] = width;
	gadlist[id].gadpairs[3] = 0;
	gadlist[id].gadpairs[4] = width;
	gadlist[id].gadpairs[5] = height;
	gadlist[id].gadpairs[6] = 0;
	gadlist[id].gadpairs[7] = height;
	gadlist[id].gadpairs[8] = 0;
	gadlist[id].gadpairs[9] = 0;

	/* fill border structure */
	gadlist[id].gadborder.LeftEdge 	= 0;
	gadlist[id].gadborder.TopEdge 	= 0;
	gadlist[id].gadborder.FrontPen 	= 1;
	gadlist[id].gadborder.BackPen 	= 0;
	gadlist[id].gadborder.DrawMode	= JAM2;
	gadlist[id].gadborder.Count	= 5;
	gadlist[id].gadborder.XY	= gadlist[id].gadpairs;
	gadlist[id].gadborder.NextBorder= NULL;

	/* fill intuitext structure */
	gadlist[id].gadtext.FrontPen	= 1;
	gadlist[id].gadtext.BackPen	= 0;
	gadlist[id].gadtext.DrawMode	= JAM2;
	gadlist[id].gadtext.LeftEdge	= text_left;
	gadlist[id].gadtext.TopEdge	= text_top;

	gadlist[id].gadtext.IText = (UBYTE *)
				     alloc(CLEARED_ANY_MEM,
					   stringlength((UBYTE *)gadval)+1);
	stringcopy(gadlist[id].gadtext.IText,(UBYTE *)gadval);
	gadlist[id].gadtext.NextText	= NULL;

	/* fill gadget structure */
	gadlist[id].gad.NextGadget	= NULL;
	gadlist[id].gad.LeftEdge	= (SHORT)left;
	gadlist[id].gad.TopEdge		= (SHORT)top;
	gadlist[id].gad.Width		= width;
	gadlist[id].gad.Height		= height;
	gadlist[id].gad.Activation	= RELVERIFY;
	gadlist[id].gad.GadgetType	= BOOLGADGET;
	gadlist[id].gad.GadgetRender	= (APTR)&gadlist[id].gadborder;
	gadlist[id].gad.SelectRender	= NULL;
	gadlist[id].gad.GadgetText	= &gadlist[id].gadtext;
	gadlist[id].gad.MutualExclude	= NULL;
	gadlist[id].gad.SpecialInfo	= NULL;
	gadlist[id].gad.GadgetID	= (USHORT)id;
	gadlist[id].gad.UserData	= NULL;

	/* 
	** Set selection style (1=bgnd color fill, 2=bgnd color box,
	** 3=bgnd color fill+borderless+no text).
	*/

	gadlist[id].gad.Flags = NULL;  /* Clear flags from last usage. */

	switch(gadstyle)
	{
	 case 1  : gadlist[id].gad.Flags = GADGHCOMP; 
		   break;

	 case 2  : gadlist[id].gad.Flags = GADGHBOX; 
		   break;

	 case 3  : gadlist[id].gad.Flags = GADGHCOMP;  /* same as 1, but no BB */
		   break;
	}

	/* disable gadget? */
	if (status == 0) gadlist[id].gad.Flags |= GADGDISABLED;

	/* don't render a border - let bevelbox do that. */
	gadlist[id].gad.GadgetRender = NULL;

	/* render the gadget! */
	AddGadget(Wdw,&gadlist[id].gad,(UWORD)id);
	RefreshGList(&gadlist[id].gad,Wdw,NULL,1);
	
	/* make gadget beveled if not borderless */
	gadlist[id].bb_x1 = left;
	gadlist[id].bb_y1 = top;
	gadlist[id].bb_x2 = right-1;
	gadlist[id].bb_y2 = bottom-1;
	if (gadstyle != 3) BevelBox(RAISED,bottom-1,right-1,top,left);
}

void CreateStringGadget(gadstyle,gadtype,bottom,right,top,left,gadval,status,id)
ULONG gadstyle,gadtype,bottom,right,top,left,gadval,status,id;
{
/* create a string gadget */
SHORT width,height;

	/* width and height of gadget */
	width 	= right-left;
	height 	= bottom-top;

	/* how many characters can be accomodated by gadget? */
	gadlist[id].maxval = MAXCHARS;

	/* border point pairs */
	gadlist[id].gadpairs[0] = 0;
	gadlist[id].gadpairs[1] = 0;
	gadlist[id].gadpairs[2] = width;
	gadlist[id].gadpairs[3] = 0;
	gadlist[id].gadpairs[4] = width;
	gadlist[id].gadpairs[5] = height;
	gadlist[id].gadpairs[6] = 0;
	gadlist[id].gadpairs[7] = height;
	gadlist[id].gadpairs[8] = 0;
	gadlist[id].gadpairs[9] = 0;

	/* fill border structure */
	gadlist[id].gadborder.LeftEdge 	= -6;
	gadlist[id].gadborder.TopEdge 	= -3;
	gadlist[id].gadborder.FrontPen 	= 1;
	gadlist[id].gadborder.BackPen 	= 0;
	gadlist[id].gadborder.DrawMode	= JAM2;
	gadlist[id].gadborder.Count	= 5;
	gadlist[id].gadborder.XY	= gadlist[id].gadpairs;
	gadlist[id].gadborder.NextBorder= NULL;

	/* fill gadget's gadinfo.stringinfo structure */
	gadlist[id].gadinfo.stringinfo.Buffer = (UBYTE *)
				AllocMem(MAXCHARS,MEMF_ANY | MEMF_CLEAR);
	gadlist[id].gadinfo.stringinfo.UndoBuffer = (UBYTE *)
				AllocMem(MAXCHARS,MEMF_ANY | MEMF_CLEAR);

	stringcopy(gadlist[id].gadinfo.stringinfo.Buffer,(UBYTE *)gadval);

	gadlist[id].gadinfo.stringinfo.BufferPos = 0;
	gadlist[id].gadinfo.stringinfo.MaxChars = (SHORT)MAXCHARS;
	gadlist[id].gadinfo.stringinfo.DispPos = 0;
	gadlist[id].gadinfo.stringinfo.UndoPos = 0;
	gadlist[id].gadinfo.stringinfo.NumChars = 0;
	gadlist[id].gadinfo.stringinfo.DispCount = 0;
	gadlist[id].gadinfo.stringinfo.CLeft = 0;
	gadlist[id].gadinfo.stringinfo.CTop = 0;

	if (gadtype == 3)
		gadlist[id].gadinfo.stringinfo.LongInt = long_from_string(gadval);
	else
		gadlist[id].gadinfo.stringinfo.LongInt = 0L;

	gadlist[id].gadinfo.stringinfo.AltKeyMap = NULL;
	
	/* fill gadget structure */
	gadlist[id].gad.NextGadget	= NULL;
	gadlist[id].gad.LeftEdge	= (SHORT)left;
	gadlist[id].gad.TopEdge		= (SHORT)top;
	gadlist[id].gad.Width		= width-FontWidth-1;
	gadlist[id].gad.Height		= height;
 	gadlist[id].gad.Flags 		= GADGHCOMP; 
	gadlist[id].gad.Activation	= RELVERIFY;
	gadlist[id].gad.GadgetType	= STRGADGET;
	gadlist[id].gad.GadgetRender	= (APTR)&gadlist[id].gadborder;
	gadlist[id].gad.SelectRender	= NULL;
	gadlist[id].gad.GadgetText	= NULL;
	gadlist[id].gad.MutualExclude	= NULL;
	gadlist[id].gad.SpecialInfo	= (APTR)&gadlist[id].gadinfo.stringinfo;
	gadlist[id].gad.GadgetID	= (USHORT)id;
	gadlist[id].gad.UserData	= NULL;

	/* string or longint gadget type? */
	if (gadtype == 3) gadlist[id].gad.Activation |= LONGINT;

	/* set selection style (0=LEFT, 1=CENTER, 2=RIGHT, N=LEFT) */
	switch(gadstyle)
	{
	 case 1  : gadlist[id].gad.Activation |= STRINGCENTER;
		   break;

	 case 2  : gadlist[id].gad.Activation |= STRINGRIGHT;
		   break;
	}

	/* render the gadget! */
	AddGadget(Wdw,&gadlist[id].gad,(UWORD)id);
	RefreshGList(&gadlist[id].gad,Wdw,NULL,1);

	/* disable gadget? -> do so after rendering: don't want to see shadow. */
	if (status == 0) gadlist[id].gad.Flags |= GADGDISABLED;

	/* make gadget beveled */ 
	gadlist[id].bb_x1 = left-6;
	gadlist[id].bb_y1 = top-3;
	gadlist[id].bb_x2 = right-6;
	gadlist[id].bb_y2 = bottom-3;
	BevelBox(STRGADBOX,bottom-3,right-6,top-3,left-6);
}

void CreatePropGadget(gadstyle,gadtype,bottom,right,top,left,gadval,status,id)
ULONG gadstyle,gadtype,bottom,right,top,left,gadval,status,id;
{
/* create a proportional gadget */
SHORT width,height;

	/* width and height of gadget */
	width 	= right-left;
	height 	= bottom-top;

	/* record knob increment */
	if (gadval <= 0) gadval=1; 
	gadlist[id].maxval = 0xFFFF / gadval;

	/* fill gadinfo.propinfo structure */
	gadlist[id].gadinfo.propinfo.Flags = AUTOKNOB;

	switch(gadtype)
	{
	 case 4 : gadlist[id].gadinfo.propinfo.HorizPot = 0;
		  gadlist[id].gadinfo.propinfo.HorizBody = gadlist[id].maxval;
		  break;

	 case 5 : gadlist[id].gadinfo.propinfo.VertPot = 0;
		  gadlist[id].gadinfo.propinfo.VertBody = gadlist[id].maxval;
		  break;
	}

	gadlist[id].gadinfo.propinfo.CWidth 	= 0;
	gadlist[id].gadinfo.propinfo.CHeight 	= 0;
	gadlist[id].gadinfo.propinfo.HPotRes 	= 0;
	gadlist[id].gadinfo.propinfo.VPotRes 	= 0;
	gadlist[id].gadinfo.propinfo.LeftBorder	= 0;
	gadlist[id].gadinfo.propinfo.TopBorder 	= 0;

	/* fill gadget structure */
	gadlist[id].gad.NextGadget	= NULL;
	gadlist[id].gad.LeftEdge	= (SHORT)left+4;
	gadlist[id].gad.TopEdge		= (SHORT)top+2;
	gadlist[id].gad.Width		= width-7;
	gadlist[id].gad.Height		= height-3;
	gadlist[id].gad.Flags		= GADGHCOMP;
	gadlist[id].gad.Activation	= RELVERIFY;
	gadlist[id].gad.GadgetType	= PROPGADGET;
	gadlist[id].gad.GadgetRender	= (APTR)gadlist[id].render_buffer;
	gadlist[id].gad.SelectRender	= NULL;
	gadlist[id].gad.GadgetText	= NULL;
	gadlist[id].gad.MutualExclude	= NULL;
	gadlist[id].gad.SpecialInfo	= (APTR)&gadlist[id].gadinfo.propinfo;
	gadlist[id].gad.GadgetID	= (USHORT)id;
	gadlist[id].gad.UserData	= NULL;

	/* set type (4=horizontal, 5=vertical, N=horizontal) */
	switch(gadtype)
	{
	 case 4  : gadlist[id].gadinfo.propinfo.Flags |= FREEHORIZ; 
		   break;

	 case 5  : gadlist[id].gadinfo.propinfo.Flags |= FREEVERT; 
		   break;
	}

	/* set style */
	if (gadstyle == 1) 
           gadlist[id].gadinfo.propinfo.Flags |= PROPBORDERLESS;
 
	/* disable gadget? */
	if (status == 0) gadlist[id].gad.Flags |= GADGDISABLED;

	/* prepare for beveled gadget [if not borderless]? */ 
	if (gadstyle != 1)
	   gadlist[id].gadinfo.propinfo.Flags |= PROPBORDERLESS;

	/* render the gadget! */
	AddGadget(Wdw,&gadlist[id].gad,(UWORD)id);
	RefreshGList(&gadlist[id].gad,Wdw,NULL,1);

	/* make gadget beveled if not borderless */ 
	gadlist[id].bb_x1 = left;
	gadlist[id].bb_y1 = top;
	gadlist[id].bb_x2 = right;
	gadlist[id].bb_y2 = bottom;
	if (gadstyle != 1) BevelBox(RAISED,bottom,right,top,left);
}

void CreateGadget(textstyle,fontsize,fontname,gadstyle,gadtype,
		  bottom,right,top,left,gadval,status,id)
ULONG textstyle,fontsize;
UBYTE *fontname;
ULONG gadstyle,gadtype,bottom,right,top,left,gadval,status,id;
{
/* create a gadget */
ULONG i;

	if (first_creation)
	{
		first_creation=FALSE;
		for (i=1;i<=MAXGADGET;i++) 
		{
			gadlist[i].used=FALSE;			
			/*gadlist[i].selected=FALSE;*/
		}
	}

	if (id < 1 || id > MAXGADGET || left > right || top > bottom ||
	    gadtype < 1 || gadtype > 5 || gadlist[id].used) return;

	/* store essential info' */
	gadlist[id].used=TRUE;
	gadlist[id].type=gadtype;
	gadlist[id].style=gadstyle;

	/* create the gadget */
	switch(gadtype)
	{
	 /* boolean gadget */
	 case 1	 : CreateBoolGadget(textstyle,fontsize,fontname,gadstyle,
				    bottom,right,top,left,gadval,status,id);
	  	   break;	

	 /* string or longint gadget */
	 case 2	 : 
	 case 3  : CreateStringGadget(gadstyle,gadtype,bottom,right,top,left,
				      gadval,status,id);
	  	   break;	

	 /* horizontal or proportional gadget */
	 case 4	 : 
	 case 5  : CreatePropGadget(gadstyle,gadtype,bottom,right,top,left,
				    gadval,status,id);
	  	   break;	
	}	 
}

void EraseGadget(id)
ULONG id;
{
/* erase gadget */
SHORT x1,y1,x2,y2;
UBYTE FgPen;

	x1 = gadlist[id].bb_x1;
	y1 = gadlist[id].bb_y1;
	x2 = gadlist[id].bb_x2;
	y2 = gadlist[id].bb_y2;

	/* erase gadget imagery */
	FgPen = RPort->FgPen;
	SetAPen(RPort,RPort->BgPen);
	RectFill(RPort,x1,y1,x2,y2);
	SetAPen(RPort,FgPen);
}

void ChangeGadgetStatus(status,id)
ULONG status,id;
{
ULONG x1,y1,x2,y2;
/* change status of a gadget */

	if (id < 1 || id > MAXGADGET || !gadlist[id].used) return;

  	/*
	** If not a string/longint gadget, remove gadget. Don't
	** want to modify the imagery of these 2 gadget types,
	** just their status. A disabled string/longint gadget
	** simply doesn't respond to mouse or keyboard actvity.
	*/
	if (gadlist[id].type != 2 && 
	    gadlist[id].type != 3) RemoveGadget(Wdw,&gadlist[id].gad);

	/* enable or disable gadget */
	switch(status)
	{
	 /* disable */
	 case 0 : gadlist[id].gad.Flags |= GADGDISABLED;
		  break;

	 /* enable */
	 case 1 : if (gadlist[id].gad.Flags & GADGDISABLED)
		  {
		      	gadlist[id].gad.Flags &= ~GADGDISABLED;

			/* remove old gadget imagery, if not string/longint. */
			if (gadlist[id].type != 2 && 
	    		    gadlist[id].type != 3) EraseGadget(id);
		  }
		  break;
	}

	/* replace modified gadget (if not a string/longint gadget) */
	if (gadlist[id].type != 2 && gadlist[id].type != 3)
	{
		AddGadget(Wdw,&gadlist[id].gad,(UWORD)id);
		RefreshGList(&gadlist[id].gad,Wdw,NULL,1);
	}

	/* redraw bevel-box? (if not a string/longint gadget) */
	if (status == 1 && gadlist[id].type != 2 && gadlist[id].type != 3)
	{
		x1 = gadlist[id].bb_x1;
		y1 = gadlist[id].bb_y1;
		x2 = gadlist[id].bb_x2;
		y2 = gadlist[id].bb_y2;

		switch(gadlist[id].type)
		{
	 		/* boolean gadget */
			case 1 : if (gadlist[id].style != 3) 
					BevelBox(RAISED,y2,x2,y1,x1);
		 	 	 break;

		 	/* horizontal or proportional gadget */
			case 4 :
			case 5 : BevelBox(RAISED,y2,x2,y1,x1);
		 	 	 break;
		}
	}
}

void modify_gad(notches,posn,id)
LONG 	notches;
ULONG 	posn,id;
{
/*
** Modify a (proportional) gadget.
*/
ULONG 	max_notches,vertbody,horizbody,vertpot,horizpot;

	/* sanity checks */

	if (id < 1 || id > MAXGADGET || !gadlist[id].used) return;

	if (gadlist[id].type != 4 && gadlist[id].type != 5) return;

	/* determine (new) maximum # of notches */
	if (notches <= 0)
		/* 0xFFFF DIV increment */
		max_notches = 0xFFFF / gadlist[id].maxval;
	else
		max_notches = (ULONG)notches;

	/* is requested knob position off the scale? */
	if (posn > max_notches)	return;

	/* store (new) info' about max. # of levels in slider */
	gadlist[id].maxval = 0xFFFF / max_notches;

	/* calculate position and knob size */
	switch(gadlist[id].type)
	{
		case 4 : horizpot  = posn * gadlist[id].maxval;
			 horizbody = gadlist[id].maxval;
			 vertpot   = gadlist[id].gadinfo.propinfo.VertPot;
			 vertbody  = gadlist[id].gadinfo.propinfo.VertBody;
			 break;

		case 5 : vertpot   = posn * gadlist[id].maxval;
			 vertbody  = gadlist[id].maxval;
			 horizpot  = gadlist[id].gadinfo.propinfo.HorizPot;
			 horizbody = gadlist[id].gadinfo.propinfo.HorizBody;
			 break;
	}

	/* modify it! */
	NewModifyProp(&gadlist[id].gad,Wdw,NULL,
		      gadlist[id].gadinfo.propinfo.Flags,
		      horizpot,vertpot,horizbody,vertbody,1);
}

void CloseGadget(id)
ULONG id;
{
/* close a gadget */

	if (id < 1 || id > MAXGADGET || !gadlist[id].used) return;

	gadlist[id].used=FALSE;
	/*gadlist[id].selected=FALSE;*/

	/* free string gadget buffers */
	if (gadlist[id].type == 2 || gadlist[id].type == 3) 
	{
	  if (gadlist[id].gadinfo.stringinfo.Buffer)
	     FreeMem(gadlist[id].gadinfo.stringinfo.Buffer,
		     gadlist[id].maxval);

	  if (gadlist[id].gadinfo.stringinfo.UndoBuffer)
	     FreeMem(gadlist[id].gadinfo.stringinfo.UndoBuffer,
		     gadlist[id].maxval);
	}

	RemoveGadget(Wdw,&gadlist[id].gad);
	EraseGadget(id);
}

void SetCurrentGadget(id)
ULONG id;
{
/*
** Set the current gadget so that information may
** be obtained about a gadget via the GADGET(n) 
** function at times other than when a gadget event 
** occurs. This only makes sense in conjunction with
** string, longint and slider gadgets (not buttons).
*/	
	if (id < 1 || id > MAXGADGET || !gadlist[id].used) return;
	
	/* if (gadnum >= 1 && gadnum <= MAXGADGET) 
		     gadlist[gadnum].selected=FALSE;    necessary??? */

	gadnum = id;
}

void WaitGadget(id)
ULONG id;
{
/* wait on a specific gadget (id), or any gadget if id=0 */
struct 	IntuiMessage *message;
struct	Gadget *GadPtr;
USHORT	GadNum;
ULONG	MsgClass;

	if (id < 0 || id > MAXGADGET || 
	   (id > 0 && !gadlist[id].used)) return;

	/* soak up pending messages first? ** MAY RESULT IN MESSAGE LOSS? **
	while ((message = (struct IntuiMessage *)
			  GetMsg(Wdw->UserPort))) ReplyMsg(message); */

	do
	{
		/* await a message */
		if ((message = (struct IntuiMessage *)
				GetMsg(Wdw->UserPort)) == NULL)
		{
			Wait(1L << Wdw->UserPort->mp_SigBit);
			continue;
		}

		/* extract info' about Intuition event */
		MsgClass = message->Class;
		GadPtr 	 = (struct Gadget *)message->IAddress;
		if (MsgClass & GADGETUP) 
		   GadNum = GadPtr->GadgetID;
		else
		   GadNum = 0;

		/* reply to message */
		ReplyMsg(message);

		/* since GADGET WAITing will interfere with
        	** CLOSEWINDOW messages, do we have one? 
		*/
		if (MsgClass & CLOSEWINDOW) 
		{
			set_wdw_close_num();
			gadnum = CLOSEGAD;
			return;
		}

		/* will any gadget do? */
		if (id == 0 && (MsgClass & GADGETUP)) break; 
	}
	while (!(MsgClass & GADGETUP) || GadNum != id);

	/*gadlist[(ULONG)GadNum].selected = TRUE;*/
	gadnum = (ULONG)GadNum;
}

ULONG gadget_event_test()
{
/* test for the occurrence of a gadget event. */
IntuiInfo *message;
USHORT	  GadNum;
ULONG	  MsgClass;

	/* attempt to get a message */
	if ((message = GetIntuiEvent(Wdw->UserPort)) == NULL) return(0L);

	/* extract info' about Intuition event */
	MsgClass = message->Class;
	if (MsgClass & GADGETUP) 
	   GadNum = message->GadgetID;
	else
	   GadNum = 0;

	/* message matched */
	if (MsgClass & GADGETUP) ClearIntuiEvent(); 

	/* has a gadget been selected? */
	if ((MsgClass & GADGETUP) && (GadNum >= 1 && GadNum <= MAXGADGET))
	{
	    	/*gadlist[(ULONG)GadNum].selected=TRUE;*/
		gadnum = (ULONG)GadNum;
		return(1L);
	}
	else
		return(0L);
}

ULONG GadFunc(n)
ULONG n;
{
/* 
** Return information about the
** currently selected gadget after
** a gadget event or following a
** Gadget Output command.
*/
ULONG  i;
UBYTE  *s;
USHORT p;

	switch(n)
	{
		/* has a gadget been selected since the 
		   last call to GadFunc(0)? */

		case 0 : if (gadget_event_test())
				return -1L;
			  else
				return 0L;

			   /*for (i=1;i<=MAXGADGET;i++)
			 	if (gadlist[i].used && 
				    gadlist[i].selected)
				{
					gadnum = i;
					gadlist[i].selected=FALSE;
					return(-1L);
				}

				return(0L); */	/* none selected */

				break;


		/* return ID of last gadget selected */

		case 1 : /*if (gadnum >= 1 && gadnum <= MAXGADGET) 
			    gadlist[gadnum].selected=FALSE;*/

			 return(gadnum);
			 break;


		/* return string or longint value from string gadget */

		case 2 : if (gadlist[gadnum].type != 2 &&
			     gadlist[gadnum].type != 3)
			 return(0L);
			 else
			 switch(gadlist[gadnum].type)
			 {
			  case 2 : 
		          s = gadlist[gadnum].gadinfo.stringinfo.Buffer;
			  return((ULONG)s);
			  break;

			  case 3 : 
			  return(gadlist[gadnum].gadinfo.stringinfo.LongInt);
			  break;				 
			 }
			 break;


		/* return horizontal or vertical slider position */

		case 3 : if (gadlist[gadnum].type != 4 &&
			     gadlist[gadnum].type != 5)
			 return(0L);
			 else
			 {
			  switch(gadlist[gadnum].type)
			  {
			     case 4 : 
			     p=gadlist[gadnum].gadinfo.propinfo.HorizPot;
			     break;

			     case 5 : 
			     p=gadlist[gadnum].gadinfo.propinfo.VertPot;
			     break;
			  }

			  /* actual-knob-posn DIV knob-size */
		          return((ULONG)(p / gadlist[gadnum].maxval));
			 }
			 break;


		/* return address of currently selected gadget */

		case 4 : if (gadnum >= 1 && gadnum <= MAXGADGET)
				return (ULONG)&gadlist[gadnum].gad;
			 else
				return 0L;
			 break;


		/* for any other argument to the GADGET function... */

		default : return 0L;
			  break;
	}
}
