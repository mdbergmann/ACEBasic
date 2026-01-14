{* Header *******************************************************************
**                                                                         **
** Program     :  NAP (New ACE Preprocessor)                               **
** Author      :  Daniel Seifert <dseifert@hell1og.be.schule.de>           **
**                                                                         **
** Version     :  2    !!! Pre-release !!!                                 **
** Revision    :  00b3 !!! testversion !!!                                 **
**                                                                         **
** work done at:  02,04-07,14-17,23,28-29-Mar-1996                         **
**                28-Apr-1996                                              **
**                04,07,10-May-1996                                        **
**                19-20,23-30-Jun-1996                                     **
**                01-04,07,12,15-19,22-24,26-Jul-1996                      **
**                01-04,11,17-August-1996                                  **
** language    :  ACE Basic, V2.37                                         **
**                                                                         **
** description :  a preprocessor especially for ACE Basic                  **
**                                                                         **
** copyright   :  Daniel Seifert                                           **
** comment     :  read the manual for further details before 1st use       **
****************************************************************************}


DEFint a-Z

{* CR is Carriage Return whereas LF is LineFeed.                   *}
STRING   CR,LF SIZE 2

{* opt is used to save the options got from the CLI-line and Temp- **
** file contains the name of the temporary file whereas InFile and **
** Outfile specifies the files to read from or write to.           *}
STRING   opt SIZE 13
STRING   InFile,OutFile,TempFile SIZE 125
STRING   argument,token,value,object SIZE 100

{* These integers are used to mark different conditions which have **
** a default value that can be inversed by using the options.      *}
SHORTINT Remove_Structs,Remove_Comments,Remove_Defines,Const_Defines
SHORTINT Replace_Defines,Print_Errors

{* For buffer handling                                             *}
LONGINT MaxBuffer,BufferPtrBase

{* For list handling                                               *}
ADDRESS defines,include,needed_structs,structures

{* For file handling                                               *}
ADDRESS PathPtr

{* This is the path and filename of the temporary file. As I sus-  **
** pect T: to point to RAM:t you must change perhaps your assigns? *}
TempFile="t:NAP.temp"

{* In the following array the directory names to be searched thru  **
** for include files.                                              *}
DIM STRING Path(9) SIZE 100
PathPtr=@Path(0)
Path(1)="ACEINCLUDE:"

{* This array is used to save the different bases of the lists     *}
DIM ADDRESS StrucBase(3)

{* In the following array the beginnings and the sizes of the file **
** buffers will be stored.                                         *}
DIM ADDRESS BufferPtr(9,1)
BufferPtrBase=@BufferPtr(0,0)

' structure definition

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

library dos
declare function xRead&(address filehandler,address buffer,longint bytes) library dos
declare function xWrite&(address filehandler,address buffer,longint bytes) library dos
declare function Seek&(address filehandler,longint offset,longint modus) library dos

library exec
declare function Remove(address nodeptr) library exec
declare function AddTail&(address listptr,address nodeptr) library exec
declare function FindName&(address listptr,address stringptr) library exec
declare function FreeMem&(address memoryblock,longint bytesize) library exec
declare function AllocMem&(longint bytesize,longint requirements) library exec

{* All these sub programs are in NAP_Mods.o to be linked with BLINK. *}
DECLARE SUB ADDRESS  Copy (string text) EXTERNAL
DECLARE SUB SHORTINT legal (STRING text,SHORTINT position) EXTERNAL
DECLARE SUB STRING   UpperCase$(STRING lowercase) EXTERNAL
DECLARE SUB STRING   CutOff (STRING text,SHORTINT FoundSth) EXTERNAL
DECLARE SUB SHORTINT Search2(SHORTINT start,STRING text,STRING snippet) EXTERNAL
DECLARE SUB STRING   Get_name_of_object (SHORTINT startpos, STRING text) EXTERNAL
DECLARE SUB STRING   Get_name_of_object_alt (SHORTINT startpos, STRING text) EXTERNAL
DECLARE SUB STRING   ReplaceC (STRING text,STRING toReplace,STRING replace) EXTERNAL
DECLARE SUB SINGLE   ParseExpr (STRING expression) EXTERNAL

