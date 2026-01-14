#ifndef  FUNCS_EXEC_FUNCS_H
#define  FUNCS_EXEC_FUNCS_H

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

/*------ misc ---------------------------------------------------------*/
DECLARE FUNCTION LONGINT Supervisor(  ADDRESS userFunction ) LIBRARY exec
/*------ special patchable hooks TO internal exec activity ------------*/
/*------ module creation ----------------------------------------------*/
DECLARE FUNCTION InitCode(  LONGINT startClass,  LONGINT version ) LIBRARY exec
DECLARE FUNCTION InitStruct( APTR initTable, APTR memory,  LONGINT _SIZE ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR MakeLibrary( APTR funcInit, APTR structInit, \
                                        ADDRESS libInit,  LONGINT dataSize, LONGINT segList ) LIBRARY exec
DECLARE FUNCTION MakeFunctions( APTR target, APTR functionArray, \
                                LONGINT funcDispBase ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR FindResident( ADDRESS _NAME ) LIBRARY exec
DECLARE FUNCTION APTR InitResident( STRUCTPTR resident,  LONGINT segList ) LIBRARY exec
/*------ diagnostics --------------------------------------------------*/
DECLARE FUNCTION Alert(  LONGINT alertNum ) LIBRARY exec
DECLARE FUNCTION Debug(  LONGINT flags ) LIBRARY exec
/*------ interrupts ---------------------------------------------------*/
DECLARE FUNCTION Disable() LIBRARY exec
DECLARE FUNCTION Enable() LIBRARY exec
DECLARE FUNCTION Forbid() LIBRARY exec
DECLARE FUNCTION Permit() LIBRARY exec
DECLARE FUNCTION LONGINT SetSR(  LONGINT newSR,  LONGINT mask ) LIBRARY exec
DECLARE FUNCTION APTR SuperState() LIBRARY exec
DECLARE FUNCTION UserState( APTR sysStack ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR SetIntVector( LONGINT intNumber, STRUCTPTR interrupt ) LIBRARY exec
DECLARE FUNCTION AddIntServer( LONGINT intNumber, STRUCTPTR interrupt ) LIBRARY exec
DECLARE FUNCTION RemIntServer( LONGINT intNumber, STRUCTPTR interrupt ) LIBRARY exec
DECLARE FUNCTION Cause( STRUCTPTR interrupt ) LIBRARY exec
/*------ memory allocation --------------------------------------------*/
DECLARE FUNCTION APTR Allocate( STRUCTPTR freeList,  LONGINT byteSize ) LIBRARY exec
DECLARE FUNCTION Deallocate( STRUCTPTR freeList, APTR memoryBlock, \
                             LONGINT byteSize ) LIBRARY exec
DECLARE FUNCTION APTR AllocMem(  LONGINT byteSize,  LONGINT requirements ) LIBRARY exec
DECLARE FUNCTION APTR AllocAbs(  LONGINT byteSize, APTR location ) LIBRARY exec
DECLARE FUNCTION FreeMem( APTR memoryBlock,  LONGINT byteSize ) LIBRARY exec
DECLARE FUNCTION LONGINT AvailMem(  LONGINT requirements ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR AllocEntry( STRUCTPTR entry ) LIBRARY exec
DECLARE FUNCTION FreeEntry( STRUCTPTR entry ) LIBRARY exec
/*------ lists --------------------------------------------------------*/
DECLARE FUNCTION Insert( STRUCTPTR _LIST, STRUCTPTR node, STRUCTPTR pred ) LIBRARY exec
DECLARE FUNCTION AddHead( STRUCTPTR _LIST, STRUCTPTR node ) LIBRARY exec
DECLARE FUNCTION AddTail( STRUCTPTR _LIST, STRUCTPTR node ) LIBRARY exec
DECLARE FUNCTION Remove( STRUCTPTR node ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR RemHead( STRUCTPTR _LIST ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR RemTail( STRUCTPTR _LIST ) LIBRARY exec
DECLARE FUNCTION Enqueue( STRUCTPTR _LIST, STRUCTPTR node ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR FindName( STRUCTPTR _LIST, ADDRESS _NAME ) LIBRARY exec
/*------ tasks --------------------------------------------------------*/
DECLARE FUNCTION APTR AddTask( STRUCTPTR task, APTR initPC, APTR finalPC ) LIBRARY exec
DECLARE FUNCTION RemTask( STRUCTPTR task ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR FindTask( ADDRESS _NAME ) LIBRARY exec
DECLARE FUNCTION LONGINT SetTaskPri( STRUCTPTR task, LONGINT priority ) LIBRARY exec
DECLARE FUNCTION LONGINT SetSignal(  LONGINT newSignals,  LONGINT signalSet ) LIBRARY exec
DECLARE FUNCTION LONGINT SetExcept(  LONGINT newSignals,  LONGINT signalSet ) LIBRARY exec
DECLARE FUNCTION LONGINT _Wait(  LONGINT signalSet ) LIBRARY exec
DECLARE FUNCTION Signal( STRUCTPTR task,  LONGINT signalSet ) LIBRARY exec
DECLARE FUNCTION LONGINT AllocSignal( LONGINT signalNum ) LIBRARY exec
DECLARE FUNCTION FreeSignal( LONGINT signalNum ) LIBRARY exec
DECLARE FUNCTION LONGINT AllocTrap( LONGINT trapNum ) LIBRARY exec
DECLARE FUNCTION FreeTrap( LONGINT trapNum ) LIBRARY exec
/*------ messages -----------------------------------------------------*/
DECLARE FUNCTION AddPort( STRUCTPTR port ) LIBRARY exec
DECLARE FUNCTION RemPort( STRUCTPTR port ) LIBRARY exec
DECLARE FUNCTION PutMsg( STRUCTPTR port, STRUCTPTR _MESSAGE ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR GetMsg( STRUCTPTR port ) LIBRARY exec
DECLARE FUNCTION ReplyMsg( STRUCTPTR  _MESSAGE ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR WaitPort( STRUCTPTR port ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR FindPort( ADDRESS _NAME ) LIBRARY exec
/*------ libraries ----------------------------------------------------*/
DECLARE FUNCTION AddLibrary( STRUCTPTR _LIBRARY ) LIBRARY exec
DECLARE FUNCTION RemLibrary( STRUCTPTR _LIBRARY ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR OldOpenLibrary( ADDRESS libName ) LIBRARY exec
DECLARE FUNCTION CloseLibrary( STRUCTPTR _LIBRARY ) LIBRARY exec
DECLARE FUNCTION APTR SetFunction( STRUCTPTR _LIBRARY, LONGINT funcOffset, \
                                   ADDRESS newFunction ) LIBRARY exec
DECLARE FUNCTION SumLibrary( STRUCTPTR _LIBRARY ) LIBRARY exec
/*------ devices ------------------------------------------------------*/
DECLARE FUNCTION AddDevice( STRUCTPTR device ) LIBRARY exec
DECLARE FUNCTION RemDevice( STRUCTPTR device ) LIBRARY exec
DECLARE FUNCTION LONGINT OpenDevice( ADDRESS devName,  LONGINT unit, \
                                  STRUCTPTR ioRequest,  LONGINT flags ) LIBRARY exec
DECLARE FUNCTION CloseDevice( STRUCTPTR ioRequest ) LIBRARY exec
DECLARE FUNCTION LONGINT DoIO( STRUCTPTR ioRequest ) LIBRARY exec
DECLARE FUNCTION SendIO( STRUCTPTR ioRequest ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR CheckIO( STRUCTPTR ioRequest ) LIBRARY exec
DECLARE FUNCTION LONGINT WaitIO( STRUCTPTR ioRequest ) LIBRARY exec
DECLARE FUNCTION AbortIO( STRUCTPTR ioRequest ) LIBRARY exec
/*------ resources ----------------------------------------------------*/
DECLARE FUNCTION AddResource( APTR resource ) LIBRARY exec
DECLARE FUNCTION RemResource( APTR resource ) LIBRARY exec
DECLARE FUNCTION APTR OpenResource( ADDRESS resName ) LIBRARY exec
/*------ private diagnostic support -----------------------------------*/
/*------ misc ---------------------------------------------------------*/
DECLARE FUNCTION APTR RawDoFmt( ADDRESS formatString, APTR dataStream, ADDRESS putChProc, \
                                APTR putChData ) LIBRARY exec
DECLARE FUNCTION LONGINT GetCC() LIBRARY exec
DECLARE FUNCTION LONGINT TypeOfMem( APTR _ADDRESS ) LIBRARY exec
DECLARE FUNCTION LONGINT Procure( STRUCTPTR sigSem, \
                                  STRUCTPTR bidMsg ) LIBRARY exec
DECLARE FUNCTION Vacate( STRUCTPTR sigSem, \
                         STRUCTPTR bidMsg ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR OpenLibrary( ADDRESS libName,  LONGINT version ) LIBRARY exec
/*--- functions in V33 OR higher (Release 1.2) ---*/
/*------ signal semaphores (note funny registers)----------------------*/
DECLARE FUNCTION InitSemaphore( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION ObtainSemaphore( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION ReleaseSemaphore( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION LONGINT AttemptSemaphore( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION ObtainSemaphoreList( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION ReleaseSemaphoreList( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR FindSemaphore( ADDRESS sigSem ) LIBRARY exec
DECLARE FUNCTION AddSemaphore( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION RemSemaphore( STRUCTPTR sigSem ) LIBRARY exec
/*------ kickmem support ----------------------------------------------*/
DECLARE FUNCTION LONGINT SumKickData() LIBRARY exec
/*------ more memory support ------------------------------------------*/
DECLARE FUNCTION AddMemList(  LONGINT _SIZE,  LONGINT attributes, LONGINT pri, \
                              APTR _BASE, ADDRESS _NAME ) LIBRARY exec
DECLARE FUNCTION CopyMem( APTR source, APTR dest,  LONGINT _SIZE ) LIBRARY exec
DECLARE FUNCTION CopyMemQuick( APTR source, APTR dest,  LONGINT _SIZE ) LIBRARY exec
/*------ cache --------------------------------------------------------*/
/*--- functions in V36 OR higher (Release 2.0) ---*/
DECLARE FUNCTION CacheClearU() LIBRARY exec
DECLARE FUNCTION CacheClearE( APTR _ADDRESS,  LONGINT length,  LONGINT caches ) LIBRARY exec
DECLARE FUNCTION LONGINT CacheControl(  LONGINT cacheBits,  LONGINT cacheMask ) LIBRARY exec
/*------ misc ---------------------------------------------------------*/
DECLARE FUNCTION APTR CreateIORequest( STRUCTPTR port,  LONGINT _SIZE ) LIBRARY exec
DECLARE FUNCTION DeleteIORequest( APTR iorequest ) LIBRARY exec
DECLARE FUNCTION STRUCTPTR CreateMsgPort() LIBRARY exec
DECLARE FUNCTION DeleteMsgPort( STRUCTPTR port ) LIBRARY exec
DECLARE FUNCTION ObtainSemaphoreShared( STRUCTPTR sigSem ) LIBRARY exec
/*------ even more memory support -------------------------------------*/
DECLARE FUNCTION APTR AllocVec(  LONGINT byteSize,  LONGINT requirements ) LIBRARY exec
DECLARE FUNCTION FreeVec( APTR memoryBlock ) LIBRARY exec
/*------ V39 Pool LVOs...*/
DECLARE FUNCTION APTR CreatePool(  LONGINT requirements,  LONGINT puddleSize, \
                                   LONGINT threshSize ) LIBRARY exec
DECLARE FUNCTION DeletePool( APTR poolHeader ) LIBRARY exec
DECLARE FUNCTION APTR AllocPooled( APTR poolHeader,  LONGINT memSize ) LIBRARY exec
DECLARE FUNCTION FreePooled( APTR poolHeader, APTR memory,  LONGINT memSize ) LIBRARY exec
/*------ misc ---------------------------------------------------------*/
DECLARE FUNCTION LONGINT AttemptSemaphoreShared( STRUCTPTR sigSem ) LIBRARY exec
DECLARE FUNCTION ColdReboot() LIBRARY exec
DECLARE FUNCTION StackSwap( STRUCTPTR newStack ) LIBRARY exec
/*------ task trees ---------------------------------------------------*/
DECLARE FUNCTION ChildFree( APTR tid ) LIBRARY exec
DECLARE FUNCTION ChildOrphan( APTR tid ) LIBRARY exec
DECLARE FUNCTION ChildStatus( APTR tid ) LIBRARY exec
DECLARE FUNCTION ChildWait( APTR tid ) LIBRARY exec
/*------ future expansion ---------------------------------------------*/
DECLARE FUNCTION APTR CachePreDMA( APTR _ADDRESS, ADDRESS length,  LONGINT flags ) LIBRARY exec
DECLARE FUNCTION CachePostDMA( APTR _ADDRESS, addresslength,  LONGINT flags ) LIBRARY exec
/*------ NEW, FOR V39*/
/*--- functions in V39 OR higher (Release 3) ---*/
/*------ Low memory handler functions*/
DECLARE FUNCTION AddMemHandler( STRUCTPTR memhand ) LIBRARY exec
DECLARE FUNCTION RemMemHandler( STRUCTPTR memhand ) LIBRARY exec
/*------ FUNCTION TO attempt TO obtain a Quick Interrupt Vector...*/
/*DECLARE FUNCTION LONGINT ObtainQuickVector( APTR interruptCode ) LIBRARY exec*/
#endif   /* FUNCS_EXEC_FUNCS_H */
