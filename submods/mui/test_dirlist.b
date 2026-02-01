{*
** test_dirlist.b - Test MUI Dirlist and Volumelist functionality
**
** A simple file browser demonstrating:
** - MUIVolumelist - shows available volumes/devices
** - MUIDirlist - shows directory contents
**
** Layout:
**   +------------------------------------------+
**   |         File Browser Test               |
**   +------------------------------------------+
**   | +-- Volumes --+ +-- Directory ---------+ |
**   | | RAM:        | | file1.txt           | |
**   | | DH0:        | | file2.doc           | |
**   | | DF0:        | | drawer/             | |
**   | |             | |                     | |
**   | +-------------+ +---------------------+ |
**   +------------------------------------------+
**   | Path: RAM:      | Selected: file1.txt   |
**   +------------------------------------------+
**   |              [Quit]                     |
**   +------------------------------------------+
*}

#include <submods/MUI.h>

{ ============== Additional Constants ============== }
{ Dirlist-specific attributes }
CONST MUIA_Dirlist_Directory   = &H8042ea41
CONST MUIA_Dirlist_Path        = &H80426ea7

{ ============== Libraries ============== }
LIBRARY "intuition.library"
LIBRARY "muimaster.library"
LIBRARY "utility.library"

{ ============== Variables ============== }
ADDRESS app, win, rootGrp
ADDRESS volumeList, volumeListview
ADDRESS dirList, dirListview
ADDRESS txtPath, txtSelected
ADDRESS btnQuit
ADDRESS volumeGrp, dirGrp, mainColumns, buttonGrp, infoGrp
LONGINT running, returnID
LONGINT changingVolume      { Flag to prevent OnDirSelect during volume change }

{ Hooks for selection changes }
DECLARE STRUCT MUIHook volumeHook
DECLARE STRUCT MUIHook dirHook

{ ============== Callbacks ============== }

