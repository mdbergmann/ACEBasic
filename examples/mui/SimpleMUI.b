{
  SimpleMUI.b - A simple MUI example for ACE Basic
  All definitions inline to avoid include path issues.
}

{ ============== Inline Definitions ============== }

{ TagItem structure }
STRUCT TagItem
    LONGINT ti_Tag
    LONGINT ti_Data
END STRUCT

{ Tag constants }
CONST TAG_DONE   = 0&

{ MUI Attribute Tags }
CONST MUIA_Application_Title       = &H804281b8
CONST MUIA_Application_Version     = &H8042b33f
CONST MUIA_Application_Author      = &H80424842
CONST MUIA_Application_Description = &H80421fc6
CONST MUIA_Application_Window      = &H8042bfe0
CONST MUIA_Window_Title            = &H8042ad3d
CONST MUIA_Window_ID               = &H804201bd
CONST MUIA_Window_RootObject       = &H8042cba5
CONST MUIA_Window_Open             = &H80428aa0
CONST MUIA_Window_CloseRequest     = &H8042e86e
CONST MUIA_Group_Child             = &H804226e6
CONST MUIA_Text_Contents           = &H8042f8dc
CONST MUIA_Text_PreParse           = &H8042566a
CONST MUIA_Frame                   = &H8042ac64
CONST MUIV_Frame_Group             = 9

{ MUI Methods }
CONST MUIM_Notify                  = &H8042c9cb
CONST MUIM_Application_ReturnID    = &H804276ef
CONST MUIM_Application_NewInput    = &H80423ba6
CONST MUIV_Application_ReturnID_Quit = -1
CONST MUIV_EveryTime = &H49893131

{ Library function declarations }
DECLARE FUNCTION ADDRESS MUI_NewObjectA(ADDRESS classname, ADDRESS taglist) LIBRARY muimaster
DECLARE FUNCTION MUI_DisposeObject(ADDRESS obj) LIBRARY muimaster
DECLARE FUNCTION LONGINT SetAttrsA(ADDRESS obj, ADDRESS taglist) LIBRARY intuition
DECLARE FUNCTION ADDRESS AllocateTagItems(LONGINT numtags) LIBRARY utility
DECLARE FUNCTION FreeTagItems(ADDRESS taglist) LIBRARY utility
DECLARE FUNCTION LONGINT CallHookPkt(ADDRESS hook, ADDRESS obj, ADDRESS msg) LIBRARY utility
DECLARE FUNCTION LONGINT _Wait(LONGINT signalset) LIBRARY exec

{ ============== Variables ============== }

DECLARE STRUCT TagItem *tags

{ MUI object pointers }
ADDRESS app, win, grp, txt
ADDRESS textTags, groupTags, windowTags, appTags, openTags, closeTags

{ Variables for the main loop }
LONGINT sigs, result, running, returnID

{ Buffer for method messages }
DIM msgBuffer&(10)

{ ============== DoMethodA Function ============== }

SUB LONGINT DoMethodA(ADDRESS obj, ADDRESS msg)
    LONGINT classAddr
    classAddr = PEEKL(obj - 4)
    DoMethodA = CallHookPkt(classAddr, obj, msg)
END SUB

{ ============== Main Program ============== }

LIBRARY "muimaster.library"
LIBRARY "utility.library"
LIBRARY "intuition.library"
LIBRARY "exec.library"

PRINT "Creating MUI objects..."

{ Create text object tags }
textTags = AllocateTagItems(3)
IF textTags = 0& THEN
    PRINT "Failed to allocate text tags"
    GOTO cleanup
END IF
tags = textTags
tags->ti_Tag = MUIA_Text_Contents
tags->ti_Data = SADD("Hello from ACE Basic and MUI!")
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = MUIA_Text_PreParse
tags->ti_Data = SADD(CHR$(27)+"c")
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = TAG_DONE

txt = MUI_NewObjectA(SADD("Text.mui"), textTags)
IF txt = 0& THEN
    PRINT "Failed to create text object"
    GOTO cleanup
END IF
PRINT "  Text object created"

{ Create group object tags }
groupTags = AllocateTagItems(3)
IF groupTags = 0& THEN
    PRINT "Failed to allocate group tags"
    GOTO cleanup
