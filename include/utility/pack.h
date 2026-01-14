#ifndef UTILITY_PACK_H
#define UTILITY_PACK_H 1
/*
** pack.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif


/*****************************************************************************/


/* PackTable definition:
 *
 * The PackTable is a simple array of LONGWORDS that are evaluated by
 * PackStructureTags() and UnpackStructureTags().
 *
 * The table contains compressed information such as the tag offset from
 * the base tag. The tag offset has a limited range so the base tag is
 * defined in the first longword.
 *
 * After the first longword,  the fields look as follows:
 *
 *  +--------- 1 = signed,  0 = unsigned (for bits,  1=inverted boolean)
 *  |
 *  OR  +------ 00 = Pack/Unpack,  10 = Pack,  01 = Unpack,  11 = special
 *  OR / \
 *  OR | OR  +-- 00 = Byte,  01 = SHORTINT,  10 = LONGINT,  11 = Bit
 *  OR | OR / \
 *  OR | OR | OR /----- For bit operations: 1 = TAG_EXISTS is TRUE
 *  OR | OR | OR |
 *  OR | OR | OR | /-------------------- Tag offset from base tag value
 *  OR | OR | OR | OR             \
 *  m n n o o p q q q q q q q q q q r r r s s s s s s s s s s s s s
 *                  \   OR |           |
 *  Bit offset (for bit operations) ----/ OR           |
 *                        \               |
 *  Offset into data structure -----------------------------------/
 *
 * A -1 longword signifies that the next longword will be a new base tag
 *
 * A 0 longword signifies that it is the end of the pack table.
 *
 * What this implies is that there are only 13-bits of address offset
 * and 10 bits for tag offsets from the base tag.  For most uses this
 * should be enough,  but when this is not,  either multiple pack tables
 * or a pack table with extra base tags would be able to do the trick.
 * The goal here was to make the tables small and yet flexible enough to
 * handle most cases.
 */

#define PSTB_SIGNED 31
#define PSTB_UNPACK 30    /* Note that these are active low... */
#define PSTB_PACK   29    /* Note that these are active low... */
#define PSTB_EXISTS 26    /* Tag exists bit true flag hack...  */

#define PSTF_SIGNED (2147483648&)
#define PSTF_UNPACK (1073741824&)
#define PSTF_PACK   (536870912&)

#define PSTF_EXISTS (67108864&)


/*****************************************************************************/


#define PKCTRL_PACKUNPACK &H00000000
#define PKCTRL_PACKONLY   &H40000000
#define PKCTRL_UNPACKONLY &H20000000

#define PKCTRL_BYTE   &H80000000
#define PKCTRL_WORD   &H88000000
#define PKCTRL_LONG   &H90000000

#define PKCTRL_UBYTE      &H00000000
#define PKCTRL_UWORD      &H08000000
#define PKCTRL_ULONG      &H10000000

#define PKCTRL_BIT    &H18000000
#define PKCTRL_FLIPBIT    &H98000000


/*****************************************************************************/


/* Macros used by the next batch of macros below. Normally,  you don't use
 * this batch directly. Then again,  some folks are wierd
 */
/*
#define PK_BITNUM1(flg) ((flg) == &H01 ? 0 : (flg) == &H02 ? 1 : (flg) == &H04 ? 2 : (flg) == &H08 ? 3 : (flg) == &H10 ? 4 : (flg) == &H20 ? 5 : (flg) == &H40 ? 6 : 7)
#define PK_BITNUM2(flg) ((flg < &H100 ? PK_BITNUM1(flg) : 8+PK_BITNUM1(flg >> 8)))
#define PK_BITNUM(flg) ((flg < &H10000 ? PK_BITNUM2(flg) : 16+PK_BITNUM2(flg >> 16)))
#define PK_WORDOFFSET(flg) ((flg) < &H100 ? 1 : 0)
#define PK_LONGOFFSET(flg) ((flg) < &H100  ? 3 : (flg) < &H10000 ? 2 : (flg) < &H1000000 ? 1 : 0)
#define PK_CALCOFFSET(type, field) ((LONGINT)(&((STRUCT type *)0)->field))
*/

