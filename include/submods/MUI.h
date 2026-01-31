#ifndef MUI_H
#define MUI_H 1

{*
** MUI.h - MUI Support Header for ACE Basic
** Part of the MUI submod for ACE Basic
** Version 1.0 - February 2026
**
** QUICK START:
**
**   #include <submods/MUI.h>
**   EXTERNAL MUI
**
**   MUIInit()
**   txt = MUITextCentered("Hello!")
**   MUIBeginVGroup()
**       MUIChild(txt)
**   grp = MUIEndGroup()
**   win = MUIWindow("My App", grp)
**   app = MUIApp("MyApp", "$VER: MyApp 1.0", win)
**   MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)
**   MUIWindowOpen(win)
**   WHILE MUIWaitEvent(app) <> MUIV_Application_ReturnID_Quit : WEND
**   MUIDispose(app)
**   MUICleanup()
**
** COMPILE:
**
**   ace:bin/bas myprogram ace:submods/mui/MUI.o
**
** IMPORTANT:
**
** - This module is self-contained. Do NOT add LIBRARY statements
**   for muimaster in your main program. The module handles it.
**
** - MUIInit must be called first, MUICleanup last.
**
** - Objects are disposed automatically when you call MUIDispose(app).
**
** - See docs/MUI-Submod.txt for full documentation.
**
** - See examples/mui/ for example programs.
*}

CONST MUI_SUBMOD_VERSION = 1

{ TagItem structure }
STRUCT TagItem
    LONGINT ti_Tag
    LONGINT ti_Data
END STRUCT

{ Tag constants }
CONST TAG_DONE = 0&

{ Error codes for MUILastError() }
CONST MUIERR_NONE           = 0     ' No error
CONST MUIERR_NOLIBRARY      = 1     ' Could not open muimaster.library
CONST MUIERR_CREATEFAILED   = 2     ' Object creation failed
CONST MUIERR_GROUPOVERFLOW  = 3     ' Group nesting too deep (max 10)
CONST MUIERR_INVALIDPARAM   = 4     ' Invalid parameter passed

{ MUI Attribute Tags }
CONST MUIA_Application_Title       = &H804281b8
CONST MUIA_Application_Version     = &H8042b33f
CONST MUIA_Application_Author      = &H80424842
CONST MUIA_Application_Description = &H80421fc6
CONST MUIA_Application_Window      = &H8042bfe0
CONST MUIA_Application_Signals     = &H8042c5ca
CONST MUIA_Window_Title            = &H8042ad3d
CONST MUIA_Window_ID               = &H804201bd
CONST MUIA_Window_RootObject       = &H8042cba5
CONST MUIA_Window_Open             = &H80428aa0
CONST MUIA_Window_CloseRequest     = &H8042e86e
CONST MUIA_Window_ScreenTitle      = &H804234b0
CONST MUIA_Application_Sleep       = &H80425711
CONST MUIA_Group_Child             = &H804226e6
CONST MUIA_Group_Horiz             = &H8042ae4c
CONST MUIA_Text_Contents           = &H8042f8dc
CONST MUIA_Text_PreParse           = &H8042566a
CONST MUIA_Frame                   = &H8042ac64
CONST MUIV_Frame_Group             = 9

{ MUI Methods }
CONST MUIM_Notify                     = &H8042c9cb
CONST MUIM_Application_ReturnID       = &H804276ef
CONST MUIM_Application_NewInput       = &H80423ba6
CONST MUIM_CallHook                   = &H8042b96b
CONST MUIV_Application_ReturnID_Quit  = -1
CONST MUIV_EveryTime                  = &H49893131

{ Hook structure for CALLBACK support }
STRUCT MUIHook
    ADDRESS h_MinNode_mln_Succ
    ADDRESS h_MinNode_mln_Pred
    ADDRESS h_Entry
    ADDRESS h_SubEntry
    ADDRESS h_Data
END STRUCT

{ Button constants }
CONST MUIA_InputMode                  = &H8042fb04
CONST MUIV_InputMode_RelVerify        = 1
CONST MUIA_Background                 = &H8042545b
CONST MUII_ButtonBack                 = 131
CONST MUIV_Frame_Button               = 1
CONST MUIA_Pressed                    = &H80423535
CONST MUIA_ControlChar                = &H8042120b
CONST MUIA_Text_HiChar                = &H804218ff

{ Image constants }
CONST MUIA_Image_Spec                 = &H804233d5
CONST MUIV_Frame_ImageButton          = 2

{ Colorfield constants }
CONST MUIA_Colorfield_Red             = &H804279f6
CONST MUIA_Colorfield_Green           = &H80424466
CONST MUIA_Colorfield_Blue            = &H8042d3b0

{ Coloradjust constants }
CONST MUIA_Coloradjust_Red            = &H80420eaa
CONST MUIA_Coloradjust_Green          = &H804285ab
CONST MUIA_Coloradjust_Blue           = &H8042b8a3
CONST MUIA_Coloradjust_RGB            = &H8042f899
CONST MUIA_Coloradjust_ModeID         = &H8042ec59

{ Palette constants }
CONST MUIA_Palette_Entries            = &H8042a3d8
CONST MUIA_Palette_Groupable          = &H80423e67
CONST MUIA_Palette_Names              = &H8042c3a2

{ Pendisplay constants }
CONST MUIA_Pendisplay_Pen             = &H8042a748
CONST MUIA_Pendisplay_RGBcolor        = &H8042a1a9
CONST MUIA_Pendisplay_Spec            = &H8042a204
CONST MUIA_Pendisplay_Reference       = &H8042dc24

