/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: main module **
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
	   6th,7th,21st,22nd December 1992,
	   13th,30th January 1993,
	   2nd,6th,11th,14th,15th,28th February 1993,
	   7th,24th March 1993,
	   6th,13th,14th,30th June 1993,
	   1st,10th July 1993,
	   5th,26th September 1993,
	   25th October 1993,
	   15th-18th November 1993,
	   26th,27th December 1993,
	   2nd,5th,7th,9th,13th,14th January 1994,
	   7th,26th,27th February 1994,
	   4th,13th,30th April 1994,
	   14th May 1994,
	   12th,14th,21st,22nd,25th June 1994,
	   10th,14th,24th July 1994,
	   14th,19th August 1994,
	   11th,12th September 1994,
	   5th,11th March 1995,
	   8th August 1995,
	   6th October 1995,
	   10th March 1996
*/

#include "acedef.h"

/* externals */
extern	char	*srcfile,*destfile;
extern	int	sym;
extern	int	typ;
extern	int	lev;
extern	int	errors;
extern	char   	id[MAXIDSIZE]; 
extern	SYM	*curr_item;
extern	CODE	*curr_code;
extern	BOOL	end_of_source;
extern	FILE	*dest;
extern	int  	addr[2]; 
extern	char 	exit_sub_name[80];
extern	BOOL 	early_exit;
extern	int  	exitvalue;
extern	char	*rword[];
extern	BOOL 	break_opt;
extern	BOOL	optimise_opt;
extern	BOOL	make_icon;
extern	BOOL	error_log;
extern	BOOL	asm_comments;
extern	BOOL	list_source;
extern	BOOL 	wdw_close_opt;
extern	BOOL 	module_opt;
extern	BOOL	cli_args;
extern	BOOL 	mathffpused;
extern	BOOL 	mathtransused;
extern	BOOL 	dosused;
extern	BOOL 	gfxused;
extern	BOOL 	intuitionused;
extern	BOOL 	translateused;
extern	BOOL 	narratorused;
extern	BOOL	ontimerused;
extern	BOOL	iffused;
extern	BOOL 	basdatapresent;
extern	BOOL 	readpresent;

/* external functions */
char	*version();

/* functions */
void block()
{
CODE *link;
SYM  *sub_ptr;
char end_of_sub_name[80],end_of_sub_label[80];
char sub_name[80],sub_label[80],exit_sub_label[80];
char xdef_name[80];
char bytes[40],buf[40];
int  subprog;
int  sub_type,def_expr_type;

 while (!end_of_source)
 {
  if (sym != subsym && sym != defsym) 
   /* ordinary statement */
   statement();
  else
  {
   /************************/
   /* SUBprogram or DEF FN */
   /************************/
   subprog = sym;
   insymbol();
   
   sub_type = undefined;

   /* type identifiers */
   if (sym == shortintsym || sym == longintsym || sym == addresssym ||
       sym == singlesym || sym == stringsym)
   {
    switch(sym)
    {
     case shortintsym : sub_type = shorttype;  break;
     case longintsym  : sub_type = longtype;   break;
     case addresssym  : sub_type = longtype;   break;
     case singlesym   : sub_type = singletype; break;
     case stringsym   : sub_type = stringtype; break;
    }
    insymbol();
   }

   if (sym != ident) _error(32);
   else
   { 
    /* get name of subprogram and prefix _SUB_ to it */
    strcpy(sub_name,"_SUB_");
    strcat(sub_name,id);

    if (!exist(sub_name,subprogram)) 
    {
      if (sub_type == undefined) sub_type = typ;
      enter(sub_name,sub_type,subprogram,0);  /* new SUB */
      curr_item->decl=subdecl;
    }
    else
       if ((exist(sub_name,subprogram)) && (curr_item->decl == fwdref))
          curr_item->decl=subdecl;
       else 
           _error(33); /* already exists */

    sub_ptr=curr_item; /* pointer to sub info' */

    turn_event_off(sub_name);   /* see event.c */

    /* exit point name & label */
    strcpy(exit_sub_name,"_EXIT");
    strcat(exit_sub_name,sub_name);
    strcpy(exit_sub_label,exit_sub_name);
    strcat(exit_sub_label,":\0");

    /* prepare for level ONE */
    lev=ONE; 
    addr[lev]=0; 
    new_symtab();
    make_label(end_of_sub_name,end_of_sub_label);
    gen("jmp",end_of_sub_name,"  ");

    /* subprogram label -> _SUB_ prefix to make it unique */
    strcpy(sub_label,sub_name);
    strcat(sub_label,":\0");
    gen(sub_label,"  ","  ");

    /* all SUBs need link instruction -- add # of bytes later */
    gen("link","a5","  ");
    link=curr_code;

    /* parse formal parameter list */
    sub_params(sub_ptr);

    /* make this subprogram externally visible? */
    if (sym == externalsym)
    {
	insymbol();
	strcpy(xdef_name,sub_name);
	xdef_name[0] = '*';  /* signal that this is an XDEF */
	enter_XREF(xdef_name);
    }

    /* 
    ** Pass function (SUB) values via d0 for ALL subprograms 
    ** in a module since there is no link using A4 for modules.
    */
    if (module_opt)
	sub_ptr->address = extfunc;  /* This has a numeric value of 3004:
					hopefully large enough to avoid
					clashes with real stack offsets. */
	
    /* SUB or DEF FN code? */
    if (subprog == subsym)
    {
      while ((sym != endsym) && (!end_of_source)) 
      {
       if (sym == sharedsym) parse_shared_vars();
       if ((sym != endsym) && (!end_of_source)) statement();
      }

      if (end_of_source) _error(34);  /* END SUB expected */

      if (sym == endsym) 
      {
       insymbol();
       if (sym != subsym) _error(35); 
       insymbol(); 
      }
    }
    else
    {
        /* DEF FN code */
	if (sym != equal)
	   _error(5);
	else
	{
	  insymbol();
     	  def_expr_type = expr();
	  if (assign_coerce(sub_type,def_expr_type) != sub_type)
	     _error(4);
	  else
	  if (sub_type == shorttype)
	  	gen("move.w","(sp)+","d0");
	  else
		gen("move.l","(sp)+","d0");

  	  /* change object from SUB to DEF FN */
	  sub_ptr->object = definedfunc;
	}
    }

    /* establish size of stack frame */
    if (addr[lev] == 0)
       strcpy(bytes,"#\0");
    else
       strcpy(bytes,"#-");     
    itoa(addr[lev],buf,10);   
    strcat(bytes,buf);   
    change(link,"link","a5",bytes);  

    /* exit code */
    if (subprog == subsym) gen(exit_sub_label,"  ","  ");
    gen("unlk","a5","  ");
    gen("rts","  ","  ");
    gen(end_of_sub_label,"  ","  ");

    kill_symtab();
    lev=ZERO;
   } 
  }
 }
}

