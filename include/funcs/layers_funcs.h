#ifndef  FUNCS_LAYERS_FUNCS_H
#define  FUNCS_LAYERS_FUNCS_H

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

DECLARE FUNCTION InitLayers( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR CreateUpfrontLayer( STRUCTPTR li, STRUCTPTR bm, \
                                               LONGINT x0, LONGINT y0, LONGINT x1, \
                                               LONGINT y1, LONGINT flags, STRUCTPTR bm2 ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR CreateBehindLayer( STRUCTPTR li, STRUCTPTR bm, \
                                              LONGINT x0, LONGINT y0, LONGINT x1, \
                                              LONGINT y1, LONGINT flags, STRUCTPTR bm2 ) LIBRARY layers
DECLARE FUNCTION LONGINT UpfrontLayer( LONGINT dummy, STRUCTPTR layer ) LIBRARY layers
DECLARE FUNCTION LONGINT BehindLayer( LONGINT dummy, STRUCTPTR layer ) LIBRARY layers
DECLARE FUNCTION LONGINT MoveLayer( LONGINT dummy, STRUCTPTR layer, LONGINT dx, LONGINT dy ) LIBRARY layers
DECLARE FUNCTION LONGINT SizeLayer( LONGINT dummy, STRUCTPTR layer, LONGINT dx, LONGINT dy ) LIBRARY layers
DECLARE FUNCTION ScrollLayer( LONGINT dummy, STRUCTPTR layer, LONGINT dx, LONGINT dy ) LIBRARY layers
DECLARE FUNCTION LONGINT BeginUpdate( STRUCTPTR l ) LIBRARY layers
DECLARE FUNCTION EndUpdate( STRUCTPTR layer,  LONGINT flag ) LIBRARY layers
DECLARE FUNCTION LONGINT DeleteLayer( LONGINT dummy, STRUCTPTR layer ) LIBRARY layers
DECLARE FUNCTION LockLayer( LONGINT dummy, STRUCTPTR layer ) LIBRARY layers
DECLARE FUNCTION UnlockLayer( STRUCTPTR layer ) LIBRARY layers
DECLARE FUNCTION LockLayers( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION UnlockLayers( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION LockLayerInfo( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION SwapBitsRastPortClipRect( STRUCTPTR rp, STRUCTPTR cr ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR WhichLayer( STRUCTPTR li, LONGINT x, LONGINT y ) LIBRARY layers
DECLARE FUNCTION UnlockLayerInfo( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR NewLayerInfo() LIBRARY layers
DECLARE FUNCTION DisposeLayerInfo( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION LONGINT FattenLayerInfo( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION ThinLayerInfo( STRUCTPTR li ) LIBRARY layers
DECLARE FUNCTION LONGINT MoveLayerInFrontOf( STRUCTPTR layer_to_move, \
                                             STRUCTPTR other_layer ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR InstallClipRegion( STRUCTPTR layer, \
                                              STRUCTPTR region ) LIBRARY layers
DECLARE FUNCTION LONGINT MoveSizeLayer( STRUCTPTR layer, LONGINT dx, LONGINT dy, LONGINT dw, LONGINT dh ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR CreateUpfrontHookLayer( STRUCTPTR li, STRUCTPTR bm, \
                                                   LONGINT x0, LONGINT y0, LONGINT x1, \
                                                   LONGINT y1, LONGINT flags, \
                                                   STRUCTPTR hook, STRUCTPTR bm2 ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR CreateBehindHookLayer( STRUCTPTR li, STRUCTPTR bm, \
                                                  LONGINT x0, LONGINT y0, LONGINT x1, \
                                                  LONGINT y1, LONGINT flags, \
                                                  STRUCTPTR hook, STRUCTPTR bm2 ) LIBRARY layers
DECLARE FUNCTION STRUCTPTR InstallLayerHook( STRUCTPTR layer, STRUCTPTR hook ) LIBRARY layers
/*--- functions in V39 OR higher (Release 3) ---*/
DECLARE FUNCTION STRUCTPTR InstallLayerInfoHook( STRUCTPTR li, STRUCTPTR hook ) LIBRARY layers
DECLARE FUNCTION SortLayerCR( STRUCTPTR layer, LONGINT dx, LONGINT dy ) LIBRARY layers
DECLARE FUNCTION DoHookClipRects( STRUCTPTR hook, STRUCTPTR rport, STRUCTPTR rect ) LIBRARY layers
#endif   /* FUNCS_LAYERS_FUNCS_H */
