#ifndef  DATATYPES_DATATYPES_H
#define  DATATYPES_DATATYPES_H 1
/*
** datatypes.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
**
*/

/*
** This are the StructPointer defines for datatypes.h
*/
#ifndef DTHookContextPtr
#define DTHookContextPtr ADDRESS
#endif
#ifndef DataTypePtr
#define DataTypePtr ADDRESS
#endif
#ifndef DataTypeHeaderPtr
#define DataTypeHeaderPtr ADDRESS
#endif
#ifndef ToolPtr
#define ToolPtr ADDRESS
#endif
#ifndef ToolNodePtr
#define ToolNodePtr ADDRESS
#endif
/*
** End of StructPointer defines for datatypes.h
*/
                  

/*****************************************************************************/

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef  EXEC_LISTS_H
#include <exec/lists.h>
#endif
#ifndef  EXEC_NODES_H
#include <exec/nodes.h>
#endif
#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#ifndef  LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif
#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif

/*****************************************************************************/

#define ID_DTYP 1146378576 

/*****************************************************************************/

#define ID_DTHD 1146374212 

STRUCT DataTypeHeader
 
    ADDRESS   dth_Name               /* Descriptive name of the data type */
    ADDRESS   dth_BaseName               /* Base name of the data type */
    ADDRESS   dth_Pattern                /* Match pattern for file name. */
    ADDRESS   dth_Mask               /* Comparision mask */
    LONGINT    dth_GroupID                /* Group that the DataType is in */
    LONGINT    dth_ID                 /* ID for DataType (same as IFF FORM type) */
    SHORTINT     dth_MaskLen                /* Length of comparision mask */
    SHORTINT     dth_Pad                /* Unused at present (must be 0) */
    SHORTINT    dth_Flags              /* Flags */
    SHORTINT    dth_Priority               /* Priority */
END STRUCT 

#define DTHSIZE SIZEOF(DataTypeHeader)

/*****************************************************************************/

/* Basic type */
#define DTF_TYPE_MASK   &H000F
#define DTF_BINARY  &H0000
#define DTF_ASCII   &H0001
#define DTF_IFF     &H0002
#define DTF_MISC    &H0003

/* Set if case is important */
#define DTF_CASE    &H0010

/* Reserved for system use */
#define DTF_SYSTEM1 &H1000

/*****************************************************************************
 *
 * GROUP ID and ID
 *
 * This is used for filtering out objects that you don't want.  For
 * example,  you could make a filter for the ASL file requester so
 * that it only showed the files that were pictures,  or even to
 * narrow it down to only show files that were ILBM pictures.
 *
 * Note that the Group ID's are in lower case,  and always the first
 * four characters of the word.
 *
 * For ID's  If it is an IFF file,  then the ID is the same as the
 * FORM type.  If it isn't an IFF file,  then the ID would be the
 * first four characters of name for the file type.
 *
 *****************************************************************************/

/* System file,  such as  directory,  executable,  library,  device,  font,  etc. */
#define GID_SYSTEM  1937339252 

/* Formatted or unformatted text */
#define GID_TEXT    1952807028 

/* Formatted text with graphics or other DataTypes */
#define GID_DOCUMENT    1685021557 

/* Sound */
#define GID_SOUND   1936684398 

/* Musical instruments used for musical scores */
#define GID_INSTRUMENT  1768846196 

/* Musical score */
#define GID_MUSIC   1836413801 

/* Still picture */
#define GID_PICTURE 1885954932 

/* Animated picture */
#define GID_ANIMATION   1634625901 

/* Animation with audio track */
#define GID_MOVIE   1836021353 

/*****************************************************************************/

/* A code chunk contains an embedded executable that can be loaded
 * with InternalLoadSeg. */
#define ID_CODE 1146372932 

/* DataTypes comparision hook context (Read-Only).  This is the
 * argument that is passed to a custom comparision routine. */
STRUCT DTHookContext
 
    /* Libraries that are already opened for your use */
    LibraryPtr  dthc_SysBase 
    LibraryPtr  dthc_DOSBase 
    LibraryPtr  dthc_IFFParseBase 
    LibraryPtr  dthc_UtilityBase 

    /* File context */
    ADDRESS             dthc_Lock      /* Lock on the file */
    FileInfoBlockPtr  dthc_FIB       /* Pointer to a FileInfoBlock */
    ADDRESS             dthc_FileHandle    /* Pointer to the file handle (may be NULL) */
    IFFHandlePtr  dthc_IFF       /* Pointer to an IFFHandle (may be NULL) */
    ADDRESS           dthc_Buffer        /* Buffer */
    LONGINT            dthc_BufferLength  /* Length of the buffer */
END STRUCT 

/*****************************************************************************/

#define ID_TOOL 1146377292 

STRUCT Tool
 
    SHORTINT    tn_Which               /* Which tool is this */
    SHORTINT    tn_Flags               /* Flags */
    ADDRESS   tn_Program                 /* Application to use */
END STRUCT 

#define TSIZE   SIZEOF(Tool)

/* defines for tn_Which */
#define TW_INFO         1
#define TW_BROWSE       2
#define TW_EDIT         3
#define TW_PRINT        4
#define TW_MAIL         5

/* defines for tn_Flags */
#define TF_LAUNCH_MASK      &H000F
#define TF_SHELL        &H0001
#define TF_WORKBENCH        &H0002
#define TF_RX           &H0003

/*****************************************************************************/

#define ID_TAGS 1146377287 

/*****************************************************************************/

#ifndef DATATYPE
#define DATATYPE
STRUCT DataType
 
    Node dtn_Node1      /* Reserved for system use */
    Node dtn_Node2      /* Reserved for system use */
    DataTypeHeaderPtr  dtn_Header         /* Pointer to the DataTypeHeader */
    _List dtn_ToolList       /* List of tool nodes */
    ADDRESS           dtn_FunctionName   /* Name of comparision routine */
    TagItemPtr  dtn_AttrList       /* Object creation tags */
    LONGINT            dtn_Length         /* Length of the memory block */
END STRUCT 
#endif

#define DTNSIZE SIZEOF(DataType)

/*****************************************************************************/

STRUCT ToolNode
 
    Node tn_Node                /* Embedded node */
    Tool tn_Tool                /* Embedded tool */
    LONGINT    tn_Length              /* Length of the memory block */
END STRUCT 

#define TNSIZE  SIZEOF(ToolNode)

/*****************************************************************************/

#ifndef ID_NAME
#define ID_NAME 1312902469 
#endif

/*****************************************************************************/

/* text ID's */
#define DTERROR_UNKNOWN_DATATYPE        2000
#define DTERROR_COULDNT_SAVE            2001
#define DTERROR_COULDNT_OPEN            2002
#define DTERROR_COULDNT_SEND_MESSAGE        2003

/* new for V40 */
#define DTERROR_COULDNT_OPEN_CLIPBOARD      2004
#define DTERROR_Reserved            2005
#define DTERROR_UNKNOWN_COMPRESSION     2006
#define DTERROR_NOT_ENOUGH_DATA         2007
#define DTERROR_INVALID_DATA            2008

/* Offset for types */
#define DTMSG_TYPE_OFFSET           2100

/*****************************************************************************/

#endif   /* DATATYPES_DATATYPES_H */
