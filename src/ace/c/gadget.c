/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: gadget functions **
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
     Date: 1st,2nd,6th November 1993,
	   23rd-25th June 1994,
	   10th,12th July 1994,
	   12th March 1995,
	   6th November 1995
*/

#include "acedef.h"

/* externals */
extern	int	sym;
extern	int	lastsym;
extern	BOOL	gadtoolsused;
extern	BOOL	oldgadgetused;
extern	char	id[MAXIDSIZE];
extern	SHORT	shortval;
extern	LONG	longval;
extern	char	stringval[MAXSTRLEN];
extern	int	gttagcount;
extern	int	lev;
extern	SYM	*curr_item;

/* frame address registers (a4 for main, a5 for subs) */
static	char	*gt_addreg[] = { "a4","a5" };

/* GadTools tag lookup table */
#define GT_TAGBASE 0x80080000UL

static struct { char *name; unsigned long value; } gt_tags[] = {
    {"GTBB_RECESSED",	GT_TAGBASE+51},
    {"GTCB_CHECKED",	GT_TAGBASE+4},
    {"GTCY_ACTIVE",	GT_TAGBASE+15},
    {"GTCY_LABELS",	GT_TAGBASE+14},
    {"GTIN_MAXCHARS",	GT_TAGBASE+48},
    {"GTIN_NUMBER",	GT_TAGBASE+47},
    {"GTLV_LABELS",	GT_TAGBASE+6},
    {"GTLV_READONLY",	GT_TAGBASE+7},
    {"GTLV_SCROLLWIDTH",GT_TAGBASE+8},
    {"GTLV_SELECTED",	GT_TAGBASE+54},
    {"GTLV_SHOWSELECTED",GT_TAGBASE+53},
    {"GTLV_TOP",	GT_TAGBASE+5},
    {"GTMX_ACTIVE",	GT_TAGBASE+10},
    {"GTMX_LABELS",	GT_TAGBASE+9},
    {"GTMX_SPACING",	GT_TAGBASE+61},
    {"GTNM_BORDER",	GT_TAGBASE+58},
    {"GTNM_NUMBER",	GT_TAGBASE+13},
    {"GTPA_COLOR",	GT_TAGBASE+17},
    {"GTPA_COLOROFFSET",GT_TAGBASE+18},
    {"GTPA_DEPTH",	GT_TAGBASE+16},
    {"GTPA_INDICATORHEIGHT",GT_TAGBASE+20},
    {"GTPA_INDICATORWIDTH",GT_TAGBASE+19},
    {"GTPA_NUMCOLORS",	GT_TAGBASE+70},
    {"GTSC_ARROWS",	GT_TAGBASE+59},
    {"GTSC_OVERLAP",	GT_TAGBASE+24},
    {"GTSC_TOP",	GT_TAGBASE+21},
    {"GTSC_TOTAL",	GT_TAGBASE+22},
    {"GTSC_VISIBLE",	GT_TAGBASE+23},
    {"GTSL_DISPFUNC",	GT_TAGBASE+44},
    {"GTSL_LEVEL",	GT_TAGBASE+40},
    {"GTSL_LEVELFORMAT",GT_TAGBASE+42},
    {"GTSL_LEVELPLACE",	GT_TAGBASE+43},
    {"GTSL_MAX",	GT_TAGBASE+39},
    {"GTSL_MAXLEVELLEN",GT_TAGBASE+41},
    {"GTSL_MIN",	GT_TAGBASE+38},
    {"GTST_MAXCHARS",	GT_TAGBASE+46},
    {"GTST_STRING",	GT_TAGBASE+45},
    {"GTTX_BORDER",	GT_TAGBASE+57},
    {"GTTX_COPYTEXT",	GT_TAGBASE+12},
    {"GTTX_TEXT",	GT_TAGBASE+11},
    {NULL, 0}
};

unsigned long gt_tag_lookup(name)
char *name;
{
/* Look up a GadTools tag name, return its value or 0 if not found */
int i;
    for (i = 0; gt_tags[i].name != NULL; i++)
    {
	if (strcmp(name, gt_tags[i].name) == 0)
	    return gt_tags[i].value;
    }
    return 0;
}

