#ifndef LIBRARIES_LOCALE_H
#define LIBRARIES_LOCALE_H
/*
** locale.h for ACE Basic
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
** This are the StructPointer defines for locale.h
*/
#ifndef CatalogPtr
#define CatalogPtr ADDRESS
#endif
#ifndef LocalePtr
#define LocalePtr ADDRESS
#endif
#ifndef LocaleBasePtr
#define LocaleBasePtr ADDRESS
#endif
/*
** End of StructPointer defines for locale.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif


/*****************************************************************************/


/* constants for GetLocaleStr() */
#define DAY_1       1   /* Sunday    */
#define DAY_2       2   /* Monday    */
#define DAY_3       3   /* Tuesday   */
#define DAY_4       4   /* Wednesday */
#define DAY_5       5   /* Thursday  */
#define DAY_6       6   /* Friday    */
#define DAY_7       7   /* Saturday  */

#define ABDAY_1 8   /* Sun */
#define ABDAY_2 9   /* Mon */
#define ABDAY_3 10  /* Tue */
#define ABDAY_4 11  /* Wed */
#define ABDAY_5 12  /* Thu */
#define ABDAY_6 13  /* Fri */
#define ABDAY_7 14  /* Sat */

#define MON_1       15  /* January   */
#define MON_2       16  /* February  */
#define MON_3       17  /* March     */
#define MON_4       18  /* April     */
#define MON_5       19  /* May       */
#define MON_6       20  /* June      */
#define MON_7       21  /* July      */
#define MON_8       22  /* August    */
#define MON_9       23  /* September */
#define MON_10      24  /* October   */
#define MON_11      25  /* November  */
#define MON_12      26  /* December  */

#define ABMON_1 27  /* Jan */
#define ABMON_2 28  /* Feb */
#define ABMON_3 29  /* Mar */
#define ABMON_4 30  /* Apr */
#define ABMON_5 31  /* May */
#define ABMON_6 32  /* Jun */
#define ABMON_7 33  /* Jul */
#define ABMON_8 34  /* Aug */
#define ABMON_9 35  /* Sep */
#define ABMON_10    36  /* Oct */
#define ABMON_11    37  /* Nov */
#define ABMON_12    38  /* Dec */

#define YESSTR      39  /* affirmative response for yes/no queries */
#define NOSTR       40  /* negative response for yes/no queries    */

#define AM_STR      41  /* AM */
#define PM_STR      42  /* PM */

#define SOFTHYPHEN  43  /* soft hyphenation */
#define HARDHYPHEN  44  /* hard hyphenation */

#define OPENQUOTE   45  /* start of quoted block */
#define CLOSEQUOTE  46  /* end of quoted block   */

#define YESTERDAYSTR    47  /* Yesterday */
#define TODAYSTR    48  /* Today     */
#define TOMORROWSTR 49  /* Tomorrow  */
#define FUTURESTR   50  /* Future    */

#define MAXSTRMSG   51  /* current number of defined strings */


/*****************************************************************************/


/* OpenLibrary("locale.library", 0) returns a pointer to this structure */
STRUCT LocaleBase
 
    _Library lb_LibNode 
    SHORTINT       lb_SysPatches    /* TRUE if locale installed its patches */
END STRUCT 


/*****************************************************************************/


/* This structure must only be allocated by locale.library and is READ-ONLY! */
STRUCT Locale
 
    ADDRESS  loc_LocaleName        /* locale's name           */
    ADDRESS  loc_LanguageName          /* language of this locale     */
    STRING loc_PrefLanguages SIZE 40  /* 10*SIZEOF(ADDRESS) */    /* preferred languages         */
    LONGINT   loc_Flags             /* always 0 for now        */

    LONGINT   loc_CodeSet           /* always 0 for now        */
    LONGINT   loc_CountryCode           /* user's country code         */
    LONGINT   loc_TelephoneCode         /* country's telephone code    */
    LONGINT    loc_GMTOffset         /* minutes from GMT        */
    BYTE    loc_MeasuringSystem       /* what measuring system?      */
    BYTE    loc_CalendarType          /* what calendar type?         */
    STRING loc_Reserved0 SIZE 2  

    ADDRESS  loc_DateTimeFormat        /* regular date & time format  */
    ADDRESS  loc_DateFormat        /* date format by itself       */
    ADDRESS  loc_TimeFormat        /* time format by itself       */

    ADDRESS  loc_ShortDateTimeFormat   /* SHORTINT date & time format    */
    ADDRESS  loc_ShortDateFormat       /* SHORTINT date format by itself */
    ADDRESS  loc_ShortTimeFormat       /* SHORTINT time format by itself */

    /* for numeric values */
    ADDRESS  loc_DecimalPoint          /* character before the decimals */
    ADDRESS  loc_GroupSeparator        /* separates groups of digits    */
    ADDRESS  loc_FracGroupSeparator    /* separates groups of digits    */
    ADDRESS   loc_Grouping          /* size of each group        */
    ADDRESS   loc_FracGrouping          /* size of each group        */

    /* for monetary values */
    ADDRESS  loc_MonDecimalPoint 
    ADDRESS  loc_MonGroupSeparator 
    ADDRESS  loc_MonFracGroupSeparator 
    ADDRESS   loc_MonGrouping 
    ADDRESS   loc_MonFracGrouping 
    BYTE    loc_MonFracDigits         /* digits after the decimal point   */
    BYTE    loc_MonIntFracDigits      /* for international representation */
    STRING loc_Reserved1 SIZE 2  

    /* for currency symbols */
    ADDRESS  loc_MonCS             /* currency symbol          */
    ADDRESS  loc_MonSmallCS        /* symbol for small amounts     */
    ADDRESS  loc_MonIntCS          /* internationl (ISO 4217) code */

    /* for positive monetary values */
    ADDRESS  loc_MonPositiveSign       /* indicate positive money value   */
    BYTE    loc_MonPositiveSpaceSep   /* determine if separated by space */
    BYTE    loc_MonPositiveSignPos    /* position of positive sign   */
    BYTE    loc_MonPositiveCSPos      /* position of currency symbol     */
    BYTE    loc_Reserved2 

    /* for negative monetary values */
    ADDRESS  loc_MonNegativeSign       /* indicate negative money value   */
    BYTE    loc_MonNegativeSpaceSep   /* determine if separated by space */
    BYTE    loc_MonNegativeSignPos    /* position of negative sign   */
    BYTE    loc_MonNegativeCSPos      /* position of currency symbol     */
    BYTE    loc_Reserved3 
