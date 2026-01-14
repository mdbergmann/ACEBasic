#ifndef IFF_IFFPARSE_H
#define IFF_IFFPARSE_H
/*
** iffparse.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/

/*
** This are the StructPointer defines for iffparse.h
*/
#ifndef ClipboardHandlePtr
#define ClipboardHandlePtr ADDRESS
#endif
#ifndef CollectionItemPtr
#define CollectionItemPtr ADDRESS
#endif
#ifndef ContextNodePtr
#define ContextNodePtr ADDRESS
#endif
#ifndef IFFHandlePtr
#define IFFHandlePtr ADDRESS
#endif
#ifndef IFFStreamCmdPtr
#define IFFStreamCmdPtr ADDRESS
#endif
#ifndef LocalContextItemPtr
#define LocalContextItemPtr ADDRESS
#endif
#ifndef StoredPropertyPtr
#define StoredPropertyPtr ADDRESS
#endif
/*
** End of StructPointer defines for iffparse.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef DEVICES_CLIPBOARD_H
#include <devices/clipboard.h>
#endif


/*****************************************************************************/


/* Structure associated with an active IFF stream.
 * "iff_Stream" is a value used by the client's read/write/seek functions -
 * it will not be accessed by the library itself and can have any value
 * (could even be a pointer or a ADDRESS).
 *
 * This structure can only be allocated by iffparse.library
 */
STRUCT IFFHandle
 
    LONGINT iff_Stream 
    LONGINT iff_Flags 
    LONGINT  iff_Depth     /*  Depth of context stack */
END STRUCT 

/* bit masks for "iff_Flags" field */
#define IFFF_READ   0&           /* read mode - default    */
#define IFFF_WRITE  1&           /* write mode         */
#define IFFF_RWBITS (IFFF_READ OR IFFF_WRITE) /* read/write bits    */
#define IFFF_FSEEK  (2&)      /* forward seek only      */
#define IFFF_RSEEK  (4)      /* random seek    */
#define IFFF_RESERVED   &HFFFF0000&      /* Don't touch these bits */


/*****************************************************************************/


/* When the library calls your stream handler,  you'll be passed a pointer
 * to this structure as the "message packet".
 */
STRUCT IFFStreamCmd
 
    LONGINT sc_Command     /* Operation to be performed (IFFCMD_) */
    ADDRESS sc_Buf     /* Pointer to data buffer          */
    LONGINT sc_NBytes  /* Number of bytes to be affected      */
END STRUCT 


/*****************************************************************************/


/* A node associated with a context on the iff_Stack. Each node
 * represents a chunk,  the stack representing the current nesting
 * of chunks in the open IFF file. Each context node has associated
 * local context items in the (private) LocalItems list.  The ID,  type, 
 * size and scan values describe the chunk associated with this node.
 *
 * This structure can only be allocated by iffparse.library
 */
STRUCT ContextNode
 
    MinNode cn_Node 
    LONGINT       cn_ID 
    LONGINT       cn_Type 
    LONGINT       cn_Size  /*  Size of this chunk         */
    LONGINT       cn_Scan  /*  # of bytes read/written so far */
END STRUCT 


/*****************************************************************************/


/* Local context items live in the ContextNode's.  Each class is identified
 * by its lci_Ident code and has a (private) purge vector for when the
 * parent context node is popped.
 *
 * This structure can only be allocated by iffparse.library
 */
STRUCT LocalContextItem
 
    MinNode lci_Node 
    LONGINT      lci_ID 
    LONGINT      lci_Type 
    LONGINT      lci_Ident 
END STRUCT 


/*****************************************************************************/


/* StoredProperty: a local context item containing the data stored
 * from a previously encountered property chunk.
 */
STRUCT StoredProperty
 
    LONGINT sp_Size 
    ADDRESS sp_Data 
END STRUCT 


/*****************************************************************************/


/* Collection Item: the actual node in the collection list at which
 * client will look. The next pointers cross context boundaries so
 * that the complete list is accessable.
 */
STRUCT CollectionItem
 
    CollectionItemPtr  ci_Next 
    LONGINT           ci_Size 
    ADDRESS           ci_Data 
END STRUCT 


/*****************************************************************************/


