#ifndef RESOURCES_CARD_H
#define RESOURCES_CARD_H 1
/*
** card.h for ACE Basic
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
** This are the StructPointer defines for card.h
*/
#ifndef CardHandlePtr
#define CardHandlePtr ADDRESS
#endif
#ifndef CardMemoryMapPtr
#define CardMemoryMapPtr ADDRESS
#endif
#ifndef DeviceTDataPtr
#define DeviceTDataPtr ADDRESS
#endif
#ifndef TP_AmigaXIPPtr
#define TP_AmigaXIPPtr ADDRESS
#endif
/*
** End of StructPointer defines for card.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

#ifndef EXEC_INTERRUPTS_H
#include <exec/interrupts.h>
#endif

#define CARDRESNAME "card.resource"

/* Structures used by the card.resource             */

STRUCT  CardHandle  
    Node cah_CardNode 
    InterruptPtr  cah_CardRemoved 
    InterruptPtr  cah_CardInserted 
    InterruptPtr  cah_CardStatus 
    BYTE    cah_CardFlags 
END STRUCT 

STRUCT  DeviceTData  
    LONGINT   dtd_DTsize  /* Size in bytes        */
    LONGINT   dtd_DTspeed     /* Speed in nanoseconds     */
    BYTE    dtd_DTtype  /* Type of card         */
    BYTE    dtd_DTflags     /* Other flags          */
END STRUCT 

STRUCT  CardMemoryMap  
    ADDRESS   cmm_CommonMemory 
    ADDRESS   cmm_AttributeMemory 
    ADDRESS   cmm_IOMemory 

/* Extended for V39 - These are the size of the memory spaces above */

    LONGINT   cmm_CommonMemSize 
    LONGINT   cmm_AttributeMemSize 
    LONGINT   cmm_IOMemSize 

END STRUCT 

/* CardHandle.cah_CardFlags for OwnCard() function      */

#define CARDB_RESETREMOVE   0
#define CARDF_RESETREMOVE   (1)

#define CARDB_IFAVAILABLE   1
#define CARDF_IFAVAILABLE   (2)

#define CARDB_DELAYOWNERSHIP    2
#define CARDF_DELAYOWNERSHIP    (4)

#define CARDB_POSTSTATUS    3
#define CARDF_POSTSTATUS    (8)

/* ReleaseCreditCard() function flags               */

#define CARDB_REMOVEHANDLE  0
#define CARDF_REMOVEHANDLE  (1)

/* ReadStatus() return flags                    */

#define CARD_STATUSB_CCDET      6
#define CARD_STATUSF_CCDET      (64)

#define CARD_STATUSB_BVD1       5
#define CARD_STATUSF_BVD1       (32)

#define CARD_STATUSB_SC         5
#define CARD_STATUSF_SC         (32)

#define CARD_STATUSB_BVD2       4
#define CARD_STATUSF_BVD2       (16)

#define CARD_STATUSB_DA         4
#define CARD_STATUSF_DA         (16)

#define CARD_STATUSB_WR         3
#define CARD_STATUSF_WR         (8)

#define CARD_STATUSB_BSY        2
#define CARD_STATUSF_BSY        (4)

#define CARD_STATUSB_IRQ        2
#define CARD_STATUSF_IRQ        (4)

/* CardProgramVoltage() defines */

#define CARD_VOLTAGE_0V     0   /* Set to default  may be the same as 5V */
#define CARD_VOLTAGE_5V     1
#define CARD_VOLTAGE_12V    2

/* CardMiscControl() defines */

#define CARD_ENABLEB_DIGAUDIO   1
#define CARD_ENABLEF_DIGAUDIO   (2)

#define CARD_DISABLEB_WP    3
#define CARD_DISABLEF_WP    (8)

/*
 * New CardMiscControl() bits for V39 card.resource.  Use these bits to set, 
 * or clear status change interrupts for BVD1/SC,  BVD2/DA,  and BSY/IRQ.
 * Write-enable/protect change interrupts are always enabled.  The defaults
 * are unchanged (BVD1/SC is enabled,  BVD2/DA is disabled,  and BSY/IRQ is enabled).
 *
 * IMPORTANT -- Only set these bits for V39 card.resource or greater (check
 * resource base VERSION)
 *
 */

#define CARD_INTB_SETCLR    7
#define CARD_INTF_SETCLR    (128)

#define CARD_INTB_BVD1      5
#define CARD_INTF_BVD1      (32)

#define CARD_INTB_SC        5
#define CARD_INTF_SC        (32)

#define CARD_INTB_BVD2      4
#define CARD_INTF_BVD2      (16)

#define CARD_INTB_DA        4
#define CARD_INTF_DA        (16)

#define CARD_INTB_BSY       2
#define CARD_INTF_BSY       (4)

#define CARD_INTB_IRQ       2
#define CARD_INTF_IRQ       (4)


/* CardInterface() defines */

#define CARD_INTERFACE_AMIGA_0  0

/*
 * Tuple for Amiga execute-in-place software (e.g.,  games,  or other
 * such software which wants to use execute-in-place software stored
 * on a credit-card,  such as a ROM card).
 *
 * See documentatin for IfAmigaXIP().
 */

#define CISTPL_AMIGAXIP &H91

STRUCT  TP_AmigaXIP  
    BYTE    TPL_CODE 
    BYTE    TPL_LINK 
    STRING TP_XIPLOC SIZE 4  
    BYTE    TP_XIPFLAGS 
    BYTE    TP_XIPRESRV 
END STRUCT
/*

      The XIPFLAGB_AUTORUN bit means that you want the machine
      _to perform a reset if the execute-in-place card is inserted
      after DOS has been started.  The machine will then reset, 
      _and execute your execute-in-place code the next time around.
     
      NOTE -- this flag may be ignored on some machines,  in which
      _case the user will have to manually reset the machine in the
      usual way.

*/

#define XIPFLAGSB_AUTORUN   0
#define XIPFLAGSF_AUTORUN   (1)

#endif  /* RESOURCES_CARD_H */
