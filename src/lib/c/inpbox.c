/* 
** ACE db.lib module: INPUTBOX and INPUTBOX$.
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
** Return a string or long integer value via a custom requester.
**
** Author: David J Benn
**   Date: 5th,6th,12th,15th January 1994,
** 	   5th April 1994,
**	   6th,7th,24th July 1994
*/

#include <exec/types.h>
#include <intuition/intuition.h>

#define FontHeight (Scrn->RastPort.Font->tf_YSize)

#define OKGAD	  1
#define CANCELGAD 2 
#define INPUTGAD  3
#define BUFSIZE   1024

#define RAISED	  1L
#define STRGADBOX 3L

/* external variables */
extern 	struct 	Screen *Scrn,*WBScrn;
extern	struct	RastPort *RPort;

/* external functions */
extern	ULONG	stringlength();
extern	void	BevelBox();

/* globals */
UBYTE  InputBuffer[BUFSIZE];
UBYTE  UndoBuffer[BUFSIZE];
struct Window *ReqWdw;
struct Requester InpBox;

/* Font for Requester text (gadgets and prompt) */
struct TextAttr InpBoxFont =
{
  (STRPTR)"topaz.font",8,0,FPF_ROMFONT
};

/* Gadget Structures */
SHORT InputPairs[] = 
{
  0,0,271,0,271,12,0,12,0,0
};

SHORT CancelPairs[] = 
{
  0,0,60,0,60,13,0,13,0,0  
};

SHORT OKPairs[] = 
{
  0,0,30,0,30,13,0,13,0,0  
};

struct Border InputBorder =
{
  -6,-3,1,0,JAM2,5,InputPairs,NULL
};

struct Border CancelBorder =
{
  -1,-1,1,0,JAM1,5,CancelPairs,NULL
};

struct Border OKBorder =
{
  -1,-1,1,0,JAM1,5,OKPairs,NULL
};

struct IntuiText CancelText =
{
  1,0,JAM2,6,3,&InpBoxFont,(UBYTE *)"Cancel",NULL
};

struct IntuiText OKText =
{
  1,0,JAM2,7,3,&InpBoxFont,(UBYTE *)"OK",NULL
};

struct StringInfo InputGadInfo =
{
  &InputBuffer[0],
  &UndoBuffer[0],
  0,			/* buffer position */
  BUFSIZE,		/* maxchars */
  0,			/* display position */
  0,			/* undo position */
  0,			/* numchars */
  0,			/* display counter */
  0,			/* CLeft */
  0,			/* CTop */
  NULL,			/* layerptr */
  0,			/* longint */
  NULL			/* altkeymap */
};

struct Gadget InputGad =
{
  NULL,			/* next gadget */
  12,19,		/* left, top */
  270,10,		/* width, height */
  GADGHCOMP,		/* flags */
  0,			/* activation -> set by each gadget type */
  STRGADGET | 
  REQGADGET,		/* gadget type */
  (APTR)&InputBorder,	/* render */
  NULL,			/* select render */
  NULL,			/* intuitext */
  NULL,			/* mutual exclude */
  (APTR)&InputGadInfo,	/* special string gadget info */
  INPUTGAD,		/* gadget number */ 
  NULL			/* user data */
};

struct Gadget CancelGad =
{
  &InputGad,		/* next gadget */
  219,35,		/* left, top */ 
  60,13,		/* width, height */
  GADGHCOMP,		/* flags */
  RELVERIFY |
  ENDGADGET,		/* activation */
  BOOLGADGET | 
  REQGADGET,		/* gadget type */
  NULL, 		/* render */
  NULL,			/* select render */
  &CancelText,		/* intuitext */
  NULL,			/* mutual exclude */
  NULL,			/* special string gadget info */
  CANCELGAD,		/* gadget number */ 
  NULL			/* user data */
};

struct Gadget OKGad =
{
  &CancelGad,		/* next gadget */
  9,35,			/* left, top */ 
  30,13,		/* width, height */
  GADGHCOMP,		/* flags */
  RELVERIFY |
  ENDGADGET,		/* activation */
  BOOLGADGET | 
  REQGADGET,		/* gadget type */
  NULL, 		/* render */
  NULL,			/* select render */
  &OKText,		/* intuitext */
  NULL,			/* mutual exclude */
  NULL,			/* special string gadget info */
  OKGAD,		/* gadget number */ 
  NULL			/* user data */
};

