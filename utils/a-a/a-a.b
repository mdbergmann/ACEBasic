{From XRACTON@FULLERTON.EDU Thu Jun 24 00:38:10 1993
Return-Path: <XRACTON@FULLERTON.EDU>
Received: from CCVAX.FULLERTON.EDU (csu.Fullerton.EDU) by leven.appcomp.utas.edu.au (4.1/SMI-4.1)
	id AA05310; Thu, 24 Jun 93 00:37:44 EST
Received: from FULLERTON.EDU by FULLERTON.EDU (PMDF #2446 ) id
 <01GZPKD4PQ3Q002QFT@FULLERTON.EDU>; Wed, 23 Jun 1993 07:36:05 PST
Date: 23 Jun 1993 07:36:05 -0800 (PST)
From: ROLAND ACTON <XRACTON@FULLERTON.EDU>
Subject: A-A program code
To: dbenn@leven.appcomp.utas.edu.au
Message-Id: <01GZPKD4PZQW002QFT@FULLERTON.EDU>
X-Vms-To: IN%"dbenn@leven.appcomp.utas.edu.au"
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Status: OR}

Rem *** AMOS to ACE (program)
Rem ***
Rem *** FUNCTION:
Rem *** Converts (some) AMOS BASIC commands to ACE BASIC.
Rem ***
Rem *** REVISION HISTORY:
Rem *** Version 1.0: Roland Acton (xracton@ccvax.fullerton.edu)
Rem ***
Rem *** BUGS:
Rem *** String constants may accidentally be converted if they match
Rem *** with A-A's templates.
Rem *** The "then" version of AMOS's IF statement will be improperly
Rem *** converted and generate an error message from ACE.

DEFINT a-z
STRING buffer$ size 256, a$ size 2, holder$ size 2, output$ size 256
STRING checker$ size 2, infile$ size 256

Library dos
Declare Function _Read& Library dos
Declare Function _Write& Library dos

IF ARGCOUNT<>2 THEN
   Print "AMOS to ACE"
   Print "V1.0 by Roland Acton (xracton@ccvax.fullerton.edu) - June 1993"
   Print "Syntax: AMOStoACE <source-file> <destination-file>"
   STOP
END IF
Const CONVBEGINNUM=21
Const CONVANYNUM=10
Dim CONVBEGINFROM$(CONVBEGINNUM),CONVBEGINTO$(CONVBEGINNUM)
Dim CONVANYFROM$(CONVANYNUM),CONVANYTO$(CONVANYNUM)
Dim VARIABLE$(9)
Gosub TEMPLATES
OPEN "I", #1, ARG$(1)
OPEN "O", #2, ARG$(2)
BUFFER$=""
AMOSCODE=0
Print #2,"DEFLNG a-z"+Chr$(10);
REMAINING=_Read(Handle(1),Varptr(INFILE$),256&)
INFILEOFFSET=0
BEGINNINGOFLINE=0
MAINLOOP:
INSIDETEXT=0
BUFFEROFFSET=0
A=Asc(Right$(BUFFER$,1))
While(((Eof(1)<>-1) or(REMAINING>0)) and(A<>10))
   BEGINNINGOFLINE=1
   A=Peek(Varptr(INFILE$)+INFILEOFFSET)
   ++INFILEOFFSET
   --REMAINING
   IF ((A=58) and(INSIDETEXT=0)) THEN
      If Right$(BUFFER$,1)<>" " THEN
         Poke Varptr(BUFFER$)+BUFFEROFFSET,58
         ++BUFFEROFFSET
      End If
      Poke Varptr(BUFFER$)+BUFFEROFFSET,10
      A=10
   Else 
      IF A=34 THEN
         INSIDETEXT=1-INSIDETEXT
      END IF
      Poke Varptr(BUFFER$)+BUFFEROFFSET,A
   END IF
   ++BUFFEROFFSET
   Poke Varptr(BUFFER$)+BUFFEROFFSET,0
   IF REMAINING=0 THEN
      REMAINING=_Read(Handle(1),Varptr(INFILE$),256&)
      INFILEOFFSET=0
   END IF
Wend 
IF ((BUFFER$="") and(Eof(1)=-1)) THEN
   Gosub FINALIZATION
   STOP
END IF
Rem *** "Copy and change" isn't usually a good idea, but in this
Rem *** case it produces the fastest object code.
IF BEGINNINGOFLINE=1 THEN
  BEGINNINGOFLINE=0
  SPACEKLUDGE:
  If Left$(BUFFER$,1)=" " THEN
    _Write(Handle(2),Varptr(BUFFER$),1)
    BUFFER$=Mid$(BUFFER$,2)
    Goto SPACEKLUDGE
  End If
  Gosub BEFORECHECK
  For C=1 To CONVBEGINNUM
     For Z=1 To 9
        VARIABLE$(Z)=""
     Next 
     SUCCESS=1
     BUFFERSTEP=1
     For Z=1 To Len(CONVBEGINFROM$(C))
        IF  Mid$(CONVBEGINFROM$(C),Z,1)="\" THEN
           VARUSED=Val(Mid$(CONVBEGINFROM$(C),Z+1,1))
           HOLDER$=Mid$(CONVBEGINFROM$(C),Z+2,1)
           PARNUM=0
           IF  HOLDER$=")" THEN
              A=Instr(BUFFERSTEP,BUFFER$,")")
              B=INSTR(BUFFERSTEP,BUFFER$,"(")
              While((B>0) and(B<A))
                 B=INSTR(B+1,BUFFER$,"(")
                 PARNUM=PARNUM+1
              Wend 
           Else 
              A=INSTR(BUFFERSTEP,BUFFER$,HOLDER$)
           END IF
           While PARNUM>0
              A=Instr(A+1,BUFFER$,")")
              PARNUM=PARNUM-1
           Wend 
           B=Instr(BUFFERSTEP,BUFFER$,Mid$(CONVBEGINFROM$(C),Z+3,1))
           IF ((A>0) and((B=0) or(A<=B))) THEN
              VARIABLE$(VARUSED)=VARIABLE$(VARUSED)+Mid$(BUFFER$,BUFFERSTEP,A-BUFFERSTEP)
              BUFFERSTEP=A
           Else 
              SUCCESS=0
              Z=Len(CONVBEGINFROM$(C))
           END IF
           Z=Z+3
        Else 
           IF  Mid$(CONVBEGINFROM$(C),Z,1)<>Mid$(BUFFER$,BUFFERSTEP,1) THEN
              SUCCESS=0
              Z=Len(CONVBEGINFROM$(C))
           END IF
        END IF
        ++BUFFERSTEP
     Next 
     IF SUCCESS=1 THEN
        OUTPUT$=""
        For Z=1 To Len(CONVBEGINTO$(C))
           CHECKER$=Mid$(CONVBEGINTO$(C),Z,1)
           IF  CHECKER$="\" THEN
              OUTPUT$=OUTPUT$+VARIABLE$(Val(Mid$(CONVBEGINTO$(C),Z+1,1)))
              Z=Z+1
           Else 
              OUTPUT$=OUTPUT$+CHECKER$
           END IF
        Next 
        _Write(Handle(2),Varptr(OUTPUT$),Len(OUTPUT$))
        BUFFER$=Mid$(BUFFER$,BUFFERSTEP)
        C=CONVBEGINNUM
        BEGINNINGOFLINE=1
     END IF
  Next 
  Gosub AFTERCHECK
  Goto MAINLOOP
END IF
Gosub BEFORECHECK
For C=1 To CONVANYNUM
   For Z=1 To 9
      VARIABLE$(Z)=""
   Next 
   SUCCESS=1
   BUFFERSTEP=1
   For Z=1 To Len(CONVANYFROM$(C))
      IF  Mid$(CONVANYFROM$(C),Z,1)="\" THEN
         VARUSED=Val(Mid$(CONVANYFROM$(C),Z+1,1))
         HOLDER$=Mid$(CONVANYFROM$(C),Z+2,1)
         PARNUM=0
         IF  HOLDER$=")" THEN
            A=Instr(BUFFERSTEP,BUFFER$,")")
            B=INSTR(BUFFERSTEP,BUFFER$,"(")
            While((B>0) and(B<A))
               B=INSTR(B+1,BUFFER$,"(")
               PARNUM=PARNUM+1
            Wend 
         Else 
            A=INSTR(BUFFERSTEP,BUFFER$,HOLDER$)
         END IF
         While PARNUM>0
            A=Instr(A+1,BUFFER$,")")
            PARNUM=PARNUM-1
         Wend 
         B=Instr(BUFFERSTEP,BUFFER$,Mid$(CONVANYFROM$(C),Z+3,1))
         IF ((A>0) and((B=0) or(A<=B))) THEN
            VARIABLE$(VARUSED)=VARIABLE$(VARUSED)+Mid$(BUFFER$,BUFFERSTEP,A-BUFFERSTEP)
            BUFFERSTEP=A
         Else 
            SUCCESS=0
            Z=Len(CONVANYFROM$(C))
         END IF
         Z=Z+3
      Else 
         IF  Mid$(CONVANYFROM$(C),Z,1)<>Mid$(BUFFER$,BUFFERSTEP,1) THEN
            SUCCESS=0
            Z=Len(CONVANYFROM$(C))
         END IF
      END IF
      ++BUFFERSTEP
   Next 
   IF SUCCESS=1 THEN
      OUTPUT$=""
      For Z=1 To Len(CONVANYTO$(C))
         CHECKER$=Mid$(CONVANYTO$(C),Z,1)
         IF  CHECKER$="\" THEN
            OUTPUT$=OUTPUT$+VARIABLE$(Val(Mid$(CONVANYTO$(C),Z+1,1)))
            Z=Z+1
         Else 
            OUTPUT$=OUTPUT$+CHECKER$
         END IF
      Next 
      _Write(Handle(2),Varptr(OUTPUT$),Len(OUTPUT$))
      BUFFER$=Mid$(BUFFER$,BUFFERSTEP)
      C=CONVANYNUM
   END IF
Next 
Gosub AFTERCHECK
IF (Right$(BUFFER$,1)=Chr$(10)) THEN
   _Write(Handle(2),Varptr(BUFFER$),1)
   BUFFER$=Mid$(BUFFER$,2)
END IF
Goto MAINLOOP
FINALIZATION:
Close 1
Close 2
Library Close dos
Return
BEFORECHECK:
IF  Left$(BUFFER$,14)="Rem Begin AMOS" THEN
   AMOSCODE=1
END IF
IF  Left$(BUFFER$,12)="Rem End AMOS" THEN
   AMOSCODE=0
   BUFFER$="Rem AMOS"+Chr$(10)
END IF
IF  AMOSCODE=1 THEN
   BUFFER$=Chr$(10)
END IF
IF  Left$(BUFFER$,7)="Rem ACE" THEN
   _Write(Handle(2),Varptr(BUFFER$)+7,Len(BUFFER$)-7)
   BUFFER$=Chr$(10)
END IF
Return 
AFTERCHECK:
Return 
TEMPLATES:
Rem *** FROM templates contain either case-sensitive "constants" or
Rem *** the "variable" character "\". The format of the embedded
Rem *** variable flag is:
Rem *** \<variable number><success-char><fail-char>
Rem *** If the <success-char> and <fail-char> are the same, the
Rem *** match will always be successful.
Rem *** TO templates contain either constants or the variable
Rem *** character followed immediately by the variable number.
CONVBEGINFROM$(1)="Inc \1"+Chr$(10)+Chr$(10)
CONVBEGINTO$(1)="++\1"+Chr$(10)
CONVBEGINFROM$(2)="Dec \1"+Chr$(10)+Chr$(10)
CONVBEGINTO$(2)="--\1"+Chr$(10)
CONVBEGINFROM$(3)="Add \1,"+Chr$(10)+"\2"+Chr$(10)+Chr$(10)
CONVBEGINTO$(3)="\1=\1+\2"+Chr$(10)
CONVBEGINFROM$(4)="End If "
CONVBEGINTO$(4)="END IF"
CONVBEGINFROM$(5)="If\1"+Chr$(10)+Chr$(10)
CONVBEGINTO$(5)="IF\1 THEN"+Chr$(10)
CONVBEGINFROM$(6)="Do "+Chr$(10)
CONVBEGINTO$(6)="REPEAT"+Chr$(10)
CONVBEGINFROM$(7)="Loop "+Chr$(10)
CONVBEGINTO$(7)="UNTIL 1=0"+Chr$(10)
CONVBEGINFROM$(8)="Fix(\1)"+Chr$(10)
CONVBEGINTO$(8)="FIX \1+1"
CONVBEGINFROM$(9)="Say \1,"+Chr$(10)+"\2"+Chr$(10)+Chr$(10)
CONVBEGINTO$(9)="SAY \1"+Chr$(10)
CONVBEGINFROM$(10)="Open Out \1,"+Chr$(10)+"\2"+Chr$(10)+Chr$(10)
CONVBEGINTO$(10)="OPEN "+Chr$(34)+"O"+Chr$(34)+", #\1, \2"+Chr$(10)
CONVBEGINFROM$(11)="Open In \1,"+Chr$(10)+"\2"+Chr$(10)+Chr$(10)
CONVBEGINTO$(11)="OPEN "+Chr$(34)+"I"+Chr$(34)+", #\1, \2"+Chr$(10)
CONVBEGINFROM$(12)="Append \1,"+Chr$(10)+"\2"+Chr$(10)+Chr$(10)
CONVBEGINTO$(12)="OPEN "+Chr$(34)+"A"+Chr$(34)+", #\1, \2"+Chr$(10)
CONVBEGINFROM$(13)="Doke \1,"+Chr$(10)+"\2"+Chr$(10)+Chr$(10)
CONVBEGINTO$(13)="POKEW \1,\2"+Chr$(10)
CONVBEGINFROM$(14)="Loke \1,"+Chr$(10)+"\2"+Chr$(10)+Chr$(10)
CONVBEGINTO$(14)="POKEL \1,\2"+Chr$(10)
CONVBEGINFROM$(15)="Procedure \1["+Chr$(10)+"\2]"+Chr$(10)
CONVBEGINTO$(15)="SUB \1(\2)"
CONVBEGINFROM$(16)="Procedure \1"+Chr$(10)+Chr$(10)
CONVBEGINTO$(16)="SUB \1"+Chr$(10)
CONVBEGINFROM$(17)="End Proc"
CONVBEGINTO$(17)="END SUB"
CONVBEGINFROM$(18)="Proc \1["+Chr$(10)+"\2]"+Chr$(10)
CONVBEGINTO$(18)="CALL \1(\2)"
CONVBEGINFROM$(19)="Proc \1"+Chr$(10)+Chr$(10)
CONVBEGINTO$(19)="CALL \1"+Chr$(10)
CONVBEGINFROM$(20)="Set Buffer \1"+Chr$(10)+Chr$(10)
CONVBEGINTO$(20)=Chr$(10)
CONVBEGINFROM$(21)="Rename \1T"+chr$(10)+"o \2"+chr$(10)+chr$(10)
CONVBEGINTO$(21)="NAME \1AS \2"+chr$(10)
CONVANYFROM$(1)="Instr(\1,"+Chr$(10)+"\2,)\3)"+Chr$(10)
CONVANYTO$(1)="INSTR(\3,\1,\2)"
CONVANYFROM$(2)="Deek(\1)"+Chr$(10)
CONVANYTO$(2)="PEEKW(\1)"
CONVANYFROM$(3)="Leek(\1)"+Chr$(10)
CONVANYTO$(3)="PEEKL(\1)"
CONVANYFROM$(4)="Free"
CONVANYTO$(4)="FRE(-1)"
CONVANYFROM$(5)="Upper$(\1)"+Chr$(10)
CONVANYTO$(5)="UCASE$(\1)"
CONVANYFROM$(6)="Rnd(\1)"+Chr$(10)
CONVANYTO$(6)="RND"
CONVANYFROM$(7)="Hex$(\1,"+Chr$(10)+"\2)"+Chr$(10)
CONVANYTO$(7)="HEX$(\1)"
CONVANYFROM$(8)="Bin$(\1,"+Chr$(10)+"\2)"+Chr$(10)
CONVANYTO$(8)="BIN$(\1)"
CONVANYFROM$(9)="String$(\1,"+Chr$(10)+"\2)"+Chr$(10)
CONVANYTO$(9)="STRING$(\2,\1)"
CONVANYFROM$(10)="Lower$(\1)"+Chr$(10)
CONVANYTO$(10)="LCASE$(\1)"
Return 
