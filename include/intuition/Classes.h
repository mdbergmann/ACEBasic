#ifndef INTUITION_CLASSES_H
#define INTUITION_CLASSES_H 1
/*
** classes.h for ACE Basic
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
** This are the StructPointer defines for classes.h
*/
#ifndef IClassPtr
#define IClassPtr ADDRESS
#endif
#ifndef _ObjectPtr
#define _ObjectPtr ADDRESS
#endif
/*
** End of StructPointer defines for classes.h
*/


#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif

#ifndef INTUITION_CLASSUSR_H
#include <intuition/classusr.h>
#endif

/*******************************************/
/*** "White box" access to STRUCT IClass ***/
/*******************************************/

/* This structure is READ-ONLY,  and allocated only by Intuition */
STRUCT IClass  
    Hook cl_Dispatcher 
    LONGINT       cl_Reserved     /* must be 0  */
    IClassPtr  cl_Super 
    ClassID     cl_ID 

    /* where within an object is the instance data for this class? */
    SHORTINT       cl_InstOffset 
    SHORTINT       cl_InstSize 

    LONGINT       cl_UserData     /* per-class data of your choice */
    LONGINT       cl_SubclassCount 
                    /* how many direct subclasses?  */
    LONGINT       cl_ObjectCount 
                /* how many objects created of this class? */
    LONGINT       cl_Flags 
END STRUCT 


#define CLF_INLIST  &H00000001  /* class is in public class LIST */

/* add offset for instance data to an object handle */
/*
#define INST_DATA( cl,  o )  ((BYTE *) (((BYTE  *)o)+cl->cl_InstOffset))
*/
/* sizeof the instance data for a given class */
/*
#define SIZEOF_INSTANCE( cl )   ((cl)->cl_InstOffset + (cl)->cl_InstSize \
            + _sizeof (STRUCT _Object ))     
*/

/**************************************************/
/*** "White box" access to STRUCT _Object   ***/
/**************************************************/

/*
 * We have this,  the instance data of the root class,  PRECEDING
 * the "object".  This is so that Gadget objects are Gadget pointers, 
 * and so on.  If this structure grows,  it will always have o_Class
 * at the end,  so the macro OCLASS(o) will always have the same
 * offset back from the pointer returned from NewObject().
 *
 * This data structure is subject to change.  Do not use the o_Node
 * embedded structure.
 */
STRUCT _Object  
    MinNode o_Node 
    IClassPtr  o_Class 
END STRUCT 

/* convenient typecast  */
/*
#define _OBJ( o )   ((STRUCT _Object *)(o))
*/
/* get "public" handle on baseclass instance from real beginning of obj data */
/*
#define BASEOBJECT( _obj )  ( (Object *) (_OBJ(_obj)+1) )
*/
/* get back to object data STRUCT from public handle */
/*
#define _OBJECT( o )        (_OBJ(o) - 1)
*/
/* get class pointer from an object handle  */
/*
#define OCLASS( o ) ( (_OBJECT(o))->o_Class )     
*/

#endif