{ ----------------------------------------------------------------- }

{* This function is made to replace the "LINE INPUT #" command. It **
** is faster and easier to handle because it is a function. It is  **
** fully compatible with ACE's file handling and gives always the  **
** same result as "LINE INPUT #".                                  **
** To made this routine faster there is a buffered reading imple-  **
** mented. BufferPtrBase points to an array with the dimension (9, **
** 1), whereas the 1st field is the filenumber. If the second one  **
** is 0, we are getting the address of the buffer. The length of   **
** this buffer can be obtained with 0.                             *}
sub string lese(shortint filenumber)
 shared BufferPtrBase
 DIM ADDRESS BufferPointer(9,1) ADDRESS BufferPtrBase

 string   text
 address  DataPtr,position,BufferPtr
 longint  DataPos,gelesen,MaxBuffer
 shortint escape

 external longint _StartData

 BufferPtr=BufferPointer(filenumber,0)

 DataPtr=BufferPtr+2
 DataPos=peekw(BufferPtr)

 Repeat
  position=DataPtr+DataPos
  _StartData=position

  {* The following assembler routine searches from a specified po- **
  ** sition the memory for an identifer to mark the end of line.   **
  ** If a 0 (NUL) is found the routine assumes that the buffer has **
  ** been read to the end. If it founds something between 1 and 10 **
  ** it thinks that the line is finished.                          *}
  ASSEM

         movem.l   a0,(sp)+                ; rescue registers
         move.l    _StartData,a0           ; store in a0 the position

    _lese_loop:

         cmp.b     #10,(a0)+               ; if >10 then increase
         bgt.s     _lese_loop              ; and repeat

         cmp.b     #0,-(a0)                ; if 0 then goto _lese_eof
         beq.s     _lese_eof

         move.b    #0,(a0)                 ; otherwise move a 0 to it
         bra.s     _lese_end               ; and exit

    _lese_eof:

         sub.l     a0,a0

    _lese_end:

         move.l    a0,_StartData           ; store result
         movem.l   -(sp),a0                ; restore registers

  END ASSEM

  if _StartData=0 then
   text=text+cstr(position)
   MaxBuffer=BufferPointer(filenumber,1)-3
   gelesen=xRead&(handle(filenumber),DataPtr,maxbuffer)
   case
    gelesen=0        :Poke DataPtr+maxbuffer,1:lese=text:exit sub
    gelesen<MaxBuffer:Poke DataPtr+gelesen,0
   end case
   DataPos=0
  else
   ++escape
   string dummy address position
   DataPos=DataPos+len(dummy)
   ++DataPos
   Pokew BufferPtr,DataPos
   dummy=text+dummy
  end if
 until escape
 lese=dummy
end sub

ASSEM
_StartData: dc.l 0
end assem

{* ENDE closes all files and kills the temporary file.  It is used **
** when doing a CTRL-C or when NAP finishs.                        *}
SUB ende
 SHARED TempFile,OutFile,BufferPtrBase
 DIM ADDRESS BufferPtr(9,1) ADDRESS BufferPtrBase

 FOR i=1 TO 9
  CLOSE #i
  if BufferPtr(i,0) then call FreeMem&(BufferPtr(i,0),BufferPtr(i,1))
 NEXT

 CLEAR ALLOC
 If TempFile<>OutFile then KILL TempFile
 STOP
END SUB


{* This routine prints an error message to standard output. There- **
** fore the Print_Errors variable must be set, otherwise the error **
** message would be suppressed.                                    *}
sub PrErr (string text)
 shared Print_Errors

 if Print_Errors then print "-- Error : "text
end sub

