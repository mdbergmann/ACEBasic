{*
** test_list.b - Test MUI List functionality
**
** Tests list creation, insertion, removal, selection, and retrieval.
**
** Layout:
**   +----------------------------------------+
**   |         MUI List Test                  |
**   +----------------------------------------+
**   | +-- List View --+ +-- Controls ------+ |
**   | | Item 1        | | [Add Item]       | |
**   | | Item 2        | | [Remove]         | |
**   | | Item 3        | | [Clear]          | |
**   | | ...           | | Count: 3         | |
**   | +---------------+ | Selected: Item 1 | |
**   |                   +------------------+ |
**   +----------------------------------------+
**   |              [Quit]                    |
**   +----------------------------------------+
*}

#include <submods/MUI.h>

{ ============== Libraries ============== }
LIBRARY "intuition.library"
LIBRARY "muimaster.library"
LIBRARY "utility.library"

{ ============== Variables ============== }
ADDRESS app, win, rootGrp
ADDRESS listObj, listviewObj
ADDRESS btnAdd, btnRemove, btnClear, btnQuit
ADDRESS txtCount, txtSelected
ADDRESS listGrp, controlGrp, mainColumns, buttonGrp
LONGINT running, returnID
LONGINT itemCounter

{ Hook for list selection changes }
DECLARE STRUCT MUIHook selectHook

{ ============== Callbacks ============== }

