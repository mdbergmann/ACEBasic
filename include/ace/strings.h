/* From XRACTON@FULLERTON.EDU Thu Jun 24 00:39:17 1993 */

Rem *** LCASE$ (function)
Rem ***
Rem *** FUNCTION:
Rem *** Simulates the LCASE$ function hard-wired into some other
Rem *** BASICs. Takes a string as input, and returns that string
Rem *** with all uppercase letters converted to lowercase.
Rem ***
Rem *** REVISION HISTORY:
Rem *** Version 1.0: Roland Acton (xracton@ccvax.fullerton.edu)
Rem ***
Rem *** BUGS:
Rem *** Can only handle strings up to MAXSTRINGLEN.

SUB LCASE$(A$)
  Longint STEPPER
  String B$
  B$=A$
  STEPPER=@B$
Rem *** Not perfectly portable, but everybody uses ASCII these days,
Rem *** right?
  Repeat
    If Peek(STEPPER)>=65 And Peek(STEPPER)<=90 Then
      Poke STEPPER,Peek(STEPPER)+32
    End If
    ++STEPPER
  Until Peek(STEPPER)=0
  LCASE$=B$
END SUB



Rem *** MIDCOM$ (function)
Rem ***
Rem *** FUNCTION:
Rem *** Simulates the MID$ command. A$, starting at position B%, has
Rem *** its contents replaced by C$. This is done until either D%
Rem *** characters have been replaced, or the end of either A$ or C$
Rem *** has been reached. This is consistent with the way it is
Rem *** implemented in AmigaBASIC (though AmigaBASIC uses a
Rem *** different syntax). The contents of A$ are then returned to
Rem *** the calling program.
Rem *** For example, if NAME$ contains the string "Goodbye",
Rem ***
Rem *** NAGISA$=MIDCOM$(NAME$,2,"Iczer",1)
Rem ***
Rem *** will make NAGISA$ contain the string "GIodbye". NAME$ will
Rem *** be unaffected. Thus, if you actually wanted to alter NAME$
Rem *** (as the "real" MID$ command would do) you would have to use
Rem ***
Rem *** NAME$=MIDCOM$(NAME$,2,"Iczer",1)
Rem ***
Rem *** Note that since ACE does not allow function overloading, all
Rem *** four parameters are required. Pass D% a very high number if
Rem *** you want it ignored.
Rem ***
Rem *** REVISION HISTORY:
Rem *** Version 1.0: Roland Acton (xracton@ccvax.fullerton.edu)
Rem ***
Rem *** BUGS:
Rem *** None known.

SUB MIDCOM$(A$,B%,C$,D%)
  Longint STEPA, STEPC
  STEPA=@A$+B%-1
  STEPC=@C$
  While Peek(STEPA)<>0 And Peek(STEPC)<>0 And D%>0
    Poke STEPA,Peek(STEPC)
    ++STEPA
    ++STEPC
    --D%
  Wend
  MIDCOM$=A$
END SUB