static BOOL is_array_tag(tag_id)
unsigned long tag_id;
{
/* Returns TRUE if this tag expects a STRPTR* (array of string pointers) */
    return (tag_id == (GT_TAGBASE + 14) ||  /* GTCY_Labels */
	    tag_id == (GT_TAGBASE + 9));    /* GTMX_Labels */
}

/* functions */
int gt_kind_value()
{
/* Return GadTools kind value for current sym, or -1 if not a _KIND token */
    if (sym == buttonkindsym)   return 1;
    if (sym == checkboxkindsym) return 2;
    if (sym == integerkindsym)  return 3;
    if (sym == listviewkindsym) return 4;
    if (sym == mxkindsym)       return 5;
    if (sym == numberkindsym)   return 6;
    if (sym == cyclekindsym)    return 7;
    if (sym == palettekindsym)  return 8;
    if (sym == scrollerkindsym) return 9;
    if (sym == sliderkindsym)   return 11;
    if (sym == stringkindsym)   return 12;
    if (sym == textkindsym)     return 13;
    return -1;
}

void gadget_rectangle()
{
/* (x1,y1)-(x2,y2) */

    if (sym != lparen) _error(14);
    else
    {
     insymbol();
     make_sure_long(expr());	/* x1 */

     if (sym != comma) _error(16);
     else
     {
      insymbol();
      make_sure_long(expr()); /* y1 */

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
     	 make_sure_long(expr());	/* x2 */

         if (sym != comma) _error(16);
         else
         {
          insymbol();
     	  make_sure_long(expr());	/* y2 */

          if (sym != rparen) _error(9);
	  insymbol();
         }
	}
       }
      }
     }
    }
}

void close_gadget()
{
/* GADGET CLOSE gadget-id */

	insymbol();
     	make_sure_long(expr());	/* gadget-id */

	if (gadtoolsused)
	{
		gen("jsr","_CloseGTGadget","  ");
		gen("addq","#4","sp");
		enter_XREF("_CloseGTGadget");
	}
	else
	{
		gen("jsr","_CloseGadget","  ");
		gen("addq","#4","sp");
		enter_XREF("_CloseGadget");
	}
}

void gadget_output()
{
/*
** GADGET OUTPUT id
**
** Make the specified gadget the one from which 
** information may be obtained via the GADGET(n)
** function. This allows the value of a string,
** longint or slider gadget to be obtained at 
** any time rather than just when a gadget event
** occurs.
*/
	insymbol();
     	make_sure_long(expr());	/* gadget-id */

	gen("jsr","_SetCurrentGadget","  ");
	gen("addq","#4","sp");
	enter_XREF("_SetCurrentGadget");
}

void wait_gadget()
{
/* GADGET WAIT gadget-id */

	insymbol();
     	make_sure_long(expr());	/* gadget-id */

	if (gadtoolsused)
	{
		gen("jsr","_WaitGTGadget","  ");
		gen("addq","#4","sp");
		enter_XREF("_WaitGTGadget");
	}
	else
	{
		gen("jsr","_WaitGadget","  ");
		gen("addq","#4","sp");
		enter_XREF("_WaitGadget");
	}
}

void gadget_font()
{
/* GADGET FONT "fontname", size */

	insymbol();
	if (expr() != stringtype)
	{
		_error(4);  /* Type mismatch - expected string */
		return;
	}

	if (sym != comma)
	{
		_error(16);  /* ',' expected */
		return;
	}

	insymbol();
	make_sure_long(expr());  /* size */

	gen("jsr","_SetGTGadgetFont","  ");
	gen("addq","#8","sp");
	enter_XREF("_SetGTGadgetFont");
	gadtoolsused = TRUE;
}

