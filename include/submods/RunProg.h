{*
** External subprogram declaration for the library module RunProg.o, 
** which allows a program to be executed with control over stack size
** and retrieval of AmigaDOS return code. RunProg returns -1 if an
** error has occurred when attempting to execute the program.
**
** Requires version 36 or higher of the OS (Wb 2.x/3.x).
**
** See also ace.doc, "Creating & using ACE subprogram modules".
**
** This file should reside in ACEinclude: so that #include <RunProg.h>
** can be used in programs linked with RunProg.o.
**  
** Author: David J Benn
**   Date: 5th March 1995
*}

DECLARE SUB LONGINT RunProg(STRING theProg, STRING theArgs, ~
			    LONGINT stackSize) EXTERNAL
