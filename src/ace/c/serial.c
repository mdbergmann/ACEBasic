/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: serial port commands **
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
     Date: 5th,6th September 1993
*/

#include "acedef.h"

/* locals */
static	char 	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	int	sym;
extern	int	lev;
extern	int	obj;
extern	int	typ;
extern	SYM	*curr_item;
extern	char   	id[MAXIDSIZE]; 

/* functions */
void serial_command()
{
/* parse a serial command */

 insymbol();
 
 switch(sym)
 {
  	case opensym:	open_serial();				
			break;

  	case closesym:	close_serial();				
			break;

  	case readsym:	read_serial();				
			break;

  	case writesym:	write_serial();				
			break;

	default:	_error(75);	/* open,close etc expected */
			break;
 }
}

void open_serial()
{
/* open a channel to a serial port.
    
   SERIAL OPEN [#] channel,unit,baud,"N|E|O|M|S<d><s>[A][X]"[,size][,name]

   where: 	channel	= unique channel number 
		unit	= unit of serial device to use
		baud	= baud rate
		NEOMS 	= parity: None, Even, Odd, Mark, Space
		<d>	= # of data bits (1 digit)
		<s>	= # of stop bits (1 digit)
		A	= serial device will use ALL 7 port wires
		X 	= sets Xon/Xoff mode
		size	= size of serial buffer
		name	= name of serial device		
 */

 insymbol();

 if (sym == hash) insymbol();	/* # */

 if (make_integer(expr()) == shorttype) make_long();	/* channel */ 
	 	 
 if (sym != comma) _error(16);
 else
 {  
  insymbol();
  if (make_integer(expr()) == shorttype) make_long();	/* unit */ 
	 	 
  if (sym != comma) _error(16);
  else
  {
   insymbol();
   if (make_integer(expr()) == shorttype) make_long();	/* baud */ 
	 	 
   if (sym != comma) _error(16);
   else
   {
    insymbol();
    if (expr() != stringtype) _error(4);	/* parameter string */
    else
    {
     /* optional serial READ buffer size */
     if (sym == comma)
     {
      insymbol();
      if (sym != comma)
      {
         if (make_integer(expr()) == shorttype) 
	    make_long(); 			/* Read buffer size */ 
      }
      else
	 gen("move.l","#512","-(sp)");		/* defaults to 512 bytes */	
     }	
     else 
         gen("move.l","#512","-(sp)");		/* defaults to 512 bytes */

     /* optional serial device name */
     if (sym == comma)
     {
      insymbol();
      if (expr() != stringtype) _error(4);	/* serial device name */
     }
     else
	 gen("move.l","#0","-(sp)");		/* defaults to NULL */

     /* call open_serial function */
     gen("jsr","_OpenSerial","  ");
     gen("add.l","#24","sp");
     enter_XREF("_OpenSerial");      
    }
   }
  }
 }
} 

void close_serial()
{
/* close a channel to a serial port. 

   SERIAL CLOSE [#] channel
*/

 insymbol();

 if (sym == hash) insymbol();	/* # */

 if (make_integer(expr()) == shorttype) make_long();	/* channel */ 
	 	 
 gen("jsr","_CloseSerial","  ");
 gen("addq","#4","sp");
 enter_XREF("_CloseSerial"); 
}

void read_serial()
{
SYM  *storage;
char addrbuf[40];

/* read a specified number of bytes into a buffer.

   SERIAL READ [#] channel,buffer,length
*/

 insymbol();

 if (sym == hash) insymbol();	/* # */

 if (make_integer(expr()) == shorttype) make_long();	/* channel */ 

 if (sym != comma) _error(16);
 else
 {
  insymbol();						
  if (sym == ident && obj == variable)			/* buffer */
  {
   /* if string variable/array doesn't exist, create a simple variable */
   if (!exist(id,variable) && !exist(id,array)) 
   {
    /* allocate a simple string variable */
    enter(id,typ,obj,0);
    enter_DATA("_nullstring:","dc.b 0");
    gen("pea","_nullstring","  ");
    assign_to_string_variable(curr_item,MAXSTRLEN);
   }

   storage=curr_item;

   /* is it a string variable or array? */
   if (storage->type != stringtype) _error(4);
   else    
   {
    /* get address of string pointed to by variable/array element */
    itoa(-1*storage->address,addrbuf,10);
    strcat(addrbuf,frame_ptr[lev]);

    /* pass string address to function (on stack) */
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
    if (sym != comma) _error(16);
    else
    {	 
     insymbol();
     if (make_integer(expr()) == shorttype) make_long();  	/* length */ 

     /* call serial_read function */
     gen("jsr","_ReadSerial","  ");
     gen("add.l","#12","sp");
     enter_XREF("_ReadSerial");
    }
   }
  }
  else _error(19); /* variable (or array) expected */      
 }
 insymbol();
}

void write_serial()
{
/* write a specified number of bytes from a buffer.

   SERIAL WRITE [#] channel,buffer,length
*/

 insymbol();

 if (sym == hash) insymbol();	/* # */

 if (make_integer(expr()) == shorttype) make_long();	/* channel */ 

 if (sym != comma) _error(16);
 else
 {
  insymbol();
  if (expr() != stringtype) _error(4);			/* buffer */
  else
  {   	 
   if (sym != comma) _error(16);
   else
   {	 
    insymbol();
    if (make_integer(expr()) == shorttype) make_long();	/* length */ 

    /* call serial_write function */
    gen("jsr","_WriteSerial","  ");
    gen("add.l","#12","sp");
    enter_XREF("_WriteSerial");
   }	 	 
  }
 }
}
