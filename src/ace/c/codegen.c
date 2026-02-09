/* << ACE >>

   -- Amiga BASIC Compiler --

   ** codegen.c: Semantic code generation helpers **

   Reduces assembly-level noise in parser code by wrapping common
   code generation patterns into single calls.
*/

#include "acedef.h"

/* Generate a JSR to a runtime function and register its XREF. */
extern	int	lev;

void gen_rt_call(funcname)
char *funcname;
{
 gen("jsr", funcname, "  ");
 enter_XREF(funcname);
}

/* Build a frame-relative address string: e.g. "-12(a4)" */
void gen_frame_addr(address, buf)
int address;
char *buf;
{
 itoa(-1*address, buf, 10);
 strcat(buf, frame_ptr[lev]);
}

/* Generate a typed push: move.w/l src, -(sp) */
void gen_push(type, src)
int type;
char *src;
{
 if (type == shorttype)
    gen("move.w", src, "-(sp)");
 else
    gen("move.l", src, "-(sp)");
}

/* Generate a typed pop: move.w/l (sp)+, dest */
void gen_pop(type, dest)
int type;
char *dest;
{
 if (type == shorttype)
    gen("move.w", "(sp)+", dest);
 else
    gen("move.l", "(sp)+", dest);
}

/* Generate a typed move: move.w/l src, dest */
void gen_move_typed(type, src, dest)
int type;
char *src;
char *dest;
{
 if (type == shorttype)
    gen("move.w", src, dest);
 else
    gen("move.l", src, dest);
}

/* Generate a shared library function call:
   check_for_ace_lib + make_library_base + move.l base,a6
   + jsr offset(a6) + restore a4/a5 if needed. */
extern	ACELIBS	acelib[];
extern	char	librarybase[];
extern	BOOL	restore_a4;
extern	BOOL	restore_a5;

void gen_lib_call(func_item)
SYM *func_item;
{
 BYTE libnum;
 char func_address[MAXIDSIZE+9];

 if ((libnum=check_for_ace_lib(func_item->libname)) == NEGATIVE)
    make_library_base(func_item->libname);
 else
    strcpy(librarybase,acelib[libnum].base);
 gen("move.l",librarybase,"a6");
 itoa(func_item->address,func_address,10);
 strcat(func_address,"(a6)");
 gen("jsr",func_address,"  ");
 if (restore_a4) { gen("move.l","_a4_temp","a4"); restore_a4=FALSE; }
 if (restore_a5) { gen("move.l","_a5_temp","a5"); restore_a5=FALSE; }
}

/* Emit a library-open-and-check block directly to the output file:
   jsr open_func / cmpi #1,_starterr / bne ok_label / jmp _ABORT / label: */
extern	FILE	*dest;

void gen_lib_open_check(open_func, ok_label)
char *open_func;
char *ok_label;
{
 fprintf(dest,"\tjsr\t%s\n", open_func);
 fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
 fprintf(dest,"\tbne.s\t%s\n", ok_label);
 fprintf(dest,"\tjmp\t_ABORT_PROG\n");
 fprintf(dest,"%s:\n", ok_label);
}

/* Compute effective address string for a variable/array.
   Module-level objects (address==-32767) use BSS name;
   normal objects use frame-relative addressing. */
void gen_var_addr(item, buf)
SYM *item;
char *buf;
{
 if (item->address == -32767)
 {
  if (item->object == array)
  {
   if (item->libname != NULL)
      strcpy(buf, item->libname);
   else
      strcpy(buf, "0");
  }
  else if (item->object == variable)
     make_modvar_bss_name(buf, item->name);
  else
     gen_frame_addr(item->address, buf);
 }
 else
    gen_frame_addr(item->address, buf);
}

/* Push a variable's value onto the stack.
   Handles shared indirection for non-string variables. */
void gen_load_var(item, srcbuf)
SYM *item;
char *srcbuf;
{
 if ((item->shared) && (lev == ONE) && (item->type != stringtype))
 {
  gen("move.l", srcbuf, "a0");
  gen_push(item->type, "(a0)");
 }
 else
  gen_push(item->type, srcbuf);
}

/* Store a value into a variable.
   src can be "d0", "(sp)+", etc.
   Handles shared indirection for non-string variables.
   Caller handles stringtype separately. */
