/*
   AmigaBASIC token tables taken from

   Commodore Amiga BASIC Version 1.2 (Created  6 Oct 1986)
   Copyright (c) 1985, 1986 by Microsoft Corp.

   Obtained initially via trial & error method by
   Stefan Reisner, sr@ph-cip.uni-koeln.de

   Revised and expanded by Tobias Ferber, ukjg@dkauni2.bitnet
*/

/*
 * (c)Copyright 1994 by Tobias Ferber.
 *
 * This file is part of AmigaBASIC->ASCII.
 *
 * AmigaBASIC->ASCII is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 1 of the
 * License, or (at your option) any later version.
 *
 * AmigaBASIC->ASCII is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AmigaBASIC->ASCII; see the file COPYING.  If not, write to
 * the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/* 1 byte */
int tok_min= 0x80;
int tok_max= 0xff;

/* 2 bytes, leading 0xF8 character */
int f8_min= 0x81;
int f8_max= 0xdf;

/* 2 bytes, leading 0xF9 character */
int f9_min= 0xf4;
int f9_max= 0xff;

/* 2 bytes, leading 0xFA character */
int fa_min= 0x80;
int fa_max= 0x97;

/* 2 bytes, leading 0xFB character */
int fb_min= 0xff;
int fb_max= 0xff;


char *tok_tab[]= {
/* 0x80 */  "ABS",
/* 0x81 */  "ASC",
/* 0x82 */  "ATN",
/* 0x83 */  "CALL",
/* 0x84 */  "CDBL",
/* 0x85 */  "CHR$",
/* 0x86 */  "CINT",
/* 0x87 */  "CLOSE",
/* 0x88 */  "COMMON",
/* 0x89 */  "COS",
/* 0x8a */  "CVD",
/* 0x8b */  "CVI",
/* 0x8c */  "CVS",
/* 0x8d */  "DATA",
/* 0x8e */  "ELSE",
/* 0x8f */  "EOF",
/* 0x90 */  "EXP",
/* 0x91 */  "FIELD",
/* 0x92 */  "FIX",
/* 0x93 */  "FN",
/* 0x94 */  "FOR",
/* 0x95 */  "GET",
/* 0x96 */  "GOSUB",
/* 0x97 */  "GOTO",
/* 0x98 */  "IF",
/* 0x99 */  "INKEY$",
/* 0x9a */  "INPUT",
/* 0x9b */  "INT",
/* 0x9c */  "LEFT$",
/* 0x9d */  "LEN",
/* 0x9e */  "LET",
/* 0x9f */  "LINE",
/* 0xa0 */  0,
/* 0xa1 */  "LOC",
/* 0xa2 */  "LOF",
/* 0xa3 */  "LOG",
/* 0xa4 */  "LSET",
/* 0xa5 */  "MID$",
/* 0xa6 */  "MKD$",
/* 0xa7 */  "MKI$",
/* 0xa8 */  "MKS$",
/* 0xa9 */  "NEXT",
/* 0xaa */  "ON",
/* 0xab */  "OPEN",
/* 0xac */  "PRINT",
/* 0xad */  "PUT",
/* 0xae */  "READ",
/* 0xaf */  "REM",
/* 0xb0 */  "RETURN",
/* 0xb1 */  "RIGHT$",
/* 0xb2 */  "RND",
/* 0xb3 */  "RSET",
/* 0xb4 */  "SGN",
/* 0xb5 */  "SIN",
/* 0xb6 */  "SPACE$",
/* 0xb7 */  "SQR",
/* 0xb8 */  "STR$",
/* 0xb9 */  "STRING$",
/* 0xba */  "TAN",
/* 0xbb */  0,
/* 0xbc */  "VAL",
/* 0xbd */  "WEND",
/* 0xbe */  "WHILE",
/* 0xbf */  "WRITE",
/* 0xc0 */  "ELSEIF",
/* 0xc1 */  "CLNG",
/* 0xc2 */  "CVL",
/* 0xc3 */  "MKL$",
/* 0xc4 */  "AREA",
/* 0xc5 */  0,
/* 0xc6 */  0,
/* 0xc7 */  0,
/* 0xc8 */  0,
/* 0xc9 */  0,
/* 0xca */  0,
/* 0xcb */  0,
/* 0xcc */  0,
/* 0xcd */  0,
/* 0xce */  0,
/* 0xcf */  0,
/* 0xd0 */  0,
/* 0xd1 */  0,
/* 0xd2 */  0,
/* 0xd3 */  0,
/* 0xd4 */  0,
/* 0xd5 */  0,
/* 0xd6 */  0,
/* 0xd7 */  0,
/* 0xd8 */  0,
/* 0xd9 */  0,
/* 0xda */  0,
/* 0xdb */  0,
/* 0xdc */  0,
/* 0xdd */  0,
/* 0xde */  0,
/* 0xdf */  0,
/* 0xe0 */  0,
/* 0xe1 */  0,
/* 0xe2 */  0,
/* 0xe3 */  "STATIC",
/* 0xe4 */  "USING",
/* 0xe5 */  "TO",
/* 0xe6 */  "THEN",
/* 0xe7 */  "NOT",
/* 0xe8 */  "'",       /* added by tf */
/* 0xe9 */  ">",
/* 0xea */  "=",
/* 0xeb */  "<",
/* 0xec */  "+",
/* 0xed */  "-",
/* 0xee */  "*",
/* 0xef */  "/",
/* 0xf0 */  "^",
/* 0xf1 */  "AND",
/* 0xf2 */  "OR",
/* 0xf3 */  "XOR",
/* 0xf4 */  "EQV",
/* 0xf5 */  "IMP",
/* 0xf6 */  "MOD",
/* 0xf7 */  "\\",      /* added by tf */
/* 0xf8 */  0,         /* see f8_tab[] */
/* 0xf9 */  0,         /* see f9_tab[] */
/* 0xfa */  0,         /* see fa_tab[] */
/* 0xfb */  0,         /* see fb_tab[] */
/* 0xfc */  0,
/* 0xfd */  0,
/* 0xfe */  0,
/* 0xff */  0,
};

