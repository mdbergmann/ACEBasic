#ifndef DISKFONT_DISKFONT_H
#define DISKFONT_DISKFONT_H 1
/*
** diskfont.h for ACE Basic
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
** This are the StructPointer defines for diskfont.h
*/
#ifndef AvailFontsPtr
#define AvailFontsPtr ADDRESS
#endif
#ifndef AvailFontsHeaderPtr
#define AvailFontsHeaderPtr ADDRESS
#endif
#ifndef DiskFontHeaderPtr
#define DiskFontHeaderPtr ADDRESS
#endif
#ifndef FontContentsPtr
#define FontContentsPtr ADDRESS
#endif
#ifndef FontContentsHeaderPtr
#define FontContentsHeaderPtr ADDRESS
#endif
#ifndef TAvailFontsPtr
#define TAvailFontsPtr ADDRESS
#endif
#ifndef TFontContentsPtr
#define TFontContentsPtr ADDRESS
#endif
/*
** End of StructPointer defines for diskfont.h
*/
                 
#ifndef     EXEC_NODES_H
#include <exec/nodes.h>
#endif
#ifndef     EXEC_LISTS_H
#include <exec/lists.h>
#endif
#ifndef     GRAPHICS_TEXT_H
#include <graphics/text.h>
#endif


#define     MAXFONTPATH 256   /* including null terminator */

STRUCT FontContents  
    STRING fc_FileName SIZE 256  /* MAXFONTPATH */
    SHORTINT   fc_YSize 
    BYTE    fc_Style 
    BYTE    fc_Flags 
END STRUCT 

STRUCT TFontContents  
    STRING tfc_FileName SIZE 254  /* MAXFONTPATH-2 */
    SHORTINT   tfc_TagCount    /* including the TAG_DONE tag */
    /*
     *  if tfc_TagCount is non-zero,  tfc_FileName is overlayed with
     *  Text Tags starting at:  (STRUCT TagItem *)
     *      &tfc_FileName[MAXFONTPATH-(tfc_TagCount*sizeof(STRUCT TagItem))]
     */
    SHORTINT   tfc_YSize 
    BYTE    tfc_Style 
    BYTE    tfc_Flags 
END STRUCT 


#define  FCH_ID     &H0f00  /* FontContentsHeader,  then FontContents */
#define  TFCH_ID    &H0f02  /* FontContentsHeader,  then TFontContents */
#define  OFCH_ID    &H0f03  /* FontContentsHeader,  then TFontContents, 
                 * associated with outline font */

STRUCT FontContentsHeader  
    SHORTINT   fch_FileID      /* FCH_ID */
    SHORTINT   fch_NumEntries  /* the number of FontContents elements */
    /* STRUCT FontContents fch_FC[],  or STRUCT TFontContents fch_TFC[]  */
END STRUCT 


#define  DFH_ID     &H0f80
#define  MAXFONTNAME    32  /* font name including ".font\0" */

STRUCT DiskFontHeader  
    /* the following 8 bytes are not actually considered a part of the  */
    /* DiskFontHeader,  but immediately preceed it. The NextSegment is   */
    /* supplied by the linker/loader,  and the ReturnCode is the code    */
    /* at the beginning of the font in case someone runs it...      */
    /*   LONGINT dfh_NextSegment          \* actually a ADDRESS  */
    /*   LONGINT dfh_ReturnCode           \* MOVEQ #0, D0 : RTS    */
    /* here then is the official start of the DiskFontHeader...     */
    Node dfh_DF      /* node to link disk fonts */
    SHORTINT   dfh_FileID      /* DFH_ID */
    SHORTINT   dfh_Revision    /* the font revision */
    LONGINT    dfh_Segment     /* the segment address when loaded */
    STRING dfh_Name SIZE 32  /* MAXFONTNAME */  /* the FONT NAME (NULL terminated) */
    TextFont dfh_TF  /* loaded TextFont structure */
END STRUCT 

/* unfortunately,  this needs to be explicitly typed */
/* used only if dfh_TF.tf_Style FSB_TAGGED bit is set */
#define dfh_TagList dfh_Segment /* destroyed during loading */


#define     AFB_MEMORY  0
#define     AFF_MEMORY  &H0001
#define     AFB_DISK    1
#define     AFF_DISK    &H0002
#define     AFB_SCALED  2
#define     AFF_SCALED  &H0004
#define     AFB_BITMAP  3
#define     AFF_BITMAP  &H0008

#define     AFB_TAGGED  16  /* return TAvailFonts */
#define     AFF_TAGGED  &H10000L

STRUCT AvailFonts  
    SHORTINT   af_Type         /* MEMORY,  DISK,  or SCALED */
    TextAttr af_Attr     /* text attributes for font */
END STRUCT 

STRUCT TAvailFonts  
    SHORTINT   taf_Type        /* MEMORY,  DISK,  or SCALED */
    TTextAttr taf_Attr   /* text attributes for font */
END STRUCT 

STRUCT AvailFontsHeader  
    SHORTINT   afh_NumEntries   /* number of AvailFonts elements */
    /* STRUCT AvailFonts afh_AF[],  or STRUCT TAvailFonts afh_TAF[]  */
END STRUCT 

#endif  /* DISKFONT_DISKFONT_H */
