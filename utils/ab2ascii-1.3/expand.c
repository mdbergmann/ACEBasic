/*
 *  EXPAND.C
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

static unsigned char *codeptr;

/*
   Print unknown token values and character codes and warn about them.
   The value of n should be 1 (for one character) or 2 for a word of two.
*/

static void p_unknown(int n, ...)
{
  va_list argp;
  va_start(argp, n);

  fprintf(ferr,"%s: ",whoami);

  if(infile)
    fprintf(ferr,"%s: ",infile);

  fprintf(ferr,"%ld warning: Can't expand that token: ",current_line);

  if(n==1)
  { vfprintf(ferr,"<0x%02x>",argp);
    vfprintf(fout,"<0x%02x>",argp);
  }
  else /* n!=1 */
  { vfprintf(ferr,"<0x%02x,0x%02x>",argp);
    vfprintf(fout,"<0x%02x,0x%02x>",argp);
  }

  fprintf(ferr,"\n");
  fflush(ferr);
  va_end(argp);
}


/*
   These functions return the next byte, word, long, float or double from the
   current code line (codeptr).  No memory border checking will be performed.
   get_float() and get_double() are very, very hacky!
*/

static int get_byte( void )
{
  return ( (int)*codeptr++ ) & 0xFF;
}


static int get_word( void )
{
  return ( (*codeptr++ << 8) + *codeptr++ ) & 0xFFFF;
}


static long get_long( void )
{
  return ((long)get_word() << 16) + (long)get_word();
}


/*
   Die 32 bit der Fließkommazahlen einfacher Genauigkeit von links nach rechts:

     1 bit   Vorzeichen  (0=pos, 1=neg)
     7 bit   Exponent (2er-Potenz zur Multiplikation mit der Mantisse)
    24 bit   Mantisse mit führendem 1 bit (normalisierte Darstellung: 1<= m <2)

    Beispiele:    1.0 = 0x3f800000           Die kleinste darstellbare Zahl ist
                 -1.0 = 0xbf800000
                  0.0 = 0x00xxxxxx                         -38
                 10.0 = 0x41200000                 1.8 * 10
                  0.1 = 0x3dcccccd
*/

static float get_float( void )
{
  float f;
  *( (long *)&f ) = get_long();

#ifdef _DCC
  f *= 4.0;
#endif

  return f;
}

/*
   Die 64 bit der Fließkommazahlen doppelter Genauigkeit von links nach rechts:

     1 bit   Vorzeichen  (0=pos, 1=neg)
    11 bit   Exponent (2er-Potenz zur Multiplikation mit der Mantisse)
    52 bit   Mantisse mit führendem 1 bit (normalisierte Darstellung: 1<= m <2)

    Beispiele:    1.0 = 0x3ff0000000000000   Die kleinste darstellbare Zahl ist
                 -1.0 = 0xbff0000000000000
                  0.0 = 0x000xxxxxxxxxxxxx                  -308
                 10.0 = 0x4024000000000000         2.23 * 10
                  0.1 = 0x3fb9999999999999
*/

static double get_double( void )
{
  double d;
  *( (long *)&d ) = get_long();
  (void)get_long(); /* ? */
  return d;
}


#define unget(n)  codeptr-=(n)


