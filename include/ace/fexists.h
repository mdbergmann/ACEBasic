/* FEXISTS(x$) -- returns true if file exists otherwise false.

  Author: David J Benn
    Date: 28th February 1993,
	  2nd January 1994 */
		
sub fexists(x$)
  if x$="" then 
    fexists=0
  else
    open "I",#255,x$
    if handle(255) <> 0& then 
      close #255
      fexists=-1
    else 
      fexists=0
    end if
  end if
end sub
