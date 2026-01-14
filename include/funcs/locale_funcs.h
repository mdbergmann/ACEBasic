#ifndef  FUNCS_LOCALE_FUNCS_H
#define  FUNCS_LOCALE_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

/*--- functions in V38 OR higher (Release 2.1) ---*/
DECLARE FUNCTION CloseCatalog( STRUCTPTR catalog ) LIBRARY locale
DECLARE FUNCTION CloseLocale( STRUCTPTR locale ) LIBRARY locale
DECLARE FUNCTION LONGINT ConvToLower( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION LONGINT ConvToUpper( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION FormatDate( STRUCTPTR locale, STRPTR fmtTemplate, \
                             STRUCTPTR date, STRUCTPTR putCharFunc ) LIBRARY locale
DECLARE FUNCTION APTR FormatString( STRUCTPTR locale, STRPTR fmtTemplate, APTR dataStream, \
                                    STRUCTPTR putCharFunc ) LIBRARY locale
DECLARE FUNCTION STRPTR GetCatalogStr( STRUCTPTR catalog, LONGINT stringNum, \
                                       STRPTR defaultString ) LIBRARY locale
DECLARE FUNCTION STRPTR GetLocaleStr( STRUCTPTR locale, LONGINT stringNum ) LIBRARY locale
DECLARE FUNCTION BOOL IsAlNum( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsAlpha( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsCntrl( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsDigit( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsGraph( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsLower( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsPrint( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsPunct( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsSpace( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsUpper( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION BOOL IsXDigit( STRUCTPTR locale, LONGINT character ) LIBRARY locale
DECLARE FUNCTION STRUCTPTR OpenCatalogA( STRUCTPTR locale, STRPTR _NAME, \
                                         STRUCTPTR tags ) LIBRARY locale
DECLARE FUNCTION STRUCTPTR OpenLocale( STRPTR _NAME ) LIBRARY locale
DECLARE FUNCTION BOOL ParseDate( STRUCTPTR locale, STRUCTPTR date, \
                                 STRPTR fmtTemplate, STRUCTPTR getCharFunc ) LIBRARY locale
DECLARE FUNCTION LONGINT StrConvert( STRUCTPTR locale, STRPTR _STRING, APTR buffer, \
                                     LONGINT bufferSize, LONGINT _TYPE ) LIBRARY locale
DECLARE FUNCTION LONGINT StrnCmp( STRUCTPTR locale, STRPTR string1, STRPTR string2, \
                                  LONGINT length, LONGINT _TYPE ) LIBRARY locale
#endif   /* FUNCS_LOCALE_FUNCS_H */