{* This sub program is made to replace the "PUT #" command. It is  **
** also faster and 100% compatible with the "PUT #" command !      *}
sub schreibe(shortint filenumber,string text)
 shared LF
 longint geschrieben,l

 text=text+LF
 l=len(text)
 geschrieben=xWrite&(handle(filenumber),@text,l)
 IF geschrieben<l THEN CALL PrErr ("Error writing to file!"):CALL ende
END SUB

{* ReplaceDefines - Checks every word within a string whether it's **
**                  a define and replaces it if necessary          **
**                                                                 **
**   Syntax : replaced = ReplaceDefines(defineslist,text)          **
**                                                                 **
**     replaced       : (string) <text> with every used define re- **
**                      placed                                     **
**     defineslist    : (address) pointer to the list of defines   **
**     text           : (string) string to be checked              *}

sub string ReplaceDefines (address defptr,string text)
 string   object,replace,param
 shortint cparam,found,foundsth,position
 declare struct definenode *defines

 ++foundsth
 repeat
  object=get_name_of_object_alt(foundsth,text)
  foundsth=search2(foundsth,text,object)
  defines=FindName&(defptr,@object)
  if defines then
   replace=defines->replace
   ' Do we have to parse any comments?
   IF defines->countparam THEN
    ' yes - look for begin of parameter list
    position=search2(foundsth,text,"(")
    IF position=0 THEN
     ' Funny. There have to be params but there are none :(
     PrErr("Corrupt define "+cstr(defines->ln_name))
    ELSE
     cparam=0
     WHILE peek(@text+position-1)<>41        ' 41 = ")"
      param=get_name_of_object_alt(position,text)
      position=position+LEN(param)
      ++position
      ++cparam
      a$=chr$(cparam)
      found=search2(1,replace,a$)
      WHILE found
       ++found
       replace=LEFT$(replace,found-2)+param+MID$(replace,found)
       found=search2(found,replace,a$)
      WEND
     WEND
     ++position
    END IF
   ELSE
    position=foundsth+LEN(object)
   END IF
   text=LEFT$(text,foundsth-1)+replace+MID$(text,position)
   foundsth=foundsth+len(replace)
  else
   foundsth=foundsth+len(object)
  end if
 until peek(@object)=0

 ReplaceDefines=text
end sub

{* This routine replaces C-comments (/* and */) through ACE ones   **
** and checks whether there is a define                            *}
SUB STRING Convert (STRING text,address defptr)
 SHARED Replace_Defines
 DECLARE STRUCT definenode *defines

 SHORTINT foundsth,position,cparam,found
 STRING   replace,param,object

 {* Why should we waste time by using this sub program if the      **
 ** string is empty ?                                              *}
 IF peek(@text)=0 then Convert="":exit sub

 {* You must first replace */ and then /*.  This is very important **
 ** and not paying attention to that would lead to a processed co- **
 ** de where all comments begin with { but do end with a */. This  **
 ** has to do with the Legal-routine which's used to check whether **
 ** "/*" or "*/" is within a string or a comment.                  *}
 text=ReplaceC(text,"*/","}")
 text=ReplaceC(text,"/*","{")

 {* If we are allowed to replace defines within the source code we **
 ** check every word within the line if it's a defined alias. Here **
 ** one can make things like removing all  PRINT  commands through **
 ** the faster PRINTS command  (if the program just uses intuition **
 ** windows)                                                       **
 ** Note: Defines have a higher priority than the commands of the  **
 **       programming language since NAP just checks whether there **
 **       is something defined within the string but does not care **
 **       of removing real commands!                               *}
 IF Replace_Defines then text=ReplaceDefines(DefPtr,text)

 convert=text
END SUB

SUB address ReserveMem (shortint filenumber)
 shared BufferPtrBase,MaxBuffer
 address ActBuffer
 longint filesize

 DIM ADDRESS BufferPtr(9,1) ADDRESS BufferPtrBase

 filesize=seek&(handle(filenumber),0,1)
 filesize=seek&(handle(filenumber),0,-1)
 if filesize<MaxBuffer then filesize=filesize+3 else filesize=MaxBuffer+3
 ActBuffer=AllocMem&(fileSize,65536&)

 if ActBuffer=0 then
  PrErr("Not enough memory to create new filebuffer!")
  ende
 end if

 BufferPtr(filenumber,0)=ActBuffer
 BufferPtr(filenumber,1)=filesize
 ReserveMem=ActBuffer+filesize-1
