/*
** ACE library (db.lib) module: Exponentiation.
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
**   Date: 5th November 1995
** Modified: 2026 — native float types (IEEE 754)
*/

/* IEEESPPow takes/returns raw 32-bit IEEE values */
extern long IEEESPPow();

/* Exponentiation: returns x raised to the power of y.
** Uses IEEESPPow() from mathieeesingtrans.library via type-punning.
*/
float power(float y, float x)
{
	union { float f; long l; } uy, ux, ur;
	uy.f = y;
	ux.f = x;
	ur.l = IEEESPPow(uy.l, ux.l);
	return ur.f;
}
