{*
 * IFF - IFF Picture Submodule Header
 *
 * Provides IFF ILBM/ACBM picture loading and display via ilbm.library.
 * ilbm.library must be installed in LIBS: on the target system.
 * A copy is shipped at submods/iff/ilbm.library for convenience.
 *
 * Usage:
 *   REM #using ace:submods/iff/iff.o
 *   #include <submods/iff.h>
 *
 *   IF IffInit = 0 THEN
 *     IF IffOpen(1, "picture.iff") = 0 THEN
 *       PRINT "Width:"; IffWidth(1); " Height:"; IffHeight(1)
 *       IffDisplay(1, 0)
 *       WHILE INKEY$ = "" : SLEEP : WEND
 *       IffClose(1)
 *     END IF
 *     IffShutdown
 *   END IF
 *
 * Compile the module:  bas -m iff
 * Compile your program: bas myprogram
 *   (with REM #using in source, or pass iff.o on command line)
 *}

#ifndef IFF_H
#define IFF_H

REM --- Error constants ---
CONST IFF_OK       = 0
CONST IFF_ERR_OPEN = -1
CONST IFF_ERR_READ = -2
CONST IFF_ERR_CHAN = -3
CONST IFF_ERR_LIB  = -4

REM ========== Lifecycle ==========

REM IffInit - Open ilbm.library and supporting libraries.
REM Returns 0 (IFF_OK) on success, IFF_ERR_LIB (-4) if library not found.
REM Must be called before any other Iff function. Safe to call multiple times.
DECLARE SUB LONGINT IffInit EXTERNAL

REM IffShutdown - Close all channels and all libraries.
REM Call when done with all IFF operations.
DECLARE SUB IffShutdown EXTERNAL

REM ========== File Operations ==========

REM IffOpen(channel, filename$) - Open an IFF file and read header info.
REM Channels 1-15.  Returns 0 on success, negative on error.
DECLARE SUB LONGINT IffOpen(SHORTINT ch, STRING fileName$) EXTERNAL

REM IffDisplay(channel, screenAddr) - Load and display the IFF picture.
REM screenAddr = 0: ilbm.library opens its own screen/window.
REM screenAddr <> 0: use the given Screen pointer (e.g. from WINDOW(7)).
REM Returns 0 on success, negative on error.
DECLARE SUB LONGINT IffDisplay(SHORTINT ch, LONGINT scrAddr) EXTERNAL

REM IffClose(channel) - Close channel. Closes screen/window if IffDisplay
REM created them (when screenAddr was 0).
DECLARE SUB IffClose(SHORTINT ch) EXTERNAL

REM ========== Query Functions ==========

REM IffWidth(channel) - Returns picture width in pixels (0 if not open).
DECLARE SUB LONGINT IffWidth(SHORTINT ch) EXTERNAL

REM IffHeight(channel) - Returns picture height in pixels.
DECLARE SUB LONGINT IffHeight(SHORTINT ch) EXTERNAL

REM IffDepth(channel) - Returns number of bitplanes.
DECLARE SUB LONGINT IffDepth(SHORTINT ch) EXTERNAL

REM IffScreenMode(channel) - Returns screen mode:
REM   1=lores, 2=hires, 3=lores-lace, 4=hires-lace, 5=HAM.
DECLARE SUB LONGINT IffScreenMode(SHORTINT ch) EXTERNAL

REM IffFormType(channel) - Returns address of form name string
REM ("ILBM" or "ACBM").  Returns 0 if channel not open.
DECLARE SUB LONGINT IffFormType(SHORTINT ch) EXTERNAL

#endif
