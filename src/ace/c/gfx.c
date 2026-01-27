/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: graphics functions **
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
     Date: 26th October-30th November, 1st-13th December 1991,
	   14th,20th-27th January 1992, 
           2nd-17th, 21st-29th February 1992, 
	   1st,13th,14th,22nd,23rd March 1992,
	   21st,22nd April 1992,
	   2nd,3rd,11th,15th,16th May 1992,
	   7th,8th,9th,11th,13th,14th,28th,29th,30th June 1992,
	   2nd-8th,14th-19th,26th-29th July 1992,
	   1st-3rd,7th,8th,9th August 1992,
	   6th,7th,12th,13th December 1992,
	   4th January 1993,
	   1st July 1993,
	   6th February 1994,
	   14th July 1994,
	   28th August 1994
*/

#include "acedef.h"

/* locals */
static	char	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	int	sym;
extern	int	lev;
extern	int	obj;
extern	SHORT	shortval;
extern	CODE	*curr_code;
extern	SYM	*curr_item;
extern	char	id[MAXIDSIZE];

/* functions */
void pset()
{
BOOL relative;
BOOL colorset=FALSE;

  insymbol();
  if (sym == stepsym)
  { 
   insymbol();
   relative=TRUE; 
  }
  else relative=FALSE;
   
  if (sym != lparen) _error(14);
  else
     {
      /* x-coordinate */
      insymbol();
      make_sure_short(expr());
      if (sym != comma) _error(16);
      else
      {
       /* y-coordinate */
       insymbol();
       make_sure_short(expr());
       if (sym != rparen) _error(9);
       else
       {
	insymbol();
	if (sym == comma)
        {
	 /* pen color */
	 insymbol();
	 make_sure_short(expr());
	 gen("move.w","(sp)+","d0");
	 gen("move.l","_RPort","a1");
	 gen("move.l","_GfxBase","a6");
	 gen("jsr","_LVOSetAPen(a6)","  ");
	 enter_XREF("_LVOSetAPen");
	 enter_XREF("_GfxBase");
	 enter_XREF("_RPort");
	 colorset=TRUE;
	}
	else colorset=FALSE;
       }
       /* pop y-coordinate */
       gen("move.w","(sp)+","d1");
      }
      /* pop x-coordinate */
      gen("move.w","(sp)+","d0");
     }	

     /* plot point */
     if (!colorset)
     {
      gen("move.l","_GfxBase","a6");
      enter_XREF("_GfxBase");
      gen("move.l","_RPort","a1");
      enter_XREF("_RPort");
     }

     if (relative)
     {
       gen("add.w","36(a1)","d0");   /* x + RPort->cp_x */
       gen("add.w","38(a1)","d1");   /* y + RPort->cp_y */
       gen("jsr","_LVOMove(a6)","  ");
       enter_XREF("_LVOMove");
     }

     /* 
     ** Save appropriate registers for call to WritePixel()
     ** since Move() may clobber them.
     */ 
     gen("move.l","a1","a3");
     gen("move.w","d0","d3");
     gen("move.w","d1","d4");

     gen("jsr","_LVOMove(a6)","  ");

     /* 
     ** Restore appropriate registers for call to WritePixel().
     */
     gen("move.w","d4","d1");	
     gen("move.w","d3","d0");	
     gen("move.l","a3","a1");
     	
     gen("jsr","_LVOWritePixel(a6)","  ");

     enter_XREF("_LVOMove");  /* Must call Move() to change pen pos'n */
     enter_XREF("_LVOWritePixel");  

     if (colorset)
     {
      /* change back to old pen */
      gen("move.w","_fgdpen","d0");
      gen("move.l","_RPort","a1");
      gen("move.l","_GfxBase","a6");
      gen("jsr","_LVOSetAPen(a6)","  ");
      enter_XREF("_fgdpen");
     }
}

