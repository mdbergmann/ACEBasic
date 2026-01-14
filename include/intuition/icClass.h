#ifndef INTUITION_ICCLASS_H
#define INTUITION_ICCLASS_H 1
/*
** icclass.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/



#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#define ICM_Dummy   (&H0401&)   /* used for nothing     */
#define ICM_SETLOOP (&H0402&)   /* set/increment loop counter   */
#define ICM_CLEARLOOP   (&H0403&)   /* clear/decrement loop counter */
#define ICM_CHECKLOOP   (&H0404&)   /* set/increment loop       */

/* no parameters for ICM_SETLOOP,  ICM_CLEARLOOP,  ICM_CHECKLOOP  */

/* interconnection attributes used by icclass,  modelclass,  and gadgetclass */
#define ICA_Dummy   (TAG_USER+&H40000&)
#define ICA_TARGET  (ICA_Dummy + 1)
    /* interconnection target       */
#define ICA_MAP     (ICA_Dummy + 2)
    /* interconnection map tagitem list */
#define ICSPECIAL_CODE  (ICA_Dummy + 3)
    /* a "pseudo-attribute",  see below. */

/* Normally,  the value for ICA_TARGET is some object pointer, 
 * but if you specify the special value ICTARGET_IDCMP,  notification
 * will be send as an IDCMP_IDCMPUPDATE message to the appropriate window's
 * IDCMP port.  See the definition of IDCMP_IDCMPUPDATE.
 *
 * When you specify ICTARGET_IDCMP for ICA_TARGET,  the map you
 * specify will be applied to derive the attribute list that is
 * sent with the IDCMP_IDCMPUPDATE message.  If you specify a map list
 * which results in the attribute tag id ICSPECIAL_CODE,  the
 * lower sixteen bits of the corresponding ti_Data value will
 * be copied into the Code field of the IDCMP_IDCMPUPDATE IntuiMessage.
 */
#define ICTARGET_IDCMP  (NOT NULL)

#endif /* INTUITION_ICCLASS_H */
