/* << ACE >> 

   -- Amiga BASIC Compiler --

   ** #includes, #defines and function prototypes ** 
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
     Date: 19th October-30th November, 3rd-12th December 1991,
	   14th,27th January 1992, 5th,7th-17th, 
           23rd-24th February 1992,
           14th,22nd March 1992,
	   21st April 1992,
	   2nd,11th,15th May 1992,
	   7th,8th,9th,11th,13th,14th,28th June 1992,
	   2nd-6th,8th,14th-19th,26th,28th,29th July 1992,
	   1st,9th August 1992,
	   6th,28th December 1992,
	   7th January 1993,
	   11th,13th February 1993,
	   1st,6th March 1993,
	   12th April 1993,
	   17th May 1993,
	   12th,14th June 1993,
	   1st July 1993,
	   5th,25th September 1993,
	   26th October 1993,
	   6th,15th November 1993,
	   17th,18th,24th December 1993,
	   2nd,3rd,7th,9th January 1994,
	   6th,15th,16th,27th February 1994,
	   10th,14th July 1994,
	   11th September 1994,
	   13th May 1996,
	   4th,22nd June 1996,
	   4th September 1996
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/mathffp.h>
#include <libraries/mathlibrary.h>
#include <libraries/dos.h>
#include <stdio.h>

#ifdef __GNUC__
/* force compiling with builtin math for gcc */
/*
#define SPFloor( a )      ( floor( a ) )
#define SPCmp( a,b )      ( ( a > b ) ? 1 : ( a < b ) ? -1 : 0 )
#define SPFix( a )        ( (int) a )
#define SPCeil( a )       ( ceil( a ) )
#define SPFlt( a )        ( (float) a )
#define SPSub( a,b )      ( (float)(a) - (float)(b) )
#define SPAdd( a,b )      ( (float)(a) + (float)(b) )
#define SPMul( a,b )      ( (float)(a) * (float)(b) )
#define SPDiv( a,b )      ( (float)(a) / (float)(b) )
#define SPPow( a,b )      ( pow( (float)(a), (float)(b) ) )
*/
extern LONG SPFlt(LONG);
extern LONG SPAdd(LONG,LONG);
extern LONG SPSub(LONG,LONG);
extern LONG SPMul(LONG,LONG);
extern LONG SPDiv(LONG,LONG);
extern LONG SPCmp(LONG,LONG);
extern LONG SPPow(LONG,LONG);
extern LONG SPFix(LONG);
extern LONG SPFloor(LONG);
extern LONG SPCeil(LONG);
extern LONG SPTst(LONG);

#endif

