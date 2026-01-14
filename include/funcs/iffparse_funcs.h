#ifndef  FUNCS_IFFPARSE_FUNCS_H
#define  FUNCS_IFFPARSE_FUNCS_H

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

/* Basic functions */

DECLARE FUNCTION STRUCTPTR AllocIFF() LIBRARY iffparse
DECLARE FUNCTION LONGINT OpenIFF( STRUCTPTR _IFF, LONGINT rwMode ) LIBRARY iffparse
DECLARE FUNCTION LONGINT ParseIFF( STRUCTPTR _IFF, LONGINT control ) LIBRARY iffparse
DECLARE FUNCTION CloseIFF( STRUCTPTR _IFF ) LIBRARY iffparse
DECLARE FUNCTION FreeIFF( STRUCTPTR _IFF ) LIBRARY iffparse

/* READ/WRITE functions */

DECLARE FUNCTION LONGINT ReadChunkBytes( STRUCTPTR _IFF, APTR buf, LONGINT numBytes ) LIBRARY iffparse
DECLARE FUNCTION LONGINT WriteChunkBytes( STRUCTPTR _IFF, APTR buf, LONGINT numBytes ) LIBRARY iffparse
DECLARE FUNCTION LONGINT ReadChunkRecords( STRUCTPTR _IFF, APTR buf, LONGINT bytesPerRecord, \
                                           LONGINT numRecords ) LIBRARY iffparse
DECLARE FUNCTION LONGINT WriteChunkRecords( STRUCTPTR _IFF, APTR buf, LONGINT bytesPerRecord, \
                                            LONGINT numRecords ) LIBRARY iffparse

/* Context entry/EXIT */

DECLARE FUNCTION LONGINT PushChunk( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id, LONGINT _SIZE ) LIBRARY iffparse
DECLARE FUNCTION LONGINT PopChunk( STRUCTPTR _IFF ) LIBRARY iffparse

/* Low-level handler installation */

DECLARE FUNCTION LONGINT EntryHandler( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id, LONGINT position, \
                                       STRUCTPTR handler, APTR object ) LIBRARY iffparse
DECLARE FUNCTION LONGINT ExitHandler( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id, LONGINT position, \
                                      STRUCTPTR handler, APTR object ) LIBRARY iffparse

/* Built-in chunk/property handlers */

DECLARE FUNCTION LONGINT PropChunk( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id ) LIBRARY iffparse
DECLARE FUNCTION LONGINT PropChunks( STRUCTPTR _IFF, ADDRESS propArray, LONGINT numPairs ) LIBRARY iffparse
DECLARE FUNCTION LONGINT StopChunk( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id ) LIBRARY iffparse
DECLARE FUNCTION LONGINT StopChunks( STRUCTPTR _IFF, ADDRESS propArray, LONGINT numPairs ) LIBRARY iffparse
DECLARE FUNCTION LONGINT CollectionChunk( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id ) LIBRARY iffparse
DECLARE FUNCTION LONGINT CollectionChunks( STRUCTPTR _IFF, ADDRESS propArray, \
                                           LONGINT numPairs ) LIBRARY iffparse
DECLARE FUNCTION LONGINT StopOnExit( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id ) LIBRARY iffparse

/* Context utilities */

DECLARE FUNCTION STRUCTPTR FindProp( STRUCTPTR _IFF, LONGINT _TYPE, LONGINT id ) LIBRARY iffparse
DECLARE FUNCTION STRUCTPTR FindCollection( STRUCTPTR _IFF, LONGINT _TYPE, \
                                           LONGINT id ) LIBRARY iffparse
DECLARE FUNCTION STRUCTPTR FindPropContext( STRUCTPTR _IFF ) LIBRARY iffparse
DECLARE FUNCTION STRUCTPTR CurrentChunk( STRUCTPTR _IFF ) LIBRARY iffparse
DECLARE FUNCTION STRUCTPTR ParentChunk( STRUCTPTR contextNode ) LIBRARY iffparse

/* LocalContextItem support functions */

DECLARE FUNCTION STRUCTPTR AllocLocalItem( LONGINT _TYPE, LONGINT id, LONGINT ident, \
                                           LONGINT dataSize ) LIBRARY iffparse
DECLARE FUNCTION APTR LocalItemData( STRUCTPTR localItem ) LIBRARY iffparse
DECLARE FUNCTION SetLocalItemPurge( STRUCTPTR localItem, STRUCTPTR purgeHook ) LIBRARY iffparse
DECLARE FUNCTION FreeLocalItem( STRUCTPTR localItem ) LIBRARY iffparse
DECLARE FUNCTION STRUCTPTR FindLocalItem( STRUCTPTR _IFF, LONGINT _TYPE, \
                                          LONGINT id, LONGINT ident ) LIBRARY iffparse
DECLARE FUNCTION LONGINT StoreLocalItem( STRUCTPTR _IFF, STRUCTPTR localItem, \
                                         LONGINT position ) LIBRARY iffparse
DECLARE FUNCTION StoreItemInContext( STRUCTPTR _IFF, STRUCTPTR localItem, STRUCTPTR contextNode ) LIBRARY iffparse

/* IFFHandle initialization */

DECLARE FUNCTION InitIFF( STRUCTPTR _IFF, LONGINT flags, STRUCTPTR streamHook ) LIBRARY iffparse
DECLARE FUNCTION InitIFFasDOS( STRUCTPTR _IFF ) LIBRARY iffparse
DECLARE FUNCTION InitIFFasClip( STRUCTPTR _IFF ) LIBRARY iffparse

/* Internal clipboard support */

DECLARE FUNCTION STRUCTPTR OpenClipboard( LONGINT unitNumber ) LIBRARY iffparse
DECLARE FUNCTION CloseClipboard( STRUCTPTR clipHandle ) LIBRARY iffparse

/* Miscellaneous */

DECLARE FUNCTION LONGINT GoodID( LONGINT id ) LIBRARY iffparse
DECLARE FUNCTION LONGINT GoodType( LONGINT _TYPE ) LIBRARY iffparse
DECLARE FUNCTION STRPTR IDtoStr( LONGINT id, STRPTR buf ) LIBRARY iffparse
#endif   /* FUNCS_IFFPARSE_FUNCS_H */