END SUB

{ -------------------------------------------------------------------------- }

{* This sub program adds a specific file to the TempFile.          **
** Params :  filenumber  - next free filenumber                    **
**           filename    - name (incl path) of file to be included *}

SUB AddToTemp (SHORTINT filenumber,STRING filename)
 SHARED CR,Const_Defines,Remove_Structs,Remove_Defines
 SHARED MaxBuffer,Remove_Comments,BufferPtrBase,include,defines
 SHARED needed_structs,structures,PathPtr

 DIM ADDRESS BufferPtr(9,1) ADDRESS BufferPtrBase
 DIM STRING Path(9) SIZE 100% ADDRESS PathPtr

 ON BREAK CALL ende
 BREAK ON

 FOR i=0 to 9
  open "I",filenumber,Path(i)+filename
  if handle(filenumber) then exit for
 NEXT
 if handle(filenumber)=0 then
  PrErr ("Could not open "+filename+"!")
  EXIT SUB
 END IF

 address FileReady
 FileReady=ReserveMem(filenumber)

 STRING   object,toparse,fname,command,param,name_of_struct SIZE 200
 STRING   text,BigText,replace
 SHORTINT inComment,in_Struct,if_depth,valid_depth

 STRING definition size 10
 STRING declaration size 20
 STRING reserved size 55

 definition="STRUCT "
 declaration="DECLARE STRUCT "
 reserved=" LONGINT SHORTINT END STRUCT BYTE ADDRESS STRING "

 DECLARE STRUCT _List *substruct
 DECLARE STRUCT Node *EmptyNode
 DECLARE STRUCT DefineNode *EmptyDefine
 DECLARE STRUCT StructNode *EmptyStruct


 WHILE peek(fileready)=0
  if inComment then
   inComment=0
   repeat
    text=ReplaceC(lese(filenumber),"*/","}")
    foundsth=search2(1,text,"}")
    if foundsth=0 then
     if Remove_Comments=0 then call schreibe(1,text)
    else
     if Remove_Comments=0 then call schreibe(1,left$(text,FoundSth))
     text=mid$(text,foundsth+1)
    end if
   until foundsth
  else
   text=lese(filenumber)
  end if


  {* 1st look for preprocessor commands.  These commands work with **
  ** token defined via #define. Therefore defines must not be re-  **
  ** placed !                                                      *}

  ' is there a preprocessor command within this line?
  IF PEEK(@text)=35 THEN                 { 35 = "#" }
   BigText=UpperCase$(text)
   command=get_name_of_object(2,BigText)

   {* This is for  "#IF DEFINED <token>"  commands. The other #IF  **
   ** variation can be found further down.                         *}
   IF command="IF" THEN                       ' <expression>
    object=get_name_of_object(4,BigText)
    if object="DEFINED" then
     if valid_depth=if_depth then
      found=search2(4,BigText,object)
      object=get_name_of_object_alt(found+8,BigText)
      if FindName&(Defines,@object) then ++valid_depth
     end if
     ++if_depth
     {* Since we processed this variation of the "#IF" command, we **
     ** must prevent the other #IF-processing routine to process   **
     ** this one again. So we destroy it.                          *}
     poke @text+1,79
    else
     {* This is not "#IF DEFINED <token>".  Therefore it has to be **
     ** processed again below.                                     *}
    end if
   END IF

   IF command="IFDEF" THEN                     ' <token>
    if if_depth=valid_depth then
     object=get_name_of_object_alt(7,text)
     if FindName&(defines,@object) then ++valid_depth
    end if
    ++if_depth
   END IF

   IF command="IFNDEF" THEN                    ' <token>
    if if_depth=valid_depth then
     object=get_name_of_object(9,text)
     if FindName&(defines,@object)=0 then ++valid_depth
    end if
    ++if_depth
   END IF
  END IF

  {* Now we test again of existing preprocessor commands. But this **
  ** time tokens must be replaced!                                 *}

  text=convert(text,defines)
  BigText=uppercase$(text)

  ' is there a preprocessor command within this line?
  IF PEEK(@text)=35 THEN                 { 35 = "#" }
   command=get_name_of_object(2,BigText)

   IF command="ASSERT" THEN                    ' <expression>
    PrErr("#ASSERT not yet implemented")
   END IF

   IF command="ELIF" THEN                      ' <expression>
    IF if_depth=valid_depth THEN
     IF if_depth=0 THEN
      PrErr("#ELIF without #IF #ENDIF")
     ELSE
      --valid_depth
     END IF
    ELSE
     IF valid_depth+1=if_depth THEN
      IF ParseExpr(MID$(text,7)) THEN ++valid_depth
     END IF
    END IF
   END IF

   IF command="ENDIF" THEN
    if valid_depth=if_depth then --valid_depth
    --if_depth
    if if_depth<0 then
     PrErr ("Too many #ENDIF")
     if_depth=0
     valid_depth=0
    end if
   END IF

   IF command="ERROR" THEN                     ' <expression>
    PrErr("#ERROR not yet implemented")
   END IF

   IF command="IF" THEN                        ' <expression>
    IF if_depth=valid_depth then
     IF ParseExpr(MID$(text,3)) THEN ++valid_depth
    END IF
    ++if_depth
   END IF

   IF command="LINE" THEN                      ' <number> <filename>
    PrErr("#LINE not yet implemented")
   END IF

   IF command="PRAGMA" THEN                    ' <anything>
    PrErr("#PRAGMA not yet implemented")
   END IF

   IF command="DEBUG" THEN
    PrErr("#DEBUG not yet implemented")
   END IF

   IF command="NODEBUG" THEN
    PrErr("#NODEBUG not yet implemented")
   END IF

   IF command="ELSE" THEN
    if if_depth=valid_depth then --valid_depth else ++valid_depth
   END IF

   IF command="UNDEF" THEN
    ' what shall we undefine?
    object=get_name_of_object(8,BigText)
    emptydefine=FindName&(defines,@object)
    IF emptydefine=0 then
     PrErr ("Could not undefine "+object)
    else
     Remove&(emptydefine)
    end if
   END IF

   IF command="INCLUDE" THEN
    ' try to include a file, get name of include file
    fname=get_name_of_object(10,BigText)
    ' remove <brackets>
    fname=MID$(fname,2,LEN(fname)-2)

    ' file already included? If not, then
    IF FindName&(include,@fname)=0 THEN
     ' save include file name
     EmptyNode=alloc(sizeof(Node),7)
     EmptyNode->ln_name=Copy(fname)
     AddTail&(include,EmptyNode)

     ' include file
     AddToTemp(filenumber+1,fname)

     ' reset string contents
     definition="STRUCT "
     reserved=" LONGINT SHORTINT END STRUCT BYTE ADDRESS STRING "
     command="definition
     declaration="DECLARE STRUCT "
    END IF
   END IF

   IF command="DEFINE" AND Remove_Defines=0 THEN
    EmptyDefine=alloc(sizeof(DefineNode),7)
    EmptyDefine->ln_name=Copy(get_name_of_object_alt(8,text))
    toparse=get_name_of_object(8,text)
    foundsth=search2(8,text,toparse)
    poke @replace,0

    REPEAT
     IF peek(@replace)=0 THEN
      replace=MID$(text,foundsth+LEN(toparse))
     ELSE
      text=Convert(lese(filenumber),defines)
      replace=LEFT$(replace,LEN(replace)-1)+text
     END IF
     a$=RIGHT$(replace,1)
    UNTIL a$<>"\" AND a$<>"~"

    foundsth=search2(1,replace,"{")
    IF foundsth THEN
     replace=LEFT$(replace,foundsth-1)
    else
     foundsth=search2(1,replace,"'")
     IF foundsth THEN replace=LEFT$(replace,foundsth-1)
    end if

    cparam=0
    foundsth=search2(1,toparse,"(")

    IF foundsth THEN
     IF Const_Defines THEN
      PrErr (toparse+" is not legal when option Q is used !")
     ELSE
      length=len(toparse)
      WHILE peek(@toparse+foundsth-1)<>41 AND foundsth<Length
       param=get_name_of_object_alt(foundsth,toparse)
       foundsth=foundsth+LEN(param)
       ++foundsth
       ++cparam
       found=1
       REPEAT
        found=search2(found,replace,param)
       UNTIL param=get_name_of_object_alt(found-1,replace)
       replace=LEFT$(replace,found-1)+CHR$(cparam)+MID$(replace,found+LEN(param))
      WEND
     END IF
    END IF

    emptydefine->replace=replace
    emptydefine->countparam=cparam

    IF Const_Defines THEN
     schreibe(1,"CONST "+cstr(emptydefine->ln_name)+"="+STR$(VAL(replace)))
     IF cparam=0 then call AddTail&(defines,emptydefine)
    else
     AddTail&(defines,emptydefine)
    end if
   END IF

   foundsth=search2(1,text,"{")
   IF foundsth THEN text=MID$(text,foundsth) else poke @text,0

  ELSE

   if if_depth>valid_depth then
    poke @text,0
    poke @BigText,0
   end if

   ' is there a structure definition?
   struct_def=search2(1,BigText,definition)

   If struct_def then
    struct_dec=search2(1,Bigtext,declaration)

    IF struct_dec then
     if legal(text,struct_dec) and Remove_Structs THEN
      ' save name of declared structure in list
      EmptyNode=alloc(sizeof(node),7)
      emptynode->ln_name=copy(get_name_of_object(15+struct_dec,BigText))
      AddTail&(needed_structs,EmptyNode)
     end if
    ELSE
     if legal(text,struct_def) and in_Struct=0 THEN
      proceed=1
      if struct_def>1 then
       if get_name_of_object_alt(struct_def-1,text)<>definition then proceed=0
      end if

      if proceed then
       in_struct=1
       if Remove_Structs then
        ' yes, it is -> save name of structure in list
        EmptyStruct=alloc(sizeof(structnode),7)
        EmptyStruct->ln_name=Copy(get_name_of_object(6+struct_def,Bigtext))
        EmptyStruct->member_types_list=ALLOC(SIZEOF(_list),7)
        substruct=emptystruct->member_types_list
        AddTail&(structures,EmptyStruct)
        substruct->lh_Head=substruct+4
        substruct->lh_TailPred=substruct
       end if
      end if
     end if
    end if
   end if

   IF in_Struct=1 then
    ' name of substruct
    if Const_Defines then text=ReplaceDefines(defines,text):BigText=UpperCase$(text)
    name_of_struct=get_name_of_object(1,BigText)
    if name_of_struct="END" then
     in_Struct=0
    else
     IF Remove_Structs then
      if search2(1,reserved," "+name_of_struct+" ")=0 THEN
       emptynode=alloc(sizeof(node),7)
       emptynode->ln_name=copy(name_of_struct)
       AddTail&(substruct,emptynode)
      end if
     END IF
    END IF
   END IF
  END IF

  ' REMOVE COMMENTS

  FoundSth=search2(1,text,"{")
  IF FoundSth THEN
   FoundEnd=search2(FoundSth,text,"}")
   IF FoundEnd THEN
    IF Remove_Comments THEN text=cutoff(text,FoundSth)+~
                                 RIGHT$(text,LEN(text)-FoundEnd)
   ELSE
    IF Remove_Comments THEN text=cutoff(text,FoundSth)
    inComment=1
   END IF
  END IF

  IF Remove_Comments THEN
   FoundSth=search2(1,text,"'")
   IF FoundSth THEN text=cutoff(text,FoundSth)
   FoundSth=search2(1,UpperCase$(text),"REM ")
   IF FoundSth THEN text=cutoff(text,FoundSth)
  END IF

  IF LEN(text) THEN
   schreibe(1,text)
   KillEmpty=0
  ELSE
   if KillEmpty=0 then
    schreibe(1," ")
    ++KillEmpty
   end if
  end if
 WEND

 if if_depth then call PrErr("#IF without #ENDIF")
 break off
 CLOSE #filenumber
 FreeMem&(BufferPtr(filenumber,0),BufferPtr(filenumber,1))
 BufferPtr(filenumber,0)=0
