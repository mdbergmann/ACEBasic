/* << ACE >>

   -- Amiga BASIC Compiler --

   ** invoke.c: INVOKE statement/expression handler **

   Handles indirect function calls through variables (closures, SUB pointers,
   C functions).  Shared by statement.c (statement context) and factor.c
   (expression context).  The only behavioural difference is whether the
   return value is pushed onto the evaluation stack.
*/

#include "acedef.h"

extern int    sym;
extern int    lev;
extern char   id[MAXIDSIZE];
extern SYM    *curr_item;
extern int    addr[];
extern int    labelcount;
extern char   templongname[80];

/* handle_invoke  --  generate code for INVOKE dispatch.
   invoke_item  = the variable holding function/closure pointer.
   wants_return = TRUE  -> push return value onto stack (factor context).
                  FALSE -> ignore return value (statement context).
   Returns: result type when wants_return is TRUE, notype otherwise. */

int handle_invoke(invoke_item, wants_return)
SYM  *invoke_item;
BOOL  wants_return;
{
 char buf[80], addrbuf[80], numbuf[40];
 int  i;
 SHORT popcount;
 int  oldlevel;

 if (invoke_item->other != NULL &&
     invoke_item->other->object == subprogram &&
     invoke_item->dims > 0)
 {
  /* ---- Path 1: Closure dispatch ---- */
  /* Bound args come from closure record, free args from source. */
  SYM *invoke_sub = invoke_item->other;
  int bound_count = invoke_item->dims - 1;  /* dims stores count+1 */
  int free_count = invoke_sub->no_of_params - bound_count;
  int ci, formal_type;
  SHORT par_addr;
  char formaltemp[MAXPARAMS][80];
  int formaltype[MAXPARAMS];
  char addrtmp[80], offsettmp[40];
  BOOL had_parens = FALSE;

  /* Parse free args from source into temps */
  if (free_count > 0)
  {
   if (sym != lparen) { _error(14); }
   else
   {
    had_parens = TRUE;
    for (ci=0; ci<free_count; ci++)
    {
     insymbol();
     formal_type = expr();

     /* Coerce to expected type */
     switch(invoke_sub->p_type[bound_count + ci])
     {
      case shorttype: make_sure_short(formal_type); break;
      case longtype:
        if ((formal_type = make_integer(formal_type)) == shorttype)
          make_long();
        else if (formal_type == notype) _error(4);
        break;
      case singletype: gen_Flt(formal_type); break;
      case stringtype:
        if (formal_type != stringtype) _error(4);
        break;
     }

     /* Store in frame temp */
     if (invoke_sub->p_type[bound_count + ci] == shorttype)
     {
      addr[lev] += 2;
      gen_frame_addr(addr[lev], formaltemp[bound_count + ci]);
      gen_pop(shorttype, formaltemp[bound_count + ci]);
      formaltype[bound_count + ci] = shorttype;
     }
     else
     {
      addr[lev] += 4;
      gen_frame_addr(addr[lev], formaltemp[bound_count + ci]);
      gen_pop(longtype, formaltemp[bound_count + ci]);
      formaltype[bound_count + ci] = longtype;
     }

     if (ci < free_count - 1 && sym != comma) { _error(16); break; }
    }
    if (sym != rparen) _error(9);
   }
  }
  else
  {
   /* No free args; skip parens if present */
   if (sym == lparen)
   {
    had_parens = TRUE;
    insymbol();
    if (sym != rparen) _error(9);
   }
  }

  /* Load closure record address */
  gen_frame_addr(invoke_item->address, addrtmp);
  gen("move.l", addrtmp, "a2");

  /* Read bound args from closure record into temps.
     New format: bound args start after 14-byte header + param types + padding */
  {
   int param_bytes = invoke_sub->no_of_params;
   int header_plus_params = 14 + param_bytes;
   int param_padding = (4 - (header_plus_params % 4)) % 4;
   int bound_args_offset = header_plus_params + param_padding;
  for (ci=0; ci<bound_count; ci++)
  {
   sprintf(offsettmp, "%d(a2)", bound_args_offset + ci * 4);
   if (invoke_sub->p_type[ci] == shorttype)
   {
    addr[lev] += 4;
    gen_frame_addr(addr[lev], formaltemp[ci]);
    gen("move.l", offsettmp, formaltemp[ci]);
    formaltype[ci] = shorttype;
   }
   else
   {
    addr[lev] += 4;
    gen_frame_addr(addr[lev], formaltemp[ci]);
    gen("move.l", offsettmp, formaltemp[ci]);
    formaltype[ci] = longtype;
   }
  }
  }

  /* Forbid multitasking before frame setup */
  gen("movea.l", "_AbsExecBase", "a6");
  gen("jsr", "_LVOForbid(a6)", "  ");
  enter_XREF("_AbsExecBase");
  enter_XREF("_LVOForbid");

  /* Copy all params into next frame */
  par_addr = -8;
  for (ci=0; ci<invoke_sub->no_of_params; ci++)
  {
   if (invoke_sub->p_type[ci] == shorttype)
   {
    par_addr -= 2;
    itoa(par_addr, addrtmp, 10);
    strcat(addrtmp, "(sp)");
    if (ci < bound_count)
    {
     gen("move.l", formaltemp[ci], "d0");
     gen("move.w", "d0", addrtmp);
    }
    else
     gen("move.w", formaltemp[ci], addrtmp);
   }
   else
   {
    par_addr -= 4;
    itoa(par_addr, addrtmp, 10);
    strcat(addrtmp, "(sp)");
    gen("move.l", formaltemp[ci], addrtmp);
   }
  }

  /* Call through closure's function pointer */
  gen_frame_addr(invoke_item->address, addrtmp);
  gen("move.l", addrtmp, "a2");
  gen("move.l", "4(a2)", "a0");
  gen("jsr", "(a0)", "  ");

  if (wants_return)
  {
   gen_push(invoke_sub->type, "d0");
  }

  if (had_parens) insymbol();

  return wants_return ? invoke_sub->type : notype;
 }
 else
 if (invoke_item->other != NULL &&
     invoke_item->other->object == subprogram)
 {
  /* ---- Path 2: SUB calling convention (known signature) ---- */
  SYM *invoke_sub = invoke_item->other;

  if (invoke_sub->no_of_params > 0) load_params(invoke_sub);

  gen_frame_addr(invoke_item->address, addrbuf);
  gen("move.l",addrbuf,"a0");
  gen("jsr","(a0)","  ");

  if (wants_return)
  {
   if (invoke_sub->address != extfunc)
   {
    oldlevel=lev; lev=ZERO;
    gen_frame_addr(invoke_sub->address, addrbuf);
    lev=oldlevel;
    gen_push(invoke_sub->type, addrbuf);
   }
   else
   {
    gen_push(invoke_sub->type, "d0");
   }
  }

  if (invoke_sub->no_of_params > 0) insymbol();

  return wants_return ? invoke_sub->type : notype;
 }
 else
 {
  /* ---- Path 3: Unknown signature ---- */
  /* Runtime CLSR detection with C fallback.
     CLSR path uses BASIC calling convention (params in callee frame).
     Non-CLSR path uses C calling convention (params pushed to stack). */
  char clsr_label[80], done_label[80];
  char labnum[40];
  char p_temp[MAXPARAMS][80];
  int p_type[MAXPARAMS];
  int n_params = 0;
  int n;

  /* Generate unique labels for branching */
  itoa(labelcount++, labnum, 10);
  strcpy(clsr_label, "_InvClsr");
  strcat(clsr_label, labnum);
  strcpy(done_label, "_InvDone");
  strcat(done_label, labnum);

  /* Parse arguments into temps if present */
  if (sym == lparen)
  {
   int ptype;
   do
   {
    insymbol();
    ptype = expr();

    /* Store arg in temp - extend shorts to longs for uniform handling */
    if (ptype == shorttype)
    {
     p_type[n_params] = shorttype;
     gen("move.w", "(sp)+", "d0");
     gen_ext_to_long(FALSE, "d0");
     make_temp_long();
     strcpy(p_temp[n_params], templongname);
     gen("move.l", "d0", templongname);
    }
    else
    {
     p_type[n_params] = longtype;
     make_temp_long();
     strcpy(p_temp[n_params], templongname);
     gen("move.l", "(sp)+", templongname);
    }
    n_params++;
   }
   while ((n_params < MAXPARAMS) && (sym == comma));

   if (sym != rparen) _error(9);
   insymbol();
  }

  /* Load function pointer/closure address into a2 */
  gen_frame_addr(invoke_item->address, addrbuf);
  gen("move.l", addrbuf, "a2");

  /* Check for CLSR magic */
  gen("cmp.l", "#$434C5352", "(a2)");
  gen("beq", clsr_label, "  ");

  /* --- C calling convention path (not a CLSR) --- */
  /* Push args to stack in reverse order */
  for (n = n_params - 1; n >= 0; n--)
  {
   gen_push(p_type[n], p_temp[n]);
  }

  /* Call through pointer (a2 holds the function address) */
  gen("move.l", "a2", "a0");
  gen("jsr", "(a0)", "  ");

  /* Pop args from stack */
  if (n_params > 0)
  {
   popcount = 0;
   for (i = 0; i < n_params; i++)
   {
    if (p_type[i] == shorttype) popcount += 2;
    else popcount += 4;
   }
   gen_stack_cleanup(popcount);
  }

  /* Return value handling for C path */
  if (wants_return) gen("move.l", "d0", "-(sp)");
  gen("bra", done_label, "  ");

  /* --- CLSR path: BASIC calling convention --- */
  strcpy(buf, clsr_label);
  strcat(buf, ":");
  gen(buf, "  ", "  ");

  /* Forbid multitasking during frame setup.
     The callee will call Permit in its prologue (sub_params). */
  gen("movea.l", "_AbsExecBase", "a6");
  gen("jsr", "_LVOForbid(a6)", "  ");
  enter_XREF("_AbsExecBase");
  enter_XREF("_LVOForbid");

  /* Set up callee frame with arguments.
     Simplified approach: treat all params as longs (4 bytes).
     Frame layout: -12(sp), -16(sp), -20(sp), ... */
  {
   SHORT par_addr = -8;
   char offsetbuf[40];
   for (i = 0; i < n_params; i++)
   {
    par_addr -= 4;
    sprintf(offsetbuf, "%d(sp)", par_addr);
    gen("move.l", p_temp[i], offsetbuf);
   }
  }

  /* Call through closure's function pointer at offset 4 */
  gen("move.l", "4(a2)", "a0");
  gen("jsr", "(a0)", "  ");

  /* Return value handling for CLSR path */
  if (wants_return) gen("move.l", "d0", "-(sp)");

  /* Done label */
  strcpy(buf, done_label);
  strcat(buf, ":");
  gen(buf, "  ", "  ");

  return wants_return ? longtype : notype;
 }
}
