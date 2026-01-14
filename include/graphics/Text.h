#ifndef GRAPHICS_TEXT_H
#define GRAPHICS_TEXT_H 1
/*
** text.h for ACE Basic
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
** This are the StructPointer defines for text.h
*/
#ifndef ColorFontColorsPtr
#define ColorFontColorsPtr ADDRESS
#endif
#ifndef ColorTextFontPtr
#define ColorTextFontPtr ADDRESS
#endif
#ifndef TTextAttrPtr
#define TTextAttrPtr ADDRESS
#endif
#ifndef TextAttrPtr
#define TextAttrPtr ADDRESS
#endif
#ifndef TextExtentPtr
#define TextExtentPtr ADDRESS
#endif
#ifndef TextFontPtr
#define TextFontPtr ADDRESS
#endif
#ifndef TextFontExtensionPtr
#define TextFontExtensionPtr ADDRESS
#endif
/*
** End of StructPointer defines for text.h
*/



#ifndef EXEC_PORTS_H
#include    <exec/ports.h>
#endif  /* EXEC_PORTS_H */

#ifndef GRAPHICS_GFX_H
#include    <graphics/gfx.h>
#endif  /* GRAPHICS_GFX_H */

#ifndef UTILITY_TAGITEM_H
#include    <utility/tagitem.h>
#endif  /* UTILITY_TAGITEM_H */

/*------ Font Styles ------------------------------------------------*/
#define FS_NORMAL   0   /* normal text (no style bits set) */
#define FSB_UNDERLINED  0   /* underlined (under baseline) */
#define FSF_UNDERLINED  &H01
#define FSB_BOLD    1   /* bold face text (ORed w/ shifted) */
#define FSF_BOLD    &H02
#define FSB_ITALIC  2   /* italic (slanted 1:2 right) */
#define FSF_ITALIC  &H04
#define FSB_EXTENDED    3   /* extended face (wider than normal) */
#define FSF_EXTENDED    &H08

#define FSB_COLORFONT   6   /* this uses ColorTextFont structure */
#define FSF_COLORFONT   &H40
#define FSB_TAGGED  7   /* the TextAttr is really an TTextAttr,  */
#define FSF_TAGGED  &H80

/*------ Font Flags -------------------------------------------------*/
#define FPB_ROMFONT 0   /* font is in rom */
#define FPF_ROMFONT &H01
#define FPB_DISKFONT    1   /* font is from diskfont.library */
#define FPF_DISKFONT    &H02
#define FPB_REVPATH 2   /* designed path is reversed (e.g. left) */
#define FPF_REVPATH &H04
#define FPB_TALLDOT 3   /* designed for hires non-interlaced */
#define FPF_TALLDOT &H08
#define FPB_WIDEDOT 4   /* designed for lores interlaced */
#define FPF_WIDEDOT &H10
#define FPB_PROPORTIONAL 5  /* character sizes can vary from nominal */
#define FPF_PROPORTIONAL &H20
#define FPB_DESIGNED    6   /* size explicitly designed,  not constructed */
                /* note: if you do not set this bit in your */
                /* textattr,  then a font may be constructed */
                /* for you by scaling an existing rom or disk */
                /* font (under V36 and above). */
#define FPF_DESIGNED    &H40
    /* bit 7 is always clear for fonts on the graphics font list */
#define FPB_REMOVED 7   /* the font has been removed */
#define FPF_REMOVED (128)

/****** TextAttr node,  matches text attributes in RastPort **********/
STRUCT TextAttr  
    ADDRESS  ta_Name         /* name of the font */
    SHORTINT   ta_YSize        /* height of the font */
    BYTE    ta_Style        /* intrinsic font style */
    BYTE    ta_Flags        /* font preferences and flags */
END STRUCT 

STRUCT TTextAttr  
    ADDRESS  tta_Name        /* name of the font */
    SHORTINT   tta_YSize       /* height of the font */
    BYTE    tta_Style       /* intrinsic font style */
    BYTE    tta_Flags       /* font preferences and flags */
    TagItemPtr  tta_Tags    /* extended attributes */
END STRUCT 


/****** Text Tags ***************************************************/
#define TA_DeviceDPI    (1 OR TAG_USER)    /* Tag value is Point union: */
                    /* Hi SHORTINT XDPI,  Lo SHORTINT YDPI */

#define MAXFONTMATCHWEIGHT  32767   /* perfect match from WeighTAMatch */


