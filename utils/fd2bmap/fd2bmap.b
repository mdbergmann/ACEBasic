REM
REM FD2BMAP Library DestDir
REM
REM    by Harald Schneider
REM
REM    Converts FD-File to a ACE-BMAP File like Commodores ConvertFD.
REM
REM    Example: FD2BMAP l/dos RAM: reads l/dos_lib.fd and creates RAM:dos.bmap
REM
REM    Differences to ConvertFD:
REM		   - #private marked entries are skipped
REM         - Unlike AmigaBasic ACE allows the use of A5 for parameters so
REM           functions uses A5 are not ignored
REM    Name collision of ACE keywords and library calls are handled like
REM    ConvertFD (Read --> _Read    -    note: prior to v1.2, it used to be
REM		  			       that 'x' rather than '_' was
REM					       prefixed to the identifier).

REM Modified by David Benn: 10th,17th January, 10th August 1994,
REM			    15th October 1994, 15th September 1995

ver_str$ = "$VER: FD2BMAP V1.2 (15.09.95)"

DECLARE SUB Assert(FTxt&)
DECLARE SUB TRIM$(Txt$)

CONST Num_Keys=8	:REM Number of keywords in collision list - 1

REM Errornumbers
CONST Err_No_Offset=0
CONST Err_Func_Name=1
CONST Err_Para_Kl_a=2
CONST Err_Para_Kl_z=3
CONST Err_Func_Kl_a=4
CONST Err_Func_Kl_z=5
CONST Err_Illegal_Reg=6
CONST Err_Illegal_Nr=7
CONST Err_Sep=8
CONST Err_Reg_List=9
CONST NumErrs=9

DIM KeyWords$(Num_Keys),FailTxt$(NumErrs)

REM Error descriptions
FailTxt$(Err_No_Offset)="Missing ##bias"
FailTxt$(Err_Func_Name)="Missing function name"
FailTxt$(Err_Para_Kl_a)="'(' of parameter list expected"
FailTxt$(Err_Para_Kl_z)="')' of parameter list expected"
FailTxt$(Err_Func_Kl_a)="'(' of function list expected"
FailTxt$(Err_Func_Kl_z)="')' of function list expected"
FailTxt$(Err_Illegal_Reg)="Illegal register type (Ax or Dx)"
FailTxt$(Err_Illegal_Nr)="Illegal register number (0-7)"
FailTxt$(Err_Sep)="',' or '/' between register expected"
FailTxt$(Err_Reg_List)="register list currupted"


IF ARGCOUNT<>2 THEN
	PRINT "usage: ";ARG$(0);" libraryname DestinationDir"
	PRINT "   eg: ";ARG$(0);" sys:fd/2.0/asl ACEbmaps:"
	STOP
END IF

FName$=ARG$(1)
DestDir$=ARG$(2)

Source$=FName$+"_LIB.FD"
OPEN "i",1,Source$
IF HANDLE(1)=0 THEN
	PRINT "Cannot open ";Source$
   STOP
END IF

Dest$=FName$
i&=LEN(FName$)
WHILE i&<>0
	ch$=MID$(FName$,i&,1)
	IF ch$=":" OR ch$="/" THEN
		Dest$=MID$(FName$,i&+1)
		i&=0
	ELSE
		--i&
	END IF
WEND

IF DestDir$<>CHR$(34)+CHR$(34) THEN
	ch$=RIGHT$(DestDir$,1)
	IF ch$<>"/" AND ch$<>":" THEN
		DestDir$=DestDir$
	END IF
ELSE
	DestDir$=""
END IF
Dest$=DestDir$+Dest$+".BMAP"
OPEN "o",2,Dest$
IF HANDLE(2)=0 THEN
	PRINT "Cannot open ";Dest$
	CLOSE 1
	STOP
END IF

FOR i%=0 TO Num_Keys
	READ KeyWords$(i%)
NEXT i%

DATA "Close","Exit","Input","Open","Read","Translate","Wait","Write","Output"


ON BREAK GOTO quit.prg
BREAK ON

print
print "Creating ";Dest$;"..."
print

