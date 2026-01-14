{*
** External subprogram declarations for the
** library module WBarg.o. 
**
** See the preliminary comments in WBarg.b for
** details of each subprogram's functionality.
**
** The subprograms in WBarg.b require the dos and icon
** libraries to be open. This is handled by the code in
** WBarg.b however.
** 
** See also ace.doc, "Creating & using ACE subprogram modules".
**
** Author: David J Benn
**   Date: 29th,30th December 1994,
**   	   5th March 1995
*}

DECLARE SUB LONGINT WBlaunched EXTERNAL

DECLARE SUB SHORTINT WBargcount EXTERNAL
DECLARE SUB WBarg$(SHORTINT N) EXTERNAL
DECLARE SUB WBargPath$(SHORTINT N) EXTERNAL

DECLARE SUB ToolTypeVal$(theArg$,toolType$) EXTERNAL
DECLARE SUB LONGINT ToolTypeValMatched(toolVal$,value$) EXTERNAL
DECLARE SUB DefaultTool$(theArg$) EXTERNAL
