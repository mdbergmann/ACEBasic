#ifndef UTILITY_TAGITEM_H
#define UTILITY_TAGITEM_H 1
/*
** tagitem.h for ACE Basic
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
** This are the StructPointer defines for tagitem.h
*/
#ifndef TagItemPtr
#define TagItemPtr ADDRESS
#endif
/*
** End of StructPointer defines for tagitem.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif


/*****************************************************************************/


/* Tags are a general mechanism of extensible data arrays for parameter
 * specification and property inquiry. In practice,  tags are used in arrays, 
 * or chain of arrays.
 *
 */

STRUCT TagItem
 
    LONGINT ti_Tag    /* identifies the TYPE of DATA */
    LONGINT ti_Data   /* type-specific data          */
END STRUCT 

/* constants for Tag.ti_Tag,  control tag values */
#define TAG_DONE   (0&)   /* terminates array of TagItems. ti_Data unused */
#define TAG_END    (0&)   /* synonym FOR TAG_DONE             */
#define TAG_IGNORE (1&)   /* ignore this item,  NOT END of array       */
#define TAG_MORE   (2&)   /* ti_Data is pointer TO another array of TagItems
               * note that this tag terminates the current array
               */
#define TAG_SKIP   (3&)   /* skip this AND the NEXT ti_Data items     */

/* differentiates user tags from control tags */
#define TAG_USER   (-2147483648&)

/* If the TAG_USER bit is set in a tag number,  it tells utility.library that
 * the tag is not a control tag (like TAG_DONE,  TAG_IGNORE,  TAG_MORE) and is
 * instead an application tag. "USER" means a client of utility.library in
 * general,  including system code like Intuition or ASL,  it has nothing to do
 * with user code.
 */


/*****************************************************************************/


/* Tag filter logic specifiers for use with FilterTagItems() */
#define TAGFILTER_AND 0     /* exclude everything but filter hits   */
#define TAGFILTER_NOT 1     /* exclude only filter hits     */


/*****************************************************************************/


/* Mapping types for use with MapTags() */
#define MAP_REMOVE_NOT_FOUND 0  /* remove tags that aren't in mapList */
#define MAP_KEEP_NOT_FOUND   1  /* keep tags that aren't in mapList   */


/*****************************************************************************/


#endif /* UTILITY_TAGITEM_H */