{ Scale constants }
CONST MUIA_Scale_Horiz                = &H8042919a

{ Popstring/Popobject/Popasl/Poplist constants }
CONST MUIA_Popstring_Button           = &H8042d0b9
CONST MUIA_Popstring_String           = &H804239ea
CONST MUIA_Popstring_Toggle           = &H80422b7a
CONST MUIA_Popobject_Object           = &H804293e3
CONST MUIA_Popobject_ObjStrHook       = &H8042db44
CONST MUIA_Popobject_StrObjHook       = &H8042fbe1
CONST MUIA_Popobject_WindowHook       = &H8042f194
CONST MUIA_Popobject_Light            = &H8042a5a3
CONST MUIA_Popobject_Follow           = &H80424cb5
CONST MUIA_Popobject_Volatile         = &H804252ec
CONST MUIA_Poplist_Array              = &H8042084c
CONST MUIA_Popasl_Active              = &H80421b37
CONST MUIA_Popasl_Type                = &H8042df3d
CONST MUIA_Popasl_StartHook           = &H8042b703
CONST MUIA_Popasl_StopHook            = &H8042d8d2

{ ASL requester types for Popasl }
CONST ASL_FileRequest                 = 0
CONST ASL_FontRequest                 = 1
CONST ASL_ScreenModeRequest           = 2

{ Popup button image types }
CONST MUII_PopUp                      = 18
CONST MUII_PopFile                    = 19
CONST MUII_PopDrawer                  = 20

{ Popstring methods }
CONST MUIM_Popstring_Close            = &H8042dc52
CONST MUIM_Popstring_Open             = &H804258ba

{ String gadget constants }
CONST MUIA_String_Contents         = &H80428ffd
CONST MUIA_String_MaxLen           = &H80424984
CONST MUIA_String_Secret           = &H80428769
CONST MUIA_String_Integer          = &H80426e8a
CONST MUIA_String_Accept           = &H8042e3e1
CONST MUIV_Frame_String            = 4

{ Checkmark/Image constants }
CONST MUIA_Selected                = &H8042654b
CONST MUIV_InputMode_Toggle        = 3
CONST MUII_CheckMark               = 15
CONST MUIA_Image_FreeHoriz         = &H8042da84
CONST MUIA_Image_FreeVert          = &H8042ea28
CONST MUIA_ShowSelState            = &H8042caac

{ Cycle constants }
CONST MUIA_Cycle_Entries           = &H80420629
CONST MUIA_Cycle_Active            = &H80421788

{ Slider constants }
CONST MUIA_Slider_Min              = &H8042e404
CONST MUIA_Slider_Max              = &H8042d78a
CONST MUIA_Slider_Level            = &H8042ae3a
CONST MUIA_Numeric_Value           = &H8042ae3a

{ Gauge constants }
CONST MUIA_Gauge_Current           = &H8042f0dd
CONST MUIA_Gauge_Max               = &H8042bcdb
CONST MUIA_Gauge_InfoText          = &H8042bf15
CONST MUIA_Gauge_Horiz             = &H804232dd

{ Label/Weight constants }
CONST MUIA_Weight                  = &H80421d1f
CONST MUIA_FixWidth                = &H8042a3f1
CONST MUIA_FixHeight               = &H8042a985

{ Group builder constants }
CONST MUIA_Group_Columns           = &H8042f416
CONST MUIA_Group_Rows              = &H8042b68f
CONST MUIA_Group_SameSize          = &H80420860
CONST MUIA_Group_SameWidth         = &H8042b3ec
CONST MUIA_Group_SameHeight        = &H8042037e
CONST MUIA_Group_Spacing           = &H8042866d
CONST MUIA_FrameTitle              = &H8042d1c7

{ Radio constants }
CONST MUIA_Radio_Entries           = &H8042b6a1
CONST MUIA_Radio_Active            = &H80429b41

{ List attributes }
CONST MUIA_List_Active             = &H8042391c
CONST MUIA_List_Entries            = &H80421654
CONST MUIA_List_Quiet              = &H8042d8c7
CONST MUIA_List_Format             = &H80423c0a
CONST MUIA_List_Title              = &H80423e66
CONST MUIA_List_Visible            = &H8042191f

{ List methods }
CONST MUIM_List_Insert             = &H80426c87
CONST MUIM_List_Remove             = &H8042647e
CONST MUIM_List_Clear              = &H8042ad89
CONST MUIM_List_GetEntry           = &H804280ec

{ Listview attributes }
CONST MUIA_Listview_List           = &H8042bcce
CONST MUIA_Listview_Input          = &H8042682d
CONST MUIA_Listview_MultiSelect    = &H80427e08

{ List hooks for string copying }
CONST MUIA_List_ConstructHook      = &H8042894f
CONST MUIA_List_DestructHook       = &H804297ce
CONST MUIV_List_ConstructHook_String = -1
CONST MUIV_List_DestructHook_String  = -1

{ Special list positions }
CONST MUIV_List_Insert_Top         = 0
CONST MUIV_List_Insert_Active      = -1
CONST MUIV_List_Insert_Sorted      = -2
CONST MUIV_List_Insert_Bottom      = -3
CONST MUIV_List_Active_Off         = -1
CONST MUIV_List_Active_Top         = -2
CONST MUIV_List_Active_Bottom      = -3

