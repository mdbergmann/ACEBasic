REM #using ACE:submods/mui/mui.o
{*
** FileViewer.b - File Browser with Text Editor
** =============================================
**
** Demonstrates using custom MUI classes (MCCs):
** - Volumelist/Dirlist for file browsing (left pane)
** - TextEditor.mcc for displaying text files (right pane)
**
** Layout:
**   +--------------------------------------------------+
**   |              File Viewer                         |
**   +--------------------------------------------------+
**   | +-- Volumes --+ || +-- Text Editor ------------+ |
**   | | RAM:        | || | (file contents displayed  | |
**   | | DH0:        | || |  here when a text file    | |
**   | +-------------+ || |  is selected)             | |
**   | +-- Files ----+ || |                           | |
**   | | file1.txt   | || |                           | |
**   | | file2.doc   | || |                           | |
**   | | subdir/     | || |                           | |
**   | +-------------+ || +---------------------------+ |
**   +--------------------------------------------------+
**   | Status: Ready                                    |
**   +--------------------------------------------------+
**
** Compile:
**   bas FileViewer ace:submods/mui/MUI.o
**
** Requirements:
**   - MUI 3.8+
**   - TextEditor.mcc installed in MUI:Libs/MUI/
**
** Copyright (c) 2026 Manfred Bergmann. All rights reserved.
**
** DISCLAIMER:
** This software is provided "as is" without warranty of any kind,
** express or implied. In no event shall the author be liable for
** any damages, including but not limited to data loss, arising
** from the use of this software. Use at your own risk.
*}

#include <submods/MUI.h>

{ ============== Libraries ============== }
LIBRARY "intuition.library"
LIBRARY "utility.library"

{ ============== TextEditor.mcc Constants ============== }
{ From TextEditor_mcc.h - TextEditor_Dummy = 0xad000000 }
CONST MUIA_TextEditor_Contents    = &HAD000002
CONST MUIA_TextEditor_ReadOnly    = &HAD000019
CONST MUIA_TextEditor_FixedFont   = &HAD00000A
CONST MUIA_TextEditor_Quiet       = &HAD000017
CONST MUIA_TextEditor_HasChanged  = &HAD00000C

{ ============== Dirlist Constants ============== }
CONST MUIA_Dirlist_Directory      = &H8042ea41
CONST MUIA_Dirlist_Path           = &H80426ea7
CONST MUIA_Dirlist_Status         = &H804240de
CONST MUIA_Dirlist_NumBytes       = &H80429e26
CONST MUIA_Dirlist_NumFiles       = &H8042a6f0
CONST MUIA_Dirlist_NumDrawers     = &H80429cb8

{ Dirlist status values }
CONST MUIV_Dirlist_Status_Invalid = 0
CONST MUIV_Dirlist_Status_Reading = 1
CONST MUIV_Dirlist_Status_Valid   = 2

{ Listview double-click attribute }
CONST MUIA_Listview_DoubleClick   = &H80424635

{ ============== Event IDs ============== }
CONST ID_QUIT = -1
CONST ID_LOAD = 1
CONST ID_CLEAR = 2
CONST ID_PARENT = 3
CONST ID_ROOT = 4
CONST ID_OPEN = 5

{ ============== Global UI Objects ============== }
ADDRESS app, win, mainGroup
ADDRESS volumeList, volumeListview, volumeGrp
ADDRESS dirList, dirListview, dirGrp
ADDRESS editor, editorGrp
ADDRESS leftPane, rightPane, balPane
ADDRESS txtStatus, txtPath
ADDRESS btnLoad, btnClear, btnParent, btnRoot, btnOpen
ADDRESS buttonGrp

{ ============== State Variables ============== }
LONGINT running
LONGINT changingVolume
STRING currentPath
LONGINT editorIsMCC

{ ============== Hooks ============== }
DECLARE STRUCT MUIHook volumeHook
DECLARE STRUCT MUIHook dirHook
DECLARE STRUCT MUIHook dirDoubleHook