{*
** OnVolumeSelect - Called when user selects a volume
** Changes the Dirlist to show that volume's root
*}
SUB OnVolumeSelect(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED volumeList, dirList, txtPath, changingVolume
    LONGINT activeIdx
    ADDRESS entryPtr
    STRING volName

    IF volumeList = 0& OR dirList = 0& THEN
        OnVolumeSelect = 0&
        EXIT SUB
    END IF

    activeIdx = MUIListActive(volumeList)
    IF activeIdx < 0 THEN
        OnVolumeSelect = 0&
        EXIT SUB
    END IF

    { Get the selected volume name }
    entryPtr = MUIListGetEntry(volumeList, activeIdx)
    IF entryPtr = 0& THEN
        OnVolumeSelect = 0&
        EXIT SUB
    END IF

    volName = CSTR(entryPtr)

    PRINT "Selected volume: "; volName

    { Set flag to prevent OnDirSelect from corrupting string pool }
    changingVolume = 1

    { Set dirlist to show this volume - do this FIRST }
    MUISetStr(dirList, MUIA_Dirlist_Directory, volName)

    { Update path display AFTER directory is set }
    IF txtPath <> 0& THEN
        MUISetText(txtPath, "Path: " + volName)
    END IF

    changingVolume = 0

    OnVolumeSelect = 0&
END SUB

{*
** OnDirSelect - Called when user selects a directory entry
** Could be used to navigate into subdirectories
*}
SUB OnDirSelect(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED dirList, txtSelected, changingVolume
    LONGINT activeIdx
    ADDRESS entryPtr, nameAddr
    STRING fileName

    { Skip if we're in the middle of changing volumes }
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
        IF txtSelected <> 0& THEN
            MUISetText(txtSelected, "Sel: (none)")
        END IF
        OnDirSelect = 0&
        EXIT SUB
    END IF

    { Get the entry structure pointer }
    entryPtr = MUIListGetEntry(dirList, activeIdx)
    IF entryPtr = 0& THEN
        IF txtSelected <> 0& THEN
            MUISetText(txtSelected, "Sel: (null)")
        END IF
        OnDirSelect = 0&
        EXIT SUB
    END IF

    { Dirlist entry: name string starts at offset 8 }
    nameAddr = entryPtr + 8

    fileName = CSTR(nameAddr)

    { Update the selected text display }
    IF txtSelected <> 0& THEN
        MUISetText(txtSelected, "Sel: " + fileName)
    END IF

    PRINT "Selected: "; fileName

    OnDirSelect = 0&
END SUB

{ ============== Main Program ============== }

PRINT "MUI Dirlist/Volumelist Test"
PRINT "============================"

{ Initialize flags }
changingVolume = 0

{ Initialize MUI submod }
MUIInit

{ ============== Create List Objects ============== }

{ Create volume list }
volumeList = MUIVolumelist
IF volumeList = 0& THEN PRINT "FAIL: volumeList" : GOTO cleanup
PRINT "Volumelist created"

{ Wrap in listview for scrolling }
volumeListview = MUIListview(volumeList)
IF volumeListview = 0& THEN PRINT "FAIL: volumeListview" : GOTO cleanup
PRINT "Volumelist view created"

{ Create directory list - start with RAM: }
dirList = MUIDirlist("RAM:")
IF dirList = 0& THEN PRINT "FAIL: dirList" : GOTO cleanup
PRINT "Dirlist created"

{ Wrap in listview for scrolling }
dirListview = MUIListview(dirList)
IF dirListview = 0& THEN PRINT "FAIL: dirListview" : GOTO cleanup
PRINT "Dirlist view created"

{ Create other objects }
txtPath = MUIText("Path: RAM:")
IF txtPath = 0& THEN PRINT "FAIL: txtPath" : GOTO cleanup

txtSelected = MUIText("Selected: (none)")
IF txtSelected = 0& THEN PRINT "FAIL: txtSelected" : GOTO cleanup

btnQuit = MUIButton("Quit")
IF btnQuit = 0& THEN PRINT "FAIL: btnQuit" : GOTO cleanup

PRINT "All objects created"

{ ============== Build Layout ============== }

{ Volume list group with frame }
MUIBeginVGroup
    MUIGroupFrameT("Volumes")
    MUIChild(volumeListview)
volumeGrp = MUIEndGroup
IF volumeGrp = 0& THEN PRINT "FAIL: volumeGrp" : GOTO cleanup

{ Directory list group with frame }
MUIBeginVGroup
    MUIGroupFrameT("Directory")
    MUIChild(dirListview)
dirGrp = MUIEndGroup
IF dirGrp = 0& THEN PRINT "FAIL: dirGrp" : GOTO cleanup

{ Main two-column area }
mainColumns = MUIHGroup2(volumeGrp, dirGrp)
IF mainColumns = 0& THEN PRINT "FAIL: mainColumns" : GOTO cleanup

{ Button group at bottom }
MUIBeginHGroup
    MUIChild(MUIRectangle)
    MUIChild(btnQuit)
    MUIChild(MUIRectangle)
buttonGrp = MUIEndGroup
IF buttonGrp = 0& THEN PRINT "FAIL: buttonGrp" : GOTO cleanup

{ Info group - path and selected side by side }
infoGrp = MUIHGroup2(txtPath, txtSelected)
IF infoGrp = 0& THEN PRINT "FAIL: infoGrp" : GOTO cleanup

{ Root group }
MUIBeginVGroup
    MUIGroupSpacing(4)
    MUIChild(MUITextCentered("File Browser Test"))
    MUIChild(MUIHBar)
    MUIChild(mainColumns)
    MUIChild(MUIHBar)
    MUIChild(infoGrp)
    MUIChild(MUIHBar)
    MUIChild(buttonGrp)
rootGrp = MUIEndGroup
IF rootGrp = 0& THEN PRINT "FAIL: rootGrp" : GOTO cleanup

PRINT "Layout built"

{ ============== Create Window and App ============== }

win = MUIWindow("File Browser", rootGrp)
IF win = 0& THEN PRINT "FAIL: window" : GOTO cleanup

app = MUIApp("FileBrowser", "$VER: FileBrowser 1.0", win)
IF app = 0& THEN PRINT "FAIL: app" : GOTO cleanup

PRINT "Window and app created"

{ ============== Set Up Notifications ============== }

{ Quit button and window close }
MUINotifyButton(btnQuit, app, MUIV_Application_ReturnID_Quit)
MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

{ Volume selection hook }
MUISetupHookA4(volumeHook, @OnVolumeSelect, 0&)
MUINotifyAttrHook(volumeList, MUIA_List_Active, volumeHook)

{ Directory selection hook }
MUISetupHookA4(dirHook, @OnDirSelect, 0&)
MUINotifyAttrHook(dirList, MUIA_List_Active, dirHook)

PRINT "Notifications set up"

{ ============== Open Window ============== }

MUIWindowOpen(win)
PRINT "Window open - select a volume to browse"

{ ============== Event Loop ============== }

running = -1&

WHILE running
    returnID = MUIWaitEvent(app)

    IF returnID = -1& THEN
        PRINT "Quit"
        running = 0&
    END IF
WEND

{ ============== Cleanup ============== }

MUIWindowClose(win)

cleanup:
IF app <> 0& THEN
    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "muimaster.library"
LIBRARY CLOSE "intuition.library"

PRINT "Done!"
END