FuncOffset%=-1   :REM Holds the Offset for each library call
WriteFlag%=1     :REM Switch that enables/disable writing .FD-function in bmap
NumLine&=0		  :REM number read .FD lines
WHILE NOT EOF(1)
	LINE INPUT #1,FD$
	++NumLine&
	IF LEN(FD$)>0 THEN
		IF LEFT$(FD$,1)<>"*" THEN
			IF LEFT$(FD$,2)="##" THEN
				FD$=UCASE$(FD$)
				IF LEFT$(FD$,7)="##BIAS " THEN
					REM functionbase
					FuncOffset%=-VAL(TRIM$(MID$(FD$,7)))
				ELSE
					IF LEFT$(FD$,8)="##PUBLIC" THEN
   					REM enable writing
						WriteFlag%=1
					ELSE
						IF LEFT$(FD$,9)="##PRIVATE" THEN
							rem disable writing
							REM WriteFlag%=0
						END IF
					END IF
				END IF
			ELSE
				IF FuncOffset%=-1 THEN
					Assert(Err_No_Offset)
				END IF
				IF WriteFlag% THEN
					REM then it must be a library function
					REM checking if the syntax is ok
					pop1&=INSTR(FD$,"(")
					IF pop1&=1 THEN
						Assert(Err_Func_Name)
					END IF
					IF pop1&=0 THEN
						Assert(Err_Para_Kl_a)
					END IF
					pop2&=INSTR(FD$,")")
					IF pop2&=0 THEN
						Assert(Err_Para_Kl_z)
					END IF
					IF pop2&<pop1& THEN
						Assert(Err_Para_Kl_a)
					END IF

					pof1&=INSTR(pop1&+1,FD$,"(")
					pof2&=INSTR(pop2&+1,FD$,")")

					'..No 2nd set of parentheses (for regs)?
					'..(eg. Forbid() in Extras/FD1.3)
					IF pof1&=0 and pof2&=0 THEN get_name
 
					'..Check for errors if 2nd set of 
					'..parentheses do exist.
					IF pof1&=0 THEN
						Assert(Err_Func_Kl_a)
					END IF
					IF pof1&<pop2& THEN
						Assert(Err_Para_Kl_z)
					END IF
					IF pof2&=0 THEN
						Assert(Err_Func_Kl_z)
					END IF
					IF pof2&<pof1& THEN
						Assert(Err_Func_Kl_a)
					END IF


				get_name:

					REM isolate name of library function
					FuncName$=TRIM$(LEFT$(FD$,pop1&-1))
					IF FuncName$="" THEN
						Assert(Err_Func_Name)
					END IF

					'..Registers specified?
					IF pof1&=0 and pof2&=0 THEN
					  Regs$=""
					ELSE
		  			  Regs$=UCASE$(TRIM$(MID$(FD$,pof1&+1, ~
						       pof2&-pof1&-1)))
					END IF

					REM remove all spaces
					IF Regs$<>"" THEN
					  i&=2:ln&=LEN(Regs$)
					  WHILE i&<ln&
						IF MID$(Regs$,i&,1)=" " THEN
						  Regs$=LEFT$(Regs$,i&-1)+ ~ 
						        MID$(Regs$,i&+1)
						  --ln&
						ELSE
						  ++i&
						END IF
					  WEND
					END IF

					print FuncName$;tab(25);Regs$

					RegOk&=1 :REM no unsupported register 
						 :REM specified ?
					RegList$="" :REM used registers
					REM examine register list

					'..If no register list given -> just 
					'..write other info to bmap file.
					if pof1&=0 and pof2&=0 then write_bmap

					WHILE Regs$<>"" AND RegOk&
						IF LEN(Regs$)>=2 THEN
							ch$=LEFT$(Regs$,1)
							IF ch$="D" THEN
								RegNum&=1
							ELSE
								IF ch$="A" THEN
									RegNum&=9
								ELSE
									Assert(Err_Illegal_Reg)
								END IF
							END IF
							we&=VAL(MID$(Regs$,2,1))
							IF we&>7 THEN
								Assert(Err_Illegal_Nr)
							END IF
							RegNum&=RegNum&+we&
							IF RegNum&>14 THEN
								PRINT "Warning: ";FuncName$;" requires register(s) ";
								PRINT "ACE doesn't support register. Function ignored!"
								RegOk&=0
		               END IF
							RegList$=RegList$+CHR$(RegNum&)
							IF LEN(Regs$)>=3 THEN
								ch$=MID$(Regs$,3,1)
								IF ch$<>"," AND ch$<>"/" THEN
									Assert(Err_Sep)
								END IF
							   Regs$=MID$(Regs$,4)
							ELSE
								Regs$=""
							END IF
						ELSE
							Assert(Err_Reg_List)
						END IF
					WEND


				write_bmap:

					REM write to .BMAP file if regs ok
               				IF RegOk& THEN
					  REM check & eliminate name collisions
					  FOR i%=0 TO Num_Keys
					    IF FuncName$=KeyWords$(i%) THEN
						  FuncName$="_" + FuncName$
						  i%=NumKeys
					    END IF
					  NEXT i%

					  REM make offset writeable 
					  Off$="  ":Off&=@Off$
					  POKEW Off&,FuncOffset%
					  PRINT #2,FuncName$;CHR$(0); ~
						   CHR$(PEEK(Off&)); ~
						   CHR$(PEEK(Off&+1));
					  IF RegList$<>"" THEN
						PRINT #2,RegList$;
					  END IF
					  PRINT #2,CHR$(0);
					END IF
				END IF
				FuncOffset%=FuncOffset%-6
			END IF
		END IF
	END IF
WEND

'..finish up
print
print Dest$;" created."
print

CLOSE 2
CLOSE 1
STOP

quit.prg:
  print "***Break: ";ARG$(0);" terminating."
  CLOSE 2
  CLOSE 1
  KILL Dest$
  print "Destination file removed."
  STOP

SUB Assert(FTxt&)
	SHARED NumLine&,FailTxt$
	PRINT "ERROR in line";NumLine&;FailTxt$(FTxt&)
	CLOSE 2
	CLOSE 1
 	STOP
END SUB

SUB TRIM$(st$)
	SHORTINT ln
	LONGINT StStart,AdrAnf,AdrEnd
	ln=LEN(st$)
	IF ln<>0 THEN
		StStart=SADD(st$)
   	AdrAnf=StStart: AdrEnd=StStart+ln-1

	   WHILE PEEK(AdrAnf)=32 AND AdrAnf<=AdrEnd
			++AdrAnf
		WEND

		WHILE PEEK(AdrEnd)=32 AND AdrEnd>AdrAnf
   		--AdrEnd
		WEND
		IF AdrAnf>AdrEnd THEN
			TRIM$=""
		ELSE
			TRIM$=MID$(st$,AdrAnf-StStart+1,AdrEnd-AdrAnf+1)
	   END IF
	ELSE
		TRIM$=""
	END IF
END SUB