{ Menu/Menuitem attributes }
CONST MUIA_Menu_Enabled            = &H8042ed48
CONST MUIA_Menu_Title              = &H8042a0e3
CONST MUIA_Menuitem_Checked        = &H8042562a
CONST MUIA_Menuitem_Checkit        = &H80425ace
CONST MUIA_Menuitem_CommandString  = &H8042b9cc
CONST MUIA_Menuitem_Enabled        = &H8042ae0f
CONST MUIA_Menuitem_Exclude        = &H80420bc6
CONST MUIA_Menuitem_Shortcut       = &H80422030
CONST MUIA_Menuitem_Title          = &H804218be
CONST MUIA_Menuitem_Toggle         = &H80424d5c
CONST MUIA_Menuitem_Trigger        = &H80426f32
CONST MUIA_Window_Menustrip        = &H8042855e
CONST MUIA_Family_Child            = &H8042c696

{ Menu special values }
CONST NM_BARLABEL                  = -1

{ Register (tabs) constants }
CONST MUIA_Register_Frame          = &H8042349b
CONST MUIA_Register_Titles         = &H804297ec

{ Group paging (used by Register) }
CONST MUIA_Group_PageMode          = &H80421a5f
CONST MUIA_Group_ActivePage        = &H80424199

{ Scrollgroup constants }
CONST MUIA_Scrollgroup_Contents    = &H80421261
CONST MUIA_Scrollgroup_FreeHoriz   = &H804292f3
CONST MUIA_Scrollgroup_FreeVert    = &H804224f2
CONST MUIA_Scrollgroup_HorizBar    = &H8042b63d
CONST MUIA_Scrollgroup_VertBar     = &H8042cb41

{ Virtgroup constants }
CONST MUIA_Virtgroup_Input         = &H80427f7e
CONST MUIA_Virtgroup_Left          = &H80429371
CONST MUIA_Virtgroup_Top           = &H80425200

{ Balance constants }
CONST MUIA_Balance_Quiet           = &H80427486

{ Frame type for virtual groups }
CONST MUIV_Frame_Virtual           = 11

{ ============== Tag Builder ============== }
{*
** Tag builder functions for constructing MUI tag arrays.
** All state is maintained in the module.
**
** Usage:
**   MUITagStart
**   MUITag MUIA_Something, value
**   MUITag MUIA_Another, value2
**   MUITagEnd
**   obj = MUINewObj(SADD("ClassName.mui"))
*}
DECLARE SUB MUITagStart EXTERNAL
DECLARE SUB MUITag(LONGINT tagId, LONGINT tagVal) EXTERNAL
DECLARE SUB MUITagEnd EXTERNAL
DECLARE SUB ADDRESS MUINewObj(ADDRESS className) EXTERNAL

{ ============== Group Builder ============== }
{*
** Stack-based group builder for nested MUI groups.
** Supports up to 10 nesting levels, 10 children per group.
** All state is maintained in the module.
**
** Usage:
**   MUIBeginVGroup
**     MUIGroupFrameT "Settings"
**     MUIGroupSameSize
**     MUIChild MUIText("Hello")
**     MUIChild MUIButton("OK")
**   grp = MUIEndGroup
**
** Column group example (for forms):
**   MUIBeginColGroup(2)
**     MUIChild(MUILabelRight("Name:"))
**     MUIChild(MUIString("", 40))
**     MUIChild(MUILabelRight("Age:"))
**     MUIChild(MUIInteger(0))
**   grp = MUIEndGroup
*}
DECLARE SUB MUIBeginVGroup EXTERNAL
DECLARE SUB MUIBeginHGroup EXTERNAL
DECLARE SUB MUIBeginColGroup(SHORTINT cols) EXTERNAL
DECLARE SUB MUIBeginRowGroup(SHORTINT rows) EXTERNAL
DECLARE SUB MUIGroupFrameT(STRING title) EXTERNAL
DECLARE SUB MUIGroupFrame EXTERNAL
DECLARE SUB MUIGroupSameSize EXTERNAL
DECLARE SUB MUIGroupSameWidth EXTERNAL
DECLARE SUB MUIGroupSameHeight EXTERNAL
DECLARE SUB MUIGroupSpacing(SHORTINT space) EXTERNAL
DECLARE SUB MUIChild(ADDRESS child) EXTERNAL
DECLARE SUB MUIChildWeight(ADDRESS child, SHORTINT weight) EXTERNAL
DECLARE SUB ADDRESS MUIEndGroup EXTERNAL

{ Quick form helpers - two-column label/gadget layouts }
DECLARE SUB ADDRESS MUIForm2(ADDRESS l1, ADDRESS g1, ADDRESS l2, ADDRESS g2) EXTERNAL
DECLARE SUB ADDRESS MUIForm3(ADDRESS l1, ADDRESS g1, ADDRESS l2, ADDRESS g2, ADDRESS l3, ADDRESS g3) EXTERNAL

{ ============== Module EXTERNAL declarations ============== }

{ Library management - MUST be called first and last }
DECLARE SUB MUIInit EXTERNAL
DECLARE SUB MUICleanup EXTERNAL

{ Error handling }
DECLARE SUB LONGINT MUIVersion EXTERNAL      ' Returns MUI library version (e.g., 20)
DECLARE SUB LONGINT MUILastError EXTERNAL    ' Returns last error code (MUIERR_*)
DECLARE SUB ADDRESS MUIErrorStr EXTERNAL     ' Returns last error as string pointer

{ Low-level functions }
{ DoMethodA implemented via CallHookPkt in the module }
DECLARE SUB LONGINT DoMethodA(ADDRESS obj, ADDRESS msg) EXTERNAL
DECLARE SUB MUIDispose(ADDRESS obj) EXTERNAL