static void expand_token( int t )
{
  switch( t )
  {

/**/case 0x00:
      fputc( '\n',fout );
      break;

/**/case 0x01:  /* variable reference */
      {
        short id;
        char *s;

        id= get_word();

        if( s = get_sym(id) )
        {
          fputs( s,fout );
        }
        else
        {
          fprintf(fout,"var%04x",id);
          warn("%ld: warning: reference to undeclared variable id %d",
            current_line,id);
        }
      }
      break;

/**/case 0x02:  /* label definition */
      {
        short id;
        char *s;

        id= get_word();

        if( s= get_sym(id) )
        {
          fputs( s,fout );
        }
        else
        {
          fprintf(fout,"label%04x",id);
          warn("%ld: warning: label definition w/ undefined symbol id %d",
            current_line,id);
        }
      }
      break;

/**/case 0x03:  /* label reference */
      if( get_byte() == 0)
      {
        short id;
        char *s;

        id = get_word();

        if( s= get_sym(id) )
        {
          fputs( s,fout );
        }
        else
        {
          fprintf(fout,"label%04x",id);
          warn("%ld: warning: reference to label w/ undefined symbol id %d",
            current_line,id);
        }
      }
      break;

/**/case 0x08:
      get_byte(); /* conditional skip (introduced by <0xc4,0x44>) */
      get_byte();
      get_byte();
      break;

/**/case 0x0e:    /* 0x00 + 2 byte line # reference */
      get_byte();
      fprintf( fout, "%d", get_word() );
      break;

/**/case 0x0f:  /* 1 byte decimal integer */
      fprintf( fout, "%d", get_byte() );
      break;

/**/case 0x0c:  /* 2 byte hex integer */
      fprintf( fout, "&H%x", get_word() );
      break;

/**/case 0x1c:  /* 2 byte integer */
      fprintf( fout, "%d", get_word() );
      break;

/**/case 0x1d:  /* 4 byte float */
      fprintf( fout, "%g", get_float() );
      break;

/**/case 0x1e:  /* 4 byte decimal integer */
      fprintf( fout, "%ld", get_long() );
      break;

/**/case 0x1f:  /* 8 byte double */
      fprintf( fout, "%g", get_double() );
      break;

/**/case '\"':
      {
        int c;

        fputc( t,fout );
        for(;;)
        {
          c= get_byte();

          if(c)
          {
            fputc( c,fout );

            if( c == '\"' )
            {
              c= get_byte();
              if( c == '\"' )
              {
                fputc( c,fout );
              }
              else
              {
                unget(1);
                break;
              }
            }
          }
          else /* c == '\0' */
          {
            unget(1);
            break;
          }
        }
      }
      break;

/**/case 0x3a:
      t= get_word();
      if(t != 0xafe8) /* tick'ed REMark */
        fputc( 0x3a, fout );
      unget(2);
      break;

/**/case 0xaf: /* REM */
      {
        int c= get_byte();

        if( c != 0xe8 )
        {
          fputs( tok_tab[t-tok_min], fout );
          unget(1);
        }
        else fputs( tok_tab[c-tok_min], fout );

        while( c= get_byte() )
          fputc( c,fout );

        fputc( '\n',fout );
      }
      break;

/**/case 0xbe: /* WHILE */
      fputs( tok_tab[t-tok_min], fout );
      get_byte();
      break;

/**/case 0xf8:
      t= get_byte();
      if( f8_min <= t && t <= f8_max )
      {
        if(f8_tab[t-f8_min])
          fputs( f8_tab[t-f8_min], fout );
        else
          p_unknown(2, 0xf8,t);
      }
      else p_unknown(2, 0xf8,t);
      break;

/**/case 0xf9:
      t= get_byte();
      if( f9_min <= t && t <= f9_max )
      {
        if(f9_tab[t-f9_min])
          fputs( f9_tab[t-f9_min], fout );
        else
          p_unknown(2, 0xf9,t);
      }
      else p_unknown(2, 0xf9,t);
      break;

/**/case 0xfa:
      t= get_byte();
      if( fa_min <= t && t <= fa_max )
      {
        if(fa_tab[t-fa_min])
          fputs( fa_tab[t-fa_min], fout );
        else
          p_unknown(2, 0xfa,t);
      }             
      else p_unknown(2, 0xfa,t);
      break;

/**/case 0xfb:
      t= get_byte();
      if( fb_min <= t && t <= fb_max )
      {
        if(fb_tab[t-fb_min])
          fputs( fb_tab[t-fb_min], fout );
        else
          p_unknown(2, 0xfb,t);
      }
      else p_unknown(2, 0xfb,t);
      break;


/**/default:
      if( 0x11 <= t && t <= 0x1a)
      {
        fputc( t - 0x11 + '0', fout );  /* digits '0'..'9' */
      }

      else if( tok_min <= t && t <= tok_max)
      {
        if(tok_tab[t-tok_min])
          fputs( tok_tab[t-tok_min], fout );
        else
          p_unknown(1,t);
      }

      else
      {
        if( isprint(t) )
          fputc( t,fout );
        else
          p_unknown(1,t);
      }

      break;
  }
}


void expand_code( void )
{
  for(current_line=1; code_buffer; current_line++)
  {
    codeline_t *cl= code_buffer;
    char *s= codeptr= cl->s;

    int i= get_byte(); /* indentation */
    while(i--) fputc( ' ',fout );

    if(cl->flags)
    {
      switch(cl->flags)
      {
        case 0x80: /* line # definition */
          fprintf( fout,"%d ",get_word() ); /* decimal number plus 1 space character */
          break;

        default:
          warn("%d: warning: unknown code line prefix 0x%02x",
            current_line, cl->flags);
          break;
      }
    }

    do {

      expand_token( get_byte() );

    } while( (long)codeptr - (long)s < cl->len );

    if( (long)codeptr - (long)s != cl->len )
      warn("%d: warning: expanded %ld of %d code bytes",
        current_line, (long)codeptr - (long)s, cl->len);

    code_buffer= code_buffer->next;

    free(cl->s);
    free(cl);
  }

  if(current_line-1 != numlines)
    warn("warning: expanded %ld of %ld code lines", current_line-1, numlines);
}
