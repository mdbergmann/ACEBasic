#ifndef DOS_DOSASL_H
#define DOS_DOSASL_H 1
/*
** dosasl.h for ACE Basic
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
** This are the StructPointer defines for dosasl.h
*/
#ifndef AChainPtr
#define AChainPtr ADDRESS
#endif
#ifndef AnchorPathPtr
#define AnchorPathPtr ADDRESS
#endif
/*
** End of StructPointer defines for dosasl.h
*/
      
#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif



/***********************************************************************
************************ PATTERN MATCHING ******************************
************************************************************************

* structure expected by MatchFirst,  MatchNext.
* Allocate this structure and initialize it as follows:
*
* Set ap_BreakBits to the signal bits (CDEF) that you want to take a
* break on,  or NULL,  if you don't want to convenience the user.
*
* If you want to have the FULL PATH NAME of the files you found, 
* allocate a buffer at the END of this structure,  and put the size of
* it into ap_Strlen.  If you don't want the full path name,  make sure
* you set ap_Strlen to zero.  In this case,  the name of the file,  and stats
* are available in the ap_Info,  as per usual.
*
* Then call MatchFirst() and then afterwards,  MatchNext() with this structure.
* You should check the return value each time (see below) and take the
* appropriate action,  ultimately calling MatchEnd() when there are
* no more files and you are done.  You can tell when you are done by
* checking for the normal AmigaDOS return code ERROR_NO_MORE_ENTRIES.
*
*/

STRUCT AnchorPath  
    AChainPtr  ap_Base    /* pointer to first anchor */
#define ap_First ap_Base
    AChainPtr  ap_Last    /* pointer to last anchor */
#define ap_Current ap_Last
    LONGINT    ap_BreakBits    /* Bits we want to break on */
    LONGINT    ap_FoundBreak   /* Bits we broke on. Also returns ERROR_BREAK */
    BYTE    ap_Flags    /* New use for extra word. */
    BYTE    ap_Reserved 
    SHORTINT    ap_Strlen   /* This is what ap_Length used to be */
#define ap_Length ap_Flags  /* Old compatability for LONGWORD ap_Length */
    FileInfoBlock ap_Info 
    STRING ap_Buf SIZE 1    /* Buffer for path name,  allocated by user */
    /* FIX! */
END STRUCT 


#define APB_DOWILD  0   /* User option ALL */
#define APF_DOWILD  1

#define APB_ITSWILD 1   /* Set by MatchFirst,  used by MatchNext  */
#define APF_ITSWILD 2   /* Application can test APB_ITSWILD,  too */
                /* (means that there's a wildcard    */
                /* in the pattern after calling      */
                /* MatchFirst).              */

#define APB_DODIR   2   /* Bit is SET if a DIR node should be */
#define APF_DODIR   4   /* entered. Application can RESET this */
                /* bit after MatchFirst/MatchNext to AVOID */
                /* entering a dir. */

#define APB_DIDDIR  3   /* Bit is SET for an "expired" dir node. */
#define APF_DIDDIR  8

#define APB_NOMEMERR    4   /* Set on memory error */
#define APF_NOMEMERR    16

#define APB_DODOT   5   /* If set,  allow conversion of '.' to */
#define APF_DODOT   32  /* CurrentDir */

#define APB_DirChanged  6   /* ap_Current->an_Lock changed */
#define APF_DirChanged  64  /* since last MatchNext call */

#define APB_FollowHLinks 7  /* follow hardlinks on DODIR - defaults   */
#define APF_FollowHLinks 128    /* to not following hardlinks on a DODIR. */


STRUCT AChain  
    AChainPtr  an_Child 
    AChainPtr  an_Parent 
    ADDRESS    an_Lock 
    FileInfoBlock an_Info 
    BYTE    an_Flags 
    STRING an_String SIZE 1     /* FIX!! */
END STRUCT 

#define DDB_PatternBit  0
#define DDF_PatternBit  1
#define DDB_ExaminedBit 1
#define DDF_ExaminedBit 2
#define DDB_Completed   2
#define DDF_Completed   4
#define DDB_AllBit  3
#define DDF_AllBit  8
#define DDB_Single  4
#define DDF_Single  16

/*
 * Constants used by wildcard routines,  these are the pre-parsed tokens
 * referred to by pattern match.  It is not necessary for you to do
 * anything about these,  MatchFirst() MatchNext() handle all these for you.
 */

#define P_ANY       &H80    /* Token for '*' or '#?  */
#define P_SINGLE    &H81    /* Token for '?' */
#define P_ORSTART   &H82    /* Token for '(' */
#define P_ORNEXT    &H83    /* Token for '|' */
#define P_OREND &H84    /* Token for ')' */
#define P_NOT       &H85    /* Token for '~' */
#define P_NOTEND    &H86    /* Token for */
#define P_NOTCLASS  &H87    /* Token for '^' */
#define P_CLASS &H88    /* Token for '[]' */
#define P_REPBEG    &H89    /* Token for '[' */
#define P_REPEND    &H8A    /* Token for ']' */
#define P_STOP      &H8B    /* token to force end of evaluation */

/* Values for an_Status,  NOTE: These are the actual bit numbers */

#define COMPLEX_BIT 1   /* Parsing complex pattern */
#define EXAMINE_BIT 2   /* Searching directory */

/*
 * Returns from MatchFirst(),  MatchNext()
 * You can also get dos error returns,  such as ERROR_NO_MORE_ENTRIES, 
 * these are in the dos.h file.
 */

#define ERROR_BUFFER_OVERFLOW   303 /* User or internal buffer overflow */
#define ERROR_BREAK     304 /* A break character was received */
#define ERROR_NOT_EXECUTABLE    305 /* A file has E bit cleared */

#endif /* DOS_DOSASL_H */
