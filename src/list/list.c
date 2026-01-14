/*
** Beginnings of a library module to support a list datatype in ACE (** INCOMPLETE **).
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
**
** NOTE: strlen() and strcpy() functions will have to be changed
**       for use with ACE! (see ace:src/lib/c_string.c).
**
** Author: David J Benn
**   Date: 3rd,4th October 1995
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>

#define pairtype	0
#define shorttype	1
#define longtype	2
#define singletype	3
#define stringtype	4
#define notype		30
#define marked		31

#define MEMTYPE		9L

#define OK		0L
#define ERR		1L

#define FATAL		TRUE
#define NONFATAL	FALSE
#define ALLOCERR	1L
#define INTUITIONERR	2L

typedef union value_type {
	SHORT	shortnum;
	LONG	longnum;
	float	singlenum;
	char	*string;
} VALUE;

typedef struct atom_type {
	ULONG kind;
	VALUE value;
	ULONG Reserved;	/* makes ATOM same size as PAIR */
} ATOM;

typedef struct pair_type {
	ULONG kind;
	void *car;		/* points to: ATOM or PAIR */	
	struct pair_type *cdr;	/* points to: PAIR */
} PAIR;

/* Globals */
struct Remember *AllocList = NULL;
struct Library *IntuitionBase = NULL;

/* Prototypes */
PAIR *reverse();
void traverse();

void error();
ATOM *atom();
PAIR *cons();
void *car();
PAIR *cdr();
void ShowAtom();
ULONG TheFlags();
ULONG alloc();
void free_alloc();
void startup();
void cleanup();

/* Functions */
void main()
{
PAIR *p;
SHORT a,b,c;

	startup();

	/* Test of list functions */

	a = 3; 
	b = 5; 
	c = 9;

	p = cons(atom(&a,shorttype),
	    cons(atom(&b,shorttype),
	    cons(atom(&c,shorttype),NULL)));

/*	p = cons(cons(atom(&a,shorttype),NULL),
	         cons(atom("hello world",stringtype),NULL));

	ShowAtom(car(car(p)));
	ShowAtom(car(cdr(p)));
*/

	p = reverse(p);
	traverse(p);

	cleanup();
	exit(OK);
}

PAIR *reverse(L)
PAIR *L;
{
/*
** Reverse a list of atoms by CONSing onto the natural recursion.
*/
	if (L) return cons(atom(&((ATOM *)car(L))->value.shortnum,shorttype),
			   reverse(cdr(L)));
}

void traverse(L)
PAIR *L;
{
/*
	if (L)
	{
		if (((PAIR *)car(L))->kind == pairtype) 
		{
			puts("--> car(L)");
			traverse(car(L));
		}
		else
		{
			puts("--> show car(L)");
			ShowAtom(car(L));
		}

		puts("--> cdr(L)");
		traverse(cdr(L));
	}
*/
	while (L)
	{
		ShowAtom(car(L));
		L = cdr(L);	
	}

}

void error(err, fatal)
ULONG err, fatal;
{
/* 
** Display an error message and terminate program
** if error is fatal.
*/

	switch(err)
	{
		case ALLOCERR 		: puts("Out of memory!"); 
					  break;

		case INTUITIONERR 	: puts("Can't open Intuition library");
					  break;
	}

	cleanup();
	if (fatal) exit(ERR);
}

ATOM *atom(value, type)
void *value;
ULONG type;
{
/*
** Create a new atom, record its type
** and return a pointer to the allocated
** object.
*/
ATOM *a;
char *s;

	a = (ATOM *)alloc(MEMTYPE, sizeof(ATOM));

	if (type == stringtype)
	{
		s = (char *)alloc(MEMTYPE, strlen((char *)value)+1);
		if (s == NULL) error(ALLOCERR, FATAL);
	}

	if (a == NULL)
		error(ALLOCERR, FATAL);
	else
	{
		a->kind = 1<<type;
		
		switch(type)
		{
		  case shorttype  : a->value.shortnum = *((SHORT *)value); break;
		  case longtype	  : a->value.longnum = *((LONG *)value); break;
		  case singletype : a->value.singlenum = *((float *)value); break;
		  case stringtype : strcpy(s,(char *)value); a->value.string = s; break;
		}	
	}

	return a;
}

PAIR *cons(first, second)
void *first;
PAIR *second;
{
/*
** Constructs a pair and sets car and cdr links
** according to first and second parameters.
** While second must be a pair, the first may
** be either a pair or an atom.
*/ 
PAIR *p;

	p = (PAIR *)alloc(MEMTYPE,sizeof(PAIR));

	if (p == NULL) 
		error(ALLOCERR, FATAL);
	else
	{
		p->kind = 1<<pairtype;
		p->car = first;
		p->cdr = second;
	}

	return p;	
}

void *car(pair)
PAIR *pair;
{
/*
** Returns a pointer to the car link of a pair.
** May be a pointer to a pair or an atom.
*/

	if (pair == NULL) 
		return NULL;	/* shouldn't happen */
	else
		return pair->car;
}

PAIR *cdr(pair)
PAIR *pair;
{
/*
** Returns a pointer to the cdr link of a pair.
** This pointer will always be to a pair.
*/
	if (pair == NULL) 
		return NULL;	/* signifies end of list */
	else
		return pair->cdr;
}

void ShowAtom(a)
ATOM *a;
{
	if (a == NULL)
	{
		puts("CAR is NULL!");
	}
	else 
	if (a->kind == pairtype)
	{
		puts("CAR is a PAIR");
	}
	else
	switch(a->kind)
	{
		case 1<<shorttype  : printf(" short: %d\n",((ATOM *)a)->value.shortnum);
				     break;
		case 1<<longtype   : printf("  long: %ld\n",((ATOM *)a)->value.longnum);
				     break;
		case 1<<singletype : printf("single: %lx\n",((ATOM *)a)->value.singlenum);
				     break;
		case 1<<stringtype : printf("string: %s\n",((ATOM *)a)->value.string);
				     break;
	}
}

ULONG TheFlags(MemType,bytes)
LONG MemType,bytes;
{
ULONG flags;

 	switch(MemType)
 	{
  		case 0L : flags = MEMF_CHIP; break;
  		case 1L : flags = MEMF_FAST; break;
  		case 2L : flags = MEMF_PUBLIC; break;

  		case 3L : flags = MEMF_CHIP | MEMF_CLEAR; break;
  		case 4L : flags = MEMF_FAST | MEMF_CLEAR; break;
  		case 5L : flags = MEMF_PUBLIC | MEMF_CLEAR; break;

		case 6L : flags = MEMF_ANY; break;
		case 7L : flags = MEMF_ANY | MEMF_CLEAR; break;

		/* see basfun.c */
		case 9L : flags = MEMF_ANY | MEMF_CLEAR; break;	

		/* if all else fails... */
  		default : flags = MEMF_ANY | MEMF_CLEAR; break;
 	}

	return flags;
}

ULONG alloc(MemType,bytes)
LONG MemType,bytes;
{
/* 
** Allocate memory as requested.
*/	
 	return((ULONG)AllocRemember(&AllocList,bytes,TheFlags(MemType,bytes)));     
}

void free_alloc()
{
/* 
** Free all memory allocated by AllocRemember().
*/
	if (AllocList != NULL) FreeRemember(&AllocList,TRUE);
}

void startup()
{
	IntuitionBase = (struct Library *)OpenLibrary("intuition.library", 0L);
	if (IntuitionBase == NULL) error(INTUITIONERR, FATAL);
}

void cleanup()
{
	if (IntuitionBase) CloseLibrary(IntuitionBase);
	free_alloc();
}
