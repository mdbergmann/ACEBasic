
{********************************************************************
** NAP_Mods : Sub modules needed by NAP.                           **
**                                                                 **
** For information about the copyright read the corresponding sec- **
** tion in NAP.doc, since these modules are part of NAP.           **
*********************************************************************
** Copy - copies a string into an allocated memoryblock            **
**                                                                 **
**   Syntax : memorypos = Copy(text)                               **
**                                                                 **
**     memorypos      : (address) a pointer to the memory block    **
**                      the string has been copied to              **
**     text           : (string) the string to be stored           **
**                                                                 **
** Comment : There'll be no checking whether the memory block has  **
**           been allocated successfully !!!                       **
*********************************************************************
** Search2 - replace of INSTR (faster than INSTR)                  **
**                                                                 **
**   Syntax : found_position = Search2(start,text,snippet)         **
**                                                                 **
**     found_position : (shortint) Contains the number of the byte **
**                      where the strings match/0 if nothing found **
**     start          : (shortint) where to start comparing        **
**     text           : (string) String to be searched             **
**     snippet        : (string) String to look for in <text>      **
**                                                                 **
**  Comment : <start> is NOT optional                              **
*********************************************************************
** Legal - checks whether a specified byte of a string is within a **
**         comment ala ACE or within a string                      **
**                                                                 **
**   Syntax : Result = Legal(text,position)                        **
**                                                                 **
**     Result         : (shortint) Is 1 if neither within a string **
**                      nor a comment. Otherwise 0                 **
**     Text           : (string)                                   **
**     Position       : (shortint) byte to check                   **
*********************************************************************
** UpperCase$ - makes a string uppercase (faster than UCASE$)      **
**                                                                 **
**   Syntax : upcase = UpperCase$(lowercase)                       **
**                                                                 **
**     upcase         : (string) same as <lowercase> but uppercase **
**     lowercase      : (string) string to be upcased              **
*********************************************************************
** AlreadyInList - checks whether a specified string is already    **
**                 saved in a certain list                         **
**                                                                 **
**   Syntax : Result = AlreadyInList(begin_of_list,what)           **
**                                                                 **
**     result         : (address) Pointer to entry, 0 if none      **
**     begin_of_list  : (address) pointer to the first entry of a  **
**                      "LinkedList"                               **
**     what           : (string) String to be looked for           **
**                                                                 **
** Comment : This routine is since NAP 2.00b2 obsolete. Before it  **
**           I used my own linked structures but since then NAP is **
**           using the exec structures which are also supported by **
**           some exec routines, namely FindName& which does re-   **
**           place AlreadyInList since version 2.00b2              **
*********************************************************************
** CutOff - cuts off the right part of a string after a specified  **
**          position, if this position is neither within a comment **
**          nor a string                                           **
**                                                                 **
**   Syntax : cutted = CutOff(text,position)                       **
**                                                                 **
**     cutted         : (string) cutted string                     **
**     text           : (string) string to be cutted               **
**     position       : (shortint) position from which to cut      **
**                                                                 **
** Comment : To recognize whether <position> is within a string or **
**           a comment the LEGAL routine (see above) is used.      **
*********************************************************************
** Get_name_of_object : Gets the next text within a string that is **
**                      embetted in spaces                         **
**                                                                 **
**   Syntax : object = Get_name_of_object (startpos,text)          **
**                                                                 **
**     object         : (string) name of object                    **
**     startpos       : (shortint) where to start looking for      **
**     text           : (string) string to be gone through         **
*********************************************************************
** Get_name_of_object_alt : Same as "Get_name_of_object" but looks **
**                          for a string that is not within a-Z,   **
**                          0-9, "_" and "."                       **
*********************************************************************
** ReplaceC : Replaces a certain text within a specified string    **
**                                                                 **
**   Syntax : replaced = ReplaceC(text,toReplace,replace)          **
**                                                                 **
**     replaced       : (string) returned string where the text    **
**                      has been replaced                          **
**     text           : (string) the string where the replacement  **
**                      shall happen                               **
**     toReplace      : (string) text which shall be replaced      **
**     replace        : (string) text which shall be put in        **
*********************************************************************
** ParseExpr : Parses a mathematical expression                    **
**                                                                 **
**   Syntax : result = ParseExpr(expression)                       **
**                                                                 **
**     result         : (single) result of the expression          **
**     expression     : (string) expression to be parsed           **
**                                                                 **
** Comment: Does only support +, -, /, *, \, (, and ). Parentheses **
**          must not be nested. = statements are implemented and   **
**          if both sides of the = are mathematical the same a 1   **
**          will be returned, otherwise a 0.                       **
*********************************************************************



*********************************************************************
** Special thanks go to  Herbert Breuer  who not just supported me **
** with great moral support during my work on  NAP   but also with **
** tips, hints and ideas, especially for the assembler routines.   **
********************************************************************}

