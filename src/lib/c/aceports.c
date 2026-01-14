/* 
** ACE messaging mechanism. Uses Exec Message Ports.
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
** Up to 255 message ports per program are allowed for.
** In reality the number of task signals will limit this
** to a lesser value.
**
** All of the following "MessageXXXX" functions set "error_code"
** which is accessible via the BASIC ERR function.
**
** MessageOpen() 	-  Sets up a message channel.
** MessageClose()	-  Cleans up a message channel.
** MessageWrite()	-  Writes a message to a channel.
** MessageRead()	-  Reads a message from a channel.
** MessageWait()	-  Waits for a message on a channel.
** MessageClear()	-  Clears a message channel.
**
** Author: David J Benn
**   Date: 23rd,24th,26th,27th January 1994,
**	   13th,15th February 1994,
**	   22nd,23rd,28th August 1994,
**	   10th,11th September 1994
*/

#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>

#define MINCHANNEL   	  	1
#define MAXCHANNEL 		255

#define NO_ERR		  	0
#define OPEN_ERR   		400
#define CLOSE_ERR   		401
#define READ_ERR   		402
#define WRITE_ERR   		403
#define WAIT_ERR		404
#define CHAN_ERR		405

#define CLEARED_PUBLIC_MEM  	5L
#define CLEARED_ANY_MEM  	7L

/* structure types */
typedef struct ACEport
{
	char	mode;		/* read or write */
	char 	*name; 		/* name of target port */
	struct 	MsgPort *port;	/* message or reply port */
} ACEPORT;

typedef struct ACEmsg
{
	struct 	Message header;
	char	*msg;	
} ACEMSG;

/* globals */
BOOL	first=TRUE;
ACEPORT	aceport[MAXCHANNEL+1];

/* externals */
extern	ULONG	error_code;

/* external functions */
extern	void 	*alloc();
extern	char 	*stringcopy();
extern	ULONG 	stringlength();
extern	struct 	MsgPort *CreatePort();
extern	struct 	MsgPort *FindPort();
extern	void	DeletePort();
extern	void	PutMsg();
extern	ACEMSG	*GetMsg();
extern	void	WaitPort();

/* functions */
BOOL bad(channel)
SHORT 	channel;
{
/* 
** Return TRUE if channel number is invalid.
*/

	if (channel < MINCHANNEL || channel > MAXCHANNEL) 
		return(TRUE);
	else
	    	return(FALSE);
}

void MessageOpen(mode,name,channel)
char  	*mode,*name;
SHORT 	channel;
{
SHORT  	i;
/* 
** Set up a message channel.
*/

	/* clear port info' array? */
	if (first)
	{
		first=FALSE;
		for (i=1;i<=255;i++)
		{
			aceport[i].mode = ' ';
			aceport[i].name = NULL;
			aceport[i].port = NULL;
		}
	}

	/* 
	** Can we use this channel and port-name? 
	*/
	if (bad(channel)) 
		{ error_code = CHAN_ERR; return; }
	else
	if (aceport[channel].port != NULL) 
		{ error_code = OPEN_ERR; return; }
	else
	{
	  switch(*mode)
	  {
		case 'r' :
		case 'R' : 	if (FindPort(name)) 
				   { error_code = OPEN_ERR; return; }
				aceport[channel].mode = 'R';
				break;

		case 'w' :
		case 'W' :	if (!FindPort(name)) 
				   { error_code = OPEN_ERR; return; }
				aceport[channel].mode = 'W';
				break;

		default  :	aceport[channel].mode = ' ';
				error_code = OPEN_ERR; return;
				break;
	  }

	  /* 
	  ** Create a named message port. 
	  */	
	  if (aceport[channel].mode == 'R')
	  {
		if (!(aceport[channel].port = CreatePort(name,0L)))
		{
			error_code = OPEN_ERR;
			return;
		}
	  }
	  else
	  /* 
	  ** Create an unnamed (reply) message port 
	  ** and store target port name.
	  */
	  if (aceport[channel].mode == 'W')
	  {
		if (!(aceport[channel].port = CreatePort(NULL,0L)))
		{
			error_code = OPEN_ERR;
			return;			
		}
		else
		{
			aceport[channel].name = (char *)
				alloc(CLEARED_ANY_MEM,stringlength(name)+1);

			if (aceport[channel].name == NULL) 
			{
				error_code = OPEN_ERR;
				return;
			}		
			else
				stringcopy(aceport[channel].name,name);
		}
	  }
 	  else
		/* Read or Write mode not specified! */
		error_code = OPEN_ERR;
	}
}