/*****************************************************************************/


/* Some handy dandy macros to easily create pack tables
 *
 * Use PACK_STARTTABLE() at the start of a pack table. You pass it the
 * base tag value that will be handled in the following chunk of the pack
 * table.
 *
 * PACK_ENDTABLE() is used to mark the end of a pack table.
 *
 * PACK_NEWOFFSET() lets you change the base tag value used for subsequent
 * entries in the table
 *
 * PACK_ENTRY() lets you define an entry in the pack table. You pass it the
 * base tag value,  the tag of interest,  the type of the structure to use, 
 * the field name in the structure to affect and control bits (combinations of
 * the various PKCTRL_XXX bits)
 *
 * PACK_BYTEBIT() lets you define a bit-control entry in the pack table. You
 * pass it the same data as PACK_ENTRY,  plus the flag bit pattern this tag
 * affects. This macro should be used when the field being affected is byte
 * sized.
 *
 * PACK_WORDBIT() lets you define a bit-control entry in the pack table. You
 * pass it the same data as PACK_ENTRY,  plus the flag bit pattern this tag
 * affects. This macro should be used when the field being affected is SHORTINT
 * sized.
 *
 * PACK_LONGBIT() lets you define a bit-control entry in the pack table. You
 * pass it the same data as PACK_ENTRY,  plus the flag bit pattern this tag
 * affects. This macro should be used when the field being affected is longword
 * sized.
 *
 * EXAMPLE:
 *
 *    LONGINT packTable[] =
 *     
 *     PACK_STARTTABLE(GA_Dummy), 
 *     PACK_ENTRY(GA_Dummy, GA_Left, Gadget, LeftEdge, PKCTRL_WORD|PKCTRL_PACKUNPACK), 
 *     PACK_ENTRY(GA_Dummy, GA_Top, Gadget, TopEdge, PKCTRL_WORD|PKCTRL_PACKUNPACK), 
 *     PACK_ENTRY(GA_Dummy, GA_Width, Gadget, Width, PKCTRL_UWORD|PKCTRL_PACKUNPACK), 
 *     PACK_ENTRY(GA_Dummy, GA_Height, Gadget, Height, PKCTRL_UWORD|PKCTRL_PACKUNPACK), 
 *     PACK_WORDBIT(GA_Dummy, GA_RelVerify, Gadget, Activation, PKCTRL_BIT|PKCTRL_PACKUNPACK, GACT_RELVERIFY)
 *     PACK_ENDTABLE
 *    END STRUCT 
 */
/*
#define PACK_STARTTABLE(tagbase)               (tagbase)
#define PACK_NEWOFFSET(tagbase)            (-1L), (tagbase)
#define PACK_ENDTABLE                      0
#define PACK_ENTRY(67108864&)     (control OR ((tag-tagbase) << 16L) OR PK_CALCOFFSET(type, field))
#define PACK_BYTEBIT(67108864&) (control OR ((tag-tagbase) << 16L) OR PK_CALCOFFSET(type, field) OR (PK_BITNUM(flags) << 13L))
#define PACK_WORDBIT(67108864&) (control OR ((tag-tagbase) << 16L) OR (PK_CALCOFFSET(type, field)+PK_WORDOFFSET(flags)) OR ((PK_BITNUM(flags)&7) << 13L))
#define PACK_LONGBIT(67108864) (control OR ((tag-tagbase) << 16L) OR (PK_CALCOFFSET(type, field)+PK_LONGOFFSET(flags)) OR ((PK_BITNUM(flags)&7) << 13L))
*/

/*****************************************************************************/


#endif /* UTILITY_PACK_H */
