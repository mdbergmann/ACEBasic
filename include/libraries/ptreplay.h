
/* ptreplay.h -- definition of ptreplay.library structures */

#ifndef	LIBRARIES_PTREPLAY_H 
#define LIBRARIES_PTREPLAY_H

#ifndef	EXEC_TYPES_H
#include <exec/types.h>
#endif

#define PTREPLAYNAME "ptreplay.library"

Struct Module
    STRPTR mod_Name
/* The rest is private for now, but more details may be released later. */
End Struct

/* This structure is returned by GetSample function */
Struct PTSample
	STRING _Name SIZE 22	/* Null terminated string with samplename */
	SHORTINT Length		/* Sample length in words */
	BYTE FineTune		/* FineTune of sample in lower 4 bits */
	BYTE Volume		/* Volume of sample */
	SHORTINT _Repeat	/* Repeat start in number of words */
	SHORTINT Replen		/* Repeat length in number of words */
End Struct

#endif /* LIBRARIES_PTREPLAY_H */