{ ============== File Reading Variables ============== }
STRING fileLine
LONGINT lineCount


{ ============== Helper Functions ============== }

{*
** LoadTextFile - Load a text file into the editor
** Reads file line by line and sets editor contents
*}
SUB LoadTextFile(STRING filePath)
    SHARED editor, txtStatus, fileLine, lineCount
    STRING contents
    LONGINT maxSize
    LONGINT loadOK

    IF editor = 0& THEN
        EXIT SUB
    END IF

    { Update status }
    MUISetText(txtStatus, "Loading: " + filePath)

    { Clear previous content }
    MUISetStr(editor, MUIA_TextEditor_Contents, "")

    { Use ACE BASIC file I/O with error trapping }
    loadOK = 0
    ON ERROR GOTO loadError
    ERROR ON

    OPEN "I",#1,filePath

    contents = ""
    lineCount = 0
    maxSize = 60000  { Limit to prevent memory issues }

    WHILE NOT EOF(1) AND LEN(contents) < maxSize
        LINE INPUT #1, fileLine
        contents = contents + fileLine + CHR$(10)
        lineCount = lineCount + 1
    WEND

    CLOSE #1
    loadOK = -1

    ERROR OFF

    PRINT "Read"; lineCount; "lines,"; LEN(contents); "chars"

    { Set the contents }
    PRINT "Setting editor contents..."
    MUISetStr(editor, MUIA_TextEditor_Contents, contents)
    PRINT "Contents set"

    MUISetText(txtStatus, "Loaded: " + STR$(lineCount) + " lines from " + filePath)
    EXIT SUB

loadError:
    CLOSE #1
    MUISetText(txtStatus, "Error reading file: " + filePath)
    MUISetStr(editor, MUIA_TextEditor_Contents, "Error reading file: " + filePath)
END SUB

{*
** GetParentPath - Get the parent directory of a path using string manipulation
*}
SUB GetParentPath
    SHARED currentPath, dirList, txtPath, txtStatus
    LONGINT pathLen, i, lastSlash, colonPos

    IF dirList = 0& THEN
        EXIT SUB
    END IF

    pathLen = LEN(currentPath)
    IF pathLen = 0 THEN
        EXIT SUB
    END IF

    { Remove trailing slash if present }
    IF RIGHT$(currentPath, 1) = "/" THEN
        currentPath = LEFT$(currentPath, pathLen - 1)
        pathLen = pathLen - 1
    END IF

    { Find the colon (volume separator) }
    colonPos = INSTR(currentPath, ":")
    IF colonPos = 0 THEN
        EXIT SUB
    END IF

    { If we're at volume root (e.g., "RAM:"), can't go higher }
    IF pathLen = colonPos THEN
        MUISetText(txtStatus, "Already at volume root")
        EXIT SUB
    END IF

    { Find last slash }
    lastSlash = 0
    FOR i = pathLen TO 1 STEP -1
        IF MID$(currentPath, i, 1) = "/" THEN
            lastSlash = i
            EXIT FOR
        END IF
    NEXT i

    { Go to parent }
    IF lastSlash > colonPos THEN
        { Has subdirectory - go up one level }
        currentPath = LEFT$(currentPath, lastSlash)
    ELSE
        { No slash after colon - go to volume root }
        currentPath = LEFT$(currentPath, colonPos)
    END IF

    MUISetStr(dirList, MUIA_Dirlist_Directory, currentPath)
    MUISetText(txtPath, "Path: " + currentPath)
    MUISetText(txtStatus, "Browsing: " + currentPath)
END SUB

{ ============== Callbacks ============== }