void paint()
{
BOOL paintcolor=FALSE;
BOOL bordercolor=FALSE;

 /* PAINT (X,Y)[,paintcolor-id[,bordercolor-id]] */

 insymbol();
 if (sym != lparen) _error(14);
 else
 {
  insymbol();
  make_sure_short(expr()); /* X */

  if (sym != comma) _error(16);
  else
  {
   insymbol();
   make_sure_short(expr()); /* Y */
   
   if (sym != rparen) _error(9);
   else
   {
    insymbol();
    if (sym == comma) 
    {
     insymbol();
     if (sym != comma)
     {
      make_sure_short(expr()); /* paintcolor-id */
      paintcolor=TRUE;
     }
     
     if (sym == comma)
     {
      insymbol();
      make_sure_short(expr()); /* bordercolor-id */
      bordercolor=TRUE;
     }
    }
   }
   /* pop parameters */
   if (bordercolor)
      gen("move.w","(sp)+","d3");
   else
      gen("moveq","#-1","d3");  /* flag no border color-id */

   if (paintcolor)
      gen("move.w","(sp)+","d2");
   else
      gen("moveq","#-1","d2");  /* flag no paint color-id */

   gen("move.w","(sp)+","d1");  /* Y */
   gen("move.w","(sp)+","d0");  /* X */
   
   /* call paint routine */
   gen("jsr","_paint","  ");
   enter_XREF("_paint");
   enter_XREF("_GfxBase");
  }
 }
}

void circle()
{
BOOL relative;
BOOL colorset=FALSE;
BOOL start_angle=FALSE;
BOOL end_angle=FALSE;
BOOL aspect=FALSE;
BOOL fill=FALSE;

  insymbol();
  if (sym == stepsym)
  { 
   insymbol();
   relative=TRUE; 
  }
  else relative=FALSE;
   
  if (sym != lparen) { _error(14); return; }
  else
     {
      /* x-coordinate */
      insymbol();
      make_sure_short(expr());
      if (sym != comma) { _error(16); return; }
      else
      {
       /* y-coordinate */
       insymbol();
       make_sure_short(expr());
       if (sym != rparen) { _error(9); return; }
       else
       {
	insymbol();
	if (sym != comma) 
           { _error(29); return; } /* radius expected -> no point going on */
        else
        {
	 /* radius */
	 insymbol();
	 gen_Flt(expr());
        }
       }
      }
     }
  
     if (sym == comma)
     {
      /* color */
      insymbol();
      if (sym != comma)   /* else skipping to next parameter (start angle) */
      {
       make_sure_short(expr());
       gen("move.w","(sp)+","d0");
       gen("move.l","_RPort","a1");
       gen("move.l","_GfxBase","a6");
       gen("jsr","_LVOSetAPen(a6)","  ");
       enter_XREF("_LVOSetAPen");
       enter_XREF("_GfxBase");
       enter_XREF("_RPort");
       colorset=TRUE;
      }
     }
     else colorset=FALSE;
  
     /* start & end angle in <<degrees>> */

     if (sym == comma)
     {
      insymbol();
      if (sym != comma)  /* else skip to end angle */
      {
       gen_Flt(expr());
       gen("move.l","(sp)+","d3"); /* start angle */
       start_angle=TRUE;
      }

     if (sym == comma) 
     {
      insymbol();
      if (sym != comma)  /* else skip to aspect */
      {
       if (!start_angle) _error(30); /* no start angle! */
       gen_Flt(expr());
       gen("move.l","(sp)+","d4"); /* end angle */
       end_angle=TRUE;
      }
     }
     else _error(16);  

     if (sym == comma)
     {
      /* aspect */
      insymbol();
      if (sym != comma && !(sym == ident && id[0]=='F' && (id[1]=='\0' || id[1]==':')))
      {
       gen_Flt(expr());
       gen("move.l","(sp)+","d5"); /* aspect */
       aspect=TRUE;
      }
     }

     /* fill flag? */
     if (sym == ident && id[0]=='F' && (id[1]=='\0' || id[1]==':'))
     {
      fill = TRUE;
      insymbol();
     }
     else if (sym == comma)
     {
      insymbol();
      if (sym == ident && id[0]=='F' && (id[1]=='\0' || id[1]==':'))
      {
       fill = TRUE;
       insymbol();
      }
     }
    }
  
     /* pop radius & (x,y) coordinates */
     gen("move.l","(sp)+","d2");      /* radius */
     gen("move.w","(sp)+","_shorty"); /* y */
     gen("move.w","(sp)+","_shortx"); /* x */

     if (relative)
     {
       gen("move.l","_RPort","a1");

       gen("move.w","_shortx","d0");
       gen("add.w","36(a1)","d0");   /* x + RPort->cp_x */
       gen("move.w","d0","_shortx");

       gen("move.w","_shorty","d0");
       gen("add.w","38(a1)","d0");   /* y + RPort->cp_y */
       gen("move.w","d0","_shorty");
     }

     /* convert x & y values to floats */
     gen("move.w","_shortx","d0");
     gen("ext.l","d0","  ");
     gen("move.l","_MathBase","a6");
     gen("jsr","_LVOSPFlt(a6)","  ");
     gen("move.l","d0","_floatx");

     gen("move.w","_shorty","d0");
     gen("ext.l","d0","  ");
     gen("move.l","_MathBase","a6");
     gen("jsr","_LVOSPFlt(a6)","  ");
     gen("move.l","d0","_floaty");

     gen("move.l","_floatx","d0");
     gen("move.l","_floaty","d1");

     if (!start_angle) gen("moveq","#0","d3");  /* default is zero */
     if (!end_angle)  gen("move.l","#$b3800049","d4");  /* default is 359 */
     if (!aspect) gen("move.l","#$e147af3f","d5");  /* default is .44 */

     if (fill && !start_angle && !end_angle)
     {
      gen("jsr","_fillellipse","  ");
      enter_XREF("_fillellipse");
     }
     else if (fill && (start_angle || end_angle))
     {
      _error(83);  /* fill not supported for arcs */
      gen("jsr","_ellipse","  ");
      enter_XREF("_ellipse");
     }
     else
     {
      gen("jsr","_ellipse","  ");
      enter_XREF("_ellipse");
     }
     enter_XREF("_GfxBase");
     enter_XREF("_MathBase");
     enter_XREF("_MathTransBase");

     enter_BSS("_shortx","ds.w 1");
     enter_BSS("_shorty","ds.w 1");
     enter_BSS("_floatx","ds.l 1");
     enter_BSS("_floaty","ds.l 1");
   
     if (colorset)
     {
      /* change back to old pen */
      gen("move.w","_fgdpen","d0");
      gen("move.l","_RPort","a1");
      gen("move.l","_GfxBase","a6");
      gen("jsr","_LVOSetAPen(a6)","  ");
      enter_XREF("_fgdpen");
     }          
}