SUB OnSelectChange(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED listObj, txtSelected
    LONGINT activeIdx
    ADDRESS entryPtr
    STRING entryText
    SHORTINT i, ch

    IF listObj <> 0& AND txtSelected <> 0& THEN
        activeIdx = MUIListActive(listObj)
        IF activeIdx >= 0 THEN
            entryPtr = MUIListGetEntry(listObj, activeIdx)
            IF entryPtr <> 0& THEN
                { Convert C string pointer to BASIC string }
                entryText = ""
                FOR i = 0 TO 30
                    ch = PEEK(entryPtr + i)
                    IF ch = 0 THEN EXIT FOR
                    entryText = entryText + CHR$(ch)
                NEXT i
                MUISetText(txtSelected, entryText)
            ELSE
                MUISetText(txtSelected, "(null)")
            END IF
        ELSE
            MUISetText(txtSelected, "none")
        END IF
    END IF

    OnSelectChange = 0&
END SUB

{ ============== Helper SUBs ============== }

SUB UpdateCount
    SHARED listObj, txtCount
    LONGINT cnt

    IF listObj <> 0& AND txtCount <> 0& THEN
        cnt = MUIListCount(listObj)
        MUISetText(txtCount, "Count: " + STR$(cnt))
    END IF
END SUB

{ ============== Main Program ============== }

PRINT "MUI List Test"
PRINT "============="

{ Initialize counter for new items }
itemCounter = 1

{ Initialize MUI submod }
MUIInit

{ ============== Create Objects ============== }

{ Create list object }
listObj = MUIList
IF listObj = 0& THEN PRINT "FAIL: listObj" : GOTO cleanup
PRINT "List object created"

{ Wrap in listview for scrolling }
listviewObj = MUIListview(listObj)
IF listviewObj = 0& THEN PRINT "FAIL: listviewObj" : GOTO cleanup
PRINT "Listview created"

{ Add some initial items }
MUIListInsert(listObj, "First Item")
MUIListInsert(listObj, "Second Item")
MUIListInsert(listObj, "Third Item")
itemCounter = 4
PRINT "Initial items added"

{ Control buttons }
btnAdd = MUIButton("Add Item")
IF btnAdd = 0& THEN PRINT "FAIL: btnAdd" : GOTO cleanup

btnRemove = MUIButton("Remove")
IF btnRemove = 0& THEN PRINT "FAIL: btnRemove" : GOTO cleanup

btnClear = MUIButton("Clear All")
IF btnClear = 0& THEN PRINT "FAIL: btnClear" : GOTO cleanup

btnQuit = MUIButton("Quit")
IF btnQuit = 0& THEN PRINT "FAIL: btnQuit" : GOTO cleanup

{ Status text objects }
txtCount = MUIText("Count: 3")
IF txtCount = 0& THEN PRINT "FAIL: txtCount" : GOTO cleanup

txtSelected = MUIText("Sel: none")
IF txtSelected = 0& THEN PRINT "FAIL: txtSelected" : GOTO cleanup

PRINT "All objects created"

{ ============== Build Layout ============== }

{ List group with frame }
MUIBeginVGroup
    MUIGroupFrameT("List")
    MUIChild(listviewObj)
listGrp = MUIEndGroup
IF listGrp = 0& THEN PRINT "FAIL: listGrp" : GOTO cleanup

{ Control group with frame }
MUIBeginVGroup
    MUIGroupFrameT("Controls")
    MUIGroupSpacing(4)
    MUIChild(btnAdd)
    MUIChild(btnRemove)
    MUIChild(btnClear)
    MUIChild(MUIHBar)
    MUIChild(txtCount)
    MUIChild(txtSelected)
controlGrp = MUIEndGroup
IF controlGrp = 0& THEN PRINT "FAIL: controlGrp" : GOTO cleanup

{ Main two-column area }
mainColumns = MUIHGroup2(listGrp, controlGrp)
IF mainColumns = 0& THEN PRINT "FAIL: mainColumns" : GOTO cleanup

{ Button group at bottom }
MUIBeginHGroup
    MUIChild(MUIRectangle)
    MUIChild(btnQuit)
    MUIChild(MUIRectangle)
buttonGrp = MUIEndGroup
IF buttonGrp = 0& THEN PRINT "FAIL: buttonGrp" : GOTO cleanup

{ Root group }
MUIBeginVGroup
    MUIGroupSpacing(4)
    MUIChild(MUITextCentered("MUI List Test"))
    MUIChild(MUIHBar)
    MUIChild(mainColumns)
    MUIChild(MUIHBar)
    MUIChild(buttonGrp)
rootGrp = MUIEndGroup
IF rootGrp = 0& THEN PRINT "FAIL: rootGrp" : GOTO cleanup

PRINT "Layout built"

{ ============== Create Window and App ============== }

win = MUIWindow("MUI List Test", rootGrp)
IF win = 0& THEN PRINT "FAIL: window" : GOTO cleanup

app = MUIApp("ListTest", "$VER: ListTest 1.0", win)
IF app = 0& THEN PRINT "FAIL: app" : GOTO cleanup

PRINT "Window and app created"

{ ============== Set Up Notifications ============== }

{ Button notifications: Add=1, Remove=2, Clear=3, Quit=-1 }
MUINotifyButton(btnAdd, app, 1)
MUINotifyButton(btnRemove, app, 2)
MUINotifyButton(btnClear, app, 3)
MUINotifyButton(btnQuit, app, MUIV_Application_ReturnID_Quit)

{ Close notification }
MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

{ Selection change hook }
MUISetupHookA4(selectHook, @OnSelectChange, 0&)
MUINotifyAttrHook(listObj, MUIA_List_Active, selectHook)

{ ============== Open Window ============== }

MUIWindowOpen(win)
PRINT "Window open"

{ ============== Event Loop ============== }

running = -1&

WHILE running
    returnID = MUIWaitEvent(app)

    IF returnID = -1& THEN
        { Quit or window closed }
        PRINT "Quit"
        running = 0&
    END IF

    IF returnID = 1 THEN
        { Add button pressed }
        MUIListInsert(listObj, "Item " + STR$(itemCounter))
        itemCounter = itemCounter + 1
        UpdateCount
        PRINT "Added item, count now:"; MUIListCount(listObj)
    END IF

    IF returnID = 2 THEN
        { Remove button pressed - remove selected item }
        LONGINT sel
        sel = MUIListActive(listObj)
        IF sel >= 0 THEN
            MUIListRemove(listObj, sel)
            UpdateCount
            PRINT "Removed item at:"; sel
        ELSE
            PRINT "No item selected to remove"
        END IF
    END IF

    IF returnID = 3 THEN
        { Clear button pressed }
        MUIListClear(listObj)
        UpdateCount
        MUISetText(txtSelected, "Sel: none")
        PRINT "List cleared"
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
