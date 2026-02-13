{*
 * DP - Double-Precision Math Submodule Header
 *
 * Provides IEEE 64-bit double-precision floating point via
 * mathieeedoubbas.library and mathieeedoubtrans.library.
 *
 * Usage:
 *   EXTERNAL dp
 *   '$include "submods/dp.h"
 *
 *   IF DpOpen THEN
 *     a = DpNew : b = DpNew : r = DpNew
 *     DpFromLong(a, 21)
 *     DpFromLong(b, 3)
 *     DpAdd(r, a, b)
 *     PRINT "21 + 3 ="; DpToLong(r)
 *     DpClose
 *   END IF
 *
 * Doubles are 8-byte values stored at ADDRESS pointers.
 * Use DpNew to allocate, pass addresses to all DP functions.
 *}

#ifndef DP_H
#define DP_H

REM --- Double size constant ---
CONST DP_SIZE = 8

REM --- Lifecycle ---
DECLARE SUB LONGINT DpOpen EXTERNAL
DECLARE SUB DpClose EXTERNAL
DECLARE SUB ADDRESS DpNew EXTERNAL

REM --- Conversion ---
DECLARE SUB DpFromLong(ADDRESS dr, LONGINT n) EXTERNAL
DECLARE SUB LONGINT DpToLong(ADDRESS d) EXTERNAL

REM --- Arithmetic ---
DECLARE SUB DpAdd(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
DECLARE SUB DpSub(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
DECLARE SUB DpMul(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
DECLARE SUB DpDiv(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL

REM --- Comparison ---
DECLARE SUB LONGINT DpCmp(ADDRESS d1, ADDRESS d2) EXTERNAL

REM --- Unary ---
DECLARE SUB DpAbs(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpNeg(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpCeil(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpFloor(ADDRESS dr, ADDRESS d) EXTERNAL

REM --- SINGLE Conversion ---
DECLARE SUB DpFromSingle(ADDRESS dr, SINGLE s) EXTERNAL
DECLARE SUB SINGLE DpToSingle(ADDRESS d) EXTERNAL

REM --- Trigonometric (radians) ---
DECLARE SUB DpSin(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpCos(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpTan(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpAsin(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpAcos(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpAtan(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpSinCos(ADDRESS drSin, ADDRESS drCos, ADDRESS d) EXTERNAL

REM --- Hyperbolic ---
DECLARE SUB DpSinh(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpCosh(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpTanh(ADDRESS dr, ADDRESS d) EXTERNAL

REM --- Exponential / Logarithmic ---
DECLARE SUB DpExp(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpLog(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpLog10(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpSqrt(ADDRESS dr, ADDRESS d) EXTERNAL
DECLARE SUB DpPow(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL

REM --- String Conversion ---
DECLARE SUB DpFromStr(ADDRESS dr, STRING s$) EXTERNAL
DECLARE SUB STRING DpToStr$(ADDRESS d) EXTERNAL

#endif
