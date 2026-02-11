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

BOOL tst_for_zero()
{
/*
** Remove redundant tst.l after move to data register.
**
**		move.l  X,dn		(sets condition codes)
**		tst.l   dn		(redundant)
**
**	->	move.l  X,dn
**		nop
**
** Only applies when destination is d0-d7.
** movea to address registers does NOT set condition codes.
*/
	if (strcmp(first->opcode, "move.l") == 0 &&
	    strcmp(second->opcode, "tst.l") == 0 &&
	    first->destopr[0] == 'd' &&
	    strcmp(first->destopr, second->srcopr) == 0)
	{
		change(second, "nop", "  ", "  ");
		curr = second->next;
		peep++;
		return(TRUE);
	}
	else
		return(FALSE);
}

BOOL addq_for_small_add()
{
/*
** Replace add.l #N,reg with addq #N,reg when 1 <= N <= 8.
** Safety net for any add.l #small not caught by gen_stack_cleanup.
** addq saves 4 bytes per occurrence (2 vs 6 byte encoding).
*/
	if (strcmp(first->opcode, "add.l") == 0 &&
	    first->srcopr[0] == '#' &&
	    first->srcopr[1] >= '1' && first->srcopr[1] <= '8' &&
	    first->srcopr[2] == '\0')
	{
		change(first, "addq", first->srcopr, first->destopr);
		/* don't change curr - only first was transformed */
		peep++;
		return(TRUE);
	}
	else
		return(FALSE);
}

BOOL extb_for_020()
{
/*
** Replace ext.w dn + ext.l dn with extb.l dn + nop on 68020+.
** Safety net for byte-to-long not caught by gen_ext_to_long.
**
**		ext.w   dn
**		ext.l   dn		(same register)
**
**	->	extb.l  dn
**		nop
*/
extern	BOOL	cpu020_opt;

	if (cpu020_opt &&
	    strcmp(first->opcode, "ext.w") == 0 &&
	    strcmp(second->opcode, "ext.l") == 0 &&
	    strcmp(first->srcopr, second->srcopr) == 0)
	{
		change(first, "extb.l", first->srcopr, "  ");
		change(second, "nop", "  ", "  ");
		curr = second->next;
		peep++;
		return(TRUE);
	}
	else
		return(FALSE);
}

/*
** Check if destopr is a negative sp-relative offset: "-N(sp)"
** but NOT "-(sp)" (which is a push).
*/
static BOOL is_sp_offset(str)
char *str;
{
 int len;
 if (str[0] != '-') return(FALSE);
 if (str[1] < '0' || str[1] > '9') return(FALSE);
 len = strlen(str);
 if (len < 5) return(FALSE);
 if (strcmp(str + len - 4, "(sp)") != 0) return(FALSE);
 return(TRUE);
}

/*
** Try to optimize a self-recursive tail call.
** jsr_node points to a "jsr _SUB_X" instruction that matches
** the current SUB.  lb[] is the lookback buffer, lb_pos is the
** next-write index.
**
** Returns TRUE if the tail call was successfully optimized.
*/
#define LB_SIZE 50

static BOOL try_tco(jsr_node, lb, lb_pos, sub_name)
CODE *jsr_node;
CODE *lb[];
int  lb_pos;
char *sub_name;
{
 CODE *c, *node, *push_node, *pop_node;
 CODE *forbid_jsr, *forbid_movea;
 char tcr_name[80];
 char new_dest[40];
 char save_opc[40], save_src[40];
 int  i, offset;

 push_node = NULL;
 pop_node  = NULL;
 forbid_jsr   = NULL;
 forbid_movea = NULL;

 /* --- Forward scan: verify tail position --- */
 c = jsr_node->next;
 while (c != NULL)
 {
  /* Skip NOPs */
  if (strcmp(c->opcode, "nop") == 0) { c = c->next; continue; }

  /* Allow labels */
  if (strchr(c->opcode, ':') != NULL) { c = c->next; continue; }

  /* Push (return value from level-0 storage) */
  if (is_a_move(c->opcode) &&
      strcmp(c->destopr, "-(sp)") == 0 &&
      push_node == NULL)
  {
   push_node = c;
   c = c->next;
   continue;
  }

  /* Pop (return value assignment back to same storage) */
  if (is_a_move(c->opcode) &&
      strcmp(c->srcopr, "(sp)+") == 0 &&
      push_node != NULL && pop_node == NULL)
  {
   pop_node = c;
   c = c->next;
   continue;
  }

  /* UNLK a5 -> the SUB exit */
  if (strcmp(c->opcode, "unlk") == 0 &&
      strcmp(c->srcopr, "a5") == 0)
  {
   /* verify RTS follows (skip NOPs) */
   {
   CODE *rts;
   rts = c->next;
   while (rts && strcmp(rts->opcode, "nop") == 0)
    rts = rts->next;
   if (rts == NULL || strcmp(rts->opcode, "rts") != 0)
    return(FALSE);
   }
   break; /* tail position verified */
  }

  /* Any other instruction -> not a tail call */
  return(FALSE);
 }

 if (c == NULL) return(FALSE);

 /* --- Backward scan through lookback: find Forbid + param moves --- */
 i = (lb_pos - 1 + LB_SIZE) % LB_SIZE;
 while (i != lb_pos && lb[i] != NULL)
 {
  node = lb[i];

  /* Skip NOPs */
  if (strcmp(node->opcode, "nop") == 0)
  {
   i = (i - 1 + LB_SIZE) % LB_SIZE;
   continue;
  }

  /* Param move: move.X temp, -N(sp) */
  if (is_a_move(node->opcode) && is_sp_offset(node->destopr))
  {
   /* remap -N(sp) to -(N-8)(a5) -- copy strings before change()
      frees the old CODE members */
   strcpy(save_opc, node->opcode);
   strcpy(save_src, node->srcopr);
   offset = atoi(node->destopr);
   offset += 8;
   sprintf(new_dest, "%d(a5)", offset);
   change(node, save_opc, save_src, new_dest);

   i = (i - 1 + LB_SIZE) % LB_SIZE;
   continue;
  }

  /* Forbid JSR */
  if (strcmp(node->opcode, "jsr") == 0 &&
      strcmp(node->srcopr, "_LVOForbid(a6)") == 0)
  {
   forbid_jsr = node;
   i = (i - 1 + LB_SIZE) % LB_SIZE;
   continue;
  }

  /* Forbid MOVEA */
  if (strcmp(node->opcode, "movea.l") == 0 &&
      strcmp(node->srcopr, "_AbsExecBase") == 0)
  {
   forbid_movea = node;
   break;
  }

  /* Unknown instruction -> stop backward scan */
  break;
 }

 /* --- Apply transformation --- */

 /* NOP out Forbid block */
 if (forbid_jsr)   change(forbid_jsr,   "nop", "  ", "  ");
 if (forbid_movea) change(forbid_movea, "nop", "  ", "  ");

 /* Change jsr _SUB_X to jmp _SUB_X_tcr */
 strcpy(tcr_name, sub_name);
 strcat(tcr_name, "_tcr");
 change(jsr_node, "jmp", tcr_name, "  ");

 /* NOP out return-value push/pop */
 if (push_node) change(push_node, "nop", "  ", "  ");
 if (pop_node)  change(pop_node,  "nop", "  ", "  ");

 return(TRUE);
}