' structure definition, must be the same as in NAP.b

STRUCT Node
 address   ln_Succ
 address   ln_Pred
 BYTE      ln_Type
 BYTE      ln_Pri
 ADDRESS   ln_Name
END STRUCT

STRUCT _List
 address   lh_Head
 address   lh_Tail
 address   lh_TailPred
 BYTE      lh_Type
 BYTE      l_pad
END STRUCT

STRUCT StructNode
 address   ln_Succ
 address   ln_Pred
 BYTE      ln_Type
 BYTE      ln_Pri
 ADDRESS   ln_Name
 ADDRESS   member_types_list
END STRUCT

STRUCT DefineNode
 address   ln_Succ
 address   ln_Pred
 BYTE      ln_Type
 BYTE      ln_Pri
 ADDRESS   ln_Name
 STRING    replace SIZE 200
 SHORTINT  countparam
END STRUCT


sub address copy (string text) external
 string dummy address alloc(len(text)+1,7)

 ' Let ACE do the hard work ;)
 dummy=text
 copy=@dummy
end sub

sub shortint Search2 (shortint start,string text,string snippet) external
 external longint _address1
 external longint _address2
 external longint _result

 _result=start
 _address1=@text
 _address2=@snippet

 ASSEM

      movem.l  a1-a3/d0-d2/d5,-(a7)         'save registers

      move.l   _address1,a1                 'set values
      move.l   _address2,a2
      move.l   _result,d2
      subq.l   #1,d2
      adda.l   d2,a1
      move.b   (a2)+,d0                     'first byte of string2 to d0
      move.l   a2,a3                        'begin of string2 (store)

      sub.l    d5,d5                        'clear d5

  search_loop1:

      cmp.b    #0,(a1)                      'end of string1?
      beq.s    search_exit                  'if yes, exit

      cmp.b    (a1)+,d0                     'equal to begin of string2?
      bne.s    search_loop1                 'if not, repeat loop

      move.l   a3,a2                        'begin of string2+1 to a2
      move.l   a1,d1                        'backup of a1 to d1

  search_loop2:

      cmp.b    #0,(a2)                      'end of string2?
      beq.s    search_found                 'if yes, exit (found :)

      cmpm.b   (a1)+,(a2)+                  'compare next byte
      beq.s    search_loop2                 'if equal repeat loop

      move.l   d1,a1                        'restore pointer
      bra.s    search_loop1                 'repeat outer loop

  search_found:

      move.l   d1,d5                        'begin of string2 in d1 to d5
      move.l   _address1,d1                 'calculate difference between
      sub.l    d1,d5                        ' found pos and begin of string1

  search_exit:

      move.l   d5,_result                   'move result to _result
      movem.l  (a7)+,a1-a3/d0-d2/d5         'restore registers

 END ASSEM

 Search2=_result
End SUB