char *f8_tab[]= {
/* 0x81 */  "CHAIN",
/* 0x82 */  "CLEAR",
/* 0x83 */  "CLS",
/* 0x84 */  "CONT",
/* 0x85 */  "CSNG",
/* 0x86 */  "DATE$",
/* 0x87 */  "DEFINT",
/* 0x88 */  "DEFSNG",
/* 0x89 */  "DEFDBL",
/* 0x8a */  "DEFSTR",
/* 0x8b */  "DEF",
/* 0x8c */  "DELETE",
/* 0x8d */  "DIM",
/* 0x8e */  "EDIT",
/* 0x8f */  "END",
/* 0x90 */  "ERASE",
/* 0x91 */  "ERL",
/* 0x92 */  "ERROR",
/* 0x93 */  "ERR",
/* 0x94 */  "FILES",
/* 0x95 */  "FRE",
/* 0x96 */  "HEX$",
/* 0x97 */  "INSTR",
/* 0x98 */  "KILL",
/* 0x99 */  "LIST",
/* 0x9a */  "LLIST",
/* 0x9b */  "LOAD",
/* 0x9c */  "LPOS",
/* 0x9d */  "LPRINT",
/* 0x9e */  "MERGE",
/* 0x9f */  "NAME",
/* 0xa0 */  "NEW",
/* 0xa1 */  "OCT$",
/* 0xa2 */  "OPTION",
/* 0xa3 */  "PEEK",
/* 0xa4 */  "POKE",
/* 0xa5 */  "POS",
/* 0xa6 */  "RANDOMIZE",
/* 0xa7 */  0,
/* 0xa8 */  "RESTORE",
/* 0xa9 */  "RESUME",
/* 0xaa */  "RUN",
/* 0xab */  "SAVE",
/* 0xac */  0,
/* 0xad */  "STOP",
/* 0xae */  "SWAP",
/* 0xaf */  "SYSTEM",
/* 0xb0 */  "TIME",
/* 0xb1 */  "TRON",
/* 0xb2 */  "TROFF",
/* 0xb3 */  "VARPTR",
/* 0xb4 */  "WIDTH",
/* 0xb5 */  "BEEP",
/* 0xb6 */  "CIRCLE",
/* 0xb7 */  0,
/* 0xb8 */  "MOUSE",
/* 0xb9 */  "POINT",
/* 0xba */  "PRESET",
/* 0xbb */  "PSET",
/* 0xbc */  "RESET",
/* 0xbd */  "TIMER",
/* 0xbe */  "SUB",
/* 0xbf */  "EXIT",
/* 0xc0 */  "SOUND",
/* 0xc1 */  0,
/* 0xc2 */  "MENU",
/* 0xc3 */  "WINDOW",
/* 0xc4 */  0,
/* 0xc5 */  "LOCATE",
/* 0xc6 */  "CSRLIN",
/* 0xc7 */  "LBOUND",
/* 0xc8 */  "UBOUND",
/* 0xc9 */  "SHARED",
/* 0xca */  "UCASE$",
/* 0xcb */  "SCROLL",
/* 0xcc */  "LIBRARY",
/* 0xcd */  0,
/* 0xce */  0,
/* 0xcf */  0,
/* 0xd0 */  0,
/* 0xd1 */  "",        /* prefix for a vector (x1,x2,...,xN) */
/* 0xd2 */  "PAINT",
/* 0xd3 */  "SCREEN",
/* 0xd4 */  "DECLARE",
/* 0xd5 */  "FUNCTION",
/* 0xd6 */  "DEFLNG",
/* 0xd7 */  "SADD",
/* 0xd8 */  "AREAFILL",
/* 0xd9 */  "COLOR",
/* 0xda */  "PATTERN",
/* 0xdb */  "PALETTE",
/* 0xdc */  "SLEEP",
/* 0xdd */  "CHDIR",
/* 0xde */  "STRIG",
/* 0xdf */  "STICK",
};