/* Requester NewWindow Structure */
struct NewWindow InpBoxWdw =
{
  0,0,			/* left, top  -> set later */
  296,0,		/* width, height -> set below */
  0,1,			/* detailpen, blockpen */
  GADGETUP |
  REQCLEAR |
  ACTIVEWINDOW,		/* IDCMP flags */
  WINDOWDEPTH |		
  WINDOWDRAG |
  ACTIVATE |
  SMART_REFRESH,	/* flags */
  NULL,			/* first gadget */
  NULL,			/* check mark */
  NULL,		 	/* title -> set later */
  NULL,			/* screen -> set later */
  NULL,			/* bitmap */
  0,0,			/* min width, height */ 
  0,0,			/* max width, height */ 
  0 			/* type -> set later */
};

/* functions */
struct IntuiText *make_intuitext_prompt(prompt,txt)
UBYTE  *prompt;
struct IntuiText *txt;
{
  txt->FrontPen  = 3;
  txt->BackPen 	 = 0;
  txt->DrawMode	 = JAM2;
  txt->LeftEdge	 = 10;
  txt->TopEdge 	 = 4;
  txt->ITextFont = &InpBoxFont;
  txt->IText	 = prompt;
  txt->NextText	 = NULL;

  return(txt);
}

BOOL InpBox_Request()
{
BOOL   retval,Waiton=TRUE;
ULONG  MessageClass;
struct IntuiMessage *message;
struct Gadget *GadgetPtr;
USHORT GadgetID;

  /* 
  ** Handle the requester's gadgets allowing 
  ** the user to enter text and quit when done.
  */
  while (Waiton)
  {
  	if ((message = (struct IntuiMessage *)
	    GetMsg(ReqWdw->UserPort)) == NULL)
	{
		Wait(1L << ReqWdw->UserPort->mp_SigBit);
		continue;
	}

	MessageClass = message->Class;

	if (MessageClass == REQCLEAR)
	{
		Waiton = FALSE;
	}
	else
	if (MessageClass == GADGETUP)
	{
		GadgetPtr = (struct Gadget *)message->IAddress;
		GadgetID = GadgetPtr->GadgetID;

		switch(GadgetID)
		{
			case INPUTGAD	: break;
			case CANCELGAD	: retval = FALSE; break;
			case OKGAD	: retval = TRUE; break;
		}
	}

        ReplyMsg(message);
  }

  return(retval);
}

void await_wdw_activation()
{
BOOL   Waiton=TRUE;
ULONG  MessageClass;
struct IntuiMessage *message;

  /* 
  ** Wait for the requester's window to become active
  ** so we can safely activate the string gadget. 
  */
  while (Waiton)
  {
  	if ((message = (struct IntuiMessage *)
	    GetMsg(ReqWdw->UserPort)) == NULL)
	{
		Wait(1L << ReqWdw->UserPort->mp_SigBit);
		continue;
	}

	MessageClass = message->Class;
	ReplyMsg(message);

	if (MessageClass == ACTIVEWINDOW)
	{
		Waiton=FALSE;
		continue;
	}
  }
}

void set_parameters(title,defval,xpos,ypos) 
UBYTE *title,*defval;
SHORT xpos,ypos;
{
UBYTE  	*buf,*undo;
int 	i;

  /* modify values as necessary */

  /* 
  ** Adjust for title bar size and consequent 
  ** lowering of requester layer.
  */
  InpBoxWdw.Height = 65;
  if (FontHeight >= 8) 
     InpBoxWdw.Height += (FontHeight-8);  /* use Topaz 8 as a baseline. */

  /* Set Screen Type */
  if (Scrn != WBScrn) 
  {
	InpBoxWdw.Type = CUSTOMSCREEN;
	InpBoxWdw.Screen = Scrn;
  }
  else
  {
	InpBoxWdw.Type = WBENCHSCREEN;
	InpBoxWdw.Screen = NULL;
  }
 
  if (xpos != 0) InpBoxWdw.LeftEdge = xpos;
  else
      InpBoxWdw.LeftEdge = 0;

  if (ypos != 0) InpBoxWdw.TopEdge = ypos;
  else
      InpBoxWdw.TopEdge = 0;

  if (title) 
	InpBoxWdw.Title = title;
  else
	InpBoxWdw.Title = (UBYTE *)"  ";

  /* fill input buffers with ASCII zeros in case defval=NULL */
  buf = InputBuffer; undo = UndoBuffer;
  for (i=0;i<BUFSIZE;i++) { InputBuffer[i] = 0; UndoBuffer[i] = 0; }  

  /* put default value into input buffers? */
  if (defval)
  {
	i=0;
  	while (*defval && i<BUFSIZE-1) 
	{ 
		*buf++ = *defval; 
		*undo++ = *defval++;
		++i; 
	}
  }
}