END SUB

{ -------------------------------------------------------------------------- }

SUB RemoveStuff
 ' remove comments, unused structs or just copy the contents of the temp
 ' file to the output file.

 ' see all above
 SHARED needed_structs,structures,BufferPtrBase
 DIM ADDRESS BufferPtr(9,1) ADDRESS BufferPtrBase

 address FileReady
 FileReady=ReserveMem(1)

 ON BREAK CALL ende
 BREAK ON

 STRING   object,text,definition,declaration SIZE 100
 STRING   name_of_struct,BigText SIZE 100
 SHORTINT in_Struct

 definition="STRUCT "
 declaration="DECLARE STRUCT "

 DECLARE STRUCT _List *structs,*substruct
 DECLARE STRUCT Node *EmptyNode
 DECLARE STRUCT StructNode *EmptyStruct

 structs=structures
 REPEAT
  EmptyStruct=structs->lh_Head
  FoundSth=0
  WHILE EmptyStruct->ln_Succ
   object=cstr(EmptyStruct->ln_name)
   IF FindName&(needed_structs,object) THEN
    substruct=emptystruct->member_types_list
    emptynode=substruct->lh_head
    WHILE emptynode->ln_succ
     object=cstr(emptynode->ln_name)
     IF FindName&(needed_structs,object)=0 THEN
      AddTail&(needed_structs,emptynode)
      FoundSth=1
     END IF
     emptynode=emptynode->ln_succ
    WEND
   END IF
   emptystruct=emptystruct->ln_succ
  WEND
 UNTIL FoundSth=0

 WHILE peek(FileReady)=0
  text=lese(1)
  BigText=UpperCase$(text)

  ' REMOVE STRUCTS

  IF in_Struct=0 THEN
   struct_def=search2(1,Bigtext,definition)

   IF struct_def THEN
    proceed=1
    if search2(1,Bigtext,declaration) then
     proceed=0
    else
     if struct_def>1 then
      if get_name_of_object_alt(struct_def-1,BigText)<>definition THEN proceed=0
     end if
    end if

    IF proceed and legal(text,struct_def) THEN
     ' if it is really a definition and if it is not within a comment,
     ' then get the name of the struct
     name_of_struct=get_name_of_object(struct_def+6,BigText)

     ' does we need this struct?
     IF FindName&(needed_structs,name_of_struct)=0 THEN
      ' no
      REPEAT
       text=lese(1)
      UNTIL search2(1,UpperCase$(text),"END STRUCT") OR Peek(FileReady)
      text=lese(1)
     ELSE
      in_Struct=1
     END IF
    END IF
   END IF
  END IF

  IF in_Struct THEN
   IF UpperCase$(get_name_of_object(1,text))="END" then in_Struct=0
  END IF

  schreibe(2,text)
 WEND

 {* The BREAK OFF is life-rescuing: If the user would press CTRL-C **
 ** after the memory is freed but before this is stored, the ENDE- **
 ** routine would free the memory again -> would cause a 81000009! *}
 break off
 FreeMem&(BufferPtr(1,0),BufferPtr(1,1))
 BufferPtr(1,0)=0