{*
** OnVolumeSelect - Called when user selects a volume
*}
SUB OnVolumeSelect(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED volumeList, dirList, txtPath, txtStatus, changingVolume, currentPath
    LONGINT activeIdx
    ADDRESS entryPtr

    IF volumeList = 0& OR dirList = 0& THEN
        OnVolumeSelect = 0&
        EXIT SUB
    END IF

    activeIdx = MUIListActive(volumeList)
    IF activeIdx < 0 THEN
        OnVolumeSelect = 0&
        EXIT SUB
    END IF

    entryPtr = MUIListGetEntry(volumeList, activeIdx)
    IF entryPtr = 0& THEN
        OnVolumeSelect = 0&
        EXIT SUB
    END IF

    currentPath = CSTR(entryPtr)

    changingVolume = 1
    MUISetStr(dirList, MUIA_Dirlist_Directory, currentPath)
    MUISetText(txtPath, "Path: " + currentPath)
    MUISetText(txtStatus, "Browsing: " + currentPath)
    changingVolume = 0

    OnVolumeSelect = 0&
END SUB

{*
** OnDirSelect - Called when user single-clicks a directory entry
*}
SUB OnDirSelect(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED dirList, txtStatus, changingVolume
    LONGINT activeIdx
    ADDRESS entryPtr, nameAddr
    STRING fileName

    IF changingVolume THEN
        OnDirSelect = 0&
        EXIT SUB
    END IF

    IF dirList = 0& THEN
        OnDirSelect = 0&
        EXIT SUB
    END IF

    activeIdx = MUIListActive(dirList)
    IF activeIdx < 0 THEN
        OnDirSelect = 0&
        EXIT SUB
    END IF

    entryPtr = MUIListGetEntry(dirList, activeIdx)
    IF entryPtr = 0& THEN
        OnDirSelect = 0&
        EXIT SUB
    END IF

    { Dirlist entry: name is inline string at offset 8 }
    nameAddr = entryPtr + 8
    fileName = CSTR(nameAddr)

    MUISetText(txtStatus, "Selected: " + fileName)

    OnDirSelect = 0&
END SUB

{*
** OnDirDoubleClick - Called when user double-clicks a directory entry
** Navigates into directories or loads text files
*}
SUB OnDirDoubleClick(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED dirList, editor, txtPath, txtStatus, currentPath
    LONGINT activeIdx
    ADDRESS entryPtr, nameAddr, pathAddr
    STRING fileName, fullPath
    LONGINT entryType

    IF dirList = 0& THEN
        OnDirDoubleClick = 0&
        EXIT SUB
    END IF

    activeIdx = MUIListActive(dirList)
    IF activeIdx < 0 THEN
        OnDirDoubleClick = 0&
        EXIT SUB
    END IF

    entryPtr = MUIListGetEntry(dirList, activeIdx)
    IF entryPtr = 0& THEN
        OnDirDoubleClick = 0&
        EXIT SUB
    END IF

    { Dirlist entry structure:
      Offset 0: LONG (unknown/zero)
      Offset 4: LONG type (negative=file, positive=drawer)
      Offset 8: char name[] (inline string) }
    entryType = PEEKL(entryPtr + 4)
    nameAddr = entryPtr + 8
    fileName = CSTR(nameAddr)

    { Get full path from dirlist - includes the selected item }
    pathAddr = MUIGet(dirList, MUIA_Dirlist_Path)
    IF pathAddr <> 0& THEN
        fullPath = CSTR(pathAddr)
    ELSE
        { Construct path manually }
        IF RIGHT$(currentPath, 1) = ":" OR RIGHT$(currentPath, 1) = "/" THEN
            fullPath = currentPath + fileName
        ELSE
            fullPath = currentPath + "/" + fileName
        END IF
    END IF

    IF entryType > 0 THEN
        { It's a directory - navigate into it }
        currentPath = fullPath
        IF RIGHT$(currentPath, 1) <> ":" AND RIGHT$(currentPath, 1) <> "/" THEN
            currentPath = currentPath + "/"
        END IF
        MUISetStr(dirList, MUIA_Dirlist_Directory, currentPath)
        MUISetText(txtPath, "Path: " + currentPath)
        MUISetText(txtStatus, "Browsing: " + currentPath)
    ELSE
        { It's a file - try to load it }
        { Check if it might be a text file }
        IF INSTR(UCASE$(fileName), ".TXT") > 0 ~
           OR INSTR(UCASE$(fileName), ".DOC") > 0 ~
           OR INSTR(UCASE$(fileName), ".README") > 0 ~
           OR INSTR(UCASE$(fileName), ".B") > 0 ~
           OR INSTR(UCASE$(fileName), ".H") > 0 ~
           OR INSTR(UCASE$(fileName), ".C") > 0 ~
           OR INSTR(UCASE$(fileName), ".S") > 0 ~
           OR INSTR(UCASE$(fileName), ".ASM") > 0 ~
           OR INSTR(UCASE$(fileName), ".I") > 0 ~
           OR INSTR(fileName, "README") > 0 ~
           OR INSTR(fileName, "Makefile") > 0 THEN
            LoadTextFile(fullPath)
        ELSE
            { Try to load anyway for unknown types }
            LoadTextFile(fullPath)
        END IF
    END IF

    OnDirDoubleClick = 0&
END SUB

{ ============== Main Program ============== }

PRINT "File Viewer - MUI Custom Class Demo"
PRINT "===================================="
PRINT

{ Initialize state }
running = -1
changingVolume = 0
currentPath = "RAM:"

{ Initialize MUI }
MUIInit

IF MUILastError <> MUIERR_NONE THEN
    PRINT "Failed to initialize MUI"
    STOP
END IF

PRINT "MUI version:"; MUIVersion

{ ============== Create Volume List ============== }

PRINT "Creating volume list..."
volumeList = MUIVolumelist
IF volumeList = 0& THEN PRINT "FAIL: volumeList" : GOTO cleanup

volumeListview = MUIListview(volumeList)
IF volumeListview = 0& THEN PRINT "FAIL: volumeListview" : GOTO cleanup

MUIBeginVGroup
    MUIGroupFrameT("Volumes")
    MUIChildWeight(volumeListview, 100)
volumeGrp = MUIEndGroup
IF volumeGrp = 0& THEN PRINT "FAIL: volumeGrp" : GOTO cleanup

{ ============== Create Directory List ============== }

PRINT "Creating directory list..."
dirList = MUIDirlist("RAM:")
IF dirList = 0& THEN PRINT "FAIL: dirList" : GOTO cleanup

dirListview = MUIListview(dirList)
IF dirListview = 0& THEN PRINT "FAIL: dirListview" : GOTO cleanup

{ Navigation buttons }
btnParent = MUIButton("Parent")
btnRoot = MUIButton("Root")
btnOpen = MUIButton("Open")

MUIBeginVGroup
    MUIGroupFrameT("Files")
    MUIChildWeight(dirListview, 100)
    MUIBeginHGroup
        MUIGroupSameSize
        MUIChild(btnOpen)
        MUIChild(btnParent)
        MUIChild(btnRoot)
    MUIChild(MUIEndGroup)
dirGrp = MUIEndGroup
IF dirGrp = 0& THEN PRINT "FAIL: dirGrp" : GOTO cleanup

{ ============== Create Left Pane ============== }

txtPath = MUIText("Path: RAM:")

MUIBeginVGroup
    MUIChild(txtPath)
    MUIChildWeight(volumeGrp, 30)
    MUIChildWeight(dirGrp, 70)
leftPane = MUIEndGroup
IF leftPane = 0& THEN PRINT "FAIL: leftPane" : GOTO cleanup

{ ============== Create TextEditor ============== }

PRINT "Creating TextEditor.mcc..."

MUITagStart
MUITag(MUIA_TextEditor_ReadOnly, 0&)    { Allow editing for now to test }
MUITag(MUIA_TextEditor_FixedFont, -1&)  { Use fixed-width font }
MUITagEnd
editor = MUINewObj(SADD("TextEditor.mcc"))

IF editor = 0& THEN
    PRINT "WARNING: TextEditor.mcc not found!"
    PRINT "Using fallback text object"
    { Fallback to simple text if TextEditor not available }
    editor = MUITextFramed("TextEditor.mcc not installed. Please install from MUI:Libs/MUI/")
    editorIsMCC& = 0
ELSE
    PRINT "TextEditor.mcc loaded successfully"
    editorIsMCC& = -1
END IF

{ Load/Clear buttons }
btnLoad = MUIButton("Load")
btnClear = MUIButton("Clear")

MUIBeginVGroup
    MUIGroupFrameT("Text Viewer")
    MUIChildWeight(editor, 100)
    MUIBeginHGroup
        MUIGroupSameSize
        MUIChild(btnLoad)
        MUIChild(btnClear)
    MUIChild(MUIEndGroup)
editorGrp = MUIEndGroup
IF editorGrp = 0& THEN PRINT "FAIL: editorGrp" : GOTO cleanup

{ ============== Create Right Pane ============== }

rightPane = editorGrp

{ ============== Create Main Layout ============== }

PRINT "Building main layout..."

{ Create a thin rectangle as separator instead of Balance }
{ Balance has internal height constraints that can't be overridden }
balPane = MUIRectangle
MUISet(balPane, MUIA_FixWidth, 2&)
MUISet(balPane, MUIA_Background, MUII_ButtonBack)

{ Status bar }
txtStatus = MUITextFramed("Ready - Select a volume and file to view")

{ Main horizontal split }
MUIBeginHGroup
    MUIChildWeight(leftPane, 35)
    MUIChild(balPane)
    MUIChildWeight(rightPane, 65)
mainGroup = MUIEndGroup

{ Add status bar at bottom }
MUIBeginVGroup
    MUIChildWeight(mainGroup, 100)
    MUIChild(txtStatus)
mainGroup = MUIEndGroup

IF mainGroup = 0& THEN PRINT "FAIL: mainGroup" : GOTO cleanup

{ ============== Create Window and App ============== }

PRINT "Creating window..."

win = MUIWindowID("File Viewer", mainGroup, &H46564557)  { "FVEW" }
IF win = 0& THEN PRINT "FAIL: window" : GOTO cleanup

app = MUIApp("FileViewer", "$VER: FileViewer 1.0 (2026)", win)
IF app = 0& THEN PRINT "FAIL: app" : GOTO cleanup

PRINT "Application created"

{ ============== Setup Notifications ============== }

PRINT "Setting up notifications..."

{ Window close }
MUINotifyClose(win, app, ID_QUIT)

{ Button notifications }
MUINotifyButton(btnLoad, app, ID_LOAD)
MUINotifyButton(btnClear, app, ID_CLEAR)
MUINotifyButton(btnOpen, app, ID_OPEN)
MUINotifyButton(btnParent, app, ID_PARENT)
MUINotifyButton(btnRoot, app, ID_ROOT)

{ Volume selection hook }
MUISetupHookA4(volumeHook, @OnVolumeSelect, 0&)
MUINotifyAttrHook(volumeList, MUIA_List_Active, volumeHook)

{ Directory single-click hook }
MUISetupHookA4(dirHook, @OnDirSelect, 0&)
MUINotifyAttrHook(dirList, MUIA_List_Active, dirHook)

{ Directory double-click hook }
MUISetupHookA4(dirDoubleHook, @OnDirDoubleClick, 0&)
MUINotifyAttrHook(dirListview, MUIA_Listview_DoubleClick, dirDoubleHook)

PRINT "Notifications set up"

{ ============== Open Window ============== }

MUIWindowOpen(win)

PRINT "Window opened"
PRINT
PRINT "Usage:"
PRINT "  - Click a volume to browse it"
PRINT "  - Select a directory and click Open to enter it"
PRINT "  - Select a file and click Open or Load to view it"
PRINT "  - Use Parent/Root buttons to navigate up"
PRINT

{ ============== Event Loop ============== }

WHILE running
    eventID& = MUIWaitEvent(app)

    IF eventID& = ID_QUIT OR eventID& = MUIV_Application_ReturnID_Quit THEN
        running = 0
    END IF

    IF eventID& = ID_LOAD THEN
        { Load selected file }
        activeIdx& = MUIListActive(dirList)
        IF activeIdx& >= 0 THEN
            entryPtr& = MUIListGetEntry(dirList, activeIdx&)
            IF entryPtr& <> 0& THEN
                { Type is at offset 4, name at offset 8 }
                entryType& = PEEKL(entryPtr& + 4)
                nameAddr& = entryPtr& + 8
                fileName$ = CSTR(nameAddr&)

                { Check if it's a file (type < 0) }
                IF entryType& < 0 THEN
                    { Construct full path manually }
                    IF RIGHT$(currentPath, 1) = ":" OR RIGHT$(currentPath, 1) = "/" THEN
                        fullPath$ = currentPath + fileName$
                    ELSE
                        fullPath$ = currentPath + "/" + fileName$
                    END IF
                    LoadTextFile(fullPath$)
                ELSE
                    MUISetText(txtStatus, "Please select a file, not a directory")
                END IF
            END IF
        ELSE
            MUISetText(txtStatus, "Please select a file first")
        END IF
    END IF

    IF eventID& = ID_CLEAR THEN
        MUISetStr(editor, MUIA_TextEditor_Contents, "")
        MUISetText(txtStatus, "Editor cleared")
    END IF

    IF eventID& = ID_OPEN THEN
        { Open selected item - directory or file }
        activeIdx& = MUIListActive(dirList)
        IF activeIdx& >= 0 THEN
            entryPtr& = MUIListGetEntry(dirList, activeIdx&)
            IF entryPtr& <> 0& THEN
                { Type is at offset 4, name at offset 8 }
                entryType& = PEEKL(entryPtr& + 4)
                nameAddr& = entryPtr& + 8
                fileName$ = CSTR(nameAddr&)

                IF entryType& > 0 THEN
                    { It's a directory - navigate into it }
                    IF RIGHT$(currentPath, 1) = ":" OR RIGHT$(currentPath, 1) = "/" THEN
                        currentPath = currentPath + fileName$
                    ELSE
                        currentPath = currentPath + "/" + fileName$
                    END IF
                    currentPath = currentPath + "/"
                    MUISetStr(dirList, MUIA_Dirlist_Directory, currentPath)
                    MUISetText(txtPath, "Path: " + currentPath)
                    MUISetText(txtStatus, "Browsing: " + currentPath)
                ELSE
                    { It's a file - load it }
                    IF RIGHT$(currentPath, 1) = ":" OR RIGHT$(currentPath, 1) = "/" THEN
                        fullPath$ = currentPath + fileName$
                    ELSE
                        fullPath$ = currentPath + "/" + fileName$
                    END IF
                    LoadTextFile(fullPath$)
                END IF
            END IF
        ELSE
            MUISetText(txtStatus, "Please select an item first")
        END IF
    END IF

    IF eventID& = ID_PARENT THEN
        GetParentPath
    END IF

    IF eventID& = ID_ROOT THEN
        { Go to root of current volume }
        colonPos% = INSTR(currentPath, ":")
        IF colonPos% > 0 THEN
            currentPath = LEFT$(currentPath, colonPos%)
            MUISetStr(dirList, MUIA_Dirlist_Directory, currentPath)
            MUISetText(txtPath, "Path: " + currentPath)
            MUISetText(txtStatus, "Browsing: " + currentPath)
        END IF
    END IF
WEND

{ ============== Cleanup ============== }

PRINT "Cleaning up..."

MUIWindowClose(win)

cleanup:
IF app <> 0& THEN
    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

PRINT "Done!"
END
