     	  '..Using pointers to implement an array of numbers  
	  '..(single-precision values in this case). 
 
	  {* Variables *} 
          ADDRESS memBlock 
 
	  {* Subprograms *} 
          SUB SetElement(ADDRESS addr, LONGINT i, SINGLE x) 
            *!(addr + i*SIZEOF(SINGLE)) := x 
          END SUB 
 
          SUB SINGLE Element(ADDRESS addr, LONGINT i) 
            Element = *!(addr + i*SIZEOF(SINGLE)) 
          END SUB 
 
	  {* Main *} 
 
          '..Allocate a memBlock of N single-precision floats
          INPUT "How many numbers? ",N 
          memBlock = ALLOC(N*SIZEOF(SINGLE)) 
          IF memBlock = 0& THEN STOP 
          PRINT "Allocated";N;"values ( 0 to";N-1;")" 
 
          '..Fill "array" with the squares of i 
          FOR i=0 TO N-1
            SetElement(memBlock, i, i*i) 
          NEXT 
 
          '..Display "array" elements 
          FOR i=0 TO N-1
            PRINT i, Element(memBlock, i) 
          NEXT 
 
	  END
