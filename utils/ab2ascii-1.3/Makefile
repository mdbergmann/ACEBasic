#
# Makefile for the AmigaBASIC -> ASCII converter
#
# (c)Copyright 1994 by Tobias Ferber.
#
# This file is part of AmigaBASIC->ASCII.
#
# AmigaBASIC->ASCII is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 1 of the
# License, or (at your option) any later version.
#
# AmigaBASIC->ASCII is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with AmigaBASIC->ASCII; see the file COPYING.  If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#

rm= rm
CC= gccv
CFLAGS= -O2 -Wall -L/usr/os-lib -DDEBUG

.PHONY: all clean

all: ab2ascii

ab2ascii: main.o args.o flist.o symbols.o codelines.o expand.o tokens.o
	$(CC) $(CFLAGS) -lm -o $@ $^

main.o: main.c abasic.h ab2ascii.c
	$(CC) $(CFLAGS) -c -o $@ main.c

args.o: args.c
	$(CC) $(CFLAGS) -c -o $@ $<

flist.o: flist.c
	$(CC) $(CFLAGS) -c -o $@ $<

symbols.o: symbols.c abasic.h
	$(CC) $(CFLAGS) -c -o $@ symbols.c

codelines.o: codelines.c abasic.h
	$(CC) $(CFLAGS) -c -o $@ codelines.c

expand.o: expand.c abasic.h
	$(CC) $(CFLAGS) -c -o $@ expand.c

tokens.o: tokens.c
	$(CC) $(CFLAGS) -c -o $@ tokens.c

# --- clean

clean:
	$(rm) ab2asci main.o args.o flist.o symbols.o codelines.o tokens.o