void draw_line()
{
BOOL relative=FALSE;
BOOL colorset=FALSE;
BOOL box=FALSE;
BOOL boxfill=FALSE;
CODE *cx,*cx1,*cx2,*cx3,*cx4,*cx5,*cx6;

 if (sym == stepsym)
 {
  relative=TRUE;
  insymbol();
 }
 else relative=FALSE;
 
 if (sym != lparen)
    _error(14);
 else
 {
  insymbol();
  make_sure_short(expr());  /* x */
  if (sym != comma)
     _error(16);
  else
  {
   insymbol();
   make_sure_short(expr()); /* y */
   if (sym != rparen)
      _error(9);
   else
   {
    gen("move.w","(sp)+","d1");   /* ymin */
    gen("move.w","(sp)+","d0");   /* xmin */
    
    /* save x1 & y1 since they may be changed by expr() calls below. */
    gen("move.w","d0","_xmin");   cx1=curr_code;
    gen("move.w","d1","_ymin");   cx2=curr_code;
    enter_BSS("_xmin","ds.w 1");
    enter_BSS("_ymin","ds.w 1");

    gen("move.l","_RPort","a1");
    gen("move.l","_GfxBase","a6");
    enter_XREF("_GfxBase");
    enter_XREF("_RPort");

     if (!relative)
     {
      /* move to x,y */
      gen("jsr","_LVOMove(a6)","  "); 
      cx=curr_code;  /* don't need this Move for boxfill */
      /* XREF declared by box or line (see below) */
     }
     
     insymbol();
    }
   
   /* second coordinate clause ? */
   if (sym != minus)
   {
    if (relative)
    {
     /* no second coordinate clause */
     /* draw line from last pen position to x,y */
     gen("move.l","_RPort","a1");
     gen("move.l","_GfxBase","a6");
     gen("jsr","_LVODraw(a6)","  ");
     enter_XREF("_LVODraw");
    }
    else _error(21);
   }
   else
   {
    insymbol();
    if (sym != lparen)
       _error(14);
    else
    {
     insymbol();
     make_sure_short(expr());  /* x */
     if (sym != comma)
        _error(16);
     else
     {
      insymbol();
      make_sure_short(expr()); /* y */
      if (sym != rparen)
         _error(9);
      else
      {
       /* pen color ? */
       insymbol();
       if (sym == comma)
       {
	insymbol();
	if (sym != comma)	/* ",," -> no color-id */
        {
	 colorset=TRUE;
	 gen("move.w","_xmin","-(sp)");	/* save d0 & d1 */
	 cx3=curr_code;
	 gen("move.w","_ymin","-(sp)");
	 cx4=curr_code;
         make_sure_short(expr());
         gen("move.l","_RPort","a1");
         gen("move.l","_GfxBase","a6");
         gen("move.w","(sp)+","d0");
         gen("jsr","_LVOSetAPen(a6)","  ");
	 gen("move.w","(sp)+","_ymin");
	 cx5=curr_code;
	 gen("move.w","(sp)+","_xmin");	/* restore d0 & d1 */
	 cx6=curr_code;
         enter_XREF("_LVOSetAPen");
	}
        else colorset=FALSE;
       }

       /* box or boxfill? */
       if (sym == comma)
       {
        insymbol();
	if (sym == ident)
        {
         if ((id[0]=='B') && ((id[1]=='\0') || (id[1]==':'))) box=TRUE;
         else
             if (((id[0]=='B') && (id[1]=='F'))
                && ((id[2]=='\0') || (id[2]==':'))) boxfill=TRUE;
             else
		 _error(20);
         insymbol();
        }
      }

      /* draw the line, outline box, or filled box */
      if (box)
      {
	gen("move.w","(sp)+","d5");  /* y2 */
	gen("move.w","(sp)+","d4");  /* x2 */
	gen("move.w","_ymin","d3");     /* y1 */
    	gen("move.w","_xmin","d2");     /* x1 */
       	/* x1=d2; y1=d3 x2=d4; y2=d5 */
       	/* already moved to x1,y1 */
        gen("move.l","_RPort","a1");
        gen("move.l","_GfxBase","a6");
        gen("move.w","d4","d0");	
	gen("move.w","d3","d1");	
	gen("jsr","_LVODraw(a6)","  "); /* x1,y1 - x2,y1 */
        gen("move.w","d4","d0");	
	gen("move.w","d5","d1");	
	gen("jsr","_LVODraw(a6)","  "); /* x2,y1 - x2,y2 */
        gen("move.w","d2","d0");	
	gen("move.w","d5","d1");	
	gen("jsr","_LVODraw(a6)","  "); /* x2,y2 - x1,y2 */
        gen("move.w","d2","d0");	
	gen("move.w","d3","d1");	
	gen("jsr","_LVODraw(a6)","  "); /* x1,y2 - x1,y1 */
	enter_XREF("_LVODraw");
	enter_XREF("_LVOMove");
        enter_BSS("_xmin","ds.w 1");
        enter_BSS("_ymin","ds.w 1");
      }		
      else
      if (boxfill)
      {
	change(cx,"nop","  ","  ");   /* don't need Move */
        gen("move.l","_RPort","a1");
        gen("move.l","_GfxBase","a6");
	gen("move.w","(sp)+","d3");  /* ymax */
	gen("move.w","(sp)+","d2");  /* xmax */
     	gen("move.w","_ymin","d1");     /* ymin */
	gen("move.w","_xmin","d0");     /* xmin */
        gen("jsr","_LVORectFill(a6)","  ");
        enter_XREF("_LVORectFill"); 
        enter_BSS("_xmin","ds.w 1");
        enter_BSS("_ymin","ds.w 1");
      }
      else
      {
        /* draw line */
        gen("move.l","_RPort","a1");
        gen("move.l","_GfxBase","a6");
	gen("move.w","(sp)+","d1");  /* y2 */
	gen("move.w","(sp)+","d0");  /* x2 */
	/* already moved to x1,y1 */
        gen("jsr","_LVODraw(a6)","  ");
        enter_XREF("_LVODraw");
   	enter_XREF("_LVOMove");
	/* don't need to save x1 & x2 in _xmin & _ymin */
	change(cx1,"nop","  ","  ");
 	change(cx2,"nop","  ","  ");
	if (colorset)
	{
	 change(cx3,"nop","  ","  ");
	 change(cx4,"nop","  ","  ");
	 change(cx5,"nop","  ","  ");
	 change(cx6,"nop","  ","  ");
	}
      }
     }  	    
    }
   }
   }
  }
 }
 if (colorset)
 {
  /* change back to old pen */
  gen("move.w","_fgdpen","d0");
  gen("move.l","_RPort","a1");
  gen("move.l","_GfxBase","a6");
  gen("jsr","_LVOSetAPen(a6)","  ");
  enter_XREF("_fgdpen");
 }
}

