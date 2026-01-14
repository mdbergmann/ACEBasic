#ifndef DEVICES_KEYMAP_H
#define DEVICES_KEYMAP_H 1
/*
** keymap.h for ACE Basic
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
** This are the StructPointer defines for keymap.h
*/
#ifndef KeyMapPtr
#define KeyMapPtr ADDRESS
#endif
#ifndef KeyMapNodePtr
#define KeyMapNodePtr ADDRESS
#endif
#ifndef KeyMapResourcePtr
#define KeyMapResourcePtr ADDRESS
#endif
/*
** End of StructPointer defines for keymap.h
*/
           
#ifndef EXEC_NODES_H
#include    <exec/nodes.h>
#endif
#ifndef EXEC_LISTS_H
#include    <exec/lists.h>
#endif


STRUCT   KeyMap  
    ADDRESS   km_LoKeyMapTypes 
    ADDRESS   km_LoKeyMap 
    ADDRESS   km_LoCapsable 
    ADDRESS   km_LoRepeatable 
    ADDRESS   km_HiKeyMapTypes 
    ADDRESS   km_HiKeyMap 
    ADDRESS   km_HiCapsable 
    ADDRESS   km_HiRepeatable 
END STRUCT 

STRUCT  KeyMapNode  
    Node kn_Node     /* including name of keymap */
    KeyMap kn_KeyMap 
END STRUCT 

/* the structure of keymap.resource */
STRUCT  KeyMapResource  
    Node kr_Node 
    _List kr_List     /* a list of KeyMapNodes */
END STRUCT 

/* Key Map Types */
#define  KC_NOQUAL   0
#define  KC_VANILLA  7      /* note that SHIFT+ALT+CTRL is VANILLA */
#define  KCB_SHIFT   0
#define  KCF_SHIFT   &H01
#define  KCB_ALT     1
#define  KCF_ALT     &H02
#define  KCB_CONTROL 2
#define  KCF_CONTROL &H04
#define  KCB_DOWNUP  3
#define  KCF_DOWNUP  &H08

#define  KCB_DEAD    5      /* may be dead or modified by dead key: */
#define  KCF_DEAD    &H20   /*   use dead prefix bytes      */

#define  KCB_STRING  6
#define  KCF_STRING  &H40

#define  KCB_NOP     7
#define  KCF_NOP     &H80


/* Dead Prefix Bytes */
#define DPB_MOD 0
#define DPF_MOD &H01
#define DPB_DEAD    3
#define DPF_DEAD    &H08

#define DP_2DINDEXMASK  &H0f    /* mask for index for 1st of two dead keys */
#define DP_2DFACSHIFT   4   /* shift for factor for 1st of two dead keys */

#endif  /* DEVICES_KEYMAP_H */
