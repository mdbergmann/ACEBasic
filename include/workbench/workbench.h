#ifndef WORKBENCH_WORKBENCH_H
#define WORKBENCH_WORKBENCH_H 1
/*
** workbench.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/

/*
** This are the StructPointer defines for workbench.h
*/
#ifndef AppIconPtr
#define AppIconPtr ADDRESS
#endif
#ifndef AppMenuItemPtr
#define AppMenuItemPtr ADDRESS
#endif
#ifndef AppMessagePtr
#define AppMessagePtr ADDRESS
#endif
#ifndef AppWindowPtr
#define AppWindowPtr ADDRESS
#endif
#ifndef DiskObjectPtr
#define DiskObjectPtr ADDRESS
#endif
#ifndef DrawerDataPtr
#define DrawerDataPtr ADDRESS
#endif
#ifndef FreeListPtr
#define FreeListPtr ADDRESS
#endif
#ifndef OldDrawerDataPtr
#define OldDrawerDataPtr ADDRESS
#endif
/*
** End of StructPointer defines for workbench.h
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_TASKS_H
#include <exec/tasks.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef WORKBENCH_STARTUP_H
#include <workbench/startup.h>
#endif

#define WBDISK      1
#define WBDRAWER    2
#define WBTOOL      3
#define WBPROJECT   4
#define WBGARBAGE   5
#define WBDEVICE    6
#define WBKICK      7
#define WBAPPICON   8

STRUCT OldDrawerData   /* pre V36 definition */
    NewWindow dd_NewWindow    /* args to open window */
    LONGINT        dd_CurrentX     /* current x coordinate of origin */
    LONGINT        dd_CurrentY     /* current y coordinate of origin */
END STRUCT 
/* the amount of DrawerData actually written to disk */
#define OLDDRAWERDATAFILESIZE   (SIZEOF(OldDrawerData))

STRUCT DrawerData  
    NewWindow dd_NewWindow    /* args to open window */
    LONGINT        dd_CurrentX     /* current x coordinate of origin */
    LONGINT        dd_CurrentY     /* current y coordinate of origin */
    LONGINT       dd_Flags    /* flags for drawer */
    SHORTINT       dd_ViewModes    /* view mode for drawer */
END STRUCT 
/* the amount of DrawerData actually written to disk */
#define DRAWERDATAFILESIZE  (SIZEOF(DrawerData))

STRUCT DiskObject  
    SHORTINT       do_Magic  /* a magic number at the start of the file */
    SHORTINT       do_Version  /* a version number,  so we can change it */
    _Gadget do_Gadget   /* a copy of in core gadget */
    BYTE        do_Type 
    ADDRESS   do_DefaultTool 
    ADDRESS   do_ToolTypes
    LONGINT        do_CurrentX 
    LONGINT        do_CurrentY 
    DrawerDataPtr  do_DrawerData 
    ADDRESS   do_ToolWindow   /* only applies to tools */
    LONGINT        do_StackSize    /* only applies to tools */

END STRUCT 

#define WB_DISKMAGIC    &He310  /* a magic number,  not easily impersonated */
#define WB_DISKVERSION  1   /* our current version number */
#define WB_DISKREVISION 1   /* our current revision number */
/* I only use the lower 8 bits of Gadget.UserData for the revision # */
#define WB_DISKREVISIONMASK 255

STRUCT FreeList  
    SHORTINT        fl_NumFree 
    _List fl_MemList 
END STRUCT 

/* workbench does different complement modes for its gadgets.
** It supports separate images,  complement mode,  and backfill mode.
** The first two are identical to intuitions GFLG_GADGIMAGE and GFLG_GADGHCOMP.
** backfill is similar to GFLG_GADGHCOMP,  but the region outside of the
** image (which normally would be color three when complemented)
** is flood-filled to color zero.
*/
#define GFLG_GADGBACKFILL &H0001
#define GADGBACKFILL      &H0001    /* an old synonym */

/* if an icon does not really live anywhere,  set its current position
** to here
*/
#define NO_ICON_POSITION    (&H80000000)

/* workbench now is a library.  this is it's name */
#define WORKBENCH_NAME      "workbench.library"

/* If you find am_Version >= AM_VERSION,  you know this structure has
 * at least the fields defined in this version of the include file
 */
#define AM_VERSION  1

STRUCT AppMessage  
    _Message am_Message   /* standard message structure */
    SHORTINT am_Type       /* message type */
    LONGINT am_UserData       /* application specific */
    LONGINT am_ID         /* application definable ID */
    LONGINT am_NumArgs         /* # of elements in arglist */
    WBArgPtr  am_ArgList    /* the arguements themselves */
    SHORTINT am_Version        /* will be AM_VERSION */
    SHORTINT am_Class      /* message class */
    SHORTINT am_MouseX      /* mouse x position of event */
    SHORTINT am_MouseY      /* mouse y position of event */
    LONGINT am_Seconds        /* current system clock time */
    LONGINT am_Micros         /* current system clock time */
    STRING am_Reserved SIZE 32  /* 8*SIZEOF(LONGINT) */   /* avoid recompilation */
END STRUCT 

/* types of app messages */
#define AMTYPE_APPWINDOW   7    /* app window message    */
#define AMTYPE_APPICON     8    /* app icon message  */
#define AMTYPE_APPMENUITEM 9    /* app menu item message */


/*
 * The following structures are private.  These are just stub
 * structures for code compatibility...
 */
STRUCT  AppWindow    
    ADDRESS   aw_PRIVATE 
END STRUCT 

STRUCT  AppIcon      
    ADDRESS   ai_PRIVATE 
END STRUCT 

STRUCT      AppMenuItem  
    ADDRESS   ami_PRIVATE 
END STRUCT 

#endif  /* !WORKBENCH_WORKBENCH_H */
