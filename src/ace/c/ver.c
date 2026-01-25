/* << ACE >>
**
** -- Amiga BASIC Compiler --
**
** ** Compiler version info' ***
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
**   Date: 24th,29th July 1994,
**	   3rd,10th,19th,20th,22nd,28th August 1994,
**	   1st,3rd,4th,9th-12th,17th September 1994,
**	   1st,2nd October 1994,
**	   5th,11th,12th March 1995,
**	   7th,8th August 1995,
**	   6th October 1995,
**	   6th,7th November 1995,
**	   10th March 1996,
**	   9th September 1996
*/

/* version string for AmigaDOS VERSION command */
static 	char 	*ace_ver = "$VER: ACE 2.6 (25.01.26)";

/* version number for display */
static  char	*version_string = "2.6";

char	*version()
{
/*
** Returns compiler version information.
*/
	return version_string;
}
 
 
 
 