void parse()
{
 lev=ZERO;
 addr[lev]=0;
 new_symtab();
 create_lists();
  
 insymbol();
 block();

 undef_label_check();
 kill_symtab();
}

void compile(source_name,dest_name)
char *source_name,*dest_name;
{
char buf[40],bytes[40],icon_name[MAXSTRLEN];
FILE *icon_src,*icon_dest;
int  cc;

 /* 
 ** Parse the source file producing XREFs, code, data, 
 ** bss & basdata segments.
 */
 parse();

 /* optimise? */
 if (optimise_opt && !early_exit) optimise();

 if (!module_opt)
 {
   /* startup xrefs for startup.lib */
   enter_XREF("_startup");
   enter_XREF("_cleanup");
 
   /* command line argument xref */
   if (cli_args) enter_XREF("_parse_cli_args");

   if (translateused)
   {
    enter_XREF("_opentranslator");
    enter_XREF("_closetranslator");
   }

   if (mathffpused)
   {
    enter_XREF("_openmathffp");
    enter_XREF("_closemathffp");
   }

   if (mathtransused)
   {
    enter_XREF("_openmathtrans");
    enter_XREF("_closemathtrans");
   }

   if (gfxused)
   {
    enter_XREF("_opengfx");
    enter_XREF("_closegfx");
    enter_XREF("_openintuition");
    enter_XREF("_closeintuition");
   }

   if (intuitionused)
   {
    enter_XREF("_openintuition");
    enter_XREF("_closeintuition");
   }

   if (iffused)
   {
    enter_XREF("_create_ILBMLib");
    enter_XREF("_remove_ILBMLib");
   }

   enter_XREF("_starterr");

   /*
   ** A module may need to jump to _EXIT_PROG so
   ** make this label externally referenceable (* = XDEF).
   */
   enter_XREF("*EXIT_PROG");

   if (ontimerused) enter_XREF("_ontimerstart");

   /*
   ** Always call this in case a db.lib function 
   ** allocates memory via alloc(). This also takes
   ** care of the use of ALLOC by an ACE program.
   ** To do this we always need to externally 
   ** reference the free_alloc() function.
   */
   enter_XREF("_free_alloc");
 }
 else
 {
   /*
   ** Current module may need to jump to _EXIT_PROG, so externally reference it.
   */
    enter_XREF("_EXIT_PROG");
 }
  
 /* DATA statements? */
 if (basdatapresent) enter_BSS("_dataptr:","ds.l 1");
 if ((readpresent) && (!basdatapresent)) _error(25); 

 /* ------------------------------------------------- */
 /* create A68K compatible 68000 assembly source file */
 /* ------------------------------------------------- */

 if (!early_exit) 
	printf("\ncreating %s\n",dest_name);
 else
	printf("\nfreeing code list...\n");

 if (!early_exit) write_xrefs();

 /* startup code */
 fprintf(dest,"\n\tSECTION code,CODE\n\n");

 if (!module_opt)
 {
   /* 
   ** Check for Wb start BEFORE DOING ANYTHING ELSE! 
   ** This also always opens dos.library and stores 
   ** CLI argument data. 
   */
   fprintf(dest,"\tjsr\t_startup\n");
   fprintf(dest,"\tcmpi.b\t#1,_starterr\n"); /* see _startup in startup.lib */
   fprintf(dest,"\tbne.s\t_START_PROG\n");
   fprintf(dest,"\trts\n");
   fprintf(dest,"_START_PROG:\n");

   /* storage for initial stack pointer */
   enter_BSS("_initialSP:","ds.l 1");
   fprintf(dest,"\tmove.l\tsp,_initialSP\n"); /* save task's stack pointer */

   fprintf(dest,"\tmovem.l\td1-d7/a0-a6,-(sp)\n"); /* save initial registers */

   if (cli_args) 
      fprintf(dest,"\tjsr\t_parse_cli_args\n"); /* get CLI arguments */

   if (translateused) 
   {
    fprintf(dest,"\tjsr\t_opentranslator\n");
    fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
    fprintf(dest,"\tbne.s\t_translate_ok\n");
    fprintf(dest,"\tjmp\t_ABORT_PROG\n");
    fprintf(dest,"_translate_ok:\n");
   }   

   if (mathffpused) 
   {
    fprintf(dest,"\tjsr\t_openmathffp\n");
    fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
    fprintf(dest,"\tbne.s\t_mathffp_ok\n");
    fprintf(dest,"\tjmp\t_ABORT_PROG\n");
    fprintf(dest,"_mathffp_ok:\n");
   }   

   if (mathtransused) 
   {
    fprintf(dest,"\tjsr\t_openmathtrans\n"); 
    fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
    fprintf(dest,"\tbne.s\t_mathtrans_ok\n");
    fprintf(dest,"\tjmp\t_ABORT_PROG\n");
    fprintf(dest,"_mathtrans_ok:\n");
   }   

   if (intuitionused && !gfxused) 
   {
    fprintf(dest,"\tjsr\t_openintuition\n");   
    fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
    fprintf(dest,"\tbne.s\t_intuition_ok\n");
    fprintf(dest,"\tjmp\t_ABORT_PROG\n");
    fprintf(dest,"_intuition_ok:\n");
   }   

   if (gfxused)
   {
    /* open intuition.library */
    fprintf(dest,"\tjsr\t_openintuition\n");    
    fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
    fprintf(dest,"\tbne.s\t_intuition_ok\n");
    fprintf(dest,"\tjmp\t_ABORT_PROG\n");
    fprintf(dest,"_intuition_ok:\n");

    /* open graphics.library */
    fprintf(dest,"\tjsr\t_opengfx\n");  
    fprintf(dest,"\tcmpi.b\t#1,_starterr\n");
    fprintf(dest,"\tbne.s\t_gfx_ok\n");
    fprintf(dest,"\tjmp\t_ABORT_PROG\n");
    fprintf(dest,"_gfx_ok:\n");
   }   

   /* create temporary ILBM.library */
   if (iffused) fprintf(dest,"\tjsr\t_create_ILBMLib\n");

   /* get timer event trapping start time */
   if (ontimerused) fprintf(dest,"\tjsr\t_ontimerstart\n");

   /* size of stack frame */ 
   if (addr[lev] == 0)
      strcpy(bytes,"#\0");
   else
      strcpy(bytes,"#-");     
   itoa(addr[lev],buf,10);   
   strcat(bytes,buf);     
 
   /* create stack frame */
   fprintf(dest,"\tlink\ta4,%s\n\n",bytes); 

   /* initialise global DATA pointer */
   if (basdatapresent) fprintf(dest,"\tmove.l\t#_BASICdata,_dataptr\n");
 }

 /* write code & kill code list */
 kill_code();

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
       translateused) 
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

 if (!early_exit)
 {
   write_data();
   write_basdata();  
   write_bss();
 }

 fprintf(dest,"\n\tEND\n");

 /* errors? */
 if (errors > 0) putchar('\n');

 printf("%s compiled ",source_name);

 if (errors == 0)    
    printf("with no errors.\n");
 else
 {
  exitvalue=10; /* set ERROR for bas script */
  printf("with %d ",errors);
  if (errors > 1) printf("errors.\n");
  else printf("error.\n");
 }

 /* make icon? */
 if (make_icon && !early_exit)
 {
  if ((icon_src = fopen("ACE:icons/exe.info","r")) == NULL)
    puts("can't open ACE:icons/exe.info for reading."); 
  else
  {
   cc=0; while(source_name[cc] != '.') cc++; 
   source_name[cc] = '\0';   
   sprintf(icon_name,"%s.info",source_name);
   if ((icon_dest = fopen(icon_name,"w")) == NULL)
      printf("can't open %s.info for writing.\n",source_name);
   else
   {
    while (!feof(icon_src)) fputc(fgetc(icon_src),icon_dest);
    fclose(icon_dest);
    fclose(icon_src);
    puts("icon created.");
   }
  }
 }
}

