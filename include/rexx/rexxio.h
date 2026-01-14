#ifndef REXX_REXXIO_H
#define REXX_REXXIO_H 1
/*
** rexxio.h for ACE Basic
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
** This are the StructPointer defines for rexxio.h
*/
#ifndef IoBuffPtr
#define IoBuffPtr ADDRESS
#endif
#ifndef RexxMsgPortPtr
#define RexxMsgPortPtr ADDRESS
#endif
/*
** End of StructPointer defines for rexxio.h
*/


#ifndef REXX_STORAGE_H
#include <rexx/storage.h>
#endif

#define RXBUFFSZ  204              /* buffer length     */

/*
 * The IoBuff is a resource node used to maintain the File List.  Nodes
 * are allocated and linked into the list whenever a file is opened.
 */
STRUCT IoBuff  
   RexxRsrc iobNode         /* structure for files/strings   */
   ADDRESS     iobRpt             /* read/write pointer        */
   LONGINT     iobRct             /* character count       */
   LONGINT     iobDFH             /* DOS filehandle        */
   ADDRESS     iobLock                /* DOS lock          */
   LONGINT     iobBct             /* buffer length     */
   STRING iobArea SIZE 204  /* RXBUFFSZ  */         /* buffer AREA           */
END STRUCT                       /* SIZE: 256 bytes       */

/* Access mode definitions                      */
#define RXIO_EXIST   -1        /* an external filehandle    */
#define RXIO_STRF    0             /* a "string file"       */
#define RXIO_READ    1             /* read-only access      */
#define RXIO_WRITE   2             /* write mode            */
#define RXIO_APPEND  3             /* append mode (existing file)   */

/*
 * Offset anchors for SeekF()
 */
#define RXIO_BEGIN   -1&           /* relative TO start     */
#define RXIO_CURR    0&        /* relative TO current position  */
#define RXIO_END     1&        /* relative TO END       */

/* The Library List contains just plain resource nodes.     */

#define LLOFFSET(rrp) (rrp->rr_Arg1)   /* "Query" offset        */
#define LLVERS(rrp)   (rrp->rr_Arg2)   /* library version       */

/*
 * The RexxClipNode structure is used to maintain the Clip List.  The value
 * string is stored as an argstring in the rr_Arg1 field.
 */
#define CLVALUE(rrp) ((ADDRESS) rrp->rr_Arg1)

/*
 * A message port structure,  maintained as a resource node.  The ReplyList
 * holds packets that have been received but haven't been replied.
 */
STRUCT RexxMsgPort  
   RexxRsrc rmp_Node            /* linkage node          */
   MsgPort rmp_Port            /* the message port      */
   _List rmp_ReplyList       /* messages awaiting reply   */
   END STRUCT 

/*
 * DOS Device types
 */
#define DT_DEV    0&               /* a device          */
#define DT_DIR    1&               /* an ASSIGNed directory */
#define DT_VOL    2&               /* a volume          */

/*
 * Private DOS packet types
 */
#define ACTION_STACK 2002&         /* stack a LINE          */
#define ACTION_QUEUE 2003&         /* queue a LINE          */

#endif
