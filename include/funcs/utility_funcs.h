#ifndef  FUNCS_UTILITY_FUNCS_H
#define  FUNCS_UTILITY_FUNCS_H

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

/*--- functions in V36 OR higher (Release 2.0) ---*/

/* Tag item functions */

DECLARE FUNCTION STRUCTPTR FindTagItem( LONGINT tagVal, STRUCTPTR tagList ) LIBRARY utility
DECLARE FUNCTION LONGINT GetTagData( LONGINT tagValue, LONGINT defaultVal, \
                                     STRUCTPTR tagList ) LIBRARY utility
DECLARE FUNCTION LONGINT PackBoolTags( LONGINT initialFlags, STRUCTPTR tagList, \
                                       STRUCTPTR boolMap ) LIBRARY utility
DECLARE FUNCTION STRUCTPTR NextTagItem( ADDRESS tagListPtr ) LIBRARY utility
DECLARE FUNCTION FilterTagChanges( STRUCTPTR changeList, \
                                   STRUCTPTR originalList, LONGINT apply ) LIBRARY utility
DECLARE FUNCTION MapTags( STRUCTPTR tagList, STRUCTPTR mapList, \
                          LONGINT mapType ) LIBRARY utility
DECLARE FUNCTION STRUCTPTR AllocateTagItems( LONGINT numTags ) LIBRARY utility
DECLARE FUNCTION STRUCTPTR CloneTagItems( STRUCTPTR tagList ) LIBRARY utility
DECLARE FUNCTION FreeTagItems( STRUCTPTR tagList ) LIBRARY utility
DECLARE FUNCTION RefreshTagItemClones( STRUCTPTR clone, STRUCTPTR original ) LIBRARY utility
DECLARE FUNCTION BOOL TagInArray( LONGINT tagValue, ADDRESS tagArray ) LIBRARY utility
DECLARE FUNCTION LONGINT FilterTagItems( STRUCTPTR tagList, ADDRESS filterArray, \
                                         LONGINT logic ) LIBRARY utility

/* Hook functions */

DECLARE FUNCTION LONGINT CallHookPkt( STRUCTPTR hook, APTR object, APTR paramPacket ) LIBRARY utility

/* Date functions */

DECLARE FUNCTION Amiga2Date( LONGINT seconds, STRUCTPTR result ) LIBRARY utility
DECLARE FUNCTION LONGINT Date2Amiga( STRUCTPTR date ) LIBRARY utility
DECLARE FUNCTION LONGINT CheckDate( STRUCTPTR date ) LIBRARY utility

/* 32 bit integer muliply functions */

DECLARE FUNCTION LONGINT SMult32( LONGINT arg1, LONGINT arg2 ) LIBRARY utility
DECLARE FUNCTION LONGINT UMult32( LONGINT arg1, LONGINT arg2 ) LIBRARY utility

/* 32 bit integer division funtions. The quotient AND the remainder are */
/* returned respectively in d0 AND d1 */

DECLARE FUNCTION LONGINT SDivMod32( LONGINT dividend, LONGINT divisor ) LIBRARY utility
DECLARE FUNCTION LONGINT UDivMod32( LONGINT dividend, LONGINT divisor ) LIBRARY utility
/*--- functions in V37 OR higher (Release 2.04) ---*/

/* International STRING routines */

DECLARE FUNCTION LONGINT Stricmp( STRPTR string1, STRPTR string2 ) LIBRARY utility
DECLARE FUNCTION LONGINT Strnicmp( STRPTR string1, STRPTR string2, LONGINT length ) LIBRARY utility
DECLARE FUNCTION LONGINT ToUpper( LONGINT character ) LIBRARY utility
DECLARE FUNCTION LONGINT ToLower( LONGINT character ) LIBRARY utility
/*--- functions in V39 OR higher (Release 3) ---*/

/* More tag Item functions */

DECLARE FUNCTION ApplyTagChanges( STRUCTPTR _LIST, STRUCTPTR changeList ) LIBRARY utility

/* 64 bit integer muliply functions. The results are 64 bit quantities */
/* returned in D0 AND D1 */

DECLARE FUNCTION LONGINT SMult64( LONGINT arg1, LONGINT arg2 ) LIBRARY utility
DECLARE FUNCTION LONGINT UMult64( LONGINT arg1, LONGINT arg2 ) LIBRARY utility

/* Structure TO Tag AND Tag TO Structure support routines */

DECLARE FUNCTION LONGINT PackStructureTags( APTR pack, ADDRESS packTable, \
                                            STRUCTPTR tagList ) LIBRARY utility
DECLARE FUNCTION LONGINT UnpackStructureTags( APTR pack, ADDRESS packTable, \
                                              STRUCTPTR tagList ) LIBRARY utility

/* NEW, object-oriented NameSpaces */

DECLARE FUNCTION BOOL AddNamedObject( STRUCTPTR nameSpace, STRUCTPTR object ) LIBRARY utility
DECLARE FUNCTION STRUCTPTR AllocNamedObjectA( STRPTR _NAME, STRUCTPTR tagList ) LIBRARY utility
DECLARE FUNCTION LONGINT AttemptRemNamedObject( STRUCTPTR object ) LIBRARY utility
DECLARE FUNCTION STRUCTPTR FindNamedObject( STRUCTPTR nameSpace, \
                                            STRPTR _NAME, STRUCTPTR lastObject ) LIBRARY utility
DECLARE FUNCTION FreeNamedObject( STRUCTPTR object ) LIBRARY utility
DECLARE FUNCTION STRPTR NamedObjectName( STRUCTPTR object ) LIBRARY utility
DECLARE FUNCTION ReleaseNamedObject( STRUCTPTR object ) LIBRARY utility
DECLARE FUNCTION RemNamedObject( STRUCTPTR object, STRUCTPTR _MESSAGE ) LIBRARY utility

/* Unique ID generator */

DECLARE FUNCTION LONGINT GetUniqueID() LIBRARY utility


#endif   /* FUNCS_UTILITY_FUNCS_H */