void color()
{
 /* foreground color */
 insymbol();
 make_sure_short(expr());
 gen("move.w","(sp)+","d0");
 gen("move.w","d0","_fg");   /* foreground pen for text color change */
 gen("move.w","d0","_fgdpen");  /* change global foreground color holder */
 gen("move.l","_RPort","a1");
 gen("move.l","_GfxBase","a6");
 gen("jsr","_LVOSetAPen(a6)","  ");
 enter_XREF("_LVOSetAPen");
 enter_XREF("_GfxBase");
 enter_XREF("_RPort");
 enter_XREF("_fgdpen");
 enter_BSS("_fg","ds.w 1");

 if (sym == comma)
 {
  /* background color */
  insymbol();
  make_sure_short(expr());
  gen("move.w","(sp)+","d0");
  gen("move.w","d0","_bg");  /* background pen for text color change */
  gen("move.w","d0","_bgpen"); /* change global background pen color */
  gen("move.l","_RPort","a1");
  gen("move.l","_GfxBase","a6");
  gen("jsr","_LVOSetBPen(a6)","  ");
  enter_XREF("_LVOSetBPen");
  enter_XREF("_bgpen");
  enter_BSS("_bg","ds.w 1");
 }
 else 
 {
  /* default to current background pen */
  gen("move.w","_bgpen","_bg");
  enter_XREF("_bgpen");
  enter_BSS("_bg","ds.w 1");
 }

 /* call text color change routine */
 gen("move.w","_fg","d0");
 gen("move.w","_bg","d1");
 gen("jsr","_changetextcolor","  ");
 enter_XREF("_changetextcolor");
 enter_XREF("_DOSBase");
}

