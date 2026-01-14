/*
** array_size.h
**
** Author: David Benn
**   Date: 5th,28th August 1994
**
** For example:
**
** -----------------------
** #include <array_size.h>
**
** dim a(4,5)
** print sizeof(a)
** print array_size_2D(4,5,sizeof(single))
**
** dim b(4,5,2)
** print sizeof(b)
** print array_size_3D(4,5,2,sizeof(single))
** -----------------------------------------
**
** When compiled and run, the output of this
** program is:
**
** 120
** 120
** 360
** 360
**
** This shows that array_size_2D/3D calculate the
** correct number of bytes required to allocate
** memory for a 2D or 3D array dynamically.
**
** See also the DIM entry in ref.doc.
*/

SUB LONGINT array_size_2D(n,m,element_size)
/* Determine size of memory required
** for a 2D array of a given element
** type. The return value from this SUB
** can be passed to ACE's ALLOC function.
**
** n = max. index of first dimension
** m = max. index of second dimension
** element_size = size in bytes of array element data type
**                (use the SIZEOF function to determine this).
*/
 	array_size_2D = (n+1) * (m+1)*element_size
END SUB

SUB LONGINT array_size_3D(a,b,c,element_size)
/* Determine size of memory required
** for a 3D array of a given element
** type. The return value from this SUB
** can be passed to ACE's ALLOC function.
**
** a = max. index of first dimension
** b = max. index of second dimension
** c = max. index of third dimension
** element_size = size in bytes of array element data type
**                (use the SIZEOF function to determine this).
*/
 	array_size_3D = (a+1) * (b+1) * (c+1)*element_size
END SUB
