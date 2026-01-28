/*
** ILBM library structures. Taken from Jeff Glatt's complete 
** ILBM_lib.h header file.
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
** 7th August 1994, David Benn
*/

#define	maxColorReg 	32	
#define	maxCycles	8	 	

typedef struct {
    UWORD w, h;			/* raster width & height in pixels */
    WORD  x, y;			/* position for this image */
    UBYTE nPlanes;		/* # source bitplanes */
    UBYTE masking;		/* masking technique */
    UBYTE compression;		/* compression algorithm */
    UBYTE pad1;			/* UNUSED.  For consistency, put 0 here.*/
    UWORD transparentColor;	/* transparent "color number" */
    UBYTE xAspect, yAspect;	/* aspect ratio, a rational number x/y */
    WORD  pageWidth, pageHeight;/* source "page" size in pixels */
} BitMapHeader;

typedef struct {
	WORD	pad1;	/* future exp - store 0 here */
	WORD	rate;	/* 60/sec=16384, 30/sec=8192, 1/sec=16384/60=273 */
	WORD	active;	/* lo bit 0=no cycle, 1=yes; next bit 1=rvs */
	UBYTE	low;	/* range lower */
	UBYTE	high;	/* range upper */
} CrngChunk;

typedef struct {
   UBYTE iFlags;
   UBYTE iUserFlags;
   BitMapHeader iBMHD;
   ULONG iViewModes;
   WORD iColorTable[maxColorReg];
   UBYTE iNumColors;
   UBYTE iCycleCnt;
   CrngChunk iCRNG[maxCycles];
   struct Window *iWindow;
   struct Screen *iScreen;
   struct BitMap *iBMAP;
   ULONG iBMSize;
} ILBMFrame;
