DP-Float: Double-Precision Math for ACE BASIC
==============================================

Author: David Benn

A submodule providing IEEE 64-bit double-precision floating point for
ACE BASIC programs. Gives 15+ significant digits of precision compared
to ~7 digits with ACE's native SINGLE (FFP) type.

Wraps the Amiga mathieeedoubbas.library and mathieeedoubtrans.library.


Why Use This?
-------------

ACE BASIC's built-in SINGLE type uses Amiga's FFP (Fast Floating Point)
format, which only gives ~7 significant digits of precision. That's fine
for simple graphics or casual math, but falls short for:

- Scientific/engineering calculations where rounding errors accumulate
  (e.g. orbital mechanics, signal processing, statistical analysis)
- Financial or high-precision arithmetic where you need more than
  7 reliable digits
- Large/small number ranges -- FFP has a limited exponent range, while
  IEEE 64-bit doubles cover roughly 10^-308 to 10^+308
- Trigonometry and transcendentals at higher accuracy (15 digits vs 7)
- String-to-number and number-to-string conversion with full double
  precision (useful for data parsing/output)

In short, it fills the gap left by ACE not having a native DOUBLE type.
Any program that needs more precision or range than SINGLE provides can
use this module instead.


Quick Start
-----------

  REM #using ace:submods/dp-float/dp-float.o
  #include <submods/dp-float.h>

  IF DpOpen THEN
    a = DpNew : b = DpNew : r = DpNew
    DpFromLong(a, 355)
    DpFromLong(b, 113)
    DpDiv(r, a, b)
    PRINT "355/113 = "; DpToStr$(r)   ' 3.14159292035398
    DpClose
  END IF


How It Works
------------

Doubles are 8-byte values stored at ADDRESS pointers. You allocate them
with DpNew, then pass the address to all DP functions. The first ADDRESS
parameter (dr) is always the destination where the result is written.
Source and destination may be the same pointer for in-place operations.

Memory allocated by DpNew (8 bytes via ALLOC) is reclaimed when the
program exits.


Building
--------

Compile the module once on the Amiga:

  bas -m dp-float

Then in your program, either use REM #using (recommended) or pass
dp-float.o on the command line:

  bas myprogram

Do NOT combine both methods -- that causes double-link errors.


API Reference
=============

Lifecycle
---------

  DpOpen            Open the IEEE DP math libraries. Returns -1 on
                    success, 0 on failure. Must be called before any
                    other DP function.

  DpClose           Close the IEEE DP math libraries.

  DpNew             Allocate an 8-byte double. Returns ADDRESS
                    (0 on failure).

Conversion
----------

  DpFromLong(dr, n)       Convert LONGINT to double.
  DpToLong(d)             Convert double to LONGINT (truncates toward zero).
  DpFromSingle(dr, s)     Convert ACE SINGLE (FFP) to double.
  DpToSingle(d)           Convert double to ACE SINGLE (FFP).
                          Precision reduced to ~7 digits.
  DpFromStr(dr, s$)       Parse string to double.
                          Accepts: [+|-][.]nnn[.nnn][e|E[+|-]nnn]
  DpToStr$(d)             Format double as string (up to 15 significant
                          digits). Fixed notation for exponents -4..+15,
                          scientific notation otherwise.

Arithmetic
----------

  DpAdd(dr, d1, d2)       dr = d1 + d2
  DpSub(dr, d1, d2)       dr = d1 - d2
  DpMul(dr, d1, d2)       dr = d1 * d2
  DpDiv(dr, d1, d2)       dr = d1 / d2
  DpPow(dr, d1, d2)       dr = d1 ^ d2

Comparison
----------

  DpCmp(d1, d2)           Returns +1 if d1 > d2, 0 if equal,
                          -1 if d1 < d2.

Unary
-----

  DpAbs(dr, d)            dr = |d|
  DpNeg(dr, d)            dr = -d
  DpCeil(dr, d)           dr = smallest integer >= d
  DpFloor(dr, d)          dr = largest integer <= d

Trigonometric (all angles in radians)
-------------------------------------

  DpSin(dr, d)            dr = sin(d)
  DpCos(dr, d)            dr = cos(d)
  DpTan(dr, d)            dr = tan(d)
  DpAsin(dr, d)           dr = arcsin(d), d in [-1,1]
  DpAcos(dr, d)           dr = arccos(d), d in [-1,1]
  DpAtan(dr, d)           dr = arctan(d)
  DpSinCos(drSin, drCos, d)  Compute sin and cos simultaneously.
                              Faster than separate calls.

Hyperbolic
----------

  DpSinh(dr, d)           dr = sinh(d)
  DpCosh(dr, d)           dr = cosh(d)
  DpTanh(dr, d)           dr = tanh(d)

Exponential / Logarithmic
-------------------------

  DpExp(dr, d)            dr = e^d
  DpLog(dr, d)            dr = ln(d)
  DpLog10(dr, d)          dr = log10(d)
  DpSqrt(dr, d)           dr = sqrt(d)


Requirements
============

- AmigaOS 3.x with Kickstart 34+
- mathieeedoubbas.library (ROM)
- mathieeedoubtrans.library (ROM)
- mathtrans.library (ROM, needed for SINGLE conversion)