END SUB

SUB Usage
 ?
 ? "Usage :"
 ?
 ? " "ARG$(0)" [-options] <infile> <outfile>"
 ?
 ? " options are :  s   -> do not remove unused structs"
 ? "                c   -> do not remove comments"
 ? "                q   -> write #defines as CONST"
 ? "                i   -> ignore defines"
 ? "                e   -> suppress error messages"
 ? "                b## -> set buffer to ## kilobytes"
 ? "                h   -> this text"
 ? "                d<token>[=<replacement>] -> define token"
 ? "                p<directory>             -> add includedirectory"
 ? "                u<token>                 -> undefine token"
 ?
 ? "Read the manual for more information."
 Ende
END SUB

{ -------------------------------------------------------------------------- }

start2&=TIMER
? "New ACE Preprocessor version 2.00beta3, copyright © 1996 Daniel Seifert"

{* The defaults of the options                                     *}

Remove_Structs  = 1               ' do remove unused structures
Remove_Comments = 1               ' do remove EVERY comment
Remove_Defines  = 0               ' do not ignore defines
Const_Defines   = 0               ' do not replace defines by CONST
Replace_Defines = 1               ' but do replace defines directly
Print_Errors    = 1               ' do print errors/warnings


DECLARE STRUCT _List *liste
DECLARE STRUCT DefineNode *emptydefine

