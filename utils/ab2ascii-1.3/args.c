/*
 *  ARGS.C
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

#include <string.h>
#include <stdio.h>

static char *howtouse[]= {
#ifdef DEBUG
  "-d", "--debug",           "set debugging mode on",
#endif
  "-E", "--stderr",          "redirect error messages",
  "-h", "--help",            "display this short usage information and exit",
  "-o", "--output",          "set output filename (%s for the input filename)",
  "-v", "--version",         "display author and version information",
  (char *)0L, (char *)0L, (char *)0L
};

char *
convert_args(s)
char *s;
{
  char **t= howtouse;

  while(*t)
  { if(!strcmp(s,t[1]))
      break;
    t= &t[3];
  }

  return (*t) ? *t : s;
}

void
display_args(void)
{
  char **t= howtouse;

  while(*t)
  { if(t[2] && *t[2])
      printf("%2s or %-16s %s\n",t[0],t[1],t[2]);
    t= &t[3];
  }
}
