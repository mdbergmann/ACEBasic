/* 
** Invoke a system requester using AutoRequest().
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
**   Date: 13th January, 
**	   22nd-27th December 1993,
**	   2nd January 1994,
**	   14th August 1994
*/

#include <exec/types.h>
#include <intuition/intuition.h>

#define  FontWidth  (RPort->Font->tf_XSize)
#define  FontHeight (RPort->Font->tf_YSize)

/* externals variables */
extern struct Window *Wdw;
extern struct RastPort *RPort;

/* external functions */
extern ULONG stringlength();

/* functions */
void fill_intuitext(txt,left,top,msg)
struct IntuiText *txt;
SHORT  left,top;
UBYTE  *msg;
{
  txt->FrontPen  = 0;
  txt->BackPen   = 1;
  txt->DrawMode  = JAM1;
  txt->LeftEdge  = left;
  txt->TopEdge   = top;
  txt->ITextFont = NULL;	/* use default font */
  txt->IText     = msg;
  txt->NextText  = NULL;
}

SHORT sysrequest(response2,response1,body)
char *response2,*response1,*body;
{
SHORT  req_x,req_y,x_offset,y_offset;
struct IntuiText main;
struct IntuiText pprompt;
struct IntuiText nprompt;

  /* 
  ** Build and display a system requester, then
  ** return a result (0 or 1) indicating which
  ** button was pressed. Note: response1 must
  ** be non-NULL for this to work and the Intuition
  ** library must be open. Under Wb 1.3, the width
  ** of the requester is derived from the width of
  ** the "body" text. Wb 2.04 controls this width
  ** independently.
  */
 
  if (response1 == NULL) return 0;	/* 0 = error */

  req_x = stringlength(body)*FontWidth + FontWidth*5;
  req_y = FontHeight*8;

  x_offset = FontWidth >> 1;
  y_offset = FontHeight >> 1;

  fill_intuitext(&main,FontWidth,FontHeight,body);

  if (response2 != NULL)
  {
    /* two gadgets (eg: OK + CANCEL) */
    fill_intuitext(&pprompt,x_offset,y_offset,response1);
    fill_intuitext(&nprompt,x_offset,y_offset,response2);
    return -1*AutoRequest(Wdw,&main,&pprompt,&nprompt,NULL,NULL,req_x,req_y);
  }
  else
  {
    /* one gadget (eg: OK) */
    fill_intuitext(&nprompt,x_offset,y_offset,response1);
    AutoRequest(Wdw,&main,NULL,&nprompt,NULL,NULL,req_x,req_y);
    return -1;
  }
}