/* AmigaBASIC reserved words */
enum { 	abssym = 0,
	allsym,		
	andsym,		
	appendsym,  	
	areasym,  	
	areafillsym, 	
	assym,  		
	ascsym, 		
	atnsym, 		
	basesym,		
	beepsym,  	
	breaksym, 	
	callsym,  	
	cdblsym,  	
	chainsym,	
	chdirsym, 	
	chrstrsym, 	
	cintsym,  	
	circlesym, 	
	clearsym,	
	clngsym,  	
	closesym, 	
	clssym,  	
	collisionsym,	
	colorsym, 	
	commonsym,	
	contsym,  	
	cossym,  	
	csngsym,  	
	csrlinsym, 	
	cvdsym,		
	cvisym,		
	cvlsym,		
	cvssym,		
	datasym,  	
	datestrsym, 	
	declaresym, 	
	defsym,  	
	defdblsym, 	
	defintsym, 	
	deflngsym, 	
	defsngsym, 	
	defstrsym, 	
	deletesym, 	
	dimsym,  	
	elsesym,  	
	elseifsym, 	
	endsym,  	
	eofsym,  	
	eqvsym,  	
	erasesym, 	
	erlsym,  	
	errsym,  	
	errorsym, 	
	exitsym,  	
	expsym,  	
	fieldsym,	
	filessym,	
	fixsym,  	
	fnsym,  		
	forsym, 	 	
	fresym,  	
	functionsym, 	
	getsym,  	
	gosubsym, 	
	gotosym,  	
	hexsym,  	
	ifsym,  		
	impsym,  	
	inkeysym, 	
	inputsym, 	
	inputstrsym,	
	instrsym, 	
	intsym,  	
	killsym,  	
	lboundsym,  	
	leftstrsym, 	
	lensym,  	
	letsym,  	
	librarysym, 	
	linesym,  	
	listsym,		
	llistsym,	
	loadsym,		
	locsym,  	
	locatesym, 	
	lofsym,  	
	logsym,  	
	lpossym,  	
	lprintsym, 	
	lsetsym,		
	menusym,  	
	mergesym,	
	midstrsym, 	
	mkdstrsym,	
	mkistrsym,	
	mklstrsym,	
	mksstrsym,	
	modsym,  	
	mousesym, 	
	namesym,  	
	newsym,		
	nextsym,  	
	notsym,  	
	objaxsym,	
	objaysym,	
	objclipsym,	
	objclosesym,	
	objhitsym,	
	objoffsym,	
	objonsym,	
	objplanessym,	
	objprioritysym,	
	objshapesym,	
	objstartsym,	
	objstopsym,	
	objvxsym,	
	objvysym,	
	objxsym,		
	objysym,		
	octstrsym, 	
	offsym,  	
	onsym,  		
	opensym,		
	optionsym,	
	orsym,  		
	outputsym,	
	paintsym, 	
	palettesym, 	
	patternsym, 	
	peeksym,  	
	peeklsym, 	
	peekwsym, 	
	pointsym, 	
	pokesym,  	
	pokelsym, 	
	pokewsym, 	
	possym,  	
	presetsym, 	
	printsym, 	
	psetsym,  	
	ptabsym,  	
	putsym,  	
	randomizesym, 	
	readsym,  	
	remsym,  	
	restoresym, 	
	resumesym,	
	returnsym, 	
	rightstrsym, 	
	rndsym,  	
	rsetsym,		
	runsym,		
	saddsym,  	
	savesym,		
	saysym,  	
	screensym, 	
	scrollsym, 	
	sgnsym,  	
	sharedsym, 	
	sinsym,  	
	sleepsym, 	
	soundsym, 	
	spacestrsym, 	
	spcsym,  	
	sqrsym,  	
	staticsym, 	
	stepsym,  	
	sticksym, 	
	stopsym,  	
	strstrsym, 	
	strigsym, 	
	stringstrsym,	
	subsym,  	
	swapsym,  	
	systemsym, 	
	tabsym,  	
	tansym,  	
	thensym,  	
	timestrsym, 	
	timersym, 	
	tosym,  		
	translatestrsym, 
	troff,		
	tron,		
	uboundsym,	
	ucasestrsym, 	
	usingsym, 	
	valsym,  	
	varptrsym, 	
	waitsym,  	
	wavesym,  	
	wendsym,  	
	whilesym, 	
	widthsym, 	
	windowsym, 	
	writesym, 	
	xorsym,

/* ACE-specific reserved words */
	addresssym,
	allocsym,
	argstrsym,
	argcountsym,
	assemsym,
	backsym,
	bevelboxsym,
	binstrsym,
	blocksym,
	buttonsym,
	bytesym,
	casesym,
	constsym,
	cstrsym,
	daysym,	
	externalsym,
	fileboxstrsym,
	fontsym,	
	forwardsym,
	gadgetsym,
	globalsym,
	handlesym,
	headingsym,
	homesym,	
	iffsym,	
	inputboxsym,
	inputboxstrsym,
	longintsym,
	messagesym,	
	msgboxsym,	
	pendownsym,	
	penupsym,	
	potxsym,	
	potysym,	
	printssym,	
	repeatsym,	
	serialsym,	
	setheadingsym,	
	setxysym,	
	shlsym,		
	shortintsym,	
	shrsym,		
	singlesym,	
	sizesym,	
	sizeofsym,
	stringsym,
	structsym,	
	stylesym,	
	turnsym,	
	turnleftsym,
	turnrightsym,
	turtlesym,	
	untilsym,	
	xcorsym,	
	ycorsym,	
 
	RWSENTINEL };

/* special symbols */
enum {	increment =	500,
	decrement,
	shortpointer,	
	longpointer,
	singlepointer,
	memberpointer,
	plus,
	minus,
	multiply,
	fdiv,
	idiv,
	raiseto,
	lparen,
	rparen,
	comma,
	apostrophe,
	semicolon,
	becomes,
	colon,
	question,
	notequal,
	ltorequal,     
	gtorequal,
	equal,
	lessthan,
	gtrthan,
	hash,
	octalprefix,
	hexprefix,
	atsymbol,
	endofline,

	RSSENTINEL };

/* symbols */
enum {	shortconst = 	1000,
	longconst,
	singleconst,
	doubleconst,
	stringconst,
	ident };

/* types */
enum {	bytetype = 	2000,
	shorttype,
	longtype,
	singletype,
	doubletype,
	stringtype,
	notype };

/* objects */
enum {	variable = 	3000,
	array,
	subprogram,
	definedfunc,
	function,
	extfunc,
	extvar,
	label,
	constant,
	structdef,
	structure,
	rsvd_word,

	undefined =      9999 };