{*
** ============== Text Objects ==============
** Create text display objects.
** All return ADDRESS of object or 0& on failure.
*}
DECLARE SUB ADDRESS MUIText(STRING contents) EXTERNAL
DECLARE SUB ADDRESS MUITextCentered(STRING contents) EXTERNAL
DECLARE SUB ADDRESS MUITextFramed(STRING contents) EXTERNAL

{*
** ============== Button Objects ==============
** MUIButton(label)           - Standard button
** MUIKeyButton(label, key)   - Button with keyboard shortcut (e.g., "_OK", "o")
** MUIImageButton(imageSpec)  - Button with MUI image (MUII_* constant)
*}
DECLARE SUB ADDRESS MUIButton(STRING label) EXTERNAL
DECLARE SUB ADDRESS MUIKeyButton(STRING label, STRING key) EXTERNAL
DECLARE SUB ADDRESS MUIImageButton(LONGINT imageSpec) EXTERNAL

{ Object helpers - Groups (quick helpers) }
DECLARE SUB ADDRESS MUIVGroup2(ADDRESS child1, ADDRESS child2) EXTERNAL
DECLARE SUB ADDRESS MUIVGroup3(ADDRESS c1, ADDRESS c2, ADDRESS c3) EXTERNAL
DECLARE SUB ADDRESS MUIVGroup4(ADDRESS c1, ADDRESS c2, ADDRESS c3, ADDRESS c4) EXTERNAL
DECLARE SUB ADDRESS MUIHGroup2(ADDRESS child1, ADDRESS child2) EXTERNAL
DECLARE SUB ADDRESS MUIHGroup3(ADDRESS c1, ADDRESS c2, ADDRESS c3) EXTERNAL
DECLARE SUB ADDRESS MUIHGroup4(ADDRESS c1, ADDRESS c2, ADDRESS c3, ADDRESS c4) EXTERNAL

{*
** ============== Window & Application ==============
** MUIWindow(title, rootObj)     - Create window with root group
** MUIWindowID(title, root, id)  - Window with ID for position memory
** MUIWindowWithMenu(t, r, menu) - Window with attached menustrip
** MUIWindowOpen(win)            - Open/show window
** MUIWindowClose(win)           - Close/hide window
** MUIApp(title, ver, win)       - Create app with single window
** MUIAppMulti(title, ver)       - Create app for multiple windows
** MUIAppSleep/Wake(app)         - Disable/enable all windows
*}
DECLARE SUB ADDRESS MUIWindow(STRING title, ADDRESS rootObj) EXTERNAL
DECLARE SUB ADDRESS MUIWindowID(STRING title, ADDRESS rootObj, LONGINT windowID) EXTERNAL
DECLARE SUB ADDRESS MUIWindowWithMenu(STRING title, ADDRESS rootObj, ADDRESS mstrip) EXTERNAL
DECLARE SUB MUIWindowOpen(ADDRESS win) EXTERNAL
DECLARE SUB MUIWindowClose(ADDRESS win) EXTERNAL
DECLARE SUB LONGINT MUIWindowIsOpen(ADDRESS win) EXTERNAL
DECLARE SUB MUIWindowTitle(ADDRESS win, STRING title) EXTERNAL
DECLARE SUB MUIWindowScreenTitle(ADDRESS win, STRING title) EXTERNAL
DECLARE SUB ADDRESS MUIApp(STRING appTitle, STRING appVersion, ADDRESS theWin) EXTERNAL
DECLARE SUB ADDRESS MUIAppMulti(STRING appTitle, STRING appVersion) EXTERNAL
DECLARE SUB MUIAppAddWindow(ADDRESS theApp, ADDRESS win) EXTERNAL
DECLARE SUB MUIAppRemWindow(ADDRESS theApp, ADDRESS win) EXTERNAL
DECLARE SUB MUIAppSleep(ADDRESS theApp) EXTERNAL
DECLARE SUB MUIAppWake(ADDRESS theApp) EXTERNAL

{*
** ============== ID-Based Notifications ==============
** Set up notifications that return an ID to your event loop.
** MUINotifyButton(btn, app, id) - Return id when button clicked
** MUINotifyClose(win, app, id)  - Return id when window close requested
*}
DECLARE SUB MUINotifyButton(ADDRESS btn, ADDRESS theApp, LONGINT buttonID) EXTERNAL
DECLARE SUB MUINotifyCheckmark(ADDRESS chk, ADDRESS theApp, LONGINT checkID) EXTERNAL
DECLARE SUB MUINotifyClose(ADDRESS theWin, ADDRESS theApp, LONGINT closeID) EXTERNAL

