#ifndef DATATYPES_TEXTCLASS_H
#define DATATYPES_TEXTCLASS_H 1
/*
** textclass.h for ACE Basic
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
** This are the StructPointer defines for textclass.h
*/
#ifndef LinePtr
#define LinePtr ADDRESS
#endif
/*
** End of StructPointer defines for textclass.h
*/
        
#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef DATATYPES_DATATYPESCLASS_H
#include <datatypes/datatypesclass.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif



/*****************************************************************************/

#define TEXTDTCLASS     "text.datatype"

/*****************************************************************************/

/* Text attributes */
#define TDTA_Buffer     (DTA_Dummy + 300)
#define TDTA_BufferLen      (DTA_Dummy + 301)
#define TDTA_LineList       (DTA_Dummy + 302)
#define TDTA_WordSelect     (DTA_Dummy + 303)
#define TDTA_WordDelim      (DTA_Dummy + 304)
#define TDTA_WordWrap       (DTA_Dummy + 305)
     /* Boolean. Should the text be SHORTINT wrapped.  Defaults to false. */

/*****************************************************************************/

/* There is one Line structure for every line of text in our document.  */
STRUCT _Line
 
    MinNode ln_Link        /* to link the lines together */
    ADDRESS       ln_Text        /* pointer to the text for this line */
    LONGINT        ln_TextLen         /* the character length of the text for this line */
    SHORTINT        ln_XOffset         /* where in the line the text starts */
    SHORTINT        ln_YOffset         /* line the text is on */
    SHORTINT        ln_Width       /* Width of line in pixels */
    SHORTINT        ln_Height      /* Height of line in pixels */
    SHORTINT        ln_Flags       /* info on the line */
    BYTE         ln_FgPen       /* foreground pen */
    BYTE         ln_BgPen       /* background pen */
    LONGINT        ln_Style       /* Font style */
    ADDRESS         ln_Data        /* Link data... */
END STRUCT 

/*****************************************************************************/

/* Line.ln_Flags */

/* Line Feed */
#define LNF_LF      (1&)

/* Segment is a link */
#define LNF_LINK    (2&)

/* ln_Data is a pointer to an DataTypes object */
#define LNF_OBJECT  (4&)

/* Object is selected */
#define LNF_SELECTED    (8)

/*****************************************************************************/

/* IFF types that may be text */
#define ID_FTXT     1179932756 
#define ID_CHRS     1128813139 

/*****************************************************************************/

#endif  /* DATATYPES_TEXTCLASS_H */
