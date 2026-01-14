/*
   Extract the token table out of the AmigaBASIC Editor (if available on stdin)
   We need AmigaBASIC Version 1.3 as of 6 Oct 1986
   hacked by Tobias Ferber 1994.
*/

#include <stdio.h>

/* let's roll */

int main(int argc, char **argv)
{
  int c,x='A';

  fseek(stdin, 0xBEB4, 0L);  /* beginning of the token table(s) */

  if( ftell(stdin) != 0xBEB4 )
  {
    fprintf(stderr,"usage: %s < [AmigaBASIC Editor]\n",*argv);
    exit(10);
  }

  printf("; AmigaBASIC Token table\n\n");

  getchar();

  do {

    c= getchar();

    if(c == 0x00) do {
      ++x;
      c= getchar();

    } while( c == 0x00 );

    printf("  \"%c",x);
    ungetc(c,stdin);

    do {

      c= getchar();

      if(c < 0x80)
        putchar(c);
      else
        ungetc(c,stdin);

    } while( c < 0x80 && !feof(stdin) );


    printf("\"\t0x");

    do {
      c= getchar();

      if(c >= 0x80)
        printf("%02x",c);
      else
        ungetc(c,stdin);

    } while( c > 0x80 && !feof(stdin) );

    printf("\n");

  } while( !feof(stdin) && x <= 'Z' );

  exit(0);
}