END STRUCT 

/* constants for Locale.loc_MeasuringSystem */
#define MS_ISO      0   /* international metric system */
#define MS_AMERICAN 1   /* american system         */
#define MS_IMPERIAL 2   /* imperial system         */
#define MS_BRITISH  3   /* british system          */

/* constants for Locale.loc_CalendarType */
#define CT_7SUN 0   /* 7 days a week,  Sunday is the first day    */
#define CT_7MON 1   /* 7 days a week,  Monday is the first day    */
#define CT_7TUE 2   /* 7 days a week,  Tuesday is the first day   */
#define CT_7WED 3   /* 7 days a week,  Wednesday is the first day */
#define CT_7THU 4   /* 7 days a week,  Thursday is the first day  */
#define CT_7FRI 5   /* 7 days a week,  Friday is the first day    */
#define CT_7SAT 6   /* 7 days a week,  Saturday is the first day  */

/* constants for Locale.loc_MonPositiveSpaceSep and Locale.loc_MonNegativeSpaceSep */
#define SS_NOSPACE 0  /* cur. symbol is NOT separated from value with a space */
#define SS_SPACE   1  /* cur. symbol IS separated from value with a space     */

/* constants for Locale.loc_MonPositiveSignPos and Locale.loc_MonNegativeSignPos */
#define SP_PARENS    0  /* () surround the quantity and currency_symbol   */
#define SP_PREC_ALL  1  /* sign string comes before amount and symbol     */
#define SP_SUCC_ALL  2  /* sign string comes after amount and symbol      */
#define SP_PREC_CURR 3  /* sign string comes right before currency symbol */
#define SP_SUCC_CURR 4  /* sign string comes right after currency symbol  */

/* constants for Locale.loc_MonPositiveCSPos and Locale.loc_MonNegativeCSPos */
#define CSP_PRECEDES 0  /* currency symbol comes before value */
#define CSP_SUCCEEDS 1  /* currency symbol comes after value  */

/* elements of the byte arrays pointed to by:
 *   Locale.loc_Grouping
 *   Locale.loc_FracGrouping
 *   Locale.loc_MonGrouping
 *   Locale.loc_MonFracGrouping
 * are interpreted as follows:
 *
 *    255     indicates that no further grouping is to be performed
 *    0       indicates that the previous element is to be repeatedly used
 *        for the remainder of the digits
 *    <other> the number of digits that comprises the current group
 */


/*****************************************************************************/


/* Tags for OpenCatalog() */
#define OC_TagBase     (TAG_USER + &H90000)
#define OC_BuiltInLanguage OC_TagBase+1   /* language of built-in strings    */
#define OC_BuiltInCodeSet  OC_TagBase+2   /* code set of built-in strings    */
#define OC_Version     OC_TagBase+3   /* catalog version number required */
#define OC_Language    OC_TagBase+4   /* preferred language of catalog   */


/*****************************************************************************/


/* Comparison types for StrnCmp() */
#define SC_ASCII    0
#define SC_COLLATE1 1
#define SC_COLLATE2 2


/*****************************************************************************/


/* This structure must only be allocated by locale.library and is READ-ONLY! */
STRUCT Catalog
 
    Node cat_Link    /* for internal linkage    */
    SHORTINT   cat_Pad     /* to longword align       */
    ADDRESS  cat_Language    /* language of the catalog */
    LONGINT   cat_CodeSet     /* currently always 0      */
    SHORTINT   cat_Version     /* version of the catalog  */
    SHORTINT   cat_Revision    /* revision of the catalog */
END STRUCT 


/*****************************************************************************/


#endif  /* LIBRARIES_LOCALE_H */
