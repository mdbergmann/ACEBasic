#ifndef EXEC_INITIALIZERS_H
#define EXEC_INITIALIZERS_H 1
/*
** initializers.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
**
*/


#define OFFSET(structName,  structEntry) \
                (&(((STRUCT structName *) 0)->structEntry))
#define INITBYTE(offset, value)  &He000, (SHORTINT) (offset), (SHORTINT) ((value)<<8)
#define INITWORD(offset, value)  &Hd000, (SHORTINT) (offset), (SHORTINT) (value)
#define INITLONG(offset, value)  &Hc000, (SHORTINT) (offset),  \
                (SHORTINT) ((value)>>16),  \
                (SHORTINT) ((value) & &Hffff)
#define INITSTRUCT(size, offset, value, count) \
                (SHORTINT) (&Hc000|(size<<12)|(count<<8)| \
                ((SHORTINT) ((offset)>>16)),  \
                ((SHORTINT) (offset)) & &Hffff)
#endif /* EXEC_INITIALIZERS_H */