char *f9_tab[]= {
/* 0xf4 */  "OFF",
/* 0xf5 */  "BREAK",
/* 0xf6 */  "WAIT",
/* 0xf7 */  "USR",
/* 0xf8 */  "TAB",
/* 0xf9 */  "STEP",
/* 0xfa */  "SPC",
/* 0xfb */  "OUTPUT",
/* 0xfc */  "BASE",
/* 0xfd */  "AS",
/* 0xfe */  "APPEND",
/* 0xff */  "ALL",
};

char *fa_tab[]= {
/* 0x80 */  "WAVE",
/* 0x81 */  "POKEW",
/* 0x82 */  "POKEL",
/* 0x83 */  "PEEKW",
/* 0x84 */  "PEEKL",
/* 0x85 */  "SAY",
/* 0x86 */  "TRANSLATE$",
/* 0x87 */  "OBJECT.SHAPE",
/* 0x88 */  "OBJECT.PRIORITY",
/* 0x89 */  "OBJECT.X",
/* 0x8a */  "OBJECT.Y",
/* 0x8b */  "OBJECT.VX",
/* 0x8c */  "OBJECT.VY",
/* 0x8d */  "OBJECT.AX",
/* 0x8e */  "OBJECT.AY",
/* 0x8f */  "OBJECT.CLIP",
/* 0x90 */  "OBJECT.PLANES",
/* 0x91 */  "OBJECT.HIT",
/* 0x92 */  "OBJECT.ON",
/* 0x93 */  "OBJECT.OFF",
/* 0x94 */  "OBJECT.START",
/* 0x95 */  "OBJECT.STOP",
/* 0x96 */  "OBJECT.CLOSE",
/* 0x97 */  "COLLISION",
};

char *fb_tab[]= {
/* 0xff */  "PTAB",
};
