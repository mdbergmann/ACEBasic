#ifndef  FUNCS_EXPANSION_FUNCS_H
#define  FUNCS_EXPANSION_FUNCS_H

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

/*--- functions in V33 OR higher (Release 1.2) ---*/
DECLARE FUNCTION AddConfigDev( STRUCTPTR configDev ) LIBRARY expansion
/*--- functions in V36 OR higher (Release 2.0) ---*/
DECLARE FUNCTION BOOL AddBootNode( LONGINT bootPri,  LONGINT flags, \
                                   STRUCTPTR deviceNode, STRUCTPTR configDev ) LIBRARY expansion
/*--- functions in V33 OR higher (Release 1.2) ---*/
DECLARE FUNCTION AllocBoardMem(  LONGINT slotSpec ) LIBRARY expansion
DECLARE FUNCTION STRUCTPTR AllocConfigDev() LIBRARY expansion
DECLARE FUNCTION APTR AllocExpansionMem(  LONGINT numSlots,  LONGINT slotAlign ) LIBRARY expansion
DECLARE FUNCTION ConfigBoard( APTR board, STRUCTPTR configDev ) LIBRARY expansion
DECLARE FUNCTION ConfigChain( APTR baseAddr ) LIBRARY expansion
DECLARE FUNCTION STRUCTPTR FindConfigDev( STRUCTPTR oldConfigDev, \
                                          LONGINT manufacturer, LONGINT product ) LIBRARY expansion
DECLARE FUNCTION FreeBoardMem(  LONGINT startSlot,  LONGINT slotSpec ) LIBRARY expansion
DECLARE FUNCTION FreeConfigDev( STRUCTPTR configDev ) LIBRARY expansion
DECLARE FUNCTION FreeExpansionMem(  LONGINT startSlot,  LONGINT numSlots ) LIBRARY expansion
DECLARE FUNCTION LONGINT ReadExpansionByte( APTR board,  LONGINT offset ) LIBRARY expansion
DECLARE FUNCTION ReadExpansionRom( APTR board, STRUCTPTR configDev ) LIBRARY expansion
DECLARE FUNCTION RemConfigDev( STRUCTPTR configDev ) LIBRARY expansion
DECLARE FUNCTION WriteExpansionByte( APTR board,  LONGINT offset, LONGINT _BYTE ) LIBRARY expansion
DECLARE FUNCTION ObtainConfigBinding() LIBRARY expansion
DECLARE FUNCTION ReleaseConfigBinding() LIBRARY expansion
DECLARE FUNCTION SetCurrentBinding( STRUCTPTR currentBinding, LONGINT bindingSize ) LIBRARY expansion
DECLARE FUNCTION LONGINT GetCurrentBinding( STRUCTPTR currentBinding, LONGINT bindingSize ) LIBRARY expansion
DECLARE FUNCTION STRUCTPTR MakeDosNode( APTR parmPacket ) LIBRARY expansion
DECLARE FUNCTION BOOL AddDosNode( LONGINT bootPri,  LONGINT flags, STRUCTPTR deviceNode ) LIBRARY expansion
/*--- functions in V36 OR higher (Release 2.0) ---*/
#endif   /* FUNCS_EXPANSION_FUNCS_H */
