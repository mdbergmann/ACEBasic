/*
** db.lib module: void 	SYSTEM command-string
**		  short	SYSTEM
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
**   Date: 27th December 1993,
**	   5th January 1994
*/

#include <exec/types.h>
#include <exec/execbase.h>
#include <dos/dosextens.h>

/* externals */
extern	BPTR 	stdout;
extern	struct 	ExecBase *AbsExecBase;

/* functions */
void system_call(command)
STRPTR command;
{
BPTR out = 0L;

  if (stdout) out = stdout;

  Execute(command,0L,out);
}

SHORT system_version()
{
  return (SHORT)(AbsExecBase->LibNode.lib_Version);
}
