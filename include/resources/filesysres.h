#ifndef RESOURCES_FILESYSRES_H
#define RESOURCES_FILESYSRES_H 1
/*
** filesysres.h for ACE Basic
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
** This are the StructPointer defines for filesysres.h
*/
#ifndef FileSysEntryPtr
#define FileSysEntryPtr ADDRESS
#endif
#ifndef FileSysResourcePtr
#define FileSysResourcePtr ADDRESS
#endif
/*
** End of StructPointer defines for filesysres.h
*/


#ifndef EXEC_NODES_H
#include    <exec/nodes.h>
#endif
#ifndef EXEC_LISTS_H
#include    <exec/lists.h>
#endif
#ifndef DOS_DOS_H
#include    <dos/dos.h>
#endif

#define FSRNAME "FileSystem.resource"

STRUCT FileSysResource  
    Node fsr_Node        /* on resource list */
    ADDRESS   fsr_Creator         /* name of creator of this resource */
    _List fsr_FileSysEntries  /* list of FileSysEntry structs */
END STRUCT 

STRUCT FileSysEntry  
    Node fse_Node    /* on fsr_FileSysEntries list */
                /* ln_Name is of creator of this entry */
    LONGINT   fse_DosType     /* DosType of this FileSys */
    LONGINT   fse_Version     /* Version of this FileSys */
    LONGINT   fse_PatchFlags  /* bits set for those of the following that */
                /*   need to be substituted into a standard */
                /*   device node for this file system: e.g. */
                /*   &H180 for substitute SegList & GlobalVec */
    LONGINT   fse_Type        /* device node type: zero */
    ADDRESS    fse_Task        /* standard dos "task" FIELD */
    ADDRESS    fse_Lock        /* not used for devices: zero */
    ADDRESS    fse_Handler     /* filename to loadseg (if SegList is null) */
    LONGINT   fse_StackSize   /* stacksize to use when starting task */
    LONGINT    fse_Priority    /* task priority when starting task */
    ADDRESS    fse_Startup     /* startup msg: FileSysStartupMsg for disks */
    ADDRESS    fse_SegList     /* code to run to start new task */
    ADDRESS    fse_GlobalVec   /* BCPL global vector when starting task */
    /* no more entries need exist than those implied by fse_PatchFlags */
END STRUCT 

#endif  /* RESOURCES_FILESYSRES_H */
