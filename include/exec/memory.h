#ifndef EXEC_MEMORY_H
#define EXEC_MEMORY_H 1
/*
** memory.h for ACE Basic
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
** This are the StructPointer defines for memory.h
*/
#ifndef MemChunkPtr
#define MemChunkPtr ADDRESS
#endif
#ifndef MemEntryPtr
#define MemEntryPtr ADDRESS
#endif
#ifndef MemHandlerDataPtr
#define MemHandlerDataPtr ADDRESS
#endif
#ifndef MemHeaderPtr
#define MemHeaderPtr ADDRESS
#endif
#ifndef MemListPtr
#define MemListPtr ADDRESS
#endif
#ifndef me_Un_StructPtr
#define me_Un_StructPtr ADDRESS
#endif
/*
** End of StructPointer defines for memory.h
*/
         
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */


/****** MemChunk ****************************************************/

STRUCT  MemChunk  
    MemChunkPtr  mc_Next   /* pointer to next chunk */
    LONGINT   mc_Bytes        /* chunk byte size  */
END STRUCT 


/****** MemHeader ***************************************************/

STRUCT  MemHeader  
    Node mh_Node 
    SHORTINT   mh_Attributes   /* characteristics of this region */
    MemChunkPtr  mh_First  /* first free region        */
    ADDRESS    mh_Lower        /* lower memory bound       */
    ADDRESS    mh_Upper        /* upper memory bound+1 */
    LONGINT   mh_Free         /* total number of free bytes   */
END STRUCT 


/****** MemEntry ****************************************************/

STRUCT me_Un_Struct  
    LONGINT   meu_Regs 
    ADDRESS    meu_Addr 
END STRUCT 

STRUCT  MemEntry  
    me_Un_Struct me_Un 
                           /* the AllocMem requirements */
                           /* the address of this memory region */
    LONGINT   me_Length       /* the length of this memory region */
END STRUCT 

#define me_un       me_Un_Struct   /* compatibility - do NOT use*/
#define me_Reqs     me_Un_Struct->meu_Reqs
#define me_Addr     me_Un_Struct->meu_Addr


/****** MemList *****************************************************/

/* Note: sizeof(STRUCT MemList) includes the size of the first MemEntry! */
STRUCT  MemList  
    Node ml_Node 
    SHORTINT   ml_NumEntries   /* number of entries in this STRUCT */
    STRING ml_ME SIZE 8      /* the first entry  */
END STRUCT 

#define ml_me   ml_ME       /* compatability - do not use */


/*----- Memory Requirement Types ---------------------------*/
/*----- See the AllocMem() documentation for details--------*/

#define MEMF_ANY    (0&)    /* Any type of memory will do */
#define MEMF_PUBLIC (1&)
#define MEMF_CHIP   (2&)
#define MEMF_FAST   (4&)
#define MEMF_LOCAL  (256&) /* Memory that does not go away at RESET */
#define MEMF_24BITDMA (512&)   /* DMAable memory within 24 bits of address */
#define MEMF_KICK   (1024&)    /* Memory that can be used for KickTags */

#define MEMF_CLEAR   (65536&)   /* AllocMem: NULL out area before return */
#define MEMF_LARGEST (131072&)   /* AvailMem: return the largest chunk size */
#define MEMF_REVERSE (262144&)   /* AllocMem: allocate from the top down */
#define MEMF_TOTAL   (524288&)   /* AvailMem: return total size of memory */

#define MEMF_NO_EXPUNGE (2147483648&) /*AllocMem: Do not cause expunge on failure */

/*----- Current alignment rules for memory blocks (may increase) -----*/
#define MEM_BLOCKSIZE   8&
#define MEM_BLOCKMASK   (MEM_BLOCKSIZE-1)


/****** MemHandlerData **********************************************/
/* Note:  This structure is *READ ONLY* and only EXEC can create it!*/
STRUCT MemHandlerData
 
    LONGINT   memh_RequestSize    /* Requested allocation size */
    LONGINT   memh_RequestFlags   /* Requested allocation flags */
    LONGINT   memh_Flags      /* Flags (see below) */
END STRUCT 

#define MEMHF_RECYCLE   (1) /* 0==First time,  1==recycle */

/****** Low Memory handler return values ***************************/
#define MEM_DID_NOTHING (0) /* Nothing we could do... */
#define MEM_ALL_DONE    (-1)    /* We did all we could do */
#define MEM_TRY_AGAIN   (1) /* We did some,  try the allocation again */

#endif  /* EXEC_MEMORY_H */