sub shortint legal (string text,shortint position) external
 EXTERNAL longint _result
 EXTERNAL longint _address1

 _address1=@text
 _result=position

 ASSEM

       movem.l a0/d0-d3/d5-d7,-(a7)      ' The comments for this routine
                                         ' will be written when it should
       move.l  _address1,a0              ' happen to me to get some time
       move.l  _result,d0                ' left (perhaps next year)
       add.l   d0,a0                     ' I assume this routine to be
       move.b  #0,-(a0)                  ' very optimizable ...
       move.l  _address1,a0

       moveq   #0,d1
       moveq   #0,d5
       moveq   #0,d6
       moveq   #0,d7

       cmp.b   #1,d0
       ble     _leg_set
       subq    #1,d0

  _leg_loop:

       cmp.l   d1,d0
       beq.s   _leg_exit

       move.b  (a0)+,d2
       addq    #1,d1

       cmp.b   #123,d2
       beq.s   _leg_c1
       cmp.b   #34,d2
       beq.s   _leg_c3
       cmp.b   #39,d2
       beq.s   _leg_c4
       cmp.b   #82,d2
       beq.s   _leg_REM
       bra.s   _leg_loop

  _leg_c1:

       moveq   #1,d5

  _leg_c1_loop:

       cmp.b   #0,(a0)
       beq.s   _leg_exit
       addq    #1,d1
       cmp.b   #125,(a0)+
       bne.s   _leg_c1_loop
       moveq   #0,d5
       bra.s   _leg_loop

  _leg_c3:

       moveq   #1,d6

  _leg_c3_loop:

       cmp.b   #0,(a0)
       beq.s   _leg_exit
       addq    #1,d1
       cmp.b   #34,(a0)+
       bne.s   _leg_c3_loop
       moveq   #0,d6
       bra.s   _leg_loop

  _leg_c4:

       cmp.b   #0,d6
       bne.s   _leg_loop

       addq    #1,d7
       bra.s   _leg_exit

  _leg_REM:

       cmp.b   #0,d6
       bne.s   _leg_loop

       addq    #1,d1
       cmp.b   #69,(a0)+
       bne.s   _leg_loop
       cmp.b   #77,(a0)+
       bne.s   _leg_loop
       cmp.b   #32,(a0)+
       bne.s   _leg_loop

       addq    #1,d7

  _leg_exit:

       move.l  #0,_result

       add.l   d5,d7
       add.l   d6,d7
       cmp.b   #0,d7
       beq.s   _leg_set
       bra.s   _leg_end

  _leg_set:

       move.l  #1,_result

  _leg_end:

       movem.l (a7)+,a0/d0-d3/d5-d7

 END ASSEM

 Legal=_result
end sub

sub uppercase$(string lowercase) external
 external longint _address3
 _address3=@lowercase

 ASSEM

              movem.l   a0,-(a7)
              move.l    _address3,a0

    uc_loop:

              cmp.b     #97,(a0)
              blt.s     uc_loop_next

              cmp.b     #122,(a0)
              bgt.s     uc_loop_next

              bclr.b    #5,(a0)

    uc_loop_next:

              tst.b    (a0)+
              bne.s    uc_loop

              movem.l  (a7)+,a0

 END ASSEM

 uppercase$=lowercase
END SUB

sub string CutOff (string text,shortint FoundSth) external
 if legal(text,FoundSth) then CutOff=left$(text,FoundSth-1) else CutOff=text
end sub

SUB STRING Get_name_of_object (SHORTINT startpos, STRING text) external
 EXTERNAL LONGINT _start
 EXTERNAL LONGINT _end
 EXTERNAL LONGINT _pointer

 _start=startpos-1
 _end=0
 _pointer=@text

 ASSEM

     movem.l  d0-d5/a0,-(a7)           { save registers              }
     move.l   _pointer,a0
     add.l    _start,a0
     moveq.l  #0,d0

  _gno_loop1:

     move.b   (a0),d0
     sub.b    #32,d0                   { <> SPACE -> exit            }
     bne.s    _gno_ex_l1
     add.l    #1,a0
     bra.s    _gno_loop1

  _gno_ex_l1:

     move.l   a0,_pointer

  _gno_loop2:

     move.b   (a0)+,d0
     sub.b    #0,d0
     beq.s    _gno_exit                { = EOS -> exit               }

     sub.b    #32,d0
     beq.s    _gno_exit                { = SPACE -> exit             }

     bra.s    _gno_loop2               { else repeat                 }

  _gno_exit:

     move.l   a0,_end
     movem.l  (a7)+,d0-d5/a0           { restore registers           }

 END ASSEM

 Get_name_of_object=left$(CSTR(_pointer),_end-_pointer-1)
END SUB