void setattr_gadget()
{
/* GADGET SETATTR id, TAG=value [, TAG=value ...]
**
** For each TAG=value pair, calls _SetGTGadgetAttrSingle(value, tag, id).
** This allows runtime-evaluated expressions as values.
*/
char vbuf[80];
unsigned long tag_id;
static int gtstrcount = 0;

	insymbol();
	make_sure_long(expr());	/* gadget-id -> d0 and on stack */

	/* Save gadget-id to BSS temp and clean up stack */
	enter_BSS("_setattr_id:", "ds.l 1");
	gen("move.l", "(sp)+,_setattr_id", "  ");

	if (sym != comma) { _error(16); return; }

	/* Parse TAG=value pairs, call _SetGTGadgetAttrSingle for each */
	do {
	    insymbol();
	    if (sym != ident)
	    {
		_error(82);
		break;
	    }
	    tag_id = gt_tag_lookup(id);
	    if (tag_id == 0)
	    {
		_error(82);
		break;
	    }
	    insymbol();
	    if (sym != equal)
	    {
		_error(82);
		break;
	    }
	    insymbol();

	    /* Push gadget-id (rightmost param, pushed first) */
	    gen("move.l", "_setattr_id,-(sp)", "  ");

	    /* Push tag constant */
	    sprintf(vbuf, "#$%lx,-(sp)", tag_id);
	    gen("move.l", vbuf, "  ");

	    /* Handle different value types */
	    if (sym == stringconst)
	    {
		/* String constant - create data entry and push address */
		char strlabel[40], strdata[256];
		sprintf(strlabel, "_gtstr%d:", gtstrcount);
		sprintf(strdata, "dc.b '%s',0", stringval);
		enter_DATA(strlabel, strdata);
		sprintf(vbuf, "_gtstr%d", gtstrcount);
		gen("pea", vbuf, "  ");
		gtstrcount++;
		insymbol();
	    }
	    else
	    {
		/* Evaluate expression - result already on stack from expr() */
		make_sure_long(expr());
		/* Don't push d0 - expr() already left it on stack */
	    }

	    /* Call _SetGTGadgetAttrSingle(value, tag, id) */
	    gen("jsr", "_SetGTGadgetAttrSingle", "  ");
	    gen("add.l", "#12,sp", "  ");
	    enter_XREF("_SetGTGadgetAttrSingle");

	} while (sym == comma);

	gadtoolsused = TRUE;
}

void modify_gadget()
{
/* 
** GADGET MOD gadget-id,knob-position[,max-position] 
**
** For the modification of (proportional) gadgets.
*/

	insymbol();
    	make_sure_long(expr());	/* gadget-id */
	
	if (sym != comma) _error(16);
	else
	{
		insymbol();
    		make_sure_long(expr());	/* knob-position */

		/* specify new maximum notches for slider? */
		if (sym != comma) 
			gen("move.l","#-1","-(sp)");
		else
		{
			insymbol();
    			make_sure_long(expr());	/* max-position */
		}

		/* call function */
		gen("jsr","_modify_gad","  ");
		gen("add.l","#12","sp");
		
		enter_XREF("_modify_gad");
		enter_XREF("_GfxBase");
	}
}

