/*
** ACE header file for the library module ListBox.o, which creates a simple 
** ListView gadget-based requester with a Cancel and Ok button, and returns 
** the number of the selection made or LISTBOX_CANCELLED.
**
** See also ace.doc, "Creating & using ACE subprogram modules".
**
** This file should reside in ACEinclude: so that #include <SUBmods/ListBox.h>
** can be used in programs linked with ListBox.o.
**  
** Author: David J Benn
**   Date: 29th June, 17th October 1995
*/

CONST LISTBOX_CANCELLED = 0
CONST LISTBOX_ITEM_STRINGSIZE = 80

DECLARE SUB LONGINT ListBox(ADDRESS listItemArray, LONGINT items, ~
			    STRING wdwTitle, STRING prompt) EXTERNAL