SUB STRING Get_name_of_object_alt (SHORTINT startpos, STRING text) external
 EXTERNAL LONGINT _start
 EXTERNAL LONGINT _end
 EXTERNAL LONGINT _pointer

 _start=startpos
 _end=0
 _pointer=@text

 ASSEM

     movem.l  d0-d5/a0,-(a7)           ' save registers
     move.l   _pointer,a0              ' set values
     add.l    _start,a0                ' add start difference
     moveq.l  #0,d0
     subq.l   #1,a0

  _gnoa_loop1:

     move.b   (a0)+,d0

     cmp.b    #0,d0
     beq.s    _gnoa_ex_l1

     cmp.b    #46,d0                   ' = "." then exit
     beq.s    _gnoa_ex_l1

     cmp.b    #48,d0                   ' < "0" then repeat
     blt.s    _gnoa_loop1
     cmp.b    #57,d0                   ' <= "9" then exit
     ble.s    _gnoa_ex_l1

     cmp.b    #65,d0                   ' < "A" then repeat
     blt.s    _gnoa_loop1
     cmp.b    #90,d0                   ' <= "Z" then exit
     ble.s    _gnoa_ex_l1

     cmp.b    #95,d0                   ' = "_" then exit
     beq.s    _gnoa_ex_l1

     cmp.b    #97,d0                   ' < "a" then repeat
     blt.s    _gnoa_loop1
     cmp.b    #122,d0                  ' > "z" then repeat
     bgt.s    _gnoa_loop1

  _gnoa_ex_l1:

     subq.l   #1,a0
     move.l   a0,_pointer

  _gnoa_loop2:

     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq.s    _gnoa_exit                { = EOS -> exit               }

     cmp.b    #46,d0                   ' = "." then repeat
     beq.s    _gnoa_loop2

     cmp.b    #48,d0                   ' < "0" then exit
     blt.s    _gnoa_exit
     cmp.b    #57,d0                   ' <= "9" then repeat
     ble.s    _gnoa_loop2

     cmp.b    #65,d0                   ' < "A" then exit
     blt.s    _gnoa_exit
     cmp.b    #90,d0                   ' <= "Z" then repeat
     ble.s    _gnoa_loop2

     cmp.b    #95,d0                   ' = "_" then repeat
     beq.s    _gnoa_loop2

     cmp.b    #97,d0                   ' < "a" then exit
     blt.s    _gnoa_exit
     cmp.b    #122,d0                  ' <= "z" then repeat
     ble.s    _gnoa_loop2

  _gnoa_exit:

     move.l   a0,_end
     movem.l  (a7)+,d0-d5/a0           { restore registers           }

 END ASSEM

 Get_name_of_object_alt=left$(CSTR(_pointer),_end-_pointer-1)
END SUB

{* This routine is obsolete since NAP V2.00b2. I have included it  **
** because there might be use. In further versions this routine    **
** won't be implemented any more ! Contact me if you wanna know    **
** how to use it (special structures!)                             *}
sub address AlreadyInList (address begin_of_list,string what) external
 external longint _result
 external longint _address1
 external longint _address2

 _address1=begin_of_list
 _address2=@what

 ASSEM

     movem.l  a0-a1,-(sp)
     move.l   _address1,a0
     move.l   _address2,a1
     move.l   #0,_result

  AL_loop:

     cmp.l    #0,100(a0)               ' 100 = Offset for nextone
     beq.s    AL_exit

     movea.l  a1,a2
     movea.l  a0,a3

  AL_comploop:

     cmpm.b   (a2)+,(a3)+
     beq.s    AL_comploop_2

     move.l   100(a0),a0
     bra.s    AL_loop

  AL_comploop_2:

     cmp.b    #0,-(a2)
     beq.s    AL_comploop_exit
     addq     #1,a2
     bra.s    AL_comploop

  AL_comploop_exit:

     move.l   a0,_result

  AL_exit:

     movem.l  (sp)+,a0-a1

 END ASSEM

 AlreadyInList=_result
END SUB

