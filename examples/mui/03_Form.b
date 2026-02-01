{*
** 03_Form.b - Input form with various gadgets
**
** Copyright (c) 2026 Manfred Bergmann. All rights reserved.
**
** Demonstrates:
** - Column groups for form layout (MUIBeginColGroup 2)
** - String gadgets (MUIString, MUIInteger)
** - Checkmarks (MUICheckmark)
** - Cycle gadgets (MUICycle)
** - Labels (MUILabelRight for right-aligned labels)
** - Reading gadget values
**
** Compile: ace:bin/bas 03_Form ace:submods/mui/MUI.o
*}

#include <submods/MUI.h>

{ Libraries needed by main program (muimaster opened by submod) }
LIBRARY "intuition.library"
LIBRARY "utility.library"

CONST ID_SUBMIT = 1
CONST ID_CLEAR = 2

ADDRESS app, win, grp
ADDRESS strName, strAge, chkMember, cycCountry
ADDRESS btnSubmit, btnClear, txtStatus
LONGINT eventID, running
STRING nameVal SIZE 80, statusStr SIZE 100

{ Country options - null-terminated array of string pointers }
DIM countries&(5)

{ Initialize MUI }
MUIInit

{ Set up cycle gadget entries }
countries&(0) = SADD("Germany")
countries&(1) = SADD("USA")
countries&(2) = SADD("UK")
countries&(3) = SADD("Other")
countries&(4) = 0&              ' Null terminator required!

{ Create gadgets }
strName = MUIString("", 40)
strAge = MUIInteger(25)
chkMember = MUICheckmark(0)     ' 0 = unchecked, -1 = checked
cycCountry = MUICycle(VARPTR(countries&(0)))
txtStatus = MUIText("Fill in the form and click Submit")
btnSubmit = MUIButton("Submit")
btnClear = MUIButton("Clear")

{ Build layout }
MUIBeginVGroup
    MUIChild(MUITextCentered("Registration Form"))

    { Form using 2-column layout }
    MUIBeginColGroup(2)
        MUIGroupFrameT("Details")
        MUIChild(MUILabelRight("Name:"))
        MUIChild(strName)
        MUIChild(MUILabelRight("Age:"))
        MUIChild(strAge)
        MUIChild(MUILabelRight("Member:"))
        MUIChild(chkMember)
        MUIChild(MUILabelRight("Country:"))
        MUIChild(cycCountry)
    MUIChild(MUIEndGroup)

    MUIChild(txtStatus)

    MUIBeginHGroup
        MUIGroupSameSize
        MUIChild(btnSubmit)
        MUIChild(btnClear)
    MUIChild(MUIEndGroup)
grp = MUIEndGroup

win = MUIWindow("Form Example", grp)
app = MUIApp("FormExample", "$VER: FormExample 1.0", win)

IF app <> 0& THEN
    MUINotifyButton(btnSubmit, app, ID_SUBMIT)
    MUINotifyButton(btnClear, app, ID_CLEAR)
    MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

    MUIWindowOpen(win)

    running = -1
    WHILE running
        eventID = MUIWaitEvent(app)

        CASE
            eventID = MUIV_Application_ReturnID_Quit : running = 0

            eventID = ID_SUBMIT : BLOCK
                { Read values from gadgets }
                nameVal = ""
                IF MUIGetStringContents(strName) <> 0& THEN
                    nameVal = CSTR(MUIGetStringContents(strName))
                END IF

                statusStr = "Name: " + nameVal + ", Age: " + STR$(MUIGetInteger(strAge))

                IF MUIGetChecked(chkMember) THEN
                    statusStr = statusStr + " (Member)"
                END IF

                statusStr = statusStr + ", Country #" + STR$(MUIGetActive(cycCountry))

                PRINT statusStr
                MUISetText(txtStatus, "Submitted!")
            END BLOCK

            eventID = ID_CLEAR : BLOCK
                MUISetStringContents(strName, "")
                MUISet(strAge, MUIA_String_Integer, 0)
                MUISetChecked(chkMember, 0)
                MUISetActive(cycCountry, 0)
                MUISetText(txtStatus, "Form cleared")
            END BLOCK
        END CASE
    WEND

    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

END
