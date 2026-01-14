#ifndef INTUITION_CLASSUSR_H
#define INTUITION_CLASSUSR_H 1
/*
** classusr.h for ACE Basic
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
** This are the StructPointer defines for classusr.h
*/
#ifndef opAddTailPtr
#define opAddTailPtr ADDRESS
#endif
#ifndef opGetPtr
#define opGetPtr ADDRESS
#endif
#ifndef opMemberPtr
#define opMemberPtr ADDRESS
#endif
#ifndef opSetPtr
#define opSetPtr ADDRESS
#endif
#ifndef opUpdatePtr
#define opUpdatePtr ADDRESS
#endif
/*
** End of StructPointer defines for classusr.h
*/



#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif

#ifndef _ObjectPtr
#define _ObjectPtr ADDRESS
#endif


/*** User visible handles on objects,  classes,  messages ***/
#define  Object   LONGINT      /* abstract HANDLE */

#define  ClassID  ADDRESS 

/* you can use this type to point to a "generic" message, 
 * in the object-oriented programming parlance.  Based on
 * the value of 'MethodID',  you dispatch to processing
 * for the various message types.  The meaningful parameter
 * packet structure definitions are defined below.
 */
/*
typedef STRUCT  
    LONGINT MethodID 
END STRUCT       *Msg 
*/

/*
 * Class id strings for Intuition classes.
 * There's no real reason to use the uppercase constants
 * over the lowercase strings,  but this makes a good place
 * to list the names of the built-in classes.
 */
#define ROOTCLASS   "rootclass"     /* classusr.h     */
#define IMAGECLASS  "imageclass"        /* imageclass.h   */
#define FRAMEICLASS "frameiclass"
#define SYSICLASS   "sysiclass"
#define FILLRECTCLASS   "fillrectclass"
#define GADGETCLASS "gadgetclass"       /* gadgetclass.h  */
#define PROPGCLASS  "propgclass"
#define STRGCLASS   "strgclass"
#define BUTTONGCLASS    "buttongclass"
#define FRBUTTONCLASS   "frbuttonclass"
#define GROUPGCLASS "groupgclass"
#define ICCLASS     "icclass"       /* icclass.h      */
#define MODELCLASS  "modelclass"
#define ITEXTICLASS "itexticlass"
#define POINTERCLASS    "pointerclass"      /* pointerclass.h */

/* Dispatched method ID's
 * NOTE: Applications should use Intuition entry points,  not direct
 * DoMethod() calls,  for NewObject,  DisposeObject,  SetAttrs, 
 * SetGadgetAttrs,  and GetAttr.
 */

#define OM_Dummy    (&H100)
#define OM_NEW      (&H101) /* 'object' parameter is "true class"   */
#define OM_DISPOSE  (&H102) /* delete self (no parameters)      */
#define OM_SET      (&H103) /* set attributes (in tag list)     */
#define OM_GET      (&H104) /* return single attribute value    */
#define OM_ADDTAIL  (&H105) /* add self to a List (let root do it)  */
#define OM_REMOVE   (&H106) /* remove self from list        */
#define OM_NOTIFY   (&H107) /* send to self: notify dependents  */
#define OM_UPDATE   (&H108) /* notification message from somebody   */
#define OM_ADDMEMBER    (&H109) /* used by various classes with lists   */
#define OM_REMMEMBER    (&H10A) /* used by various classes with lists   */

/* Parameter "Messages" passed to methods   */

/* OM_NEW and OM_SET    */
STRUCT opSet  
    LONGINT       MethodID 
    TagItemPtr  ops_AttrList   /* new attributes   */
    GadgetInfoPtr  ops_GInfo  /* always there for gadgets, 
                     * when SetGadgetAttrs() is used, 
                     * but will be NULL for OM_NEW
                     */
END STRUCT 

/* OM_NOTIFY,  and OM_UPDATE */
STRUCT opUpdate  
    LONGINT       MethodID 
    TagItemPtr  opu_AttrList   /* new attributes   */
    GadgetInfoPtr  opu_GInfo  /* non-NULL when SetGadgetAttrs or
                     * notification resulting from gadget
                     * input occurs.
                     */
    LONGINT       opu_Flags   /* defined below    */
END STRUCT 

/* this flag means that the update message is being issued from
 * something like an active gadget,  a la GACT_FOLLOWMOUSE.  When
 * the gadget goes inactive,  it will issue a final update
 * message with this bit cleared.  Examples of use are for
 * GACT_FOLLOWMOUSE equivalents for propgadclass,  and repeat strobes
 * for buttons.
 */
#define OPUF_INTERIM    &H1

/* OM_GET   */
STRUCT opGet  
    LONGINT       MethodID 
    LONGINT       opg_AttrID 
    ADDRESS   opg_Storage    /* may be other types,  but "int"
                     * types are all LONGINT
                     */
END STRUCT 

/* OM_ADDTAIL   */
STRUCT opAddTail  
    LONGINT       MethodID 
    ListPtr  opat_List 
END STRUCT 

/* OM_ADDMEMBER,  OM_REMMEMBER   */
#define  opAddMember opMember
STRUCT opMember  
    LONGINT       MethodID 
    _ObjectPtr    opam_Object
END STRUCT 


#endif