/* Structure returned by OpenClipboard(). You may do CMD_POSTs and such
 * using this structure. However,  once you call OpenIFF(),  you may not
 * do any more of your own I/O to the clipboard until you call CloseIFF().
 */
STRUCT ClipboardHandle
 
    IOClipReq cbh_Req 
    MsgPort cbh_CBport 
    MsgPort cbh_SatisfyPort 
END STRUCT 


/*****************************************************************************/


/* IFF return codes. Most functions return either zero for success or
 * one of these codes. The exceptions are the read/write functions which
 * return positive values for number of bytes or records read or written, 
 * or a negative error code. Some of these codes are not errors per sae, 
 * but valid conditions such as EOF or EOC (End of Chunk).
 */
#define IFFERR_EOF    -1&   /* Reached logical end of file  */
#define IFFERR_EOC    -2&   /* About to leave context   */
#define IFFERR_NOSCOPE    -3&   /* No valid scope for property  */
#define IFFERR_NOMEM      -4&   /* Internal memory alloc failed */
#define IFFERR_READ   -5&   /* Stream read error        */
#define IFFERR_WRITE      -6&   /* Stream write error       */
#define IFFERR_SEEK   -7&   /* Stream seek error        */
#define IFFERR_MANGLED    -8&   /* Data in file is corrupt  */
#define IFFERR_SYNTAX     -9&   /* IFF syntax error     */
#define IFFERR_NOTIFF     -10&  /* Not an IFF file      */
#define IFFERR_NOHOOK     -11&  /* No call-back hook provided   */
#define IFF_RETURN2CLIENT -12&  /* Client handler normal return */


/*****************************************************************************/

/* Universal IFF identifiers */
#define ID_FORM   1179603533 
#define ID_LIST   1279873876 
#define ID_CAT    1128354848 
#define ID_PROP   1347571536 
#define ID_NULL   538976288 

/* Identifier codes for universally recognized local context items */
#define IFFLCI_PROP         1886547824 
#define IFFLCI_COLLECTION   1668246636 
#define IFFLCI_ENTRYHANDLER 1701734500 
#define IFFLCI_EXITHANDLER  1702389860 


/*****************************************************************************/


/* Control modes for ParseIFF() function */
#define IFFPARSE_SCAN    0&
#define IFFPARSE_STEP    1&
#define IFFPARSE_RAWSTEP 2&


/*****************************************************************************/


/* Control modes for StoreLocalItem() function */
#define IFFSLI_ROOT  1&  /* Store in default context      */
#define IFFSLI_TOP   2&  /* Store in current context      */
#define IFFSLI_PROP  3&  /* Store in topmost FORM or LIST */


/*****************************************************************************/


/* Magic value for writing functions. If you pass this value in as a size
 * to PushChunk() when writing a file,  the parser will figure out the
 * size of the chunk for you. If you know the size,  is it better to
 * provide as it makes things faster.
 */
#define IFFSIZE_UNKNOWN -1&


/*****************************************************************************/


/* Possible call-back command values */
#define IFFCMD_INIT 0   /* Prepare the stream for a session */
#define IFFCMD_CLEANUP  1   /* Terminate stream session     */
#define IFFCMD_READ 2   /* Read bytes from stream       */
#define IFFCMD_WRITE    3   /* Write bytes to stream        */
#define IFFCMD_SEEK 4   /* Seek on stream           */
#define IFFCMD_ENTRY    5   /* You just entered a new context   */
#define IFFCMD_EXIT 6   /* You're about to leave a context  */
#define IFFCMD_PURGELCI 7   /* Purge a LocalContextItem     */


/*****************************************************************************/


/* Obsolete IFFParse definitions,  here for source code compatibility only.
 * Please do NOT use in new code.
 *
 * #define IFFPARSE_V37_NAMES_ONLY to remove these older names
 */
#ifndef IFFPARSE_V37_NAMES_ONLY
#define IFFSCC_INIT IFFCMD_INIT
#define IFFSCC_CLEANUP  IFFCMD_CLEANUP
#define IFFSCC_READ IFFCMD_READ
#define IFFSCC_WRITE    IFFCMD_WRITE
#define IFFSCC_SEEK IFFCMD_SEEK
#endif


/*****************************************************************************/


#endif /* IFFPARSE_H */
