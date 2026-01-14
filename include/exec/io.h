#ifndef EXEC_IO_H
#define EXEC_IO_H 1
/*
** io.h for ACE Basic
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
** This are the StructPointer defines for io.h
*/
#ifndef IORequestPtr
#define IORequestPtr ADDRESS
#endif
#ifndef IOStdReqPtr
#define IOStdReqPtr ADDRESS
#endif
/*
** End of StructPointer defines for io.h
*/
      
#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif /* EXEC_PORTS_H */

#ifndef DevicePtr
#define DevicePtr ADDRESS
#endif
#ifndef UnitPtr
#define UnitPtr ADDRESS
#endif


STRUCT IORequest  
    _Message io_Message 
    DevicePtr  io_Device      /* device node pointer  */
    UnitPtr  io_Unit        /* unit (driver private)*/
    SHORTINT   io_Command      /* device command */
    BYTE    io_Flags 
    BYTE    io_Error            /* error or warning num */
END STRUCT 

STRUCT IOStdReq  
    _Message io_Message 
    DevicePtr  io_Device      /* device node pointer  */
    UnitPtr  io_Unit        /* unit (driver private)*/
    SHORTINT   io_Command      /* device command */
    BYTE    io_Flags 
    BYTE    io_Error            /* error or warning num */
    LONGINT   io_Actual           /* actual number of bytes transferred */
    LONGINT   io_Length           /* requested number bytes transferred*/
    ADDRESS    io_Data             /* points to data area */
    LONGINT   io_Offset           /* offset for block structured devices */
END STRUCT 

/* library vector offsets for device reserved vectors */
#define DEV_BEGINIO (-30)
#define DEV_ABORTIO (-36)

/* io_Flags defined bits */
#define IOB_QUICK   0
#define IOF_QUICK   (1)


#define CMD_INVALID 0
#define CMD_RESET   1
#define CMD_READ    2
#define CMD_WRITE   3
#define CMD_UPDATE  4
#define CMD_CLEAR   5
#define CMD_STOP    6
#define CMD_START   7
#define CMD_FLUSH   8

#define CMD_NONSTD  9

#endif  /* EXEC_IO_H */