END IF
tags = groupTags
tags->ti_Tag = MUIA_Group_Child
tags->ti_Data = txt
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = MUIA_Frame
tags->ti_Data = MUIV_Frame_Group
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = TAG_DONE

grp = MUI_NewObjectA(SADD("Group.mui"), groupTags)
IF grp = 0& THEN
    PRINT "Failed to create group object"
    GOTO cleanup
END IF
PRINT "  Group object created"

{ Create window object tags }
windowTags = AllocateTagItems(4)
IF windowTags = 0& THEN
    PRINT "Failed to allocate window tags"
    GOTO cleanup
END IF
tags = windowTags
tags->ti_Tag = MUIA_Window_Title
tags->ti_Data = SADD("Simple MUI - ACE Basic")
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = MUIA_Window_ID
tags->ti_Data = &H4D554931
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = MUIA_Window_RootObject
tags->ti_Data = grp
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = TAG_DONE

win = MUI_NewObjectA(SADD("Window.mui"), windowTags)
IF win = 0& THEN
    PRINT "Failed to create window object"
    GOTO cleanup
END IF
PRINT "  Window object created"

{ Create application object tags }
appTags = AllocateTagItems(5)
IF appTags = 0& THEN
    PRINT "Failed to allocate app tags"
    GOTO cleanup
END IF
tags = appTags
tags->ti_Tag = MUIA_Application_Title
tags->ti_Data = SADD("SimpleMUI")
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = MUIA_Application_Version
tags->ti_Data = SADD("$VER: SimpleMUI 1.0")
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = MUIA_Application_Author
tags->ti_Data = SADD("ACE Basic")
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = MUIA_Application_Window
tags->ti_Data = win
tags = tags + SIZEOF(TagItem)
tags->ti_Tag = TAG_DONE

app = MUI_NewObjectA(SADD("Application.mui"), appTags)
IF app = 0& THEN
    PRINT "Failed to create application object"
    GOTO cleanup
END IF
PRINT "  Application object created"

{ Set up notification: Window close -> App quit }
msgBuffer&(0) = MUIM_Notify
msgBuffer&(1) = MUIA_Window_CloseRequest
msgBuffer&(2) = MUIV_EveryTime
msgBuffer&(3) = app
msgBuffer&(4) = 2&
msgBuffer&(5) = MUIM_Application_ReturnID
msgBuffer&(6) = MUIV_Application_ReturnID_Quit
result = DoMethodA(win, VARPTR(msgBuffer&(0)))
PRINT "  Notification set up"

{ Open the window }
openTags = AllocateTagItems(2)
IF openTags <> 0& THEN
    tags = openTags
    tags->ti_Tag = MUIA_Window_Open
    tags->ti_Data = -1&
    tags = tags + SIZEOF(TagItem)
    tags->ti_Tag = TAG_DONE
    result = SetAttrsA(win, openTags)
    FreeTagItems(openTags)
END IF

PRINT ""
PRINT "MUI Window opened!"
PRINT "Close the window or press CTRL-C to exit."
PRINT ""

{ Main event loop }
running = -1&
sigs = 0&

WHILE running
    msgBuffer&(0) = MUIM_Application_NewInput
    msgBuffer&(1) = VARPTR(sigs)
    returnID = DoMethodA(app, VARPTR(msgBuffer&(0)))

    IF returnID = -1& THEN
        running = 0&
    ELSE
        IF sigs <> 0& THEN
            sigs = _Wait(sigs OR &H1000)
            IF (sigs AND &H1000) <> 0& THEN
                PRINT "CTRL-C pressed"
                running = 0&
            END IF
        END IF
    END IF
WEND

PRINT "Closing window..."

{ Close the window }
closeTags = AllocateTagItems(2)
IF closeTags <> 0& THEN
    tags = closeTags
    tags->ti_Tag = MUIA_Window_Open
    tags->ti_Data = 0&
    tags = tags + SIZEOF(TagItem)
    tags->ti_Tag = TAG_DONE
    result = SetAttrsA(win, closeTags)
    FreeTagItems(closeTags)
END IF

cleanup:
PRINT "Cleaning up..."

IF app <> 0& THEN
    MUI_DisposeObject(app)
END IF

LIBRARY CLOSE "exec.library"
LIBRARY CLOSE "intuition.library"
LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "muimaster.library"

PRINT "Done!"
END