void area()
{
BOOL relative;
  /* AREA [STEP](x,y) */

  insymbol();
  if (sym == stepsym)
  { 
   insymbol();
   relative=TRUE; 
  }
  else relative=FALSE;
   
  if (sym != lparen) _error(14);
  else
     {
      /* x-coordinate */
      insymbol();
      make_sure_short(expr());
      if (sym != comma) _error(16);
      else
      {
       /* y-coordinate */
       insymbol();
       make_sure_short(expr());
       if (sym != rparen) _error(9);
       else
       {
        /* pop y-coordinate */
        gen("move.w","(sp)+","d1");
	insymbol();
       }
      }
      /* pop x-coordinate */
      gen("move.w","(sp)+","d0");
     }	

     /* include point in area info' */
     if (relative)
     {
       gen("add.w","_last_areaX","d0");   /* d0 = x + lastareaY */
       gen("add.w","_last_areaY","d1");   /* d1 = y + lastareaY */
       enter_XREF("_last_areaX");
       enter_XREF("_last_areaY");
     }

     gen("jsr","_area","  ");

     enter_XREF("_area");
     enter_XREF("_GfxBase");

}

areafill()
{
 /* AREAFILL [mode] */

 insymbol();

 if ((sym == shortconst) && ((shortval == 0) || (shortval == 1)))
 { 
  switch(shortval)
  {
   case 0 : gen("move.w","#0","d0"); break;
   case 1 : gen("move.w","#1","d0"); break;
  }
  insymbol();
 }
 else
     gen("move.w","#0","d0");
  
 gen("jsr","_areafill","  ");

 enter_XREF("_areafill");
 enter_XREF("_GfxBase");
}

