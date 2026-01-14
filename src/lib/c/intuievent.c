/*
** ACE linked library module: Intuition event trapping functions.
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
** The purpose of the functions in this module is to centralise
** Intuition message handling for use by ACE event trapping code.
** 
** This amounts to putting a layer between raw Intuition message 
** handling functions (GetMsg() and ReplyMsg()) and ACE.
**
** Author: David J Benn
**   Date: 12th,17th,18th,24th,26th July 1994
*/

#include <intuition/intuition.h>

/* types */
typedef	struct IntuiInfoStruct {
	ULONG 	Class;
	USHORT 	Code;
	USHORT	GadgetID;
} IntuiInfo;
 
/* globals */
static 	IntuiInfo IntuiEvent;
static 	IntuiInfo *the_event = NULL;

/* functions */
IntuiInfo *GetIntuiEvent(UserPort)
struct	MsgPort *UserPort;
{
struct 	IntuiMessage *msg;
struct	Gadget *GadPtr;
/*
** Return latest relevant Intuition message info'.
*/
	/* 
	** Attempt to retrieve a message from the IDCMP.
	*/
	msg = (struct IntuiMessage *)GetMsg(UserPort); 
	
	/*
	** If not NULL, determine nature of message and obtain
	** appropriate information, ignoring IntuiTicks.
	*/ 
	if (msg != NULL)
	{
		if (msg->Class != INTUITICKS)
		{
			/*
			** Fill IntuiInfo structure.
			*/	
			IntuiEvent.Class = msg->Class;

			if (msg->Class & GADGETUP)
			{
				/*
				** Info' for gadget events. 
				*/
				GadPtr = (struct Gadget *)msg->IAddress;
				IntuiEvent.GadgetID = GadPtr->GadgetID; 
			}
			else		
				/*
				** Info' for all other events.
				*/
				IntuiEvent.Code = msg->Code;
			
			/*
			** Point to the info'. 
			*/
			the_event = &IntuiEvent;			
		}	

		/*
		** Make sure we reply to each message once 
		** and _only_ once.
		*/
		ReplyMsg(msg);
	}

	/*
	** Return whatever message we now have (may be NULL).
	*/
	return(the_event);
}

void	ClearIntuiEvent()
{
/*
** If IntuiEvent has been matched by an event
** trapping test routine, make the_event NULL.
*/
	the_event = NULL;
}