{*
** Notifications - Hook-based (requires CALLBACK SUB)
**
** IMPORTANT: Use MUISetupHookA4 (not MUISetupHook) to enable SHARED variables
** in your CALLBACK SUB. MUISetupHookA4 captures the main program's A4 register
** which is required for SHARED variable access.
**
** Usage example:
**   DECLARE STRUCT MUIHook myHook
**   LONGINT clickCount
**   clickCount = 0
**
**   SUB OnClick(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
**       SHARED clickCount   ' Works because A4 is restored from hook
**       clickCount = clickCount + 1
**       OnClick = 0&
**   END SUB
**
**   MUISetupHookA4(VARPTR(myHook), @OnClick, 0&)  ' Use A4-aware version!
**   MUINotifyButtonHook(btn, VARPTR(myHook))
*}

{ Low-level hook setup - does NOT support SHARED in callbacks }
DECLARE SUB MUISetupHook(ADDRESS hook, ADDRESS hookFunc, ADDRESS userData) EXTERNAL
DECLARE SUB MUINotifyButtonHook(ADDRESS btn, ADDRESS hook) EXTERNAL
DECLARE SUB MUINotifyAttrHook(ADDRESS obj, LONGINT attr, ADDRESS hook) EXTERNAL

{*
** MUISetupHookA4 - Set up hook with A4 restoration for SHARED support
**
** This creates a hook that properly restores A4 before calling your callback,
** enabling SHARED variables to work correctly.
**
** Hook structure layout:
**   h_Entry (offset 8)     = stub that restores A4
**   h_SubEntry (offset 12) = saved main program A4
**   h_Data (offset 16)     = actual callback address
**
** NOTE: userData parameter is ignored. Use SHARED variables instead.
*}
SUB MUISetupHookA4(ADDRESS hook, ADDRESS hookFunc, ADDRESS userData)
    ADDRESS stubAddr

    { Get address of the hook stub }
    { Stack: -4=hook, -8=hookFunc, -12=userData, -16=stubAddr }
    ASSEM
        bra.s   _skip_hook_stub

_MUIHookStub:
        ; Called by MUI with: A0=hook, A1=msg, A2=object
        ; We need to restore A4 and call the real callback

        move.l  a4,-(sp)            ; Save MUI's A4 [SP+0]
        move.l  12(a0),a4           ; Load our A4 from h_SubEntry
        move.l  16(a0),a3           ; Get callback address from h_Data

        ; Push params for ACE CALLBACK (right-to-left: msg, obj, hook)
        ; A0 still contains hook pointer
        move.l  a1,-(sp)            ; Push msg      [SP+0], A4 at [SP+4]
        move.l  a2,-(sp)            ; Push obj      [SP+0], msg at [SP+4]
        move.l  a0,-(sp)            ; Push hook     [SP+0], obj at [SP+4], msg at [SP+8]

        jsr     (a3)                ; Call the callback

        lea     12(sp),sp           ; Clean up 3 params (12 bytes)
        move.l  (sp)+,a4            ; Restore MUI's A4
        rts

_skip_hook_stub:
        lea     _MUIHookStub(pc),a0
        move.l  a0,-16(a5)          ; Store stub address to stubAddr (local)
    END ASSEM

    { Initialize hook structure }
    POKEL hook, 0&                  { h_MinNode_mln_Succ }
    POKEL hook + 4, 0&              { h_MinNode_mln_Pred }
    POKEL hook + 8, stubAddr        { h_Entry = stub }
    POKEL hook + 16, hookFunc       { h_Data = actual callback }

    { Store our A4 to h_SubEntry }
    ASSEM
        move.l  -4(a5),a0           ; Get hook pointer (param)
        move.l  a4,12(a0)           ; h_SubEntry = our A4
    END ASSEM
END SUB

{*
** ============== Event Loop ==============
** MUIWaitEvent(app) blocks until an event occurs and returns its ID.
** Returns MUIV_Application_ReturnID_Quit (-1) when app should exit.
*}
DECLARE SUB LONGINT MUIWaitEvent(ADDRESS theApp) EXTERNAL

{*
** ============== String Gadgets ==============
** MUIString(initial, maxLen)   - Text input field
** MUIStringSecret(init, max)   - Password field (shows dots)
** MUIInteger(initial)          - Numeric input field
*}
DECLARE SUB ADDRESS MUIString(STRING initial, LONGINT maxLen) EXTERNAL
DECLARE SUB ADDRESS MUIStringSecret(STRING initial, LONGINT maxLen) EXTERNAL
DECLARE SUB ADDRESS MUIInteger(LONGINT initial) EXTERNAL

{*
** ============== Selection Gadgets ==============
** MUICheckmark(checked)        - Checkbox: -1=checked, 0=unchecked
** MUICycle(entries)            - Dropdown: entries = null-terminated array
** MUIRadio(entries)            - Radio buttons: same format as cycle
**
** For Cycle/Radio, entries must be null-terminated string pointer array:
**   DIM opts&(4)
**   opts&(0) = SADD("Option 1")
**   opts&(1) = SADD("Option 2")
**   opts&(2) = 0&                ' NULL terminator
**   cyc = MUICycle(VARPTR(opts&(0)))
*}
DECLARE SUB ADDRESS MUICheckmark(LONGINT checked) EXTERNAL
DECLARE SUB ADDRESS MUIKeyCheckmark(LONGINT checked, STRING key) EXTERNAL
DECLARE SUB ADDRESS MUICycle(ADDRESS entries) EXTERNAL
DECLARE SUB ADDRESS MUIRadio(ADDRESS entries) EXTERNAL
DECLARE SUB LONGINT MUIGetRadioActive(ADDRESS obj) EXTERNAL
DECLARE SUB MUISetRadioActive(ADDRESS obj, LONGINT idx) EXTERNAL

{*
** ============== Numeric Gadgets ==============
** MUISlider(min, max, initial) - Slider control
** MUIGauge(max)                - Progress bar (0 to max)
*}
DECLARE SUB ADDRESS MUISlider(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL
DECLARE SUB ADDRESS MUIGauge(LONGINT maxVal) EXTERNAL
DECLARE SUB MUISetGauge(ADDRESS obj, LONGINT gval) EXTERNAL

{*
** ============== Spacing & Separators ==============
** MUIRectangle - Invisible spacing element
** MUIHBar      - Horizontal separator line
** MUIVBar      - Vertical separator line
*}
DECLARE SUB ADDRESS MUIRectangle EXTERNAL
DECLARE SUB ADDRESS MUIHBar EXTERNAL
DECLARE SUB ADDRESS MUIVBar EXTERNAL

{ Misc object helpers }
DECLARE SUB ADDRESS MUIColorfield(LONGINT r, LONGINT g, LONGINT b) EXTERNAL
DECLARE SUB ADDRESS MUIImage(LONGINT imageSpec) EXTERNAL

{ Color object helpers }
DECLARE SUB ADDRESS MUIColoradjust EXTERNAL
DECLARE SUB ADDRESS MUIColoradjustRGB(LONGINT r, LONGINT g, LONGINT b) EXTERNAL
DECLARE SUB ADDRESS MUIPalette(LONGINT numColors) EXTERNAL
DECLARE SUB ADDRESS MUIPendisplay EXTERNAL
DECLARE SUB ADDRESS MUIPoppen EXTERNAL
DECLARE SUB MUISetColor(ADDRESS obj, LONGINT r, LONGINT g, LONGINT b) EXTERNAL
DECLARE SUB LONGINT MUIGetColorRed(ADDRESS obj) EXTERNAL
DECLARE SUB LONGINT MUIGetColorGreen(ADDRESS obj) EXTERNAL
DECLARE SUB LONGINT MUIGetColorBlue(ADDRESS obj) EXTERNAL
DECLARE SUB ADDRESS MUIScale EXTERNAL       ' Horizontal scale (default)
DECLARE SUB ADDRESS MUIScaleV EXTERNAL      ' Vertical scale

{ Label helpers }
DECLARE SUB ADDRESS MUILabel(STRING label) EXTERNAL
DECLARE SUB ADDRESS MUILabelRight(STRING label) EXTERNAL

{*
** ============== Attribute Access ==============
** Generic:
**   MUISet(obj, attr, value)    - Set any LONGINT attribute
**   MUISetStr(obj, attr, str)   - Set any STRING attribute
**   MUIGet(obj, attr)           - Get any LONGINT attribute
**
** Convenience (use these when possible):
**   MUISetText/MUIGetText       - Text object contents
**   MUISetStringContents/Get    - String gadget contents
**   MUISetValue/MUIGetValue     - Slider/Numeric value
**   MUISetChecked/MUIGetChecked - Checkmark state
**   MUIGetActive/MUISetActive   - Cycle/Radio selection
**   MUIGetInteger               - Integer gadget value
*}
DECLARE SUB MUISet(ADDRESS obj, LONGINT attr, LONGINT v) EXTERNAL
DECLARE SUB MUISetStr(ADDRESS obj, LONGINT attr, STRING s) EXTERNAL
DECLARE SUB LONGINT MUIGet(ADDRESS obj, LONGINT attr) EXTERNAL
DECLARE SUB MUISetText(ADDRESS obj, STRING txt) EXTERNAL
DECLARE SUB ADDRESS MUIGetText(ADDRESS obj) EXTERNAL
DECLARE SUB MUISetStringContents(ADDRESS obj, STRING txt) EXTERNAL
DECLARE SUB ADDRESS MUIGetStringContents(ADDRESS obj) EXTERNAL
DECLARE SUB MUISetValue(ADDRESS obj, LONGINT v) EXTERNAL
DECLARE SUB LONGINT MUIGetValue(ADDRESS obj) EXTERNAL
DECLARE SUB MUISetChecked(ADDRESS obj, LONGINT state) EXTERNAL
DECLARE SUB LONGINT MUIGetChecked(ADDRESS obj) EXTERNAL
DECLARE SUB LONGINT MUIGetActive(ADDRESS obj) EXTERNAL
DECLARE SUB MUISetActive(ADDRESS obj, LONGINT idx) EXTERNAL
DECLARE SUB LONGINT MUIGetInteger(ADDRESS obj) EXTERNAL

{*
** ============== List Objects ==============
** MUIList             - Create empty list (wrap in MUIListview for display)
** MUIListview(list)   - Scrollable list display
** MUIDirlist(dir)     - Directory listing
** MUIVolumelist       - Volume/drive listing
**
** List operations:
**   MUIListInsert(list, str)      - Add at end
**   MUIListInsertAt(list, str, n) - Add at position
**   MUIListRemove(list, n)        - Remove at position
**   MUIListClear(list)            - Remove all
**   MUIListCount(list)            - Get count
**   MUIListActive(list)           - Get selected index (-1 if none)
**   MUIListSetActive(list, n)     - Set selection
**   MUIListGetEntry(list, n)      - Get entry string pointer
*}
DECLARE SUB ADDRESS MUIList EXTERNAL
DECLARE SUB ADDRESS MUIListview(ADDRESS listObj) EXTERNAL
DECLARE SUB ADDRESS MUIDirlist(STRING directory) EXTERNAL
DECLARE SUB ADDRESS MUIVolumelist EXTERNAL

{ List operation functions }
DECLARE SUB MUIListInsert(ADDRESS listObj, STRING entry) EXTERNAL
DECLARE SUB MUIListInsertAt(ADDRESS listObj, STRING entry, LONGINT position) EXTERNAL
DECLARE SUB MUIListRemove(ADDRESS listObj, LONGINT position) EXTERNAL
DECLARE SUB MUIListClear(ADDRESS listObj) EXTERNAL
DECLARE SUB LONGINT MUIListCount(ADDRESS listObj) EXTERNAL
DECLARE SUB LONGINT MUIListActive(ADDRESS listObj) EXTERNAL
DECLARE SUB MUIListSetActive(ADDRESS listObj, LONGINT position) EXTERNAL
DECLARE SUB ADDRESS MUIListGetEntry(ADDRESS listObj, LONGINT position) EXTERNAL

{ ============== Menu Builder ============== }
{*
** Stack-based menu builder for MUI menus.
** Supports up to 10 menus in a menustrip, 20 items per menu.
**
** Usage:
**   MUIBeginMenustrip
**       MUIBeginMenu "File"
**           miNew = MUIMenuitem("New", "N")
**           miOpen = MUIMenuitem("Open...", "O")
**           MUIMenuSeparator
**           miQuit = MUIMenuitem("Quit", "Q")
**       MUIEndMenu
**       MUIBeginMenu "Edit"
**           miCut = MUIMenuitem("Cut", "X")
**           miCopy = MUIMenuitem("Copy", "C")
**           miPaste = MUIMenuitem("Paste", "V")
**       MUIEndMenu
**   menustrip = MUIEndMenustrip
**
**   ' Attach to window before opening
**   MUIWindowMenustrip win, menustrip
**
**   ' Set up notifications
**   MUINotifyMenu miQuit, app, MUI_ID_QUIT
*}
DECLARE SUB MUIBeginMenustrip EXTERNAL
DECLARE SUB MUIBeginMenu(STRING title) EXTERNAL
DECLARE SUB ADDRESS MUIMenuitem(STRING title, STRING shortcut) EXTERNAL
DECLARE SUB ADDRESS MUIMenuitemNoKey(STRING title) EXTERNAL
DECLARE SUB MUIMenuSeparator EXTERNAL
DECLARE SUB ADDRESS MUIMenuitemCheck(STRING title, STRING shortcut, LONGINT checked) EXTERNAL
DECLARE SUB ADDRESS MUIEndMenu EXTERNAL
DECLARE SUB ADDRESS MUIEndMenustrip EXTERNAL
DECLARE SUB MUIWindowMenustrip(ADDRESS win, ADDRESS menustrip) EXTERNAL
DECLARE SUB MUINotifyMenu(ADDRESS menuitem, ADDRESS theApp, LONGINT menuID) EXTERNAL
DECLARE SUB MUIMenuEnable(ADDRESS menuitem, LONGINT enabled) EXTERNAL
DECLARE SUB MUIMenuSetChecked(ADDRESS menuitem, LONGINT checked) EXTERNAL
DECLARE SUB LONGINT MUIMenuGetChecked(ADDRESS menuitem) EXTERNAL

{ ============== Popup Objects (Phase 11) ============== }
{*
** Popup objects combine a string gadget with a popup button.
** When the button is pressed, a popup window opens.
**
** Popasl: Uses system ASL requesters (file, font, screenmode)
** Poplist: Simple dropdown list from a string array
** Popobject: Custom popup with any MUI object
**
** Usage example (file requester):
**   popFile = MUIPopaslFile("Select a file", "#?.txt")
**   MUINotifyClose win, app, MUI_ID_QUIT
**   MUIWindowOpen win
**   ...
**   path$ = MUIPopstringValue(popFile)  ' Get selected path
**
** Usage example (poplist):
**   DIM items&(4)
**   items&(0) = SADD("Option 1")
**   items&(1) = SADD("Option 2")
**   items&(2) = SADD("Option 3")
**   items&(3) = 0&  ' NULL terminator
**   popList = MUIPoplist(VARPTR(items&(0)))
*}

{ ASL-based popups (file, font, screenmode requesters) }
DECLARE SUB ADDRESS MUIPopaslFile(STRING title, STRING patt) EXTERNAL
DECLARE SUB ADDRESS MUIPopaslDrawer(STRING title) EXTERNAL
DECLARE SUB ADDRESS MUIPopaslFont(STRING title) EXTERNAL
DECLARE SUB ADDRESS MUIPopaslFontFixed(STRING title) EXTERNAL
DECLARE SUB ADDRESS MUIPopaslScreen(STRING title) EXTERNAL

{ List-based popup (simple dropdown from string array) }
DECLARE SUB ADDRESS MUIPoplist(ADDRESS entries) EXTERNAL

{ Custom popup with any MUI object }
DECLARE SUB ADDRESS MUIPopobject(ADDRESS popupObj) EXTERNAL
DECLARE SUB ADDRESS MUIPopobjectHooked(ADDRESS popupObj, ADDRESS strObjHook, ADDRESS objStrHook) EXTERNAL

{ Popup value access }
DECLARE SUB ADDRESS MUIPopstringObj(ADDRESS popup) EXTERNAL
DECLARE SUB ADDRESS MUIPopstringValue(ADDRESS popup) EXTERNAL
DECLARE SUB MUIPopstringSetValue(ADDRESS popup, STRING value) EXTERNAL

{ Popup state and control }
DECLARE SUB LONGINT MUIPopaslActive(ADDRESS popup) EXTERNAL
DECLARE SUB MUIPopstringClose(ADDRESS popup, LONGINT success) EXTERNAL
DECLARE SUB MUIPopstringOpen(ADDRESS popup) EXTERNAL

{ ============== Register (Tabbed Pages) - Phase 12 ============== }
{*
** Register creates a tabbed interface. Each page is a group.
**
** Builder pattern:
**   MUIBeginRegister "General|Advanced|Options"
**       MUIRegisterPage generalPage
**       MUIRegisterPage advancedPage
**       MUIRegisterPage optionsPage
**   reg = MUIEndRegister
**
** Quick helper (2-3 pages):
**   reg = MUIRegister2("Page 1|Page 2", page1, page2)
**   reg = MUIRegister3("Tab A|Tab B|Tab C", pageA, pageB, pageC)
*}
DECLARE SUB MUIBeginRegister(STRING titles) EXTERNAL
DECLARE SUB MUIRegisterPage(ADDRESS pageGroup) EXTERNAL
DECLARE SUB ADDRESS MUIEndRegister EXTERNAL
DECLARE SUB ADDRESS MUIRegister2(STRING titles, ADDRESS page1, ADDRESS page2) EXTERNAL
DECLARE SUB ADDRESS MUIRegister3(STRING titles, ADDRESS page1, ADDRESS page2, ADDRESS page3) EXTERNAL
DECLARE SUB LONGINT MUIRegisterActive(ADDRESS reg) EXTERNAL
DECLARE SUB MUIRegisterSetActive(ADDRESS reg, LONGINT page) EXTERNAL

{ ============== Scrollgroup & Virtgroup - Phase 12 ============== }
{*
** Scrollgroup provides scrollable content.
** Virtgroup creates virtual content larger than visible area.
**
** Usage:
**   ' Create content group
**   MUIBeginVGroup
**       MUIChild MUIText("Line 1")
**       MUIChild MUIText("Line 2")
**       ... many children ...
**   content = MUIEndGroup
**
**   ' Wrap in virtgroup and scrollgroup
**   virt = MUIVirtgroup(content)
**   scroll = MUIScrollgroup(virt)
*}
DECLARE SUB ADDRESS MUIVirtgroup(ADDRESS contents) EXTERNAL
DECLARE SUB ADDRESS MUIVirtgroupH(ADDRESS contents) EXTERNAL
DECLARE SUB ADDRESS MUIScrollgroup(ADDRESS virtgroup) EXTERNAL
DECLARE SUB ADDRESS MUIScrollgroupHoriz(ADDRESS virtgroup) EXTERNAL
DECLARE SUB ADDRESS MUIScrollgroupVert(ADDRESS virtgroup) EXTERNAL

{ ============== Balance (Resizable Divider) - Phase 12 ============== }
{*
** Balance creates a resizable divider between groups.
** Use in HGroup for horizontal resizing, VGroup for vertical.
**
** Usage:
**   MUIBeginHGroup
**       MUIChild leftPanel
**       MUIChild MUIBalance      ' Drag to resize
**       MUIChild rightPanel
**   grp = MUIEndGroup
*}
DECLARE SUB ADDRESS MUIBalance EXTERNAL
DECLARE SUB ADDRESS MUIBalanceQuiet EXTERNAL

{ ============== Numericbutton - Phase 13 ============== }
{*
** Numericbutton creates a numeric input with +/- buttons.
** User can click buttons or type a value directly.
** Value is constrained to min/max range.
**
** Usage:
**   nb = MUINumericbutton(0, 100, 50)  ' min=0, max=100, initial=50
**   val = MUINumericbuttonValue(nb)    ' Get current value
**   MUINumericbuttonSetValue nb, 75    ' Set new value
**
** With custom format:
**   nb = MUINumericbuttonFormat(0, 255, 128, "%ld%%")  ' Shows "128%"
*}
CONST MUIA_Numeric_Min            = &H8042e404
CONST MUIA_Numeric_Max            = &H8042d78a
CONST MUIA_Numeric_Default        = &H804263e8
CONST MUIA_Numeric_Format         = &H804263e9

DECLARE SUB ADDRESS MUINumericbutton(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL
DECLARE SUB ADDRESS MUINumericbuttonFormat(LONGINT minVal, LONGINT maxVal, LONGINT initial, STRING fmt) EXTERNAL
DECLARE SUB LONGINT MUINumericbuttonValue(ADDRESS obj) EXTERNAL
DECLARE SUB MUINumericbuttonSetValue(ADDRESS obj, LONGINT value) EXTERNAL

{ ============== Dtpic (Image Display) - Phase 13 ============== }
{*
** Dtpic displays an image file using the datatypes system.
** Supports any image format with an installed datatype (IFF, PNG, JPEG, etc).
**
** Usage:
**   pic = MUIDtpic("PROGDIR:images/logo.png")
**   MUIDtpicSetName pic, "PROGDIR:images/other.png"  ' Change image
**
** With alpha support:
**   pic = MUIDtpicAlpha("PROGDIR:images/icon.png", 200)  ' 0-255 alpha
*}
CONST MUIA_Dtpic_Name             = &H80423d72
CONST MUIA_Dtpic_Alpha            = &H8042b4db

DECLARE SUB ADDRESS MUIDtpic(STRING filename) EXTERNAL
DECLARE SUB ADDRESS MUIDtpicAlpha(STRING filename, LONGINT alpha) EXTERNAL
DECLARE SUB MUIDtpicSetName(ADDRESS obj, STRING filename) EXTERNAL

{ ============== Knob & Levelmeter - Phase 13 ============== }
{*
** Additional numeric input controls.
**
** Knob: A rotary dial control.
** Levelmeter: A visual level meter with numeric display.
**
** Both use the same API as Numericbutton for value access:
**   MUINumericbuttonValue(), MUINumericbuttonSetValue()
**
** Usage:
**   knob = MUIKnob(0, 100, 50)
**   meter = MUILevelmeter(-20, 6, 0)  ' dB scale
*}
DECLARE SUB ADDRESS MUIKnob(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL
DECLARE SUB ADDRESS MUILevelmeter(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL

#endif