pattern()
{
char addrbuf[40];
char numbuf[20];
BOOL linepatterncalled;

 /* PATTERN [line-pattern][,area-pattern] | RESTORE */ 

 insymbol();

 if (sym == restoresym) 
 {
  /* restore default pattern */
  gen("move.l","#1","d1");	/* RESTORE flag */
  gen("jsr","_linepattern","  ");
  enter_XREF("_linepattern");
  gen("move.l","#1","d1");	/* RESTORE flag */
  gen("jsr","_areapattern","  ");
  enter_XREF("_areapattern");
  insymbol();
 }
 else
 {
  if (sym != comma)
  {
   /* get line-pattern */
   make_sure_short(expr());
   gen("move.w","(sp)+","d0");	/* line-pattern */
   gen("move.l","#0","d1");	/* RESTORE flag */
   gen("jsr","_linepattern","  ");
   enter_XREF("_linepattern");
   linepatterncalled=TRUE;
  }
  else
      linepatterncalled=FALSE;

  if (sym == comma)
  {
   /* area-pattern */
   insymbol();
   if ((sym == ident) && (obj == variable) && (exist(id,array)))
   {
      if (curr_item->type != shorttype) _error(28);
      else
      {
        if (!linepatterncalled)
        {
	 /* line-pattern must be set
	    to $FFFF if none specified,
	    otherwise area-pattern doesn't
	    seem to work! 
	 */
         gen("move.l","#1","d1");	/* set line-pattern to $FFFF */
         gen("jsr","_linepattern","  ");
         enter_XREF("_linepattern");
	}

       	/* get address of array */
       	itoa(-1*curr_item->address,addrbuf,10);
       	strcat(addrbuf,frame_ptr[lev]);
       	gen("move.l",addrbuf,"a0");	/* start address of array */

       	/* size of array? */
	sprintf(numbuf,"#%ld",curr_item->size/2);
	gen("move.l",numbuf,"d0");	/* size of array */

        gen("move.l","#0","d1");	/* RESTORE flag */
        gen("jsr","_areapattern","  ");
        enter_XREF("_areapattern");
	enter_XREF("_MathBase");
	enter_XREF("_MathTransBase");	/* need to find Log2(size) */
      }

     insymbol();
   }
   else
       _error(28);  /* short integer array expected */ 
  }
 }
}

void scroll()
{
 /* SCROLL (xmin,ymin)-(xmax,ymax),delta-x,delta-y */

 insymbol();

 if (sym != lparen) _error(14);
 else
 {
  insymbol();
  make_sure_short(expr());  /* xmin */
  if (sym != comma) _error(16);
  else
  {
   insymbol();
   make_sure_short(expr());  /* ymin */
   if (sym != rparen) _error(9);
   else
   {
    insymbol();
    if (sym != minus) _error(21);
    else
    {
     insymbol();
     if (sym != lparen) _error(14);
     else
     {
      insymbol(); 
      make_sure_short(expr());      /* xmax */
      if (sym != comma) _error(16);
      else
      {
       insymbol();
       make_sure_short(expr());     /* ymax */
       if (sym != rparen) _error(9);
       else
       {
	insymbol();
	if (sym != comma) _error(16);
	else
	{
	 insymbol();
	 make_sure_short(expr());   /* delta-x */ 	
	 if (sym != comma) _error(16);
	 else
	 {
	  insymbol();
	  make_sure_short(expr());  /* delta-y */	
	 }
	}     
       }

       	/* pop parameters */
	gen("move.w","(sp)+","d1");		/* delta-y */
	gen("neg.w","d1","  ");			
	gen("move.w","(sp)+","d0");		/* delta-x */
	gen("neg.w","d0","  ");
	gen("move.w","(sp)+","d5");  		/* ymax */
	gen("move.w","(sp)+","d4");  		/* xmax */
	gen("move.w","(sp)+","d3");  		/* ymin */
	gen("move.w","(sp)+","d2");  		/* xmin */

	/* call ScrollRaster function */
	gen("movea.l","_RPort","a1");		/* RastPort */
	gen("movea.l","_GfxBase","a6");
	gen("jsr","_LVOScrollRaster(a6)","  ");
	enter_XREF("_LVOScrollRaster");
	enter_XREF("_GfxBase");
	enter_XREF("_RPort");
       } 
      }
     }
    }
   }
  }
 }

void text_style()
{
/* STYLE n */
int stype;

  insymbol();
  stype = expr();

  if (stype == stringtype)
	_error(4);
  else
  {
  	if (make_integer(stype) == shorttype) make_long(); 
	gen("jsr","_change_text_style","  ");
	gen("addq","#4","sp");
	enter_XREF("_change_text_style");
	enter_XREF("_GfxBase");
  }
}

void text_font()
{
/* FONT name,size */
int ftype;

  insymbol();
  
  if (expr() != stringtype)
  	_error(4);
  else
  {
	if (sym != comma)
		_error(16);
	else
	{
		insymbol();
  		ftype = expr();

  		if (ftype == stringtype)
			_error(4);
  		else
  		{
  			if (make_integer(ftype) == shorttype) make_long();

			gen("jsr","_change_text_font","  ");
			gen("addq","#8","sp");
			enter_XREF("_change_text_font");
			enter_XREF("_GfxBase");
  		}
	}		
  }
}

void gfx_get()
{
/* GET */
 insymbol();
}

void gfx_put()
{
/* PUT */
 insymbol();
}
