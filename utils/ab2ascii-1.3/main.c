/*
    AmigaBASIC -> ASCII  -- generate ASCII source from AmigaBASIC binaries

    Original version by Stefan Reisner, sr@ph-cip.uni-koeln.de
    Revised & bug-fixes by Tobias Ferber, ukjg@dkauni2.bitnet
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

#include "abasic.h"

/* include the version tag */
#include "ab2ascii.c"
#include "version.h"

/* globals */

/* the symbol table */
symbol_t *sym_tab= NIL(symbol_t *);
int numsyms;

/* the list of code lines */
codeline_t *code_buffer= NIL(codeline_t *);
long current_line, numlines;

char *whoami; /* argv[0] */
char *infile;
int debuglevel= 0;

/* input, output and error stream */
FILE *fin, *fout, *ferr;

static void display_version_information(void)
{
  static char license[]=
    "AmigaBASIC->ASCII is free software; you can redistribute it and/or\n"
    "modify it under the terms of the GNU General Public License as\n"
    "published by the Free Software Foundation; either version 1 of the\n"
    "License, or (at your option) any later version.\n"
    "\n"
    "AmigaBASIC->ASCII is distributed in the hope that it will be useful,\n"
    "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
    "GNU General Public License for more details.\n"
    "\n"
    "You should have received a copy of the GNU General Public License\n"
    "along with AmigaBASIC->ASCII; see the file COPYING.  If not, write to the\n"
    "Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.\n"
    ;

  puts("AmigaBASIC->ASCII Version " VERSION " (compiled " __DATE__ ", " __TIME__ ")\n"
       "(c)Copyright 1994 by Tobias Ferber, ukjg@dkauni2.bitnet\n");

  puts(license);
}


void warn(const char *fmt, ...)
{
  va_list argp;
  va_start(argp,fmt);
  fprintf(ferr,"%s: ",whoami);

  if(infile)
    fprintf(ferr,"%s: ",infile);

  vfprintf(ferr,(char *)fmt,argp);
  fprintf(ferr,"\n");
  fflush(ferr);
  va_end(argp);
}


int dothehardpart( void )
{
  int len, c, n=0;
  int faux_pas= 0;
  long codesize= 0;

  /* initialize globals */

  numsyms= numlines= 0;

  /* begin scanning the input stream */

  c= fgetc(fin);

  if(c != 0xf5)
  {
    warn("Hmmm... this doesn't look like an AmigaBASIC binary.\n"
         "My output will probably look a bit funny.  Proceed, for a laugh.");
  }

  if( feof(fin) || ferror(fin) )
  { warn("unexpected end of input -- no code, no symbols");
    return 1;
  }

  /* read the code segment */

  do {

    /* Stefan Reisner thought that AmigaBASIC encodes the length of a line
     * in a 2 byte word prefix.  This is not the whole truth...
     * I've experienced that the first byte holds a flag (e.g. 0x80 indicates
     * a line number) and only the second byte encodes the length.
     */

    c= fgetc(fin); /* flags */

    if( len= fgetc(fin) )
    {
      codesize += len;
      len-= 2;

      if( !feof(fin) && !ferror(fin) )
        n= read_line(fin,len,c);
    }

  } while( len && n == len && !ferror(fin) && !feof(fin) );

  if( len )
  {
    if( n != len || ferror(fin) )
    {
      warn("I'm confused; after having read the code segment, I still seem\n"
           "to want to go on.  In fact I just wanted to read another %d bytes\n"
           "when a serious problem interrupted me.  I'll try to forget about this.",len);
    }

    if( feof(fin) )
    {
      warn("Uh, oh.  I suspect there was a null missing at the end of the code segment,\n"
           "causing me to read past where I should stop.\n"
           "I'll forget about the symbols now.  Proceed, with fingers crossed.");
    }
  }
  else if( feof(fin) || ferror(fin) ) /* and len <= 0 */
    warn("This seems to be a funny program.  The input ended without any symbol definitions.\n");

  /* read the symbols */

  if( !ferror(fin) && !feof(fin) )
  {
    int ok= 1;

#ifdef DEBUG
    if(debuglevel >= 1)
      fprintf(stderr,"skipping a '\\x%02x' character\n",fgetc(fin));
    else
#endif
      (void)fgetc(fin);  /* skip null byte */

    if( (codesize & 1) == 0 )
    {
#ifdef DEBUG
      if(debuglevel >= 1)
        fprintf(stderr,"skipping another '\\x%02x' character\n",fgetc(fin));
      else
#endif
      (void)fgetc(fin);
    }

    if( feof(fin) || ferror(fin) )
    {
      warn("I was just about to read the symbols when I reached the end of file.\n"
           "Maybe we have a BASIC program without symbols?  We'll see...");
    }

    else do {
      len= fgetc(fin);

      if( !feof(fin) )
        ok= read_sym(fin, len, numsyms++);

    } while( ok && !feof(fin) && !ferror(fin) );

    if( !ok )
    {
      warn("After having read %ld %s I couldn't get another %d bytes.\n"
           "Maybe there is not enough free store?  I'll better stop reading symbols!",
           numsyms-1, (numsyms-1 == 1) ? "symbol": "symbols");
    }
  }

#ifdef DEBUG
    if(debuglevel >= 1)
      fprintf(stderr,"expanding %ld lines of code w/ %d symbols\n",numlines,numsyms);
#endif

  expand_code();

  /* we _must_ call these to become re-entrant */

  free_symbols();
  free_code();

  return faux_pas;
}