void gen_store_var(item, addrbuf, src)
SYM *item;
char *addrbuf;
char *src;
{
 if ((item->shared) && (lev == ONE))
 {
  gen("move.l", addrbuf, "a0");
  gen_move_typed(item->type, src, "(a0)");
 }
 else
  gen_move_typed(item->type, src, addrbuf);
}

/* Generate NOP placeholders for potential type coercion.
   Fills cx[] with CODE pointers to the generated NOPs. */
extern	CODE	*curr_code;

void gen_coerce_slots(cx, count)
CODE *cx[];
int count;
{
 int i;
 for (i=0;i<count;i++)
 {
  gen("nop","  ","  ");
  cx[i]=curr_code;
 }
}

/* Generate an FFP library call: move.l _MathBase,a6 / jsr func(a6)
   + enter_XREF for the function and _MathBase. */
void gen_ffp_call(funcname)
char *funcname;
{
 char buf[80];
 gen("move.l","_MathBase","a6");
 strcpy(buf, funcname);
 strcat(buf, "(a6)");
 gen("jsr", buf, "  ");
 enter_XREF(funcname);
 enter_XREF("_MathBase");
}

/* Generate a boolean/zero test: tst.l reg.
   Replaces cmpi.l #0,reg -- saves 2 bytes, identical flags. */
void gen_bool_test(reg)
char *reg;
{
 gen("tst.l", reg, "  ");
}

/* Clean up N bytes from the stack after a call.
   Uses addq for N<=8 (2 bytes), add.l otherwise (6 bytes). */
void gen_stack_cleanup(bytes)
int bytes;
{
 char buf[12];
 sprintf(buf, "#%d", bytes);
 if (bytes <= 8)
  gen("addq", buf, "sp");
 else
  gen("add.l", buf, "sp");
}

/* Scale array index in d7 by element size.
   shorttype: d7*2, long/single: d7*4, string: d7*elem_size via lmulu. */
void gen_index_scale(type, elem_size)
int type;
LONG elem_size;
{
 char buf[20];
 if (type == shorttype)
  gen("lsl.l", "#1", "d7");
 else if (type == longtype || type == singletype)
  gen("lsl.l", "#2", "d7");
 else
 {
  /* string or other: use multiplication */
  sprintf(buf, "#%ld", elem_size);
  gen("move.l", "d7", "-(sp)");
  gen("move.l", buf, "-(sp)");
  gen_rt_call("lmulu");
  gen_stack_cleanup(8);
  gen("move.l", "d0", "d7");
 }
}

/* Sign-extend a register to long.
   from_byte=TRUE:  byte->long (extb.l on 68020+, ext.w+ext.l on 68000)
   from_byte=FALSE: short->long (ext.l on all CPUs) */
extern	BOOL	cpu020_opt;

void gen_ext_to_long(from_byte, reg)
BOOL from_byte;
char *reg;
{
 if (from_byte)
 {
  if (cpu020_opt)
   gen("extb.l", reg, "  ");
  else
  {
   gen("ext.w", reg, "  ");
   gen("ext.l", reg, "  ");
  }
 }
 else
  gen("ext.l", reg, "  ");
}

/* Emit startup assembly code (main program only).
   addr_lev is the value of addr[lev] for the stack frame size. */
extern	BOOL	cli_args;
extern	BOOL	translateused;
extern	BOOL	mathffpused;
extern	BOOL	mathtransused;
extern	BOOL	intuitionused;
extern	BOOL	gfxused;
extern	BOOL	iffused;
extern	BOOL	ontimerused;
extern	BOOL	gadtoolsused;
extern	BOOL	basdatapresent;
extern	BOOL	module_opt;