/****** TextFonts node **********************************************/
STRUCT TextFont  
    _Message tf_Message   /* reply message for font removal */
                /* font name in LN    \    used in this */
    SHORTINT   tf_YSize        /* font height        OR    order to best */
    BYTE    tf_Style        /* font style         OR    match a font */
    BYTE    tf_Flags        /* preferences and flags  /    request. */
    SHORTINT   tf_XSize        /* nominal font width */
    SHORTINT   tf_Baseline     /* distance from the top of BYTE to baseline */
    SHORTINT   tf_BoldSmear    /* smear to affect a bold enhancement */

    SHORTINT   tf_Accessors    /* access count */

    BYTE    tf_LoChar       /* the first character described here */
    BYTE    tf_HiChar       /* the last character described here */
    ADDRESS    tf_CharData     /* the bit character data */

    SHORTINT   tf_Modulo       /* the row modulo for the strike font data */
    ADDRESS    tf_CharLoc      /* ptr to location data for the strike font */
                /*   2 words: bit offset then size */
    ADDRESS    tf_CharSpace    /* ptr to words of proportional spacing data */
    ADDRESS    tf_CharKern     /* ptr to words of kerning data */
END STRUCT 

/* unfortunately,  this needs to be explicitly typed */
#define tf_Extension    tf_Message.mn_ReplyPort

/*----- tfe_Flags0 (partial definition) ----------------------------*/
#define TE0B_NOREMFONT  0   /* disallow RemFont for this font */
#define TE0F_NOREMFONT  &H01

STRUCT TextFontExtension    /* this structure is read-only */
    SHORTINT   tfe_MatchWord       /* a magic cookie for the extension */
    BYTE    tfe_Flags0          /* (system private flags) */
    BYTE    tfe_Flags1          /* (system private flags) */
    TextFontPtr  tfe_BackPtr    /* validation of compilation */
    MsgPortPtr  tfe_OrigReplyPort   /* original value in tf_Extension */
    TagItemPtr  tfe_Tags        /* Text Tags for the font */
    ADDRESS   tfe_OFontPatchS         /* (system private use) */
    ADDRESS   tfe_OFontPatchK         /* (system private use) */
    /* this space is reserved for future expansion */
END STRUCT 

/****** ColorTextFont node ******************************************/
/*----- ctf_Flags --------------------------------------------------*/
#define CT_COLORMASK    &H000F  /* mask to get to following color styles */
#define CT_COLORFONT    &H0001  /* color map contains designer's colors */
#define CT_GREYFONT &H0002  /* color map describes even-stepped */
                /* brightnesses from low to high */
#define CT_ANTIALIAS    &H0004  /* zero background thru fully saturated BYTE */

#define CTB_MAPCOLOR    0   /* map ctf_FgColor to the rp_FgPen if it's */
#define CTF_MAPCOLOR    &H0001  /* is a valid color within ctf_Low..ctf_High */

/*----- ColorFontColors --------------------------------------------*/
STRUCT ColorFontColors  
    SHORTINT   cfc_Reserved    /* *must* be zero */
    SHORTINT   cfc_Count       /* number of entries in cfc_ColorTable */
    ADDRESS   cfc_ColorTable  /* 4 bit per component color map packed xRGB */
END STRUCT 

/*----- ColorTextFont ----------------------------------------------*/
STRUCT ColorTextFont  
    TextFont ctf_TF 
    SHORTINT   ctf_Flags       /* extended flags */
    BYTE    ctf_Depth       /* number of bit planes */
    BYTE    ctf_FgColor     /* color that is remapped to FgPen */
    BYTE    ctf_Low         /* lowest color represented here */
    BYTE    ctf_High        /* highest color represented here */
    BYTE    ctf_PlanePick   /* PlanePick ala Images */
    BYTE    ctf_PlaneOnOff  /* PlaneOnOff ala Images */
    ColorFontColorsPtr  ctf_ColorFontColors  /* colors for font */
    STRING ctf_CharData SIZE 32  /*  8*SIZEOF(ADDRESS) */    /*pointers TO bit planes ala tf_CharData */
END STRUCT 

/****** TextExtent node *********************************************/
STRUCT TextExtent  
    SHORTINT   te_Width        /* same as TextLength */
    SHORTINT   te_Height       /* same as tf_YSize */
    Rectangle te_Extent  /* relative to CP */
END STRUCT 

#endif  /* GRAPHICS_TEXT_H */
