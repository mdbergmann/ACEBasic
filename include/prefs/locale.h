#ifndef PREFS_LOCALE_H
#define PREFS_LOCALE_H 1
/*
** locale.h for ACE Basic
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
** This are the StructPointer defines for locale.h
*/
#ifndef CountryPrefsPtr
#define CountryPrefsPtr ADDRESS
#endif
#ifndef LocalePrefsPtr
#define LocalePrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for locale.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_LCLE 1279478853 
#define ID_CTRY 1129599577 


STRUCT CountryPrefs
 
    STRING cp_Reserved SIZE 16  /* 4*SIZEOF(LONGINT)  */
    LONGINT cp_CountryCode 
    LONGINT cp_TelephoneCode 
    BYTE  cp_MeasuringSystem 

    STRING cp_DateTimeFormat SIZE 80  
    STRING cp_DateFormat SIZE 40  
    STRING cp_TimeFormat SIZE 40  

    STRING cp_ShortDateTimeFormat SIZE 80  
    STRING cp_ShortDateFormat SIZE 40  
    STRING cp_ShortTimeFormat SIZE 40  

    /* for numeric values */
    STRING cp_DecimalPoint SIZE 10  
    STRING cp_GroupSeparator SIZE 10  
    STRING cp_FracGroupSeparator SIZE 10  
    STRING cp_Grouping SIZE 10  
    STRING cp_FracGrouping SIZE 10  

    /* for monetary values */
    STRING cp_MonDecimalPoint SIZE 10  
    STRING cp_MonGroupSeparator SIZE 10  
    STRING cp_MonFracGroupSeparator SIZE 10  
    STRING cp_MonGrouping SIZE 10  
    STRING cp_MonFracGrouping SIZE 10  
    BYTE  cp_MonFracDigits 
    BYTE  cp_MonIntFracDigits 

    /* for currency symbols */
    STRING cp_MonCS SIZE 10  
    STRING cp_MonSmallCS SIZE 10  
    STRING cp_MonIntCS SIZE 10  

    /* for positive monetary values */
    STRING cp_MonPositiveSign SIZE 10  
    BYTE  cp_MonPositiveSpaceSep 
    BYTE  cp_MonPositiveSignPos 
    BYTE  cp_MonPositiveCSPos 

    /* for negative monetary values */
    STRING cp_MonNegativeSign SIZE 10  
    BYTE  cp_MonNegativeSpaceSep 
    BYTE  cp_MonNegativeSignPos 
    BYTE  cp_MonNegativeCSPos 

    BYTE  cp_CalendarType 
END STRUCT 


STRUCT LocalePrefs
 
    STRING lp_Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */
    STRING lp_CountryName SIZE 32  
    STRING lp_PreferredLanguages SIZE 300
    LONGINT        lp_GMTOffset 
    LONGINT       lp_Flags 
    CountryPrefs lp_CountryData 
END STRUCT 


/*****************************************************************************/


#endif /* PREFS_LOCALE_H */