BOOL satisfy_request(prompt,title,defval,xpos,ypos)
UBYTE *prompt,*title,*defval;
SHORT xpos,ypos;
{
struct 	IntuiText txt;
struct	RastPort  *old_RPort;
BOOL   	result;

  set_parameters(title,defval,xpos,ypos);

  /* open requester window */
  ReqWdw = (struct Window *)OpenWindow(&InpBoxWdw);

  if (ReqWdw)
  {
	/* invoke the requester */
	InitRequester(&InpBox);  	
	InpBox.LeftEdge = 5;
  	InpBox.TopEdge = FontHeight+3;  /* clear the window's title bar */
	InpBox.Width = 290;
	InpBox.Height = 50;
	InpBox.ReqGadget = &OKGad;
	if (prompt) 
		InpBox.ReqText = make_intuitext_prompt(prompt,&txt);
	else
		InpBox.ReqText = make_intuitext_prompt((UBYTE *)"  ",&txt);

	/* render requester */
	Request(&InpBox,ReqWdw);

	/* wait for window to become active */
	await_wdw_activation();

	/* activate the string gadget */
	ActivateGadget(&InputGad,ReqWdw,&InpBox);

	/* render 3D gadget imagery */
	old_RPort = RPort;
	RPort = InpBox.ReqLayer->rp;
	BevelBox(RAISED,47,38,35,9);		/* OK */
	BevelBox(RAISED,47,278,35,219);		/* Cancel */
	BevelBox(STRGADBOX,29,280,19-3,12-6);
	RPort = old_RPort;

	/* await request */
	result = InpBox_Request();
	EndRequest(&InpBox,ReqWdw);

	if (ReqWdw) CloseWindow(ReqWdw);
   	return(result);
  }
  else
      	/* couldn't invoke requester */
     	return(FALSE);
}

UBYTE *string_input_box(ypos,xpos,defval,title,prompt)
SHORT ypos,xpos;
UBYTE *defval,*title,*prompt;
{
	/* INPUTBOX$ */
	InputGad.Activation = RELVERIFY;
	InputGadInfo.MaxChars = BUFSIZE;

	if (!satisfy_request(prompt,title,defval,xpos,ypos))
	   InputBuffer[0] = '\0';  /* there may have been a default value! */

	return(InputBuffer);
}

LONG  longint_value(x)
UBYTE *x;
{
UBYTE *tmp;
BOOL  negnum;
LONG  num=0L;

	/* convert string to a long integer value */
 	tmp = x;

	/* get optional sign */
	if (*tmp == '-' || *tmp == '+')
	{
		if (*tmp == '-') negnum = TRUE;
		++tmp;
	}
	else
		negnum = FALSE;

	/* get integer value */
	while (*tmp)
	{
		if (*tmp >= '0' && *tmp <= '9')
			num = num*10 + *tmp-'0';
		else
			{ num = 0L; break; }	

		++tmp;
	}

	num = negnum ? -num : num;

	return(num);
}

LONG  longint_input_box(ypos,xpos,defval,title,prompt)
SHORT ypos,xpos;
UBYTE *defval,*title,*prompt;
{
	/* INPUTBOX */
	InputGad.Activation = RELVERIFY | LONGINT;

	if (defval) 
		InputGadInfo.LongInt = longint_value(defval);
	else
		InputGadInfo.LongInt = 0L;

	if (satisfy_request(prompt,title,defval,xpos,ypos))
		return(InputGadInfo.LongInt);
	else
		return(0L);
}
