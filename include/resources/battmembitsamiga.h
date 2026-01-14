#ifndef RESOURCES_BATTMEMBITSAMIGA_H
#define RESOURCES_BATTMEMBITSAMIGA_H 1
/*
** battmembitsamiga.h for ACE Basic
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
 * Amiga specific bits in the battery-backedup ram.
 *
 *  Bits 0 to 31,  inclusive
 */

/*
 * AMIGA_AMNESIA
 *
 *      The battery-backedup memory has had a memory loss.
 *      This bit is used as a flag that the user should be
 *      notified that all battery-backed bit have been
 *      reset and that some attention is required. Zero
 *      indicates that a memory loss has occured.
 */

#define BATTMEM_AMIGA_AMNESIA_ADDR  0
#define BATTMEM_AMIGA_AMNESIA_LEN   1


/*
 * SCSI_TIMEOUT
 *
 *      adjusts the timeout value for SCSI device selection.  A
 *      value of 0 will produce SHORTINT timeouts (128 ms) while a
 *      value of 1 produces LONGINT timeouts (2 sec).  This is used
 *      for SeaCrate drives (and some Maxtors apparently) that
 *      don`t respond to selection until they are fully spun up
 *      and intialised.
 */

#define BATTMEM_SCSI_TIMEOUT_ADDR   1
#define BATTMEM_SCSI_TIMEOUT_LEN    1


/*
 * SCSI_LUNS
 *
 *      Determines if the controller attempts to access logical
 *      units above 0 at any given SCSI address.  This prevents
 *      problems with drives that respond to ALL LUN addresses
 *      (instead of only 0 like they should).  Default value is
 *      0 meaning don't support LUNs.
 */

#define BATTMEM_SCSI_LUNS_ADDR      2
#define BATTMEM_SCSI_LUNS_LEN       1

#endif /* RESOURCES_BATTMEMBITSAMIGA_H */