void gen_startup_code(addr_lev)
int addr_lev;
{
char buf[40],bytes[40];

 if (!module_opt)
 {
   /*
   ** Check for Wb start BEFORE DOING ANYTHING ELSE!
   ** This also always opens dos.library and stores
   ** CLI argument data.
   */
   fprintf(dest,"\tjsr\t_startup\n");
   fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
   fprintf(dest,"\tbne.s\t_START_PROG\n");
   fprintf(dest,"\trts\n");
   fprintf(dest,"_START_PROG:\n");

   /* storage for initial stack pointer */
   enter_BSS("_initialSP:","ds.l 1");
   fprintf(dest,"\tmove.l\tsp,_initialSP\n");

   fprintf(dest,"\tmovem.l\td1-d7/a0-a6,-(sp)\n");

   if (cli_args)
      fprintf(dest,"\tjsr\t_parse_cli_args\n");

   if (translateused)
    gen_lib_open_check("_opentranslator", "_translate_ok");

   if (mathffpused)
    gen_lib_open_check("_openmathffp", "_mathffp_ok");

   if (mathtransused)
    gen_lib_open_check("_openmathtrans", "_mathtrans_ok");

   if (intuitionused && !gfxused)
    gen_lib_open_check("_openintuition", "_intuition_ok");

   if (gfxused)
   {
    gen_lib_open_check("_openintuition", "_intuition_ok");
    gen_lib_open_check("_opengfx", "_gfx_ok");
   }

   /* create temporary ILBM.library */
   if (iffused) fprintf(dest,"\tjsr\t_create_ILBMLib\n");

   /* get timer event trapping start time */
   if (ontimerused) fprintf(dest,"\tjsr\t_ontimerstart\n");

   if (gadtoolsused)
    gen_lib_open_check("_opengadtools", "_gadtools_ok");

   /* size of stack frame */
   if (addr_lev == 0)
      strcpy(bytes,"#\0");
   else
      strcpy(bytes,"#-");
   itoa(addr_lev,buf,10);
   strcat(bytes,buf);

   /* create stack frame */
   fprintf(dest,"\tlink\ta4,%s\n\n",bytes);

   /* initialise global DATA pointer */
   if (basdatapresent) fprintf(dest,"\tmove.l\t#_BASICdata,_dataptr\n");
 }
}

/* Emit exit/cleanup assembly code (main program only). */
extern	BOOL	narratorused;

void gen_exit_code()
{
 if (!module_opt)
 {
   /* exiting code */
   fprintf(dest,"\n_EXIT_PROG:\n");

   fprintf(dest,"\tunlk\ta4\n");

   /*
   ** Programs which abort should cleanup libraries, free allocated memory
   ** and possibly reply to a Wb startup message.
   */
   if (intuitionused || gfxused || mathffpused || mathtransused ||
       translateused || gadtoolsused)
      fprintf(dest,"_ABORT_PROG:\n");

   /* Free memory allocated via ALLOC and db.lib calls to alloc(). */
   fprintf(dest,"\tjsr\t_free_alloc\n");

   /* close libraries */
   if (gfxused)
   {
    fprintf(dest,"\tjsr\t_closegfx\n");
    fprintf(dest,"\tjsr\t_closeintuition\n");
   }
   if (narratorused) fprintf(dest,"\tjsr\t_cleanup_async_speech\n");
   if (intuitionused && !gfxused) fprintf(dest,"\tjsr\t_closeintuition\n");
   if (mathtransused) fprintf(dest,"\tjsr\t_closemathtrans\n");
   if (mathffpused) fprintf(dest,"\tjsr\t_closemathffp\n");
   if (translateused) fprintf(dest,"\tjsr\t_closetranslator\n");
   if (gadtoolsused) fprintf(dest,"\tjsr\t_closegadtools\n");

   /* delete temporary ILBM.library */
   if (iffused) fprintf(dest,"\tjsr\t_remove_ILBMLib\n");

   /* restore registers */
   fprintf(dest,"\tmovem.l\t(sp)+,d1-d7/a0-a6\n");

   /* restore initial stack pointer */
   fprintf(dest,"\tmove.l\t_initialSP,sp\n");

   /*
   ** Close dos.library and reply to Wb message
   ** as the LAST THING DONE before rts'ing.
   */
   fprintf(dest,"\tjsr\t_cleanup\n");

   /* return */
   fprintf(dest,"\n\trts\n");
 }
}

/* Emit assembly file header: optional 68020 machine directive + SECTION. */
void gen_asm_header()
{
 if (cpu020_opt) fprintf(dest,"\n\tmachine 68020\n");
 fprintf(dest,"\n\tSECTION code,CODE\n\n");
}

/* Emit assembly file end directive. */
void gen_asm_end()
{
 fprintf(dest,"\n\tEND\n");
}