void show_title()
{
 printf("ACE Amiga BASIC Compiler version %s, copyright ",version());
 putchar(169);  /* copyright symbol */
 puts(" 1991-1996 David Benn.");
 puts("Contributions copyright 2025 Manfred Bergmann.");
}

void usage()
{
 printf("usage: ACE [words | -bcEilmOw] <sourcefile>[.b[as]]\n");
}

BOOL check_options(opt)
char *opt;
{
BOOL legalopt=TRUE;

 if (*opt != '-') return(FALSE);
 /* extract the options */
 opt++;
 if (*opt == '\0') 
    	legalopt=FALSE;
 else
 while ((*opt != '\0') && (legalopt)) 
 {
  if (*opt == 'b') break_opt=TRUE; 
  else
  if (*opt == 'O') optimise_opt=TRUE; 
  else
  if (*opt == 'i') make_icon=TRUE; 
  else
  if (*opt == 'E') error_log=TRUE;
  else
  if (*opt == 'c') asm_comments=TRUE;
  else
  if (*opt == 'l') list_source=TRUE;
  else
  if (*opt == 'm') module_opt=TRUE;
  else
  if (*opt == 'w') wdw_close_opt=TRUE;
  else
     legalopt=FALSE;
  opt++;
 }

 return(legalopt);
}