void gadget()
{
/* GADGET gadget-id,status[,gadget-value,(x1,y1)-(x2,y2),type[,style][,font,size,txtstyle]]
   GADGET MOD gadget-id,knob-pos[,max-notches]
   GADGET WAIT gadget-id
   GADGET CLOSE gadget-id
   GADGET FONT "fontname",size  (for GadTools gadgets)
   GADGET SETATTR id, TAG=value [, TAG=value ...]
   GADGET ON | OFF | STOP
*/
int  gtype;

	insymbol();
	
	if (sym == onsym || sym == offsym || sym == stopsym)
		change_event_trapping_status(lastsym);
	else
	if (sym == closesym)
		close_gadget();
	else
	if (sym == outputsym)
		gadget_output();
	else
        if (sym == waitsym)
		wait_gadget();
	else
	if (sym == modsym)
		modify_gadget();
	else
	if (sym == setattrsym)
		setattr_gadget();
	else
	if (sym == fontsym)
		gadget_font();
	else
	{
    		make_sure_long(expr());	/* gadget-id */

	 	if (sym != comma) _error(16);
	 	else
	 	{
	 		insymbol();
			if (sym == onsym)
			{
				gen("move.l","#1","-(sp)");
				insymbol();
			}
			else
			if (sym == offsym)
			{
				gen("move.l","#0","-(sp)");
				insymbol();
			}
			else
			{
				/* status */
				make_sure_long(expr());
			}

			if (sym != comma)
			{
				gen("jsr","_ChangeGadgetStatus","  ");
				gen("addq","#8","sp");

				enter_XREF("_ChangeGadgetStatus");
				enter_XREF("_GfxBase");	
				return;	
			}
	 	}

		if (sym != comma) _error(16);
		else
		{
			insymbol();
			gtype = expr();	

			/* string or integer expression for 3rd parameter */
			if (gtype != stringtype)
			{
				make_sure_long(gtype);
			}
		}

		if (sym != comma) _error(16);
		else
		{
			insymbol();
			gadget_rectangle();	/* (x1,y1)-(x2,y2) */

			if (sym != comma) _error(16);
			else
			{
				/*
				** Gadget Type.
				*/
	 			insymbol();

				/*
				** GadTools gadget kind?
				*/
				{
				int kind;
				kind = gt_kind_value();
				if (kind >= 0)
				{
					static char *kv[] = {
					  "#0","#1","#2","#3","#4",
					  "#5","#6","#7","#8","#9",
					  "#10","#11","#12","#13"
					};
					gen("move.l",kv[kind],"-(sp)");
					insymbol();

					if (sym == comma)
					{
					  /* Parse TAG=value pairs */
					  char datalabel[80], dataname[80];
					  char literal[1024];
					  char vbuf[80];
					  int ntags;
					  unsigned long tag_id;
					  long tag_val;
					  BOOL negate;
					  BOOL is_strtag;
					  static int gtstrcount = 0;
					  /* Array tag patch tracking */
					  struct {
					    int tag_index;
					    SYM *array_sym;
					  } arr_patches[10];
					  int num_patches = 0;
					  int pi;

					  strcpy(literal, "dc.l ");
					  ntags = 0;

					  do {
					    insymbol();
					    if (sym != ident)
					    {
					      _error(82);
					      break;
					    }
					    tag_id = gt_tag_lookup(id);
					    if (tag_id == 0)
					    {
					      _error(82);
					      break;
					    }
					    insymbol();
					    if (sym != equal)
					    {
					      _error(82);
					      break;
					    }
					    insymbol();

					    is_strtag = FALSE;

					    if (is_array_tag(tag_id)
						&& sym == ident
						&& exist(id, array)
						&& curr_item->type
						   == stringtype)
					    {
					      /* String array tag value */
					      arr_patches[num_patches]
						.tag_index = ntags;
					      arr_patches[num_patches]
						.array_sym = curr_item;
					      num_patches++;
					      tag_val = 0;
					      insymbol();
					      /* Skip () */
					      if (sym == lparen)
					      {
						insymbol();
						if (sym == rparen)
						  insymbol();
					      }
					    }
					    else if (sym == stringconst)
					    {
					      /* String constant tag value */
					      char strlabel[40], strdata[256];
					      sprintf(strlabel, "_gtstr%d:",
						      gtstrcount);
					      sprintf(strdata, "dc.b '%s',0",
						      stringval);
					      enter_DATA(strlabel, strdata);
					      is_strtag = TRUE;
					      insymbol();
					    }
					    else
					    {
					      negate = FALSE;
					      if (sym == minus)
					      {
						negate = TRUE;
						insymbol();
					      }
					      if (sym == shortconst)
						tag_val = (long)shortval;
					      else if (sym == longconst)
						tag_val = longval;
					      else
					      {
						_error(82);
						break;
					      }
					      if (negate) tag_val = -tag_val;
					      insymbol();
					    }

					    /* Append tag_id,value */
					    if (ntags > 0)
					      strcat(literal, ",");
					    if (is_strtag)
					    {
					      sprintf(vbuf, "$%lx,_gtstr%d",
						      tag_id, gtstrcount);
					      gtstrcount++;
					    }
					    else
					    {
					      sprintf(vbuf, "$%lx,%ld",
						      tag_id, tag_val);
					    }
					    strcat(literal, vbuf);
					    ntags++;
					  } while (sym == comma);

					  /* Append TAG_DONE terminator */
					  strcat(literal, ",0,0");

					  /* Generate DATA entry */
					  sprintf(dataname, "_gttags%d",
						  gttagcount);
					  sprintf(datalabel, "_gttags%d:",
						  gttagcount);
					  gttagcount++;
					  /* Add alignment directive before
					     tag array to avoid unaligned
					     relocation warnings */
					  enter_DATA("", "cnop 0,2");
					  enter_DATA(datalabel, literal);

					  /* Patch array tag values */
					  for (pi = 0; pi < num_patches;
					       pi++)
					  {
					    SYM *asym;
					    char numbuf[40];
					    char patchdst[80];
					    LONG nelem, elemsz;
					    int voff;

					    asym = arr_patches[pi]
						   .array_sym;
					    nelem = max_array_ndx(asym);
					    elemsz = asym->numconst
							 .longnum;
					    /* value offset in tag array:
					       each TagItem is 8 bytes,
					       value is at +4 */
					    voff = arr_patches[pi]
						   .tag_index * 8 + 4;

					    /* Push array base addr */
					    sprintf(numbuf, "#%ld",
						    asym->address);
					    gen("move.l",
						gt_addreg[lev], "d0");
					    gen("sub.l", numbuf, "d0");
					    gen("movea.l", "d0", "a0");
					    gen("move.l", "(a0)",
						"-(sp)");
					    /* Push num_elements */
					    sprintf(numbuf, "#%ld",
						    nelem);
					    gen("move.l", numbuf,
						"-(sp)");
					    /* Push element_size */
					    sprintf(numbuf, "#%ld",
						    elemsz);
					    gen("move.l", numbuf,
						"-(sp)");
					    gen("jsr",
						"_BuildGTLabels", "  ");
					    gen("add.l", "#12", "sp");
					    /* Patch tag value in DATA */
					    sprintf(patchdst, "%s+%d",
						    dataname, voff);
					    gen("move.l", "d0",
						patchdst);
					    enter_XREF(
						"_BuildGTLabels");
					  }

					  /* Push tag array address */
					  gen("pea", dataname, "  ");
					}
					else
					{
					  gen("move.l","#0","-(sp)");
					}

					if (oldgadgetused)
					{
					  _error(81);
					  return;
					}
					gen("jsr","_CreateGTGadget","  ");
					gen("add.l","#36","sp");
					gadtoolsused = TRUE;
					enter_XREF("_CreateGTGadget");
					return;
				}
				}

				if (gadtoolsused)
				{
					_error(81);
					return;
				}
				oldgadgetused = TRUE;

				if (sym == buttonsym)
				{
					gen("move.l","#1","-(sp)");
					insymbol();
				}
				else
				if (sym == stringsym)
				{
					gen("move.l","#2","-(sp)");
					insymbol();
				}
				else
				if (sym == longintsym)
				{
					gen("move.l","#3","-(sp)");
					insymbol();
				}
				else
				if (sym == potxsym)
				{
					gen("move.l","#4","-(sp)");
					insymbol();
				}
				else
				if (sym == potysym)
				{
					gen("move.l","#5","-(sp)");
					insymbol();
				}
				else
				{
					/* type */
					make_sure_long(expr());
				}
			}

			/*
			** Optional gadget style parameter.
			*/
			if (sym != comma)
				gen("move.l","#0","-(sp)");	/* style = 0 */
			else
			{
 				insymbol();

				if (sym != comma)
					make_sure_long(expr());	/* style */
				else
					gen("move.l","#0","-(sp)");  /* style = 0 */	
			}			
		
			/*
			** Optional font and font-size parameters (for button).
			*/
			if (sym != comma)
			{
				gen("move.l","#0","-(sp)");  /* font name = NULL */
				gen("move.l","#0","-(sp)");  /* font size = 0 */
				gen("move.l","#0","-(sp)");  /* font style = 0 */
			}
			else
			{
				insymbol();
				if (expr() != stringtype)    /* font name */
					_error(4);
				else
				{
					if (sym != comma) 
						_error(16);
					else
					{
	 					insymbol();
						make_sure_long(expr());	/* font size */
					}

					if (sym != comma) 
						_error(16);
					else
					{
	 					insymbol();
						make_sure_long(expr());	/* font style */
					}
				}
			}					
	 }

	 /* call function */
	 gen("jsr","_CreateGadget","  ");
	 gen("add.l","#48","sp");

	 enter_XREF("_CreateGadget");
	 enter_XREF("_GfxBase");
	}
}

void	bevel_box()
{
/* 
** BEVELBOX (x1,y1)-(x2,y2),type
*/
	insymbol();

	gadget_rectangle();
	if (sym != comma) _error(16);
	else
	{
		insymbol();
		make_sure_long(expr());	/* type */

	 	/* call function */
		gen("jsr","_BevelBox","  ");
		gen("add.l","#20","sp");

		enter_XREF("_BevelBox");
		enter_XREF("_GfxBase");
	}
}
