/*
 *  ABASIC.H
 */

/*
 * (c)Copyright 1994 by Tobias Ferber.
 *
 * This file is part of AmigaBASIC->ASCII.
 *
 * AmigaBASIC->ASCII is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 1 of the
 * License, or (at your option) any later version.
 *
 * AmigaBASIC->ASCII is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AmigaBASIC->ASCII; see the file COPYING.  If not, write to
 * the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef ABASIC_H

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#ifdef __GNUC__
/* suggested parentheses around assignment used as truth value */
#define if(assignment) if( (assignment) )
#define while(assignment) while( (assignment) )
#endif

#define NIL(type)     (type)0L

/* AmigaBASIC variable & label symbols */
typedef struct symbol
{
  struct symbol *next;
  int id;      /* coded in 2 bytes */
  char *s;     /* length coded in 1 byte */

} symbol_t;

#define SYMBOL_SIZE  sizeof(symbol_t)

/* AmigaBASIC code lines */
typedef struct codeline
{
  struct codeline *next;
  int len, flags;
  unsigned char *s;

} codeline_t;

#define CODELINE_SIZE  sizeof(codeline_t)


/*** / GLOBALS / ***/

/* tokens.c */
extern int tok_min, tok_max;  /* 1 byte tokens */
extern int f8_min, f8_max,    /* 2 byte tokens */
           f9_min, f9_max,
           fa_min, fa_max,
           fb_min, fb_max;

extern char *tok_tab[], *f8_tab[], *f9_tab[], *fa_tab[], *fb_tab[];

/* main.c */
extern symbol_t *sym_tab;         /* gloabal symbol table */
extern int numsyms;               /* #of available symbols */
extern codeline_t *code_buffer;   /* list of code lines */
extern long numlines;             /* #of code lines */
extern long current_line;
extern char *whoami;              /* global copy of argv[0] */
extern char *infile;              /* current input filename */
extern FILE *fin, *fout, *ferr;

/*** / PROTOTYPES / ***/

#ifndef __P

#if defined (__STDC__) || defined(__cplusplus)
#define __P(protos) protos
#else /* !(__STDC__ || __cplusplus) */
#define __P(protos) ()
#endif /* __STDC__ || __cplusplus */

#endif /* !__P */

/* main.c */
extern void warn __P( (const char *fmt, ...) );

/* args.c */
extern char *convert_args __P( (char *) );
extern void display_args __P( (void) );

/* flist.c */
extern int chain_fname __P( (char *fname) );
extern char *unchain_fname __P( (void) );
extern void purge_flist __P( (void) );

/* symbols.c */
extern int read_sym __P( (FILE *fp, int len, int id) );
extern char *get_sym __P( (int id) );
extern void free_symbols __P( (void) );

/* codelines.c */
extern int read_line __P( (FILE *fp, int len, int flags) );
extern void free_code __P( (void) );

/* expand.c */
extern void expand_code __P( (void) );

#endif /* !ABASIC_H */
