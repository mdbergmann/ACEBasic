#ifndef DOS_RECORD_H
#define DOS_RECORD_H 1
/*
** record.h for ACE Basic
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
** This are the StructPointer defines for record.h
*/
#ifndef RecordLockPtr
#define RecordLockPtr ADDRESS
#endif
/*
** End of StructPointer defines for record.h
*/
    
#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif


/* Modes for LockRecord/LockRecords() */
#define REC_EXCLUSIVE       0
#define REC_EXCLUSIVE_IMMED 1
#define REC_SHARED      2
#define REC_SHARED_IMMED    3

/* STRUCT to be passed to LockRecords()/UnLockRecords() */

STRUCT RecordLock  
    ADDRESS    rec_FH      /* filehandle */
    LONGINT   rec_Offset  /* offset in file */
    LONGINT   rec_Length  /* length of file to be locked */
    LONGINT   rec_Mode    /* Type of lock */
END STRUCT 

#endif /* DOS_RECORD_H */
