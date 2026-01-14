#ifndef EXEC_DEVICES_H
#define EXEC_DEVICES_H 1
/*
** devices.h for ACE Basic
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
** This are the StructPointer defines for devices.h
*/
#ifndef DevicePtr
#define DevicePtr ADDRESS
#endif
#ifndef UnitPtr
#define UnitPtr ADDRESS
#endif
/*
** End of StructPointer defines for devices.h
*/
      
#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif /* EXEC_PORTS_H */



/****** Device ******************************************************/

STRUCT Device  
    _Library dd_Library 
END STRUCT 


/****** Unit ********************************************************/

STRUCT Unit  
    MsgPort unit_MsgPort    /* queue for unprocessed messages */
                    /* instance of msgport is recommended */
    BYTE    unit_flags 
    BYTE    unit_pad 
    SHORTINT   unit_OpenCnt        /* number of active opens */
END STRUCT 


#define UNITF_ACTIVE    (1)
#define UNITF_INTASK    (2)

#endif  /* EXEC_DEVICES_H */