#define	MAXLINELEN   1024          /* max length of a BASIC line */
#define	MAXIDSIZE     42           /* max length of identifier (+ qualifier) */
#define	MAXSTRLEN   1024           /* max length of string */
#define	MAXSHORT   32767           /* max +ve short value */
#define	MINSHORT  -32768           /* min -ve short value */
#define	MAXLONG    2147483647      /* max +ve long value */
#define	MINLONG   -2147483648      /* min -ve long value */ 
#define	MAXPARAMS     40    	   /* max # of subprogram parameters */
#define	NEGATIVE      -1	   /* a negative result from ACE lib check */
#define	MAXCASES     1000  	   /* max # of cases in a CASE statement */
#define	NUMACELIBS     7	   /* # of shared libraries used by ACE */
#define	NUMLIBS	      40	   /* max # of "other" shared libraries */
#define	LF_CODE	       0	   /* line feed code for PRINTS */
#define	TAB_CODE       1	   /* tab code for PRINTS */
#define	SPACE_CODE     2	   /* single space code for PRINTS */

/* --symbol table-- */
#define	ZERO        0
#define	ONE         1
#define	fwdref      0
#define	subdecl     1
#define	undeclared  2	   /* undeclared string variable (eg: x$="A")*/	
#define	declared    3	   /* string variable declared with STRING */
#define	MAXDIMS   255

/* --symbol table-- */
typedef union conststruct {
			   SHORT shortnum;	
			   LONG  longnum;
			   float singlenum;
			  } CONST;

typedef struct structmem {
			  char  name[MAXIDSIZE];
			  int   type;
			  ULONG offset;
			  ULONG strsize;
			  struct structmem *next;
			 } STRUCM;
  
typedef struct symstruct {
			  char   *name;              /* name of identifier */
			  int    type;               /* type (short,long...) */
			  int    object;             /* variable,sub... */
			  int    dims;               /* # of array elements */
			  BOOL   shared;	     /* is object shared? */
			  BOOL   new_string_var;     /* new string variable? */
			  SHORT  *index;     	     /* array indices */
			  SHORT	 no_of_params;       /* # of SUB parameters */
			  int	 p_type[MAXPARAMS];  /* SUB parameter types */
			  UBYTE  decl;		     /* forward reference? */
			  UBYTE  *reg;	     	     /* lib function regs */
			  char   *libname;	     /* library name */
			  CONST  numconst;	     /* a numeric constant */
			  STRUCM *structmem;         /* structdef list ptr */
			  int    address;            /* frame/library offset */
			  ULONG  size;		     /* # of bytes in object */
			  int    level;              /* main or sub program */
			  struct symstruct *other;   /* for cross-reference */
			  struct symstruct *next;    /* next table entry */
		    	 } SYM;

/* --code generator-- */

/* --code list-- */
typedef struct codelist {
			 char *opcode;          /* 68000 opcode */ 
			 char *srcopr;          /* source operand */
			 char *destopr;         /* destination operand */
			 struct codelist *next;
			} CODE;

/* --data list-- */
typedef struct datalist {
			 char *name;	        /* name of storage */
			 char *literal;         /* data */
			 struct datalist *next;
			} DATA;

/* --bss list-- */
typedef struct bsslist {
			 char *name;	        /* name of storage */
			 char *store;   	/* storage type & size */
			 struct bsslist *next;
		       } BSS;

/* --XREF list-- */
typedef struct xreflist {
			 char *name;           /* name of external reference */
			 struct xreflist *next;
			} XREF;

/* --BASIC DATA list-- */
typedef struct basicdatalist {
			 char *literal; /* string or float constant */
			 struct basicdatalist *next;
			} BASDATA;

/* --ACE library usage information-- */
typedef struct aceliblist {
			   char name[MAXIDSIZE];   /* library name */
			   char base[MAXIDSIZE+5]; /* library base: _NAMEBase */
			  } ACELIBS;

/* --function protos-- */

/* opt.c */
BOOL 	is_a_move();
SHORT	peephole();
void	optimise();

/* lex.c */
void	open_shared_libs();
void	close_shared_libs();
void 	setup();
void	cleanup();
void	_warn();
void	_error();
void	_abort();
void	open_files();
void	nextch();
BOOL	letter();
BOOL	digit();
BYTE	hex_digit();
BYTE	octal_digit();
BOOL	qualifier();
void	convert_special_ident();
BOOL	ssymbol();
int	rsvd_wd();
int	rsvd_sym();
void 	reclassify_number();
void	classify_integer();
void	insymbol();
void	showsym();
void 	showobj();
void	showtyp();
void	tab();
void	cr();
void	lf();

/* alloc.c */
void	*alloc();
void	free_alloc();
void	*sym_alloc();
void	free_sym_alloc();
CODE	*alloc_code();
void	free_code();
BOOL	alloc_code_members();
void	free_code_members();