/*
   Generate a filename from a format string fmt and the replacement string s for
   the first `%s' in fmt and open this file for write.
   Normally the FILE pointer will be returned, 0 indicates a serious problem.
   This function prints warning messages via warn().
*/

FILE *fmtopen( char *fmt, char *s )
{
  FILE *fp= (FILE *)0L;

  char *fname= (char *)malloc( strlen(s) + strlen(fmt) );

  if(fname)
  {
    sprintf(fname,fmt,s);
    fp= fopen(fname,"w");

    if(!fp)
      warn("can't write to `%s'",fname);
  }
  else warn("out of memory... aaaiiiiiieeeeeeeee!");

  if(fname)
    free(fname);

  return fp;
}


int main( int argc, char **argv )
{
  int badopt= 0;
  int numfiles= 0;
  char *outfmt;

#ifdef _DCC /* Dice */
  expand_args(argc,argv, &argc,&argv);
#endif /* _DCC */

  infile= outfmt= (char *)0L;
  whoami= *argv;

  fin= stdin;
  fout= stdout;
  ferr= stderr;

  while(--argc>0 && !badopt)
  {
    char *arg= *++argv;

    if(*arg=='-')
    {
      if(arg[1]=='-')
        arg= convert_args(*argv);

      switch(*++arg)
      {

/*-d*/  case 'd':
#ifdef DEBUG
          debuglevel= 1;
#else
          echo("not compiled w/ a symbol DEBUG defined.  No debugging information available -- Sorry.");
#endif
          break;

/*-E*/  case 'E':
          if(arg[1]) ++arg;
          else arg= (--argc > 0) ? *(++argv) : (char *)0L;

          if(arg && *arg)
          {
            if(ferr != stderr)
            {
              warn("warning: option `%s' has already been seen!",*argv);
              fclose(ferr);
            }

            ferr= fopen(arg,"w");

            if(!ferr)
            {
              warn("can't direct error output to `%s' -- will use stderr",arg);
              ferr= stderr;
            }
          }
          else
          { warn("missing filename after `%s' option",*argv);
            ++badopt;
          }
          break;

/*-?*/  case '?':
/*-h*/  case 'h':
          fprintf(stderr,
            "usage: %s [options] [-o|>] [outfile] [<] [infiles..]\n\n",whoami);

          display_args();
          badopt= 1; /* hack: means exit. */
          break;

/*-o*/  case 'o':
          if(arg[1]) ++arg;
          else arg= (--argc > 0) ? *(++argv) : (char *)0L;

          if(arg && *arg)
          {
            if(outfmt)
              warn("option `%s' has already been seen!",*argv);
            outfmt= arg;
          }
          else
          {
            warn("missing output filename after `%s' option",*argv);
            ++badopt;
          }
          break;

/*-s*/  case 's':
          warn("silent option `%s' is not yet implemented -- sorry.",*argv);
          break;

/*-v*/  case 'v':
          display_version_information();
          badopt= 1; /* hack: means exit. */
          break;

/*??*/  default:
          warn("unrecognized option `%s'",*argv);
          ++badopt;
          break;
      }
    }
    else
    {
      if(arg && *arg)
      {
        if( chain_fname(arg) )
        {
          warn("out of memory... aaaiiiiiieeeeeeeee!");
          ++badopt;
        }
        else ++numfiles;
      }
      else
      {
        warn("command line error: can't parse `%s'",arg);
        ++badopt;
      }
    }
  }


  if(numfiles)
  {
    while( !badopt && (infile= unchain_fname()) )
    {
      if( fin= fopen(infile,"rb") )
      {
        if( fout= outfmt ? fmtopen(outfmt, infile) : stdout )
        {
          badopt= dothehardpart();

          if(fout != stdout)
            fclose(fout);
        }
        else ++badopt; /* fmtopen() has already warned */
        fclose(fin);
      }
      else
      {
        warn("can't access your input file `%s'",infile);
        ++badopt;
      }
    }
    purge_flist();
  }

  else if( !badopt )
  {
    if( fout= outfmt ? fmtopen(outfmt, "stdin") : stdout )
    {
      badopt= dothehardpart();

      if(fout != stdout)
         fclose(fout);
    }
    else ++badopt; /* fmtopen() has already warned */
  }

  if(fin  && fin  != stdin)    fclose(fin);
  if(fout && fout != stdout)   fclose(fout);
  if(ferr && ferr != stderr)   fclose(ferr);

  exit( badopt ? 1:0 );
}
