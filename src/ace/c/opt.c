/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Optimiser **
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
     Date: 8th,9th,11th,14th June 1992,
	   2nd,5th July 1992,
	   6th December 1992,
	   25th December 1993,
	   5th,9th-11th April 1994,
	   24th July 1994,
	   11th September 1994,
	   11th March 1995
*/

#include "acedef.h"

/* globals */
CODE  *curr, *first, *second;
char  opcode[40],srcopr[40],destopr[40];
SHORT peep=0;

/* externals */
extern	CODE	*code;

/* functions */
BOOL is_a_move(opcode)
char *opcode;
{
 if (opcode[0] == 'm')
 {
   if (strcmp(opcode,"move.b") == 0) return(TRUE);
   else
   if (strcmp(opcode,"move.w") == 0) return(TRUE);
   else
   if (strcmp(opcode,"move.l") == 0) return(TRUE);
   else
       return(FALSE);
 }
 else
     return(FALSE);
}

BOOL push_pop_pair()
{
/* 
** Eliminate: 	stack push/pop pair
** 	  	eg: move.l d0,-(sp)
**    	    	    move.l (sp)+,d1   	->   	move.l d0,d1 		[A]
**
**      OR
** 
**		redundant dest/src register pair (from other optimisations) 
**		eg: move.l #3,d0
**		    move.l d0,-4(a4)	->	move.l #3,-4(a4)	[B]
**
**		Don't apply this transformation to instructions which
**		use labelled (BSS/DATA) items since ACE (esp. in gfx.c)
**		does things with such items which if optimised can lead
**		to a loss of valid code (eg. a d0 move may be eliminated
**		when it is required for a shared library function call;
**		see the code for COLOR as an example). This should only
**		be a problem for case [B] above, not case [A] since no
**		registers are removed in [A].
*/

   if (strcmp(first->opcode,second->opcode)==0 && 
       is_a_move(first->opcode)

     &&

       ((strcmp(first->destopr,"-(sp)")==0 && 
        strcmp(second->srcopr,"(sp)+")==0)		/* [A] */

     || 	
     
       (strcmp(first->destopr,"d0")==0 && 
        strcmp(second->srcopr,"d0")==0 &&
	first->srcopr[0] != '_' && 
	second->destopr[0] != '_')))			/* [B] */
   {
    /* copy required code */
    strcpy(opcode,first->opcode);
    strcpy(srcopr,first->srcopr);
    strcpy(destopr,second->destopr);

    /* modify first line */
    if (strcmp(srcopr,destopr) != 0)
       change(first,opcode,srcopr,destopr);  /* src operand != dest operand */ 
    else 
    {
	/* 
 	** src operand == dest operand 
	**
	** eg. 	  move.l d0,-(sp)
	**	  move.l (sp)+,d0
	**
	**     =  move.l d0,d0	[elimimate this!]
	*/
	change(first,"nop","  ","  ");	   				   
	peep++;
    }

    /* eliminate second line */
    change(second,"nop","  ","  ");

    /* skip second line */
    curr = second->next;

    peep++;

    return(TRUE);
   }
   else
   	return(FALSE);
}