/* sym.c */
void	new_symtab();
void	kill_symtab();
void	find_tab_tail();
BOOL	exist();
void	enter();
void	create_lists();
BOOL	is_a_label();
void	write_code();
BOOL	label_undef();
void	undef_label_check();
void	kill_code();
void	gen();
void	change();
BOOL	exist_DATA();
void	enter_DATA();
void	write_data();
BOOL	exist_BSS();
void	enter_BSS();
void	write_bss();
BOOL	exist_XREF();
void	enter_XREF();
void	write_xrefs();
void	enter_BASDATA();
void	write_basdata();
void	find_structmem_tail();
BOOL	structmem_exist();
void	add_struct_member();

/* basfun.c */
BOOL	strfunc();
int	stringfunction();
int	gen_single_func();
BOOL	numfunc();
int	numericfunction();	
int  	address_of_object();
int  	find_object_size();

/* functions in main ace modules */
void	make_temp_long();
void	make_temp_short();
void	make_temp_string();
void	make_string_const();

void	make_label_from_linenum();

LONG	max_array_ndx();
void	push_indices();
void	get_abs_ndx();

void	push_num_constant();
int	push_struct();

void	assem();
void	parse_option_list();

BOOL	factorfunc();
int	factor();
BOOL	coerce();

void	make_short();
void	make_long();

int	ptr_term();
int	expterm();
int	negterm();
int	prodterm();
int	idivterm();
int	modterm();
int	simple_expr();
BOOL	relop();
char	*cond_branch_op();
void	make_label();
int	relexpr();
int	notexpr();
int	andexpr();
int	orexpr();
int	eqvexpr();
int	expr();

void	pop_operands();
void	push_result();

void	gen_round();
void	gen_Flt();
void	change_Flt();

int	make_integer();
int	assign_coerce();
void	make_string_store();
void	create_string_variable();
void	assign_to_string_variable();
void	assign_to_string_array();
void	assign_to_struct();
void	assign();

void	make_array_name();
void	dim();

void	gen_printcode();
void	print_statement();
void	gen_printscode();
void	prints_statement();

void	block_if();
void	if_statement();
void	while_statement();
void	repeat_statement();
void	case_statement();
int	for_assign();
void	for_statement();
void	gen_branch();
void	on_branch();
void	block_statement();

void	make_sure_short();
void	make_sure_long();

void	pset();
void	paint();
void	circle();
void	draw_line();
void	color();
void	text_style();
void	text_font();
void	gfx_get();
void	gfx_put();

void	input();
void	point_to_array();
void	make_data_const();
void	get_data();
void	read_data();

void	change_id_type();

void	screen();
void	scroll();

void	window();
void	wdwclose();
void	wdwoutput();

void	gadget_rectangle();
void	gadget();
void	wait_gadget();
void	modify_gadget();
void	close_gadget();
void	bevel_box();

void	MsgBox();

void	clear_menu();
void	wait_menu();
void	menu();

void	open_a_file();
void	close_a_file();
void	line_input();
void	write_to_file();
void	gen_writecode();
void	print_to_file();
void	input_from_file();
void	kill();
void	osrename();
void	chdir();
void	files();

void	serial_command();
void	open_serial();
void	close_serial();
void	read_serial();
void	write_serial();
void	name_serial();

void	message();
void	message_open();
void	message_close();
void	message_read();
void	message_write();
void	message_wait();
void	message_clear();

void	iff();
void	iff_open();
void	iff_read();
void	iff_close();

BYTE 	check_for_ace_lib();
void	enter_new_library();
void	make_library_base();	
void	make_library_name();	
void	make_bmap_name();
void	get_libname();
void	library();
void	closelibrary();
void	remove_qualifier();
BOOL	search_func();
BOOL	found_func();
void	declare();

void 	load_func_params();
void 	load_mc_params();

void	sound();

void	get_event_trap_label();
void	change_event_trapping_status();
void	check_for_event();
void	ctrl_c_test();
void	break_event_test();
void	menu_event_test();
void	mouse_event_test();
void	timer_event_test();
void	error_event_test();
void	wdw_close_test();
void 	wdw_event_test();
void	gad_event_test();

void	define_structure();
void	declare_structure();
void	define_constant();
void	declare_variable();
void	define_external_object();
void	define_external_variable();
void	define_external_function();

void	call_external_function();

void	poke();
void	pokew();
void	pokel();
void	get_obj_info();
void	swap();

void	handle_label();
void	statement();

void	forward_ref();
void	load_params();
void	sub_params();
void	parse_shared_vars();

void	block();
void	parse();
void	compile();

void	show_title();
void	usage();
BOOL	check_options();
void	dump_reserved_words();
int	    main();
