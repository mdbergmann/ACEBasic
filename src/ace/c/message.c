/*
** ACE Message Ports.
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
** Author: David J Benn
**   Date: 15th February 1994,
**	   22nd August 1994,
**	   1st September 1994
*/

#include "acedef.h"

/* locals */
static 	char	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	int	sym;
extern	int	typ;
extern	int	obj;
extern	int	lev;
extern	char	id[MAXIDSIZE];
extern	SYM	*curr_item;

/* functions */
void	message_open()
{
/* 
** MESSAGE OPEN [#]channel,port-name,mode
*/
int	mtype;

	insymbol();

	if (sym == hash) insymbol();

	mtype = expr();

	if (mtype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(mtype) == shorttype) make_long();
		
		if (sym != comma) 
			_error(16);
		else
		{
			/* port-name */
			insymbol();
			if (expr() != stringtype)
				_error(4);
			else
			{
				if (sym != comma)
					_error(16);
				else
				{
					/* mode (r,R,w,W) */
					insymbol();
					if (expr() != stringtype)
						_error(4);
					else
					{
					  /* call function */
					  gen("jsr","_MessageOpen","  ");
					  gen("add.l","#12","sp");
					  enter_XREF("_MessageOpen");
					}				
				}
			}
		} 
			
	}
}

void	message_read()
{
/* 
** MESSAGE READ [#]channel,message-string
*/
int	mtype;
SYM	*storage;
char	addrbuf[40];

	insymbol();

	if (sym == hash) insymbol();

	mtype = expr();

	if (mtype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(mtype) == shorttype) make_long();
		
		if (sym != comma) 
			_error(16);
		else
		{
  			/*
			** Message string. 
			*/
  			insymbol();						
  			if (sym == ident && obj == variable)
  			{
   				/* 
				** If string variable/array doesn't exist, 
				** create a simple variable.
				*/
   				if (!exist(id,variable) && !exist(id,array)) 
   				{
    					/* 
					** Allocate a simple string variable.
					*/
    					enter(id,typ,obj,0);
    					enter_DATA("_nullstring:","dc.b 0");
    					gen("pea","_nullstring","  ");
    					assign_to_string_variable(curr_item,
								  MAXSTRLEN);
   				}

   				storage = curr_item;

   				/* 
				** Is it a string variable or array? 
				*/
   				if (storage->type != stringtype) _error(4);
   				else    
   				{
    					/* 
					** Get address of string pointed to 
					** by variable/array element.
					*/
    					itoa(-1*storage->address,addrbuf,10);
    					strcat(addrbuf,frame_ptr[lev]);

    					/*
					** Pass string address to function 
					** (on stack).
					*/
    					if (storage->object == array)
    					{
     						point_to_array(storage,addrbuf);
     						gen("move.l",addrbuf,"d0");
     						gen("add.l","d7","d0");
     						gen("move.l","d0","-(sp)");
    					}
     					else
      	 					gen("move.l",addrbuf,"-(sp)");

    					insymbol();

					/* call function */
					gen("jsr","_MessageRead","  ");
					gen("addq","#8","sp");
					enter_XREF("_MessageRead");
				}
			}
			else
			    _error(19);  /* variable or array expected */
		}   
			
	}
}

void	message_write()
{
/* 
** MESSAGE WRITE [#]channel,message-string
*/
int	mtype;

	insymbol();

	if (sym == hash) insymbol();

	mtype = expr();

	if (mtype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(mtype) == shorttype) make_long();
		
		if (sym != comma) 
			_error(16);
		else
		{
			/* message-string */
			insymbol();
			if (expr() != stringtype)
				_error(4);
			else
			{
				/* call function */
				gen("jsr","_MessageWrite","  ");
				gen("addq","#8","sp");
				enter_XREF("_MessageWrite");
			}
		} 
			
	}
}

void	message_wait()
{
/* 
** MESSAGE WAIT [#]channel
*/
int	mtype;

	insymbol();

	if (sym == hash) insymbol();

	mtype = expr();

	if (mtype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(mtype) == shorttype) make_long();

		/* call function */
		gen("jsr","_MessageWait","  ");
		gen("addq","#4","sp");
		enter_XREF("_MessageWait");
	}
}

void	message_clear()
{
/* 
** MESSAGE CLEAR [#]channel
*/
int	mtype;

	insymbol();

	if (sym == hash) insymbol();

	mtype = expr();

	if (mtype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(mtype) == shorttype) make_long();

		/* call function */
		gen("jsr","_MessageClear","  ");
		gen("addq","#4","sp");
		enter_XREF("_MessageClear");
	}
}

void	message_close()
{
/* 
** MESSAGE CLOSE [#]channel
*/
int	mtype;

	insymbol();

	if (sym == hash) insymbol();

	mtype = expr();

	if (mtype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(mtype) == shorttype) make_long();

		/* call function */
		gen("jsr","_MessageClose","  ");
		gen("addq","#4","sp");
		enter_XREF("_MessageClose");
	}
}

void	message()
{
/* 
** MESSAGE OPEN|CLOSE|READ|WRITE|WAIT|CLEAR
*/

	insymbol();

	switch(sym)
	{
		case opensym	: message_open(); break;
		case closesym	: message_close(); break;

		case readsym	: message_read(); break;
		case writesym	: message_write(); break;

		case waitsym	: message_wait(); break;
		case clearsym	: message_clear(); break;

		default		: _error(77); break;	
	}	
}