For i=0 to 3
 liste=ALLOC(SIZEOF(_list),7)
 StrucBase(i)=liste
 liste->lh_Head=liste+4
 liste->lh_TailPred=liste
Next

include        = StrucBase(0)
needed_structs = StrucBase(1)
defines        = StrucBase(2)
structures     = StrucBase(3)

poke @InFile,0
poke @OutFile,0

' ACE comments

LF=CHR$( 10)
CR=CHR$( 11)

FOR i=1 TO ARGCOUNT
 argument=ARG$(i)
 IF PEEK(@argument)=45 THEN                     ' 45 = "-"
  FOR j=2 TO LEN(argument)
   opt=UpperCase$(MID$(argument,j,1))
   CASE
    opt="S":Remove_structs=0
    opt="C":Remove_Comments=0
    opt="I":SWAP Remove_Defines,Replace_Defines
    opt="Q":Const_Defines=1
    opt="E":Print_Errors=0
    opt="B":MaxBuffer=val(mid$(argument,j+1)):exit for
    opt="D":token=get_name_of_object_alt(j+1,argument):~
            value=mid$(argument,search2(3,argument,token)+len(token)+1):~
            if peek(@value)=0 then value="1":~
            emptydefine=alloc(sizeof(definenode),7):~
            emptydefine->ln_name=copy(token):~
            emptydefine->replace=value:~
            emptydefine->countparam=0:~
            AddTail&(defines,emptydefine):~
            exit for
    opt="P":object=mid$(argument,j+1):~
            for x=2 to 9:~
             if peek(@Path(x))=0 then Path(x)=object:exit for:~
            next:~
            exit for
    opt="U":token=mid$(argument,j+1):~
            if FindName&(defines,@token) then call Remove(FindName&(defines,@token))
    100=100:CALL usage
   END CASE
  NEXT
 ELSE
  IF peek(@InFile)=0 THEN
   InFile=argument
  ELSE
   IF peek(@OutFile) THEN CALL Usage
   OutFile=argument
  END IF
 END IF
NEXT
IF peek(@OutFile)=0 then CALL Usage
if MaxBuffer=0 or MaxBuffer>64 then MaxBuffer=32
MaxBuffer=MaxBuffer*1000

OPEN "I",1,InFile
OPEN "O",2,OutFile
CLOSE #1
CLOSE #2
IF ERR THEN
 PrErr ("Could not open file to read/write.")
 ende
END IF

IF Remove_Defines then Const_Defines=0
IF Const_Defines then Replace_Defines=0
if Remove_Structs=0 then TempFile=OutFile

OPEN "O",1,TempFile
AddToTemp(2,InFile)


If Remove_Structs then
 CLOSE #1
 OPEN "I",1,TempFile
 OPEN "O",2,OutFile
 RemoveStuff
end if

? "Elapsed time :"TIMER-start2&
ende
