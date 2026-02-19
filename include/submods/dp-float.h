{*
 * DP-Float - Double-Precision Math Submodule Header
 *
 * Provides IEEE 64-bit double-precision floating point via
 * mathieeedoubbas.library and mathieeedoubtrans.library.
 * Gives 15+ significant digits of precision (vs ~7 for SINGLE).
 *
 * Doubles are 8-byte values stored at ADDRESS pointers.
 * Use DpNew to allocate a double, then pass its address to all
 * DP functions. The first ADDRESS parameter (dr) is always the
 * destination where the result is written. Source and destination
 * may be the same pointer (in-place operation).
 *
 * Memory: DpNew allocates 8 bytes via ALLOC. There is no DpFree;
 * memory is reclaimed when the program exits.
 *
 * Usage:
 *   REM #using ace:submods/dp-float/dp-float.o
 *   #include <submods/dp-float.h>
 *
 *   IF DpOpen THEN
 *     a = DpNew : b = DpNew : r = DpNew
 *     DpFromLong(a, 355)
 *     DpFromLong(b, 113)
 *     DpDiv(r, a, b)
 *     PRINT "355/113 = "; DpToStr$(r)   ' 3.14159292035398
 *     DpClose
 *   END IF
 *
 * Compile the module:  bas -m dp-float
 * Compile your program: bas myprogram
 *   (with REM #using in source, or pass dp-float.o on command line)
 *}

#ifndef DP_FLOAT_H
#define DP_FLOAT_H

REM --- Double size in bytes ---
CONST DP_SIZE = 8

REM ========== Lifecycle ==========

REM DpOpen - Open the IEEE DP math libraries.
REM Returns -1 on success, 0 on failure. Must be called before
REM any other DP function. Safe to call multiple times.
DECLARE SUB LONGINT DpOpen EXTERNAL

REM DpClose - Close the IEEE DP math libraries.
DECLARE SUB DpClose EXTERNAL

REM DpNew - Allocate an 8-byte double. Returns ADDRESS (0 on failure).
DECLARE SUB ADDRESS DpNew EXTERNAL

REM ========== Conversion ==========

REM DpFromLong(dr, n) - Convert LONGINT n to double, store at dr.
DECLARE SUB DpFromLong(ADDRESS dr, LONGINT n) EXTERNAL

REM DpToLong(d) - Convert double at d to LONGINT (truncates toward zero).
DECLARE SUB LONGINT DpToLong(ADDRESS d) EXTERNAL

REM DpFromSingle(dr, s) - Convert ACE SINGLE (IEEE SP) to double, store at dr.
DECLARE SUB DpFromSingle(ADDRESS dr, SINGLE s) EXTERNAL

REM DpToSingle(d) - Convert double at d to ACE SINGLE (IEEE SP).
REM Precision is reduced to ~7 significant digits.
DECLARE SUB SINGLE DpToSingle(ADDRESS d) EXTERNAL

REM DpFromStr(dr, s$) - Parse string to double, store at dr.
REM Accepts: [+|-][.]nnn[.nnn][e|E[+|-]nnn]
REM Examples: "42", "-3.14", ".5", "1.5e+10", "6.022e23"
REM Stores zero for invalid input.
DECLARE SUB DpFromStr(ADDRESS dr, STRING s$) EXTERNAL

REM DpToStr$(d) - Format double as string with up to 15 significant digits.
REM Uses fixed notation for exponents -4..+15, scientific notation otherwise.
DECLARE SUB STRING DpToStr$(ADDRESS d) EXTERNAL

REM ========== Arithmetic ==========

REM DpAdd(dr, d1, d2) - dr = d1 + d2
DECLARE SUB DpAdd(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL

REM DpSub(dr, d1, d2) - dr = d1 - d2
DECLARE SUB DpSub(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL

REM DpMul(dr, d1, d2) - dr = d1 * d2
DECLARE SUB DpMul(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL

REM DpDiv(dr, d1, d2) - dr = d1 / d2
DECLARE SUB DpDiv(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL

REM DpPow(dr, d1, d2) - dr = d1 ^ d2
DECLARE SUB DpPow(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL

REM ========== Comparison ==========

REM DpCmp(d1, d2) - Compare two doubles.
REM Returns: +1 if d1 > d2, 0 if d1 = d2, -1 if d1 < d2
DECLARE SUB LONGINT DpCmp(ADDRESS d1, ADDRESS d2) EXTERNAL

REM ========== Unary ==========

REM DpAbs(dr, d) - dr = |d|
DECLARE SUB DpAbs(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpNeg(dr, d) - dr = -d
DECLARE SUB DpNeg(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpCeil(dr, d) - dr = smallest integer >= d (as double)
DECLARE SUB DpCeil(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpFloor(dr, d) - dr = largest integer <= d (as double)
DECLARE SUB DpFloor(ADDRESS dr, ADDRESS d) EXTERNAL

REM ========== Trigonometric (all angles in radians) ==========

REM DpSin(dr, d) - dr = sin(d)
DECLARE SUB DpSin(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpCos(dr, d) - dr = cos(d)
DECLARE SUB DpCos(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpTan(dr, d) - dr = tan(d)
DECLARE SUB DpTan(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpAsin(dr, d) - dr = arcsin(d), d in [-1,1]
DECLARE SUB DpAsin(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpAcos(dr, d) - dr = arccos(d), d in [-1,1]
DECLARE SUB DpAcos(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpAtan(dr, d) - dr = arctan(d)
DECLARE SUB DpAtan(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpSinCos(drSin, drCos, d) - Compute sin and cos simultaneously.
REM drSin = sin(d), drCos = cos(d). Faster than calling DpSin + DpCos.
DECLARE SUB DpSinCos(ADDRESS drSin, ADDRESS drCos, ADDRESS d) EXTERNAL

REM ========== Hyperbolic ==========

REM DpSinh(dr, d) - dr = sinh(d)
DECLARE SUB DpSinh(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpCosh(dr, d) - dr = cosh(d)
DECLARE SUB DpCosh(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpTanh(dr, d) - dr = tanh(d)
DECLARE SUB DpTanh(ADDRESS dr, ADDRESS d) EXTERNAL

REM ========== Exponential / Logarithmic ==========

REM DpExp(dr, d) - dr = e^d
DECLARE SUB DpExp(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpLog(dr, d) - dr = ln(d) (natural logarithm)
DECLARE SUB DpLog(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpLog10(dr, d) - dr = log10(d) (base-10 logarithm)
DECLARE SUB DpLog10(ADDRESS dr, ADDRESS d) EXTERNAL

REM DpSqrt(dr, d) - dr = sqrt(d)
DECLARE SUB DpSqrt(ADDRESS dr, ADDRESS d) EXTERNAL

#endif
