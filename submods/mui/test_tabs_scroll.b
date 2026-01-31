' test_tabs_scroll.b - Test Phase 12: Tabs, Scrolling, Balance

#include <submods/MUI.h>

CONST ID_QUIT = 1

ADDRESS app, win, rootGrp
ADDRESS reg, page1, page2, page3
ADDRESS leftPane, rightPane, scrollGrp, virtGrp, balanceGrp
ADDRESS txtStatus
LONGINT running, eventID

PRINT "Test Phase 12: Tabs, Scrolling, Balance"

MUIInit

PRINT "Creating pages..."

' Page 1: Simple content
MUIBeginVGroup
MUIGroupFrameT("Page 1 - Basic")
MUIChild(MUITextCentered("First tab page"))
MUIChild(MUIButton("Button 1"))
page1 = MUIEndGroup

' Page 2: Scrollable content
MUIBeginVGroup
MUIGroupFrameT("Scrollable")
MUIChild(MUIText("Item 1"))
MUIChild(MUIText("Item 2"))
MUIChild(MUIText("Item 3"))
MUIChild(MUIText("Item 4"))
MUIChild(MUIText("Item 5"))
MUIChild(MUIText("Item 6"))
MUIChild(MUIText("Item 7"))
MUIChild(MUIText("Item 8"))
page2 = MUIEndGroup

virtGrp = MUIVirtgroup(page2)
scrollGrp = MUIScrollgroupVert(virtGrp)

' Page 3: Balance
leftPane = MUITextFramed("Left Pane")
rightPane = MUITextFramed("Right Pane")

MUIBeginHGroup
MUIGroupFrameT("Balance")
MUIChild(leftPane)
MUIChild(MUIBalance)
MUIChild(rightPane)
balanceGrp = MUIEndGroup

PRINT "Creating register..."

' Create Register
MUIBeginRegister("Basic|Scroll|Balance")
MUIRegisterPage(page1)
MUIRegisterPage(scrollGrp)
MUIRegisterPage(balanceGrp)
reg = MUIEndRegister

PRINT "Register created"

txtStatus = MUITextCentered("Click tabs to test")

MUIBeginVGroup
MUIChild(reg)
MUIChild(MUIHBar)
MUIChild(txtStatus)
rootGrp = MUIEndGroup

win = MUIWindow("Phase 12 Test", rootGrp)
app = MUIApp("TabsTest", "$VER: TabsTest 1.0", win)

PRINT "Setting up notifications..."

MUINotifyClose(win, app, ID_QUIT)
MUIWindowOpen(win)

PRINT "Window open - close to exit"

running = -1
WHILE running
    eventID = MUIWaitEvent(app)
    IF eventID = ID_QUIT THEN running = 0
    IF eventID = MUIV_Application_ReturnID_Quit THEN running = 0
WEND

PRINT "Cleanup..."
MUIDispose(app)
MUICleanup

PRINT "Done"
END