BOOL sign_bit_extension()
{
/*
** Combine:	move.b #n,dm
**		ext.w  dm
**
**	   ->	move.w #n,dm
**
**	   OR
**		move.w #n,dm
**		ext.l  dm
**
**	   ->	move.l #n,dm
**
**
**	  NOT	move.w (sp)+,dm
**		ext.l  dm
**
**		since this would change a short pop into a long pop!
**
**	  NOR	move.w _mylabel,dm
**		ext.l  dm
**
**		since this would try to move data beyond the confines
**		of the BSS/DATA block starting from _mylabel. 
**
**	 In short, this technique is only useful for immediate mode 
**	 addressed operands.
**
**	 Note that this kind of optimisation may lead to redundant register 
**	 moves (eg. compile the 2 line program: 'DEFLNG a-z / X = 1' and
**	 work through the transformations), so push_pop_pair() should be
**	 called after this function.
*/	

    	if (strcmp(second->opcode,"ext.l") == 0 &&
	    strcmp(first->opcode,"move.w") == 0 &&
	    first->srcopr[0] == '#') 
	{		
		strcpy(opcode,"move.l");
		strcpy(srcopr,first->srcopr);
		strcpy(destopr,first->destopr);
		change(first,opcode,srcopr,destopr);
		change(second,"nop","  ","  ");
    		curr = second->next;
		peep++;
		return(TRUE);
	}
	else
    	if (strcmp(second->opcode,"ext.w") == 0 &&
	    strcmp(first->opcode,"move.b") == 0 &&	    
	    first->srcopr[0] == '#') 
	{		
		strcpy(opcode,"move.w");
		strcpy(srcopr,first->srcopr);
		strcpy(destopr,first->destopr);
		change(first,opcode,srcopr,destopr);
		change(second,"nop","  ","  ");
    		curr = second->next;
		peep++;
		return(TRUE);
	}
	else
		return(FALSE);
}

BOOL negate_constant()
{
/*
** Constant Negation:	move.w #n,-(sp)
**			neg.w  (sp)
**			move.w (sp)+,d0		
**	becomes:	
**			move.w #-n,-(sp)
**			move.w(sp)+,d0
**
**	The latter is then a candidate for removal by push_pop_pair().	
*/

	if (((strcmp(second->opcode,"neg.w") == 0 &&
	     strcmp(first->opcode, "move.w") == 0) ||

	    (strcmp(second->opcode,"neg.l") == 0 &&
	     strcmp(first->opcode,"move.l") == 0)) &&

    	    first->srcopr[0] == '#')
	{
		strcpy(opcode,first->opcode);
		srcopr[0] = '#'; 

		if (first->srcopr[1] != '-')
		{
			/*
			** Constant is not negative so negate it.
			*/
			srcopr[1] = '-'; srcopr[2] = '\0';
			strcat(srcopr,&first->srcopr[1]);
		}
		else
		{
			/*
			** Constant is negative so skip '-'.
			*/
			srcopr[1] = '\0';
			strcat(srcopr,&first->srcopr[2]);
		}

		strcpy(destopr,first->destopr);
		change(first,opcode,srcopr,destopr);
		change(second,"nop","  ","  ");
		curr = second->next;
		peep++;		
		return(TRUE);		
	}
	else
		return(FALSE);	    	
}

SHORT peephole()
{
/* 
** Perform a series of peephole 
** optimisations on the code list.
*/
BOOL past_head;
int  opt_type;

  if (code == NULL) return;

    for (opt_type=1;opt_type<=4;opt_type++)
    {
	/* Start of code list */
	curr = code;

	past_head = FALSE;

	do
 	{
		/* get next two lines of code (skipping nops) */
		first = curr;
		if (first != NULL) 
		{
			second = first->next;

			while (second && strcmp(second->opcode,"nop") == 0)
			      second = second->next; 

			curr = second;
		}
		else
		{
			curr = second = NULL;
		}

		/* 
		** Remove redundant code in current peephole.
		**
		** Only do this if we're past the head of the
 		** code list but haven't yet reached the end of 
		** this list.
		*/
  		if (past_head && second != NULL)
		switch(opt_type)
		{
			case 1 : negate_constant();
				 break;

 			case 2 : push_pop_pair();
				 break;

			case 3 : sign_bit_extension();
				 break;

			case 4 : push_pop_pair();
				 break;
		}

		if (!past_head) past_head = TRUE;
 	}
 	while (curr != NULL);
    }

  /* total # of removals */
  return(peep);
}

void optimise()
{
SHORT peep;

 printf("\noptimising...\n");
 peep = peephole();
 printf("%d peephole ",peep);
 if (peep == 1) 
    printf("removal.");  
 else
    printf("removals."); /* peep==0 or peep>1 */
}