/*
** Tail-Call Optimization for self-recursive SUBs.
**
** Scans the code list for self-recursive JSR instructions in
** tail position.  When found, transforms:
**   - NOP out the Forbid block (not needed for self-jump)
**   - Remap param moves from sp-relative to a5-relative
**   - Change "jsr _SUB_X" to "jmp _SUB_X_tcr"
**   - NOP out the return-value push/pop pair
**
** Returns the number of tail calls optimized.
*/
SHORT optimize_tail_calls()
{
 CODE *c;
 char cur_sub[80];
 char tcr_label[80];
 BOOL tco_eligible;
 SHORT tco_count;
 CODE *lb[LB_SIZE];
 int  lb_pos, i;

 if (code == NULL) return(0);

 cur_sub[0] = '\0';
 tcr_label[0] = '\0';
 tco_eligible = FALSE;
 tco_count = 0;
 lb_pos = 0;

 for (i = 0; i < LB_SIZE; i++) lb[i] = NULL;

 c = code;
 while (c != NULL)
 {
  /* Track current SUB via _SUB_X: labels */
  if (c->opcode[0] == '_' &&
      strncmp(c->opcode, "_SUB_", 5) == 0 &&
      strchr(c->opcode, ':') != NULL &&
      strstr(c->opcode, "_tcr:") == NULL &&
      strstr(c->opcode, "_EXIT") == NULL)
  {
   /* new SUB label -- extract base name (strip colon) */
   {
   int len;
   len = strlen(c->opcode);
   if (len < 80)
   {
    strcpy(cur_sub, c->opcode);
    cur_sub[len - 1] = '\0';  /* strip colon */
   }
   }
   tco_eligible = FALSE;

   /* build expected _tcr label name */
   strcpy(tcr_label, cur_sub);
   strcat(tcr_label, "_tcr:");
  }

  /* Detect _tcr label -> SUB is TCO-eligible */
  if (!tco_eligible &&
      tcr_label[0] != '\0' &&
      strcmp(c->opcode, tcr_label) == 0)
  {
   tco_eligible = TRUE;
  }

  /* Check for self-recursive call */
  if (tco_eligible &&
      strcmp(c->opcode, "jsr") == 0 &&
      strcmp(c->srcopr, cur_sub) == 0)
  {
   if (try_tco(c, lb, lb_pos, cur_sub))
    tco_count++;
  }

  /* Update lookback buffer */
  lb[lb_pos] = c;
  lb_pos = (lb_pos + 1) % LB_SIZE;

  c = c->next;
 }

 return(tco_count);
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

    for (opt_type=1;opt_type<=7;opt_type++)
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

			case 5 : tst_for_zero();
				 break;

			case 6 : addq_for_small_add();
				 break;

			case 7 : extb_for_020();
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
SHORT tco;

 printf("\noptimising...\n");
 tco = optimize_tail_calls();
 peep = peephole();
 printf("%d peephole ",peep);
 if (peep == 1)
    printf("removal, ");
 else
    printf("removals, "); /* peep==0 or peep>1 */
 printf("%d tail call",tco);
 if (tco != 1) printf("s");
 printf(" optimized.");
}
