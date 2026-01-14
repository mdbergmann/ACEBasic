#ifndef DOS_DATETIME_H
#define DOS_DATETIME_H 1
/*
** datetime.h for ACE Basic
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
** This are the StructPointer defines for datetime.h
*/
#ifndef DateTimePtr
#define DateTimePtr ADDRESS
#endif
/*
** End of StructPointer defines for datetime.h
*/        

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif


/*
 *  Data structures and equates used by the V1.4 DOS functions
 * StrtoDate() and DatetoStr()
 */

/*--------- String/Date structures etc */
STRUCT DateTime  
    DateStamp dat_Stamp  /* DOS DateStamp */
    BYTE    dat_Format      /* controls appearance of dat_StrDate */
    BYTE    dat_Flags       /* see BITDEF's below */
    ADDRESS   dat_StrDay         /* day of the week string */
    ADDRESS   dat_StrDate        /* date string */
    ADDRESS   dat_StrTime        /* time string */
END STRUCT 

/* You need this much room for each of the DateTime strings: */
#define LEN_DATSTRING   16

/*  flags for dat_Flags */

#define DTB_SUBST   0       /* substitute Today,  Tomorrow,  etc. */
#define DTF_SUBST   1
#define DTB_FUTURE  1       /* day of the week is in future */
#define DTF_FUTURE  2

/*
 *  date format values
 */

#define FORMAT_DOS  0       /* dd-mmm-yy */
#define FORMAT_INT  1       /* yy-mm-dd  */
#define FORMAT_USA  2       /* mm-dd-yy  */
#define FORMAT_CDN  3       /* dd-mm-yy  */
#define FORMAT_MAX  FORMAT_CDN

#endif /* DOS_DATETIME_H */