void ctrl_c_break_test()
{
	if (SetSignal(0L,SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C) 
	{
		puts("\n*** Break: ACE terminating.");
		exit(5);
	}
}

void dump_reserved_words()
{
int i;

 printf("\nAmigaBASIC RESERVED WORDS: %ld\n\n",(xorsym-abssym)+1);

 for (i=abssym;i<=xorsym;i++) 
 {
 	printf("%s\n",rword[i]);
	ctrl_c_break_test();	
 }
 
 printf("\nACE-SPECIFIC RESERVED WORDS: %ld\n\n",(ycorsym-addresssym)+1);

 for (i=addresssym;i<=ycorsym;i++) 
 {
 	printf("%s\n",rword[i]);
	ctrl_c_break_test();	
 }
}
  
int main(argc,argv)
int  argc;
char *argv[];
{
char *tmparg;

 show_title();
  
 /* 
 ** - get args and compiler switches.
 ** - open source and destination files. 
 */ 
 if ((argc == 1) || (argc > 3)) 
    { usage(); exit(10); } /* arg count mismatch */

 /* send reserved words to stdout then quit? */
 tmparg = (char *)malloc(strlen(argv[1])+1);
 if (tmparg == NULL) 
 {
	puts("Unable to allocate temporary argument buffer!");
 	exit(10);
 }
 else   
 {
	strcpy(tmparg,argv[1]);

 	if (strcmp((char*)strupr(tmparg),"WORDS") == 0)
 	{
		dump_reserved_words();
		if (tmparg) free(tmparg);
 		exit(0);
 	}
	else
		if (tmparg) free(tmparg);
 }

 open_shared_libs();

 /* 
 ** compile program 
 */
 if (argc == 2) 
 {
    /* source file, no options */
    open_files(argv[1]);
    setup();
    compile(srcfile,destfile); 
 }
 else 
 {
    /* options plus source file */
    if (!check_options(argv[1])) 
       { usage(); close_shared_libs(); exit(10); } /* illegal options */  
    open_files(argv[2]);  
    setup();
    compile(srcfile,destfile);
 }

 cleanup();
 return 0;
}