void MessageClose(channel)
SHORT 	channel;
{
/*
** Remove a message channel.
*/

	if (bad(channel)) 
	{
		error_code = CHAN_ERR;
	   	return;
	}
	else
	if (aceport[channel].port == NULL) 
	{
		error_code = CLOSE_ERR;
		return;
	}
	else
	{
		DeletePort(aceport[channel].port);
		aceport[channel].mode = ' ';
		aceport[channel].name = NULL;
		aceport[channel].port = NULL;
	}
}

void MessageWrite(msg_string,channel)
char	*msg_string;	
SHORT	channel;
{
static 	ACEMSG 	pkt;
struct	MsgPort	*port;
/* 
** Write a message to a channel. 
** ReplyPort is aceport[channel].port.
*/
	if (bad(channel))
	{
		error_code = CHAN_ERR;	
		return;
	}
	else
	if (aceport[channel].port == NULL) 
	{
		error_code = WRITE_ERR;
		return;
	}
	else
	if (aceport[channel].mode != 'W')
	{
		error_code = WRITE_ERR;
		return;
	}
   	else
	if (msg_string[0] == '\0')
	{
		error_code = WRITE_ERR;
		return;
	}
	else
	{
		/*
		** Message header: type, size, replyport.
		*/
		pkt.header.mn_Node.ln_Type = NT_MESSAGE;
		pkt.header.mn_ReplyPort = aceport[channel].port;
		pkt.header.mn_Length = sizeof(ACEMSG);

		/*
		** Message body.
		*/
		pkt.msg = (char *)
			  alloc(CLEARED_PUBLIC_MEM,stringlength(msg_string)+1);
		if (pkt.msg == NULL) 
		{
			error_code = WRITE_ERR;
			return;
		}
		else
			stringcopy(pkt.msg,msg_string);
			
		/* 
		** Make sure target port still exists before
		** writing to it! 
		*/
		if (port = FindPort(aceport[channel].name))
		{
			PutMsg(port,&pkt);
		}
		else
			error_code = WRITE_ERR;
	}
}

void MessageRead(msg_string,channel)
char	*msg_string;
SHORT 	channel;
{
ACEMSG	*pkt;
/*
** Read a message from a channel.
*/

	/* assume NULL string should be returned */
	msg_string[0] = '\0';

	if (bad(channel)) 
	{
		error_code = CHAN_ERR;
		return;
	}
	else
	if (aceport[channel].port == NULL) 
	{
		error_code = READ_ERR;
		return;
	}
	else
	if (aceport[channel].mode != 'R')
	{
		error_code = READ_ERR;
		return;
	}
	else
	{
	  pkt = GetMsg(aceport[channel].port);
	  if (pkt != NULL) 
	  {
		stringcopy(msg_string,pkt->msg);
		ReplyMsg(pkt);
		/* 
		** Polling sets error_code to READ_ERR 
		** so clear it if necessary. We don't
		** really want to clear just _any_ error
		** (eg. OPEN_ERR).
		*/
		if (error_code == READ_ERR) error_code = NO_ERR; 
	  }	
	  else
		error_code = READ_ERR;
	}
}
	
void MessageWait(channel)
SHORT channel;
{
ACEMSG *pkt;
/* 
** Wait for a message on a channel.
*/

	if (bad(channel))
	{
		error_code = CHAN_ERR;
		return;
	}
	else
	if (aceport[channel].port == NULL) 
	{
		error_code = WAIT_ERR;
		return;
	}
	else
	{
		/* await a message */
		WaitPort(aceport[channel].port);
	}
}

void MessageClear(channel)
SHORT channel;
{
ACEMSG *pkt;
/* 
** Clear a message channel (prior to reading it).
*/

	if (bad(channel))
	{
		error_code = CHAN_ERR;
		return;
	}
	else
	if (aceport[channel].port == NULL) 
	{
		error_code = READ_ERR;
		return;
	}
	else
	if (aceport[channel].mode != 'R')
	{
		error_code = READ_ERR;
		return;
	}
	else
	{
		/* clear the port */
		while (pkt = GetMsg(aceport[channel].port)) ReplyMsg(pkt);
	}
}
