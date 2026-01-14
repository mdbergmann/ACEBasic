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
*/

/* External variables */
extern unsigned long MathIeeeSingTransBase;

/* External function declarations */
extern float SPFieee();	
extern float SPTieee();	
extern float SPPow();
extern float IEEESPPow();	

/* Exponentiation function */
float power(y,x)
float y;
float x;
{
/*
** Returns x raised to the power of y.
** Uses the IEEE single-precision function
** IEEESPPow() because it is more accurate
** and handles negative base values correctly.
**
** The parameters and result are converted to
** and from IEEE format respectively. 
**
** Only in the event that the IEEE SP library
** can't be opened will the FFP SPPow() function
** be used. Note that this should only happen on
** systems with an OS prior to Release 2.0. Note
** also that bogus results will be obtained via the
** FFP function if the base is negative. This doesn't
** seem to be worth fixing since only old systems
** will be affected.	
*/
	if (MathIeeeSingTransBase)
		return SPFieee(IEEESPPow(SPTieee(y),SPTieee(x)));
	else
		return SPPow(y,x);
}