SUB STRING ReplaceC (string text,string toReplace,string replace) external
 shortint foundsth

 foundSth=search2(1,text,toReplace)
 WHILE foundSth
  IF legal(text,foundsth) THEN text=LEFT$(text,foundsth-1)+~
                                    replace+MID$(text,foundsth+2)
  foundSth=search2(foundsth+1,text,toReplace)
 WEND
 ReplaceC=text
END SUB

{* Could be optimized in later versions and even expanded!         *}
SUB SINGLE ParseExpr(STRING expression_org) EXTERNAL
 SHORTINT i,j,foundend,start,ende,escape,doubleExpr
 SINGLE   erg,erg2
 STRING   char SIZE 2
 STRING   lexpr,rexpr,operators SIZE 20
 STRING   expression ADDRESS ALLOC(1025,7)

 expression=expression_org


 start=INSTR(1,expression,"=")
 IF start THEN
  ++doubleExpr
  erg2=ParseExpr(MID$(expression,start+1))
  expression=LEFT$(expression,start-1)
 END IF

 REPEAT
  start=INSTR(1,expression,"(")
  IF start THEN
   ende=INSTR(1,expression,")")
   expression=LEFT$(expression,start-1)+~
              STR$(ParseExpr(MID$(expression,start+1,ende-start-1)))+~
              MID$(expression,ende+1)
   EXIT FOR
  ELSE
   ++escape
  END IF
 UNTIL escape

 operators="+-/*\"

 --escape
 REPEAT
  FOR i=1 TO LEN(expression)
   char=MID$(expression,i,1)
   IF char="*" OR char="\" OR char="/" THEN
    start=1
    FOR j=i-1 TO 1 STEP -1
     IF INSTR(1,operators,MID$(expression,j,1)) THEN
      IF j>1 THEN
       IF INSTR(1,operators,MID$(expression,j-1,1))=0 THEN
        start=j+1
        EXIT FOR
       END IF
      END IF
     END IF
    NEXT
    lexpr=MID$(expression,start,i-start)
    IF lexpr="" THEN ++escape

    ende=LEN(Expression)
    FOR j=i+1 TO len(expression)
     IF INSTR(1,operators,MID$(expression,j,1)) THEN
      IF j>i+1 THEN ende=j-1:EXIT FOR
     END IF
    NEXT
    rexpr=MID$(expression,i+1,ende-i)

    CASE
     char="*":erg=VAL(lexpr)*VAL(rexpr)
     char="\":erg=VAL(lexpr)\VAL(rexpr)
     char="/":erg=VAL(lexpr)/VAL(rexpr)
    END CASE

    expression=LEFT$(expression,start-1)+STR$(erg)+MID$(expression,ende+1)
    EXIT FOR
   ELSE
    IF i=LEN(expression) THEN ++escape
   END IF
  NEXT
 UNTIL escape

 --escape
 REPEAT
  FOR i=2 TO LEN(expression)
   char=MID$(expression,i,1)
   IF char="+" OR char="-" THEN
    lexpr=LEFT$(expression,i-1)
    expression=MID$(expression,i+1)

    FOR j=1 TO LEN(expression)
     IF INSTR(1,operators,MID$(expression,j,1)) THEN
      IF j>1 THEN
       rexpr=LEFT$(expression,j-1)
       expression=MID$(expression,j)
       EXIT FOR
      END IF
     ELSE
      rexpr=LEFT$(expression,j)
      IF j=LEN(expression) THEN expression=""
     END IF
    NEXT

    CASE
     char="-":erg=VAL(lexpr)-VAL(rexpr)
     char="+":erg=VAL(lexpr)+VAL(rexpr)
    END CASE

    expression=STR$(erg)+expression
    EXIT FOR
   ELSE
    IF i=LEN(expression) THEN ++escape
   END IF
  NEXT
 UNTIL escape

 IF DoubleExpr THEN
  IF VAL(expression)=erg2 THEN
   expression="1"
  ELSE
   expression="0"
  END IF
 END IF

 ParseExpr=val(expression)
end sub

ASSEM
 _address1: dc.l 0
 _address2: dc.l 0
 _address3: dc.l 0
 _result:   dc.l 0
 _start:    dc.l 0
 _pointer:  dc.l 0
 _end:      dc.l 0
END ASSEM
