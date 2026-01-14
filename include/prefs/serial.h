#ifndef PREFS_SERIAL_H
#define PREFS_SERIAL_H 1
/*
** serial.h for ACE Basic
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
** This are the StructPointer defines for serial.h
*/
#ifndef SerialPrefsPtr
#define SerialPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for serial.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_SERL 1397051980 


STRUCT SerialPrefs
 
    STRING sp_Reserved SIZE 12  /* 3*SIZEOF(LONGINT) */       /* SYSTEM reserved          */
    LONGINT sp_Unit0Map           /* What unit 0 really refers to     */
    LONGINT sp_BaudRate           /* Baud rate                */

    LONGINT sp_InputBuffer        /* Input buffer: 0 - 65536      */
    LONGINT sp_OutputBuffer       /* Future: Output: 0 - 65536        */

    BYTE  sp_InputHandshake         /* Input handshaking            */
    BYTE  sp_OutputHandshake        /* Future: Output handshaking       */

    BYTE  sp_Parity             /* Parity               */
    BYTE  sp_BitsPerChar        /* I/O bits per character       */
    BYTE  sp_StopBits           /* Stop bits                */
END STRUCT 

/* constants for SerialPrefs.sp_Parity */
#define PARITY_NONE 0
#define PARITY_EVEN 1
#define PARITY_ODD  2
#define PARITY_MARK 3       /* Future enhancement */
#define PARITY_SPACE    4       /* Future enhancement */

/* constants for SerialPrefs.sp_Input/OutputHandshaking */
#define HSHAKE_XON  0
#define HSHAKE_RTS  1
#define HSHAKE_NONE 2


/*****************************************************************************/


#endif /* PREFS_SERIAL_H */
