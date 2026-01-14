#ifndef  FUNCS_INTUITION_FUNCS_H
#define  FUNCS_INTUITION_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/* Public functions OpenIntuition() AND Intuition() are intentionally */
/* NOT documented. */
DECLARE FUNCTION OpenIntuition() LIBRARY intuition
DECLARE FUNCTION Intuition( STRUCTPTR iEvent ) LIBRARY intuition
DECLARE FUNCTION SHORTINT AddGadget( STRUCTPTR _WINDOW, STRUCTPTR _GADGET, LONGINT position ) LIBRARY intuition
DECLARE FUNCTION BOOL ClearDMRequest( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION ClearMenuStrip( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION ClearPointer( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION BOOL CloseScreen( STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION CloseWindow( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION LONGINT CloseWorkBench() LIBRARY intuition
DECLARE FUNCTION CurrentTime( ADDRESS seconds, ADDRESS micros ) LIBRARY intuition
DECLARE FUNCTION BOOL DisplayAlert( LONGINT alertNumber, ADDRESS _STRING, LONGINT height ) LIBRARY intuition
DECLARE FUNCTION DisplayBeep( STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION BOOL DoubleClick( LONGINT sSeconds, LONGINT sMicros, \
                                   LONGINT cSeconds, LONGINT cMicros ) LIBRARY intuition
DECLARE FUNCTION DrawBorder( STRUCTPTR rp, STRUCTPTR border, LONGINT leftOffset, \
                             LONGINT topOffset ) LIBRARY intuition
DECLARE FUNCTION DrawImage( STRUCTPTR rp, STRUCTPTR image, LONGINT leftOffset, \
                            LONGINT topOffset ) LIBRARY intuition
DECLARE FUNCTION EndRequest( STRUCTPTR requester, STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR GetDefPrefs( STRUCTPTR preferences, LONGINT _SIZE ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR GetPrefs( STRUCTPTR preferences, LONGINT _SIZE ) LIBRARY intuition
DECLARE FUNCTION InitRequester( STRUCTPTR requester ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR ItemAddress( STRUCTPTR menuStrip, LONGINT menuNumber ) LIBRARY intuition
DECLARE FUNCTION BOOL ModifyIDCMP( STRUCTPTR _WINDOW, LONGINT flags ) LIBRARY intuition
DECLARE FUNCTION ModifyProp( STRUCTPTR _GADGET, STRUCTPTR _WINDOW, \
                             STRUCTPTR requester, LONGINT flags, \
                             LONGINT horizPot, LONGINT vertPot, \
                             LONGINT horizBody, LONGINT vertBody ) LIBRARY intuition
DECLARE FUNCTION MoveScreen( STRUCTPTR _SCREEN, LONGINT dx, LONGINT dy ) LIBRARY intuition
DECLARE FUNCTION MoveWindow( STRUCTPTR _WINDOW, LONGINT dx, LONGINT dy ) LIBRARY intuition
DECLARE FUNCTION OffGadget( STRUCTPTR _GADGET, STRUCTPTR _WINDOW, STRUCTPTR requester ) LIBRARY intuition
DECLARE FUNCTION OffMenu( STRUCTPTR _WINDOW, LONGINT menuNumber ) LIBRARY intuition
DECLARE FUNCTION OnGadget( STRUCTPTR _GADGET, STRUCTPTR _WINDOW, STRUCTPTR requester ) LIBRARY intuition
DECLARE FUNCTION OnMenu( STRUCTPTR _WINDOW, LONGINT menuNumber ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR OpenScreen( STRUCTPTR newScreen ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR OpenWindow( STRUCTPTR newWindow ) LIBRARY intuition
DECLARE FUNCTION LONGINT OpenWorkBench() LIBRARY intuition
DECLARE FUNCTION PrintIText( STRUCTPTR rp, STRUCTPTR iText, LONGINT left, LONGINT top ) LIBRARY intuition
DECLARE FUNCTION RefreshGadgets( STRUCTPTR gadgets, STRUCTPTR _WINDOW, \
                                 STRUCTPTR requester ) LIBRARY intuition
DECLARE FUNCTION SHORTINT RemoveGadget( STRUCTPTR _WINDOW, STRUCTPTR _GADGET ) LIBRARY intuition
/* The official calling sequence FOR ReportMouse is given below. */
/* Note the register order.  FOR the complete story, READ the ReportMouse */
/* autodoc. */
DECLARE FUNCTION ReportMouse( LONGINT flag, STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION BOOL Request( STRUCTPTR requester, STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION ScreenToBack( STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION ScreenToFront( STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION BOOL SetDMRequest( STRUCTPTR _WINDOW, STRUCTPTR requester ) LIBRARY intuition
DECLARE FUNCTION BOOL SetMenuStrip( STRUCTPTR _WINDOW, STRUCTPTR _MENU ) LIBRARY intuition
DECLARE FUNCTION SetPointer( STRUCTPTR _WINDOW, ADDRESS pointer, LONGINT height, \
                             LONGINT _WIDTH, LONGINT xOffset, LONGINT yOffset ) LIBRARY intuition
DECLARE FUNCTION SetWindowTitles( STRUCTPTR _WINDOW, ADDRESS windowTitle, \
                                  ADDRESS screenTitle ) LIBRARY intuition
DECLARE FUNCTION ShowTitle( STRUCTPTR _SCREEN, LONGINT showIt ) LIBRARY intuition
DECLARE FUNCTION SizeWindow( STRUCTPTR _WINDOW, LONGINT dx, LONGINT dy ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR ViewAddress() LIBRARY intuition
DECLARE FUNCTION STRUCTPTR ViewPortAddress( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION WindowToBack( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION WindowToFront( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION BOOL WindowLimits( STRUCTPTR _WINDOW, LONGINT widthMin, LONGINT heightMin, \
                                    LONGINT widthMax, LONGINT heightMax ) LIBRARY intuition
/*--- start of NEXT generation of names -------------------------------------*/
DECLARE FUNCTION STRUCTPTR SetPrefs( STRUCTPTR preferences, LONGINT _SIZE, \
                                     LONGINT inform ) LIBRARY intuition
/*--- start of NEXT NEXT generation of names --------------------------------*/
DECLARE FUNCTION LONGINT IntuiTextLength( STRUCTPTR iText ) LIBRARY intuition
DECLARE FUNCTION BOOL WBenchToBack() LIBRARY intuition
DECLARE FUNCTION BOOL WBenchToFront() LIBRARY intuition
/*--- start of NEXT NEXT NEXT generation of names ---------------------------*/
DECLARE FUNCTION BOOL AutoRequest( STRUCTPTR _WINDOW, STRUCTPTR body, \
                                   STRUCTPTR posText, STRUCTPTR negText, \
                                   LONGINT pFlag, LONGINT nFlag, LONGINT _WIDTH, \
                                   LONGINT height ) LIBRARY intuition
DECLARE FUNCTION BeginRefresh( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR BuildSysRequest( STRUCTPTR _WINDOW, STRUCTPTR body, \
                                            STRUCTPTR posText, STRUCTPTR negText, \
                                            LONGINT flags, LONGINT _WIDTH, LONGINT height ) LIBRARY intuition
DECLARE FUNCTION EndRefresh( STRUCTPTR _WINDOW, LONGINT complete ) LIBRARY intuition
DECLARE FUNCTION FreeSysRequest( STRUCTPTR _WINDOW ) LIBRARY intuition
/* The RETURN codes FOR MakeScreen(), RemakeDisplay(), AND RethinkDisplay() */
/* are only valid under V39 AND greater.  Do NOT examine them when running */
/* ON pre-V39 systems! */
DECLARE FUNCTION LONGINT MakeScreen( STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION LONGINT RemakeDisplay() LIBRARY intuition
DECLARE FUNCTION LONGINT RethinkDisplay() LIBRARY intuition
/*--- start of NEXT NEXT NEXT NEXT generation of names ----------------------*/
DECLARE FUNCTION APTR AllocRemember( STRUCTPTR rememberKey, LONGINT _SIZE, \
                                     LONGINT flags ) LIBRARY intuition
/* Public FUNCTION AlohaWorkbench() is intentionally NOT documented */
DECLARE FUNCTION AlohaWorkbench( LONGINT wbport ) LIBRARY intuition
DECLARE FUNCTION FreeRemember( STRUCTPTR rememberKey, LONGINT reallyForget ) LIBRARY intuition
/*--- start of 15 Nov 85 names ------------------------*/
DECLARE FUNCTION LONGINT LockIBase( LONGINT dontknow ) LIBRARY intuition
DECLARE FUNCTION UnlockIBase( LONGINT ibLock ) LIBRARY intuition
/*--- functions in V33 OR higher (Release 1.2) ---*/
DECLARE FUNCTION LONGINT GetScreenData( APTR buffer, LONGINT _SIZE, LONGINT _TYPE, \
                                        STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION RefreshGList( STRUCTPTR gadgets, STRUCTPTR _WINDOW, \
                               STRUCTPTR requester, LONGINT numGad ) LIBRARY intuition
DECLARE FUNCTION SHORTINT AddGList( STRUCTPTR _WINDOW, STRUCTPTR _GADGET, \
                                 LONGINT position, LONGINT numGad, STRUCTPTR requester ) LIBRARY intuition
DECLARE FUNCTION SHORTINT RemoveGList( STRUCTPTR remPtr, STRUCTPTR _GADGET, \
                                       LONGINT numGad ) LIBRARY intuition
DECLARE FUNCTION ActivateWindow( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION RefreshWindowFrame( STRUCTPTR _WINDOW ) LIBRARY intuition
DECLARE FUNCTION BOOL ActivateGadget( STRUCTPTR gadgets, STRUCTPTR _WINDOW, \
                                      STRUCTPTR requester ) LIBRARY intuition
DECLARE FUNCTION NewModifyProp( STRUCTPTR _GADGET, STRUCTPTR _WINDOW, \
                                STRUCTPTR requester, LONGINT flags, \
                                LONGINT horizPot, LONGINT vertPot, \
                                LONGINT horizBody, LONGINT vertBody, LONGINT numGad ) LIBRARY intuition
/*--- functions in V36 OR higher (Release 2.0) ---*/
DECLARE FUNCTION LONGINT QueryOverscan( LONGINT displayID, STRUCTPTR rect, \
                                        LONGINT oScanType ) LIBRARY intuition
DECLARE FUNCTION MoveWindowInFrontOf( STRUCTPTR _WINDOW, STRUCTPTR behindWindow ) LIBRARY intuition

DECLARE FUNCTION ChangeWindowBox( STRUCTPTR _WINDOW, LONGINT left, LONGINT top, LONGINT _WIDTH, \
                                  LONGINT height ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR SetEditHook( STRUCTPTR hook ) LIBRARY intuition
DECLARE FUNCTION LONGINT SetMouseQueue( STRUCTPTR _WINDOW, LONGINT queueLength ) LIBRARY intuition
DECLARE FUNCTION ZipWindow( STRUCTPTR _WINDOW ) LIBRARY intuition
/*--- public screens ---*/
DECLARE FUNCTION STRUCTPTR LockPubScreen( ADDRESS _NAME ) LIBRARY intuition
DECLARE FUNCTION UnlockPubScreen( ADDRESS _NAME, STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR LockPubScreenList( ) LIBRARY intuition
DECLARE FUNCTION UnlockPubScreenList( ) LIBRARY intuition
DECLARE FUNCTION ADDRESS NextPubScreen( STRUCTPTR _SCREEN, ADDRESS namebuf ) LIBRARY intuition
DECLARE FUNCTION SetDefaultPubScreen( ADDRESS _NAME ) LIBRARY intuition
DECLARE FUNCTION SHORTINT SetPubScreenModes( LONGINT modes ) LIBRARY intuition
DECLARE FUNCTION SHORTINT PubScreenStatus( STRUCTPTR _SCREEN, LONGINT statusFlags ) LIBRARY intuition

DECLARE FUNCTION STRUCTPTR ObtainGIRPort( STRUCTPTR gInfo ) LIBRARY intuition
DECLARE FUNCTION ReleaseGIRPort( STRUCTPTR rp ) LIBRARY intuition
DECLARE FUNCTION GadgetMouse( STRUCTPTR _GADGET, STRUCTPTR gInfo, \
                              ADDRESS mousePoint ) LIBRARY intuition
DECLARE FUNCTION GetDefaultPubScreen( ADDRESS nameBuffer ) LIBRARY intuition
DECLARE FUNCTION LONGINT EasyRequestArgs( STRUCTPTR _WINDOW, STRUCTPTR easyStruct, \
                                          ADDRESS idcmpPtr, APTR args ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR BuildEasyRequestArgs( STRUCTPTR _WINDOW, \
                                                 STRUCTPTR easyStruct, LONGINT idcmp, APTR args ) LIBRARY intuition
DECLARE FUNCTION LONGINT SysReqHandler( STRUCTPTR _WINDOW, ADDRESS idcmpPtr, LONGINT waitInput ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR OpenWindowTagList( STRUCTPTR newWindow, STRUCTPTR tagList ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR OpenScreenTagList( STRUCTPTR newScreen, STRUCTPTR tagList ) LIBRARY intuition

/*  NEW Image functions */
DECLARE FUNCTION DrawImageState( STRUCTPTR rp, STRUCTPTR image, LONGINT leftOffset, \
                                 LONGINT topOffset, LONGINT state, STRUCTPTR drawInfo ) LIBRARY intuition
DECLARE FUNCTION BOOL PointInImage( LONGINT _POINT, STRUCTPTR image ) LIBRARY intuition
DECLARE FUNCTION EraseImage( STRUCTPTR rp, STRUCTPTR image, LONGINT leftOffset, \
                             LONGINT topOffset ) LIBRARY intuition

DECLARE FUNCTION APTR NewObjectA( STRUCTPTR classPtr, ADDRESS classID, \
                                  STRUCTPTR tagList ) LIBRARY intuition

DECLARE FUNCTION DisposeObject( APTR object ) LIBRARY intuition
DECLARE FUNCTION LONGINT SetAttrsA( APTR object, STRUCTPTR tagList ) LIBRARY intuition

DECLARE FUNCTION LONGINT GetAttr( LONGINT attrID, APTR object, ADDRESS storagePtr ) LIBRARY intuition

/*  special set attribute CALL FOR gadgets */
DECLARE FUNCTION LONGINT SetGadgetAttrsA( STRUCTPTR _GADGET, STRUCTPTR _WINDOW, \
                                          STRUCTPTR requester, STRUCTPTR tagList ) LIBRARY intuition

/*  FOR class implementors only */
DECLARE FUNCTION APTR NextObject( APTR objectPtrPtr ) LIBRARY intuition
DECLARE FUNCTION STRUCTPTR MakeClass( ADDRESS classID, ADDRESS superClassID, \
                                      STRUCTPTR superClassPtr, LONGINT instanceSize, \
                                      LONGINT flags ) LIBRARY intuition
DECLARE FUNCTION AddClass( STRUCTPTR classPtr ) LIBRARY intuition


DECLARE FUNCTION STRUCTPTR GetScreenDrawInfo( STRUCTPTR _SCREEN ) LIBRARY intuition
DECLARE FUNCTION FreeScreenDrawInfo( STRUCTPTR _SCREEN, STRUCTPTR drawInfo ) LIBRARY intuition

DECLARE FUNCTION BOOL ResetMenuStrip( STRUCTPTR _WINDOW, STRUCTPTR _MENU ) LIBRARY intuition
DECLARE FUNCTION RemoveClass( STRUCTPTR classPtr ) LIBRARY intuition
DECLARE FUNCTION BOOL FreeClass( STRUCTPTR classPtr ) LIBRARY intuition
/*--- functions in V39 OR higher (Release 3) ---*/
DECLARE FUNCTION STRUCTPTR AllocScreenBuffer( STRUCTPTR sc, STRUCTPTR bm, \
                                              LONGINT flags ) LIBRARY intuition
DECLARE FUNCTION FreeScreenBuffer( STRUCTPTR sc, STRUCTPTR sb ) LIBRARY intuition
DECLARE FUNCTION LONGINT ChangeScreenBuffer( STRUCTPTR sc, STRUCTPTR sb ) LIBRARY intuition
DECLARE FUNCTION ScreenDepth( STRUCTPTR _SCREEN, LONGINT flags, APTR reserved ) LIBRARY intuition
DECLARE FUNCTION ScreenPosition( STRUCTPTR _SCREEN, LONGINT flags, LONGINT x1, \
                                 LONGINT y1, LONGINT x2, LONGINT y2 ) LIBRARY intuition
DECLARE FUNCTION ScrollWindowRaster( STRUCTPTR win, LONGINT dx, LONGINT dy, LONGINT xMin, \
                                     LONGINT yMin, LONGINT xMax, LONGINT yMax ) LIBRARY intuition
DECLARE FUNCTION LendMenus( STRUCTPTR fromwindow, STRUCTPTR towindow ) LIBRARY intuition
DECLARE FUNCTION LONGINT DoGadgetMethodA( STRUCTPTR gad, STRUCTPTR win, \
                                          STRUCTPTR req, ADDRESS _MESSAGE ) LIBRARY intuition
DECLARE FUNCTION SetWindowPointerA( STRUCTPTR win, STRUCTPTR taglist ) LIBRARY intuition
DECLARE FUNCTION BOOL TimedDisplayAlert( LONGINT alertNumber, ADDRESS _STRING, \
                                         LONGINT height, LONGINT time ) LIBRARY intuition
DECLARE FUNCTION HelpControl( STRUCTPTR win, LONGINT flags ) LIBRARY intuition
#endif   /* FUNCS_INTUITION_FUNCS_H */
