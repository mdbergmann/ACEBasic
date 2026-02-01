{*
** MUI.b - MUI Submod Implementation for ACE Basic
** Part of the MUI submod for ACE Basic
**
** Copyright (c) 2026 Manfred Bergmann. All rights reserved.
**
** This module provides MUI functionality. It handles library management
** and provides wrapper functions for MUI operations.
**
** Usage: Include submods/MUI.h in your program, then link with MUI.o
*}

{ ============== Library Function Declarations ============== }

DECLARE FUNCTION ADDRESS MUI_NewObjectA(ADDRESS classname, ADDRESS taglist) LIBRARY muimaster
DECLARE FUNCTION ADDRESS MUI_MakeObjectA(LONGINT objtype, ADDRESS params) LIBRARY muimaster
DECLARE FUNCTION MUI_DisposeObject(ADDRESS obj) LIBRARY muimaster
DECLARE FUNCTION LONGINT SetAttrsA(ADDRESS obj, ADDRESS taglist) LIBRARY intuition
DECLARE FUNCTION GetAttr&(LONGINT attrID, ADDRESS obj, ADDRESS storagePtr) LIBRARY intuition
DECLARE FUNCTION LONGINT _Wait(LONGINT signalset) LIBRARY exec
DECLARE FUNCTION ADDRESS OpenLibrary(ADDRESS libName, LONGINT libVer) LIBRARY exec
DECLARE FUNCTION CloseLibrary(ADDRESS libBase) LIBRARY exec

{*
** DoMethodA - NOT in intuition.library!
** DoMethodA is from amiga.lib (static linker library), not a shared library.
** We implement it using CallHookPkt from utility.library.
*}
DECLARE FUNCTION LONGINT CallHookPkt(ADDRESS hook, ADDRESS obj, ADDRESS msg) LIBRARY utility

SUB LONGINT DoMethodA(ADDRESS obj, ADDRESS msg) EXTERNAL
    LONGINT classAddr
    classAddr = PEEKL(obj - 4)
    DoMethodA = CallHookPkt(classAddr, obj, msg)
END SUB

{ ============== Constants ============== }
{*
** NOTE: These constants are duplicated from MUI.h by necessity.
** MUI.b is compiled separately as a module and doesn't include MUI.h.
** Each compilation unit needs its own constant definitions.
** When adding new constants, update BOTH MUI.h and MUI.b.
*}

CONST TAG_DONE = 0&

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

{ Button constants }
CONST MUIA_InputMode               = &H8042fb04
CONST MUIV_InputMode_RelVerify     = 1
CONST MUIA_Background              = &H8042545b
CONST MUII_ButtonBack              = 131
CONST MUIV_Frame_Button            = 1
CONST MUIA_Pressed                 = &H80423535
CONST MUIO_Button                  = 2
CONST MUIO_Checkmark               = 9
CONST MUIA_ControlChar             = &H8042120b
CONST MUIA_Text_HiChar             = &H804218ff

{ Size constants }
CONST MUIA_FixWidth                = &H8042a3f1
CONST MUIA_FixHeight               = &H8042a985

{ Image constants }
CONST MUIA_Image_Spec              = &H804233d5
CONST MUIV_Frame_ImageButton       = 2

{ Colorfield constants }
CONST MUIA_Colorfield_Red          = &H804279f6
CONST MUIA_Colorfield_Green        = &H80424466
CONST MUIA_Colorfield_Blue         = &H8042d3b0

{ Coloradjust constants }
CONST MUIA_Coloradjust_Red         = &H80420eaa
CONST MUIA_Coloradjust_Green       = &H804285ab
CONST MUIA_Coloradjust_Blue        = &H8042b8a3
CONST MUIA_Coloradjust_RGB         = &H8042f899
CONST MUIA_Coloradjust_ModeID      = &H8042ec59

{ Palette constants }
CONST MUIA_Palette_Entries         = &H8042a3d8
CONST MUIA_Palette_Groupable       = &H80423e67
CONST MUIA_Palette_Names           = &H8042c3a2

{ Pendisplay constants }
CONST MUIA_Pendisplay_Pen          = &H8042a748
CONST MUIA_Pendisplay_RGBcolor     = &H8042a1a9
CONST MUIA_Pendisplay_Spec         = &H8042a204
CONST MUIA_Pendisplay_Reference    = &H8042dc24

{ Poppen constants }

{ Popstring/Popobject/Popasl/Poplist constants }
CONST MUIA_Popstring_Button     = &H8042d0b9
CONST MUIA_Popstring_String     = &H804239ea
CONST MUIA_Popstring_Toggle     = &H80422b7a
CONST MUIA_Popobject_Object     = &H804293e3
CONST MUIA_Popobject_ObjStrHook = &H8042db44
CONST MUIA_Popobject_StrObjHook = &H8042fbe1
CONST MUIA_Popobject_WindowHook = &H8042f194
CONST MUIA_Popobject_Light      = &H8042a5a3
CONST MUIA_Popobject_Follow     = &H80424cb5
CONST MUIA_Popobject_Volatile   = &H804252ec
CONST MUIA_Poplist_Array        = &H8042084c
CONST MUIA_Popasl_Active        = &H80421b37
CONST MUIA_Popasl_Type          = &H8042df3d
CONST MUIA_Popasl_StartHook     = &H8042b703
CONST MUIA_Popasl_StopHook      = &H8042d8d2

{ ASL requester types for Popasl }
CONST ASL_FileRequest           = 0
CONST ASL_FontRequest           = 1
CONST ASL_ScreenModeRequest     = 2

{ Popup button image types }
CONST MUII_PopUp                = 18
CONST MUII_PopFile              = 19
CONST MUII_PopDrawer            = 20

{ MUI_MakeObject type for popup buttons }
CONST MUIO_PopButton            = 8

{ Popstring methods }
CONST MUIM_Popstring_Close      = &H8042dc52
CONST MUIM_Popstring_Open       = &H804258ba

{ ASLFO_* and ASLFR_* tags for font/file requesters }
CONST ASLFR_TitleText           = &H80080001
CONST ASLFR_DrawersOnly         = &H8008000A
CONST ASLFR_InitialFile         = &H80080008
CONST ASLFR_InitialDrawer       = &H80080004
CONST ASLFR_InitialPattern      = &H8008000C
CONST ASLFO_TitleText           = &H80080001
CONST ASLFO_FixedWidthOnly      = &H8008000C
CONST ASLSM_TitleText           = &H80080001

{ Scale constants }
CONST MUIA_Scale_Horiz             = &H8042919a

{ MUI Methods }
CONST MUIM_Notify                     = &H8042c9cb
CONST MUIM_Application_ReturnID       = &H804276ef
CONST MUIM_Application_NewInput       = &H80423ba6
CONST MUIM_Application_Input          = &H8042d0f5
CONST MUIM_CallHook                   = &H8042b96b
CONST MUIV_Application_ReturnID_Quit  = -1
CONST MUIV_EveryTime                  = &H49893131

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

{ Label constants }
CONST MUIA_Weight                  = &H80421d1f

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

{ Error codes }
CONST MUIERR_NONE           = 0
CONST MUIERR_NOLIBRARY      = 1
CONST MUIERR_CREATEFAILED   = 2
CONST MUIERR_GROUPOVERFLOW  = 3
CONST MUIERR_INVALIDPARAM   = 4

{ ============== Module State ============== }
{*
** Module arrays for MUI operations.
** Note: The 2+ DIM array bug in EXTERNAL modules has been fixed.
*}

{ Tag array for building MUI tag lists }
DIM _tags&(100)
SHORTINT _tagIndex

{ String pool for persistent strings (MUI needs them to stay valid) }
{ String copying now uses ALLOC - no pool needed }

{ Group builder state }
CONST _MUI_MAX_LEVELS = 10
CONST _MUI_MAX_CHILDREN = 10
DIM _children&(99)          { 10 levels x 10 children }
DIM _childCounts%(9)        { Child count per level }
DIM _groupFlags%(9)         { Horiz flag per level (0=vert, -1=horiz) }
DIM _groupCols%(9)          { Columns count per level (0=not a col group) }
DIM _groupSameSize%(9)      { SameSize flag per level (0=off, -1=on) }
DIM _groupSameWidth%(9)     { SameWidth flag per level (0=off, -1=on) }
DIM _groupSameHeight%(9)    { SameHeight flag per level (0=off, -1=on) }
DIM _groupFrameTitles&(9)   { Frame title address per level (0=none) }
DIM _groupSpacing%(9)       { Spacing override per level (-1=default) }
SHORTINT _groupLevel        { Current nesting level (1-based when active) }

{ Menu builder state }
CONST _MENU_MAX_MENUS = 10
CONST _MENU_MAX_ITEMS = 20
DIM _menuItems&(199)          { 10 menus x 20 items }
DIM _menuItemCounts%(9)       { Item count per menu }
DIM _menuTitles&(9)           { Menu title addresses }
SHORTINT _menuLevel           { 0 = in menustrip, 1+ = in menu }
DIM _menus&(9)                { Built menu objects for menustrip }
SHORTINT _menuCount           { Number of menus in menustrip }

{ Register builder state }
CONST _REG_MAX_PAGES = 10
CONST _REG_MAX_TITLES = 11         { 10 titles + NULL terminator }
DIM _regPages&(9)                  { Page objects (groups) }
DIM _regTitles&(10)                { Title string addresses + NULL }
SHORTINT _regPageCount             { Number of pages added }
SHORTINT _regBuilding              { -1 if currently building a register }

{ Module variables for event loop - used via SHARED }
DIM _evtMsg&(10)
LONGINT _evtSigs

{ Error state }
LONGINT _lastError
LONGINT _muiVersion
DIM _errStr&(20)            { Error message buffer (80 bytes) }

{ _CopyStr - Copy string to persistent pool, return address }
SUB ADDRESS _CopyStr(STRING s)
    ADDRESS dest
    SHORTINT i, slen

    slen = LEN(s)
    dest = ALLOC(slen + 1)

    IF dest <> 0& THEN
        { Copy string bytes }
        FOR i = 1 TO slen
            POKE dest + i - 1, ASC(MID$(s, i, 1))
        NEXT i
        POKE dest + slen, 0   { Null terminator }
    END IF

    _CopyStr = dest
END SUB

{ ============== Tag Builder ============== }
{*
** Tag builder functions for constructing MUI tag arrays.
** Usage:
**   MUITagStart
**   MUITag MUIA_Something, value
**   MUITag MUIA_Another, value2
**   MUITagEnd
**   obj = MUINewObj(SADD("ClassName.mui"))
*}

SUB MUITagStart EXTERNAL
    SHARED _tags&, _tagIndex
    _tagIndex = 0
END SUB

SUB MUITag(LONGINT tagId, LONGINT tagVal) EXTERNAL
    SHARED _tags&, _tagIndex
    _tags&(_tagIndex) = tagId
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = tagVal
    _tagIndex = _tagIndex + 1
END SUB

SUB MUITagEnd EXTERNAL
    SHARED _tags&, _tagIndex
    _tags&(_tagIndex) = TAG_DONE
END SUB

SUB ADDRESS MUINewObj(ADDRESS className) EXTERNAL
    SHARED _tags&
    MUINewObj = MUI_NewObjectA(className, VARPTR(_tags&(0)))
END SUB

{ ============== Group Builder ============== }
{*
** Stack-based group builder for nested MUI groups.
** Usage:
**   MUIBeginVGroup
**     MUIChild MUIText("Hello")
**     MUIChild MUIButton("OK")
**   grp = MUIEndGroup
*}

SUB MUIBeginVGroup EXTERNAL
    SHARED _groupLevel, _childCounts%, _groupFlags%
    SHARED _groupCols%, _groupSameSize%, _groupSameWidth%, _groupSameHeight%
    SHARED _groupFrameTitles&, _groupSpacing%
    SHORTINT lvl
    _groupLevel = _groupLevel + 1
    lvl = _groupLevel - 1
    _childCounts%(lvl) = 0
    _groupFlags%(lvl) = 0
    _groupCols%(lvl) = 0
    _groupSameSize%(lvl) = 0
    _groupSameWidth%(lvl) = 0
    _groupSameHeight%(lvl) = 0
    _groupFrameTitles&(lvl) = 0&
    _groupSpacing%(lvl) = -1
END SUB

SUB MUIBeginHGroup EXTERNAL
    SHARED _groupLevel, _childCounts%, _groupFlags%
    SHARED _groupCols%, _groupSameSize%, _groupSameWidth%, _groupSameHeight%
    SHARED _groupFrameTitles&, _groupSpacing%
    SHORTINT lvl
    _groupLevel = _groupLevel + 1
    lvl = _groupLevel - 1
    _childCounts%(lvl) = 0
    _groupFlags%(lvl) = -1
    _groupCols%(lvl) = 0
    _groupSameSize%(lvl) = 0
    _groupSameWidth%(lvl) = 0
    _groupSameHeight%(lvl) = 0
    _groupFrameTitles&(lvl) = 0&
    _groupSpacing%(lvl) = -1
END SUB

SUB MUIBeginColGroup(SHORTINT cols) EXTERNAL
    SHARED _groupLevel, _childCounts%, _groupFlags%
    SHARED _groupCols%, _groupSameSize%, _groupSameWidth%, _groupSameHeight%
    SHARED _groupFrameTitles&, _groupSpacing%
    SHORTINT lvl
    _groupLevel = _groupLevel + 1
    lvl = _groupLevel - 1
    _childCounts%(lvl) = 0
    _groupFlags%(lvl) = 0
    _groupCols%(lvl) = cols
    _groupSameSize%(lvl) = 0
    _groupSameWidth%(lvl) = 0
    _groupSameHeight%(lvl) = 0
    _groupFrameTitles&(lvl) = 0&
    _groupSpacing%(lvl) = -1
END SUB

SUB MUIBeginRowGroup(SHORTINT rows) EXTERNAL
    SHARED _groupLevel, _childCounts%, _groupFlags%
    SHARED _groupCols%, _groupSameSize%, _groupSameWidth%, _groupSameHeight%
    SHARED _groupFrameTitles&, _groupSpacing%
    SHORTINT lvl
    _groupLevel = _groupLevel + 1
    lvl = _groupLevel - 1
    _childCounts%(lvl) = 0
    _groupFlags%(lvl) = 0
    { For row groups, we store rows as negative to distinguish from columns }
    _groupCols%(lvl) = -rows
    _groupSameSize%(lvl) = 0
    _groupSameWidth%(lvl) = 0
    _groupSameHeight%(lvl) = 0
    _groupFrameTitles&(lvl) = 0&
    _groupSpacing%(lvl) = -1
END SUB

{ MUIGroupFrameT - Add titled frame to current group }
SUB MUIGroupFrameT(STRING title) EXTERNAL
    SHARED _groupLevel, _groupFrameTitles&
    IF _groupLevel > 0 THEN
        _groupFrameTitles&(_groupLevel - 1) = _CopyStr(title)
    END IF
END SUB

{ MUIGroupFrame - Add untitled frame to current group }
SUB MUIGroupFrame EXTERNAL
    SHARED _groupLevel, _groupFrameTitles&
    IF _groupLevel > 0 THEN
        { Empty string signals we want a frame but no title }
        _groupFrameTitles&(_groupLevel - 1) = SADD("")
    END IF
END SUB

{ MUIGroupSameSize - Make all children same size }
SUB MUIGroupSameSize EXTERNAL
    SHARED _groupLevel, _groupSameSize%
    IF _groupLevel > 0 THEN
        _groupSameSize%(_groupLevel - 1) = -1
    END IF
END SUB

{ MUIGroupSameWidth - Make all children same width }
SUB MUIGroupSameWidth EXTERNAL
    SHARED _groupLevel, _groupSameWidth%
    IF _groupLevel > 0 THEN
        _groupSameWidth%(_groupLevel - 1) = -1
    END IF
END SUB

{ MUIGroupSameHeight - Make all children same height }
SUB MUIGroupSameHeight EXTERNAL
    SHARED _groupLevel, _groupSameHeight%
    IF _groupLevel > 0 THEN
        _groupSameHeight%(_groupLevel - 1) = -1
    END IF
END SUB

{ MUIGroupSpacing - Set spacing between children }
SUB MUIGroupSpacing(SHORTINT space) EXTERNAL
    SHARED _groupLevel, _groupSpacing%
    IF _groupLevel > 0 THEN
        _groupSpacing%(_groupLevel - 1) = space
    END IF
END SUB

SUB MUIChild(ADDRESS child) EXTERNAL
    SHARED _children&, _childCounts%, _groupLevel
    SHORTINT lvl, idx, offs
    lvl = _groupLevel - 1
    idx = _childCounts%(lvl)
    offs = lvl * _MUI_MAX_CHILDREN
    _children&(offs + idx) = child
    _childCounts%(lvl) = idx + 1
END SUB

{ MUIChildWeight - Add child with layout weight }
SUB MUIChildWeight(ADDRESS child, SHORTINT weight) EXTERNAL
    SHARED _children&, _childCounts%, _groupLevel, _tags&, _tagIndex
    SHORTINT lvl, idx, offs

    { Set weight attribute on the child }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Weight
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = weight
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    CALL SetAttrsA(child, VARPTR(_tags&(0)))

    { Add to children list }
    lvl = _groupLevel - 1
    idx = _childCounts%(lvl)
    offs = lvl * _MUI_MAX_CHILDREN
    _children&(offs + idx) = child
    _childCounts%(lvl) = idx + 1
END SUB

SUB ADDRESS MUIEndGroup EXTERNAL
    SHARED _tags&, _tagIndex, _children&
    SHARED _childCounts%, _groupFlags%, _groupLevel
    SHARED _groupCols%, _groupSameSize%, _groupSameWidth%, _groupSameHeight%
    SHARED _groupFrameTitles&, _groupSpacing%
    SHORTINT i, cnt, offs, lvl, isHoriz, cols, sameSize, sameWidth, sameHeight, spacing
    ADDRESS frameTitle

    lvl = _groupLevel - 1
    cnt = _childCounts%(lvl)
    offs = lvl * _MUI_MAX_CHILDREN
    isHoriz = _groupFlags%(lvl)
    cols = _groupCols%(lvl)
    sameSize = _groupSameSize%(lvl)
    sameWidth = _groupSameWidth%(lvl)
    sameHeight = _groupSameHeight%(lvl)
    frameTitle = _groupFrameTitles&(lvl)
    spacing = _groupSpacing%(lvl)

    _tagIndex = 0

    { Horizontal flag - use Columns=childcount as workaround for Horiz not working }
    IF isHoriz THEN
        _tags&(_tagIndex) = MUIA_Group_Columns
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = cnt
        _tagIndex = _tagIndex + 1
    END IF

    { Columns (positive) or Rows (stored as negative) }
    IF cols > 0 THEN
        _tags&(_tagIndex) = MUIA_Group_Columns
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = cols
        _tagIndex = _tagIndex + 1
    END IF
    IF cols < 0 THEN
        _tags&(_tagIndex) = MUIA_Group_Rows
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = -cols
        _tagIndex = _tagIndex + 1
    END IF

    { Frame with optional title }
    IF frameTitle <> 0& THEN
        _tags&(_tagIndex) = MUIA_Frame
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = MUIV_Frame_Group
        _tagIndex = _tagIndex + 1
        IF PEEK(frameTitle) <> 0 THEN
            { Non-empty title string }
            _tags&(_tagIndex) = MUIA_FrameTitle
            _tagIndex = _tagIndex + 1
            _tags&(_tagIndex) = frameTitle
            _tagIndex = _tagIndex + 1
        END IF
    END IF

    { Same size }
    IF sameSize THEN
        _tags&(_tagIndex) = MUIA_Group_SameSize
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = 1&
        _tagIndex = _tagIndex + 1
    END IF

    { Same width }
    IF sameWidth THEN
        _tags&(_tagIndex) = MUIA_Group_SameWidth
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = 1&
        _tagIndex = _tagIndex + 1
    END IF

    { Same height }
    IF sameHeight THEN
        _tags&(_tagIndex) = MUIA_Group_SameHeight
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = 1&
        _tagIndex = _tagIndex + 1
    END IF

    { Spacing }
    IF spacing >= 0 THEN
        _tags&(_tagIndex) = MUIA_Group_Spacing
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = spacing
        _tagIndex = _tagIndex + 1
    END IF

    { Children }
    FOR i = 0 TO cnt - 1
        _tags&(_tagIndex) = MUIA_Group_Child
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _children&(offs + i)
        _tagIndex = _tagIndex + 1
    NEXT i

    _tags&(_tagIndex) = TAG_DONE

    { Pop the level }
    _groupLevel = _groupLevel - 1

    MUIEndGroup = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Library Management ============== }

SUB MUIInit EXTERNAL
    SHARED _tagIndex, _evtMsg&, _evtSigs, _groupLevel
    SHARED _groupCols%, _groupSameSize%, _groupSameWidth%, _groupSameHeight%
    SHARED _groupFrameTitles&, _groupSpacing%
    SHARED _menuLevel, _menuCount, _menuItemCounts%, _menuTitles&
    SHARED _lastError, _muiVersion
    SHORTINT i
    ADDRESS muiBase

    { Initialize module state }
    _tagIndex = 0
    _evtSigs = 0&
    _groupLevel = 0
    _menuLevel = 0
    _menuCount = 0
    _lastError = MUIERR_NONE
    _muiVersion = 0&

    { Initialize group builder arrays }
    FOR i = 0 TO 9
        _groupCols%(i) = 0
        _groupSameSize%(i) = 0
        _groupSameWidth%(i) = 0
        _groupSameHeight%(i) = 0
        _groupFrameTitles&(i) = 0&
        _groupSpacing%(i) = -1
        _menuItemCounts%(i) = 0
        _menuTitles&(i) = 0&
    NEXT i

    {*
    ** Open required libraries.
    ** exec.library - need to open explicitly for module to have _ExecBase
    ** intuition.library - needed for SetAttrsA, GetAttr
    ** muimaster.library - MUI object creation/disposal
    ** utility.library - needed for CallHookPkt (DoMethodA)
    *}
    LIBRARY "exec.library"
    LIBRARY "intuition.library"
    LIBRARY "utility.library"

    { Open muimaster and capture version }
    muiBase = OpenLibrary(SADD("muimaster.library"), 19&)
    IF muiBase = 0& THEN
        _lastError = MUIERR_NOLIBRARY
    ELSE
        { Read lib_Version at offset 20 (WORD) }
        _muiVersion = PEEKW(muiBase + 20)
        { Close it - LIBRARY statement will reopen }
        CloseLibrary(muiBase)
    END IF

    LIBRARY "muimaster.library"
END SUB

SUB MUICleanup EXTERNAL
    { Close all libraries opened by MUIInit }
    LIBRARY CLOSE "utility.library"
    LIBRARY CLOSE "muimaster.library"
    LIBRARY CLOSE "intuition.library"
    LIBRARY CLOSE "exec.library"
END SUB

{ ============== Error Handling ============== }

SUB LONGINT MUIVersion EXTERNAL
    SHARED _muiVersion
    MUIVersion = _muiVersion
END SUB

SUB LONGINT MUILastError EXTERNAL
    SHARED _lastError
    MUILastError = _lastError
END SUB

SUB ADDRESS MUIErrorStr EXTERNAL
    SHARED _lastError, _errStr&
    ADDRESS dest

    dest = VARPTR(_errStr&(0))

    IF _lastError = MUIERR_NONE THEN
        { "No error" }
        POKE dest, 78
        POKE dest+1, 111
        POKE dest+2, 32
        POKE dest+3, 101
        POKE dest+4, 114
        POKE dest+5, 114
        POKE dest+6, 111
        POKE dest+7, 114
        POKE dest+8, 0
    END IF
    IF _lastError = MUIERR_NOLIBRARY THEN
        { "Could not open muimaster.library" }
        POKE dest, 67
        POKE dest+1, 111
        POKE dest+2, 117
        POKE dest+3, 108
        POKE dest+4, 100
        POKE dest+5, 32
        POKE dest+6, 110
        POKE dest+7, 111
        POKE dest+8, 116
        POKE dest+9, 32
        POKE dest+10, 111
        POKE dest+11, 112
        POKE dest+12, 101
        POKE dest+13, 110
        POKE dest+14, 32
        POKE dest+15, 109
        POKE dest+16, 117
        POKE dest+17, 105
        POKE dest+18, 109
        POKE dest+19, 97
        POKE dest+20, 115
        POKE dest+21, 116
        POKE dest+22, 101
        POKE dest+23, 114
        POKE dest+24, 46
        POKE dest+25, 108
        POKE dest+26, 105
        POKE dest+27, 98
        POKE dest+28, 114
        POKE dest+29, 97
        POKE dest+30, 114
        POKE dest+31, 121
        POKE dest+32, 0
    END IF
    IF _lastError = MUIERR_CREATEFAILED THEN
        { "Object creation failed" }
        POKE dest, 79
        POKE dest+1, 98
        POKE dest+2, 106
        POKE dest+3, 101
        POKE dest+4, 99
        POKE dest+5, 116
        POKE dest+6, 32
        POKE dest+7, 99
        POKE dest+8, 114
        POKE dest+9, 101
        POKE dest+10, 97
        POKE dest+11, 116
        POKE dest+12, 105
        POKE dest+13, 111
        POKE dest+14, 110
        POKE dest+15, 32
        POKE dest+16, 102
        POKE dest+17, 97
        POKE dest+18, 105
        POKE dest+19, 108
        POKE dest+20, 101
        POKE dest+21, 100
        POKE dest+22, 0
    END IF
    IF _lastError = MUIERR_GROUPOVERFLOW THEN
        { "Group nesting overflow" }
        POKE dest, 71
        POKE dest+1, 114
        POKE dest+2, 111
        POKE dest+3, 117
        POKE dest+4, 112
        POKE dest+5, 32
        POKE dest+6, 110
        POKE dest+7, 101
        POKE dest+8, 115
        POKE dest+9, 116
        POKE dest+10, 105
        POKE dest+11, 110
        POKE dest+12, 103
        POKE dest+13, 32
        POKE dest+14, 111
        POKE dest+15, 118
        POKE dest+16, 101
        POKE dest+17, 114
        POKE dest+18, 102
        POKE dest+19, 108
        POKE dest+20, 111
        POKE dest+21, 119
        POKE dest+22, 0
    END IF
    IF _lastError = MUIERR_INVALIDPARAM THEN
        { "Invalid parameter" }
        POKE dest, 73
        POKE dest+1, 110
        POKE dest+2, 118
        POKE dest+3, 97
        POKE dest+4, 108
        POKE dest+5, 105
        POKE dest+6, 100
        POKE dest+7, 32
        POKE dest+8, 112
        POKE dest+9, 97
        POKE dest+10, 114
        POKE dest+11, 97
        POKE dest+12, 109
        POKE dest+13, 101
        POKE dest+14, 116
        POKE dest+15, 101
        POKE dest+16, 114
        POKE dest+17, 0
    END IF
    IF _lastError < 0 OR _lastError > 4 THEN
        { "Unknown error" }
        POKE dest, 85
        POKE dest+1, 110
        POKE dest+2, 107
        POKE dest+3, 110
        POKE dest+4, 111
        POKE dest+5, 119
        POKE dest+6, 110
        POKE dest+7, 32
        POKE dest+8, 101
        POKE dest+9, 114
        POKE dest+10, 114
        POKE dest+11, 111
        POKE dest+12, 114
        POKE dest+13, 0
    END IF

    MUIErrorStr = dest
END SUB

{ ============== Object Disposal ============== }

SUB MUIDispose(ADDRESS obj) EXTERNAL
    IF obj <> 0& THEN
        MUI_DisposeObject(obj)
    END IF
END SUB

{ ============== Low-level Object Creation ============== }

SUB ADDRESS _MUINewObj(ADDRESS className, ADDRESS tagList) EXTERNAL
    _MUINewObj = MUI_NewObjectA(className, tagList)
END SUB

{ ============== Text Object Helpers ============== }

{ Private helper - creates text with optional alignment and frame }
SUB ADDRESS _MUITextCreate(STRING contents, SHORTINT align, SHORTINT framed)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { Add alignment preparse if needed: 1=center, 2=right }
    IF align = 1 THEN
        _tags&(_tagIndex) = MUIA_Text_PreParse
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(CHR$(27) + "c")
        _tagIndex = _tagIndex + 1
    END IF
    IF align = 2 THEN
        _tags&(_tagIndex) = MUIA_Text_PreParse
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(CHR$(27) + "r")
        _tagIndex = _tagIndex + 1
    END IF

    { Add frame if requested }
    IF framed THEN
        _tags&(_tagIndex) = MUIA_Frame
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = MUIV_Frame_Group
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = MUIA_Text_Contents
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(contents)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    _MUITextCreate = MUI_NewObjectA(SADD("Text.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIText(STRING contents) EXTERNAL
    MUIText = _MUITextCreate(contents, 0, 0)
END SUB

SUB ADDRESS MUITextCentered(STRING contents) EXTERNAL
    MUITextCentered = _MUITextCreate(contents, 1, 0)
END SUB

SUB ADDRESS MUITextFramed(STRING contents) EXTERNAL
    MUITextFramed = _MUITextCreate(contents, 0, -1)
END SUB

{ ============== Button Helpers ============== }

SUB ADDRESS MUIButton(STRING label) EXTERNAL
    SHARED _tags&

    { Use MUI_MakeObjectA like the main program does }
    _tags&(0) = _CopyStr(label)

    MUIButton = MUI_MakeObjectA(MUIO_Button, VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIKeyButton(STRING label, STRING key) EXTERNAL
    SHARED _tags&

    { MUIO_Button automatically parses underscores in the label }
    { e.g., "_Save" becomes "Save" with 'S' underlined and as hotkey }
    { The key parameter is ignored - underscore in label defines the key }
    _tags&(0) = _CopyStr(label)

    MUIKeyButton = MUI_MakeObjectA(MUIO_Button, VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIImageButton(LONGINT imageSpec) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_ImageButton
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Background
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUII_ButtonBack
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_InputMode
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_InputMode_RelVerify
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Image_Spec
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = imageSpec
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIImageButton = MUI_NewObjectA(SADD("Image.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Group Helpers ============== }

SUB ADDRESS MUIVGroup2(ADDRESS child1, ADDRESS child2) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = child1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = child2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIVGroup2 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIHGroup2(ADDRESS child1, ADDRESS child2) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { Use Columns=2 instead of Horiz=TRUE - workaround for Horiz not working }
    _tags&(_tagIndex) = MUIA_Group_Columns
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 2&
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = child1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = child2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIHGroup2 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIVGroup3(ADDRESS c1, ADDRESS c2, ADDRESS c3) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c3
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIVGroup3 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIVGroup4(ADDRESS c1, ADDRESS c2, ADDRESS c3, ADDRESS c4) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c3
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c4
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIVGroup4 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIHGroup3(ADDRESS c1, ADDRESS c2, ADDRESS c3) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { Use Columns=3 instead of Horiz=TRUE }
    _tags&(_tagIndex) = MUIA_Group_Columns
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 3&
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c3
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIHGroup3 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIHGroup4(ADDRESS c1, ADDRESS c2, ADDRESS c3, ADDRESS c4) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { Use Columns=4 instead of Horiz=TRUE }
    _tags&(_tagIndex) = MUIA_Group_Columns
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 4&
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c3
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = c4
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIHGroup4 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Quick Form Helpers ============== }

{ MUIForm2 - Two-row form with label/gadget pairs }
SUB ADDRESS MUIForm2(ADDRESS l1, ADDRESS g1, ADDRESS l2, ADDRESS g2) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { Two columns }
    _tags&(_tagIndex) = MUIA_Group_Columns
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 2&
    _tagIndex = _tagIndex + 1

    { Row 1 }
    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = l1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g1
    _tagIndex = _tagIndex + 1

    { Row 2 }
    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = l2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIForm2 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIForm3 - Three-row form with label/gadget pairs }
SUB ADDRESS MUIForm3(ADDRESS l1, ADDRESS g1, ADDRESS l2, ADDRESS g2, ADDRESS l3, ADDRESS g3) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { Two columns }
    _tags&(_tagIndex) = MUIA_Group_Columns
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 2&
    _tagIndex = _tagIndex + 1

    { Row 1 }
    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = l1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g1
    _tagIndex = _tagIndex + 1

    { Row 2 }
    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = l2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g2
    _tagIndex = _tagIndex + 1

    { Row 3 }
    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = l3
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g3
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIForm3 = MUI_NewObjectA(SADD("Group.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Window Helpers ============== }

SUB ADDRESS MUIWindow(STRING title, ADDRESS rootObj) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Window_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Window_ID
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = &H4D554931
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Window_RootObject
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = rootObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIWindow = MUI_NewObjectA(SADD("Window.mui"), VARPTR(_tags&(0)))
END SUB

SUB MUIWindowOpen(ADDRESS win) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Window_Open
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 1&    ' Use C-style TRUE (1) instead of BASIC TRUE (-1)
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(win, VARPTR(_tags&(0)))
END SUB

SUB MUIWindowClose(ADDRESS win) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Window_Open
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 0&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(win, VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIWindowID(STRING title, ADDRESS rootObj, LONGINT windowID) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Window_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Window_ID
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = windowID
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Window_RootObject
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = rootObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIWindowID = MUI_NewObjectA(SADD("Window.mui"), VARPTR(_tags&(0)))
END SUB

SUB LONGINT MUIWindowIsOpen(ADDRESS win) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Window_Open, win, VARPTR(result))
    MUIWindowIsOpen = result
END SUB

SUB MUIWindowTitle(ADDRESS win, STRING title) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Window_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(win, VARPTR(_tags&(0)))
END SUB

SUB MUIWindowScreenTitle(ADDRESS win, STRING title) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Window_ScreenTitle
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(win, VARPTR(_tags&(0)))
END SUB

{ MUIWindowWithMenu - Create window with menustrip attached }
SUB ADDRESS MUIWindowWithMenu(STRING title, ADDRESS rootObj, ADDRESS mstrip) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Window_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Window_ID
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = &H4D554931
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Window_RootObject
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = rootObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Window_Menustrip
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = mstrip
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIWindowWithMenu = MUI_NewObjectA(SADD("Window.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Application Helpers ============== }

SUB ADDRESS MUIApp(STRING appTitle, STRING appVersion, ADDRESS theWin) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Application_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(appTitle)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Application_Version
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(appVersion)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Application_Window
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = theWin
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIApp = MUI_NewObjectA(SADD("Application.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIAppMulti(STRING appTitle, STRING appVersion) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Application_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(appTitle)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Application_Version
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(appVersion)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIAppMulti = MUI_NewObjectA(SADD("Application.mui"), VARPTR(_tags&(0)))
END SUB

SUB MUIAppAddWindow(ADDRESS theApp, ADDRESS win) EXTERNAL
    DIM msg&(5)
    CONST OM_ADDMEMBER = &H101

    msg&(0) = OM_ADDMEMBER
    msg&(1) = win

    CALL DoMethodA(theApp, VARPTR(msg&(0)))
END SUB

SUB MUIAppRemWindow(ADDRESS theApp, ADDRESS win) EXTERNAL
    DIM msg&(5)
    CONST OM_REMMEMBER = &H102

    msg&(0) = OM_REMMEMBER
    msg&(1) = win

    CALL DoMethodA(theApp, VARPTR(msg&(0)))
END SUB

SUB MUIAppSleep(ADDRESS theApp) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Application_Sleep
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 1&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(theApp, VARPTR(_tags&(0)))
END SUB

SUB MUIAppWake(ADDRESS theApp) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Application_Sleep
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 0&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(theApp, VARPTR(_tags&(0)))
END SUB

{ ============== Notification Helpers ============== }

SUB MUINotifyButton(ADDRESS btn, ADDRESS theApp, LONGINT buttonID) EXTERNAL
    DIM msg&(10)

    msg&(0) = MUIM_Notify
    msg&(1) = MUIA_Pressed
    msg&(2) = 0&
    msg&(3) = theApp
    msg&(4) = 2&
    msg&(5) = MUIM_Application_ReturnID
    msg&(6) = buttonID

    CALL DoMethodA(btn, VARPTR(msg&(0)))
END SUB

{ MUINotifyCheckmark - Notify on checkmark state change (MUIA_Selected) }
SUB MUINotifyCheckmark(ADDRESS chk, ADDRESS theApp, LONGINT checkID) EXTERNAL
    DIM msg&(10)

    msg&(0) = MUIM_Notify
    msg&(1) = MUIA_Selected
    msg&(2) = MUIV_EveryTime
    msg&(3) = theApp
    msg&(4) = 2&
    msg&(5) = MUIM_Application_ReturnID
    msg&(6) = checkID

    CALL DoMethodA(chk, VARPTR(msg&(0)))
END SUB

SUB MUINotifyClose(ADDRESS theWin, ADDRESS theApp, LONGINT closeID) EXTERNAL
    DIM msg&(10)

    msg&(0) = MUIM_Notify
    msg&(1) = MUIA_Window_CloseRequest
    msg&(2) = MUIV_EveryTime
    msg&(3) = theApp
    msg&(4) = 2&
    msg&(5) = MUIM_Application_ReturnID
    msg&(6) = closeID

    CALL DoMethodA(theWin, VARPTR(msg&(0)))
END SUB

{ ============== Event Loop ============== }

SUB LONGINT MUIWaitEvent(ADDRESS theApp) EXTERNAL
    SHARED _evtMsg&, _evtSigs
    LONGINT returnID

    returnID = 0&

    WHILE returnID = 0&
        _evtSigs = 0&
        _evtMsg&(0) = MUIM_Application_NewInput
        _evtMsg&(1) = VARPTR(_evtSigs)

        returnID = DoMethodA(theApp, VARPTR(_evtMsg&(0)))

        IF returnID = 0& AND _evtSigs <> 0& THEN
            _evtSigs = _Wait(_evtSigs)
        END IF
    WEND

    MUIWaitEvent = returnID
END SUB

{ ============== String Gadget Helpers ============== }

{ Private helper - creates string gadget with optional secret mode }
SUB ADDRESS _MUIStringCreate(STRING initial, LONGINT maxLen, SHORTINT secret)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = maxLen
    _tagIndex = _tagIndex + 1

    IF secret THEN
        _tags&(_tagIndex) = MUIA_String_Secret
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = 1&
        _tagIndex = _tagIndex + 1
    END IF

    IF LEN(initial) > 0 THEN
        _tags&(_tagIndex) = MUIA_String_Contents
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(initial)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    _MUIStringCreate = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIString(STRING initial, LONGINT maxLen) EXTERNAL
    MUIString = _MUIStringCreate(initial, maxLen, 0)
END SUB

SUB ADDRESS MUIStringSecret(STRING initial, LONGINT maxLen) EXTERNAL
    MUIStringSecret = _MUIStringCreate(initial, maxLen, -1)
END SUB

SUB ADDRESS MUIInteger(LONGINT initial) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_String_Accept
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = SADD("0123456789-")
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_String_Integer
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = initial
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIInteger = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Checkmark Helper ============== }

{ Internal: Create checkmark with optional keyboard shortcut }
{ Pass keyCode = 0 for no keyboard shortcut }
SUB ADDRESS _MUICheckmarkCreate(LONGINT checked, LONGINT keyCode)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { ImageButtonFrame }
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_ImageButton
    _tagIndex = _tagIndex + 1

    { Toggle input mode }
    _tags&(_tagIndex) = MUIA_InputMode
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_InputMode_Toggle
    _tagIndex = _tagIndex + 1

    { The checkmark image }
    _tags&(_tagIndex) = MUIA_Image_Spec
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUII_CheckMark
    _tagIndex = _tagIndex + 1

    { Allow vertical resizing only (not horizontal) }
    _tags&(_tagIndex) = MUIA_Image_FreeVert
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = -1&
    _tagIndex = _tagIndex + 1

    { Initial state }
    _tags&(_tagIndex) = MUIA_Selected
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = checked
    _tagIndex = _tagIndex + 1

    { Don't show selection state overlay }
    _tags&(_tagIndex) = MUIA_ShowSelState
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 0&
    _tagIndex = _tagIndex + 1

    { Keyboard shortcut (optional) }
    IF keyCode <> 0 THEN
        _tags&(_tagIndex) = MUIA_ControlChar
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = keyCode
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    _MUICheckmarkCreate = MUI_NewObjectA(SADD("Image.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUICheckmark(LONGINT checked) EXTERNAL
    MUICheckmark = _MUICheckmarkCreate(checked, 0)
END SUB

SUB ADDRESS MUIKeyCheckmark(LONGINT checked, STRING key) EXTERNAL
    MUIKeyCheckmark = _MUICheckmarkCreate(checked, ASC(key))
END SUB

{ ============== Cycle Helper ============== }

SUB ADDRESS MUICycle(ADDRESS entries) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Cycle_Entries
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = entries
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUICycle = MUI_NewObjectA(SADD("Cycle.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Slider Helper ============== }

SUB ADDRESS MUISlider(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Slider_Min
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = minVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Slider_Max
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = maxVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Slider_Level
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = initial
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUISlider = MUI_NewObjectA(SADD("Slider.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== Gauge Helper ============== }

SUB ADDRESS MUIGauge(LONGINT maxVal) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Gauge_Horiz
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 1&
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Gauge_Max
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = maxVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_Group
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIGauge = MUI_NewObjectA(SADD("Gauge.mui"), VARPTR(_tags&(0)))
END SUB

SUB MUISetGauge(ADDRESS obj, LONGINT gval) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Gauge_Current
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = gval
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

{ ============== Radio Helper ============== }

SUB ADDRESS MUIRadio(ADDRESS entries) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Radio_Entries
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = entries
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIRadio = MUI_NewObjectA(SADD("Radio.mui"), VARPTR(_tags&(0)))
END SUB

SUB LONGINT MUIGetRadioActive(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Radio_Active, obj, VARPTR(result))
    MUIGetRadioActive = result
END SUB

SUB MUISetRadioActive(ADDRESS obj, LONGINT idx) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Radio_Active
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = idx
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

{ ============== Rectangle and Bar Helpers ============== }

SUB ADDRESS MUIRectangle EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = TAG_DONE

    MUIRectangle = MUI_NewObjectA(SADD("Rectangle.mui"), VARPTR(_tags&(0)))
END SUB

{ Private helper - creates a framed rectangle bar/separator }
SUB ADDRESS _MUIBarCreate(SHORTINT horiz)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_Group
    _tagIndex = _tagIndex + 1

    IF horiz THEN
        { Horizontal bar - don't expand vertically }
        _tags&(_tagIndex) = MUIA_VertWeight
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = 0&
        _tagIndex = _tagIndex + 1
    ELSE
        { Vertical bar - don't expand horizontally }
        _tags&(_tagIndex) = MUIA_HorizWeight
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = 0&
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    _MUIBarCreate = MUI_NewObjectA(SADD("Rectangle.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIHBar EXTERNAL
    MUIHBar = _MUIBarCreate(-1)
END SUB

SUB ADDRESS MUIVBar EXTERNAL
    MUIVBar = _MUIBarCreate(0)
END SUB

{ ============== Misc Object Helpers ============== }

SUB ADDRESS MUIColorfield(LONGINT r, LONGINT g, LONGINT b) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_Group
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Colorfield_Red
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = r
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Colorfield_Green
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Colorfield_Blue
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = b
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIColorfield = MUI_NewObjectA(SADD("Colorfield.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIColoradjust - RGB sliders for color editing }
SUB ADDRESS MUIColoradjust EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = TAG_DONE

    MUIColoradjust = MUI_NewObjectA(SADD("Coloradjust.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIColoradjustRGB - Coloradjust with initial RGB values }
SUB ADDRESS MUIColoradjustRGB(LONGINT r, LONGINT g, LONGINT b) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Coloradjust_Red
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = r
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Coloradjust_Green
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Coloradjust_Blue
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = b
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIColoradjustRGB = MUI_NewObjectA(SADD("Coloradjust.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPalette - Color palette for selecting colors }
SUB ADDRESS MUIPalette(LONGINT numColors) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Palette_Entries
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = numColors
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIPalette = MUI_NewObjectA(SADD("Palette.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPendisplay - Display a single pen/color }
SUB ADDRESS MUIPendisplay EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_Group
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIPendisplay = MUI_NewObjectA(SADD("Pendisplay.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPoppen - Popup color picker button }
SUB ADDRESS MUIPoppen EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = TAG_DONE

    MUIPoppen = MUI_NewObjectA(SADD("Poppen.mui"), VARPTR(_tags&(0)))
END SUB

{ MUISetColor - Set RGB color on a color object (Colorfield, Coloradjust, Pendisplay) }
SUB MUISetColor(ADDRESS obj, LONGINT r, LONGINT g, LONGINT b) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Coloradjust_Red
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = r
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Coloradjust_Green
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = g
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Coloradjust_Blue
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = b
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

{ MUIGetColorRed - Get red component from color object }
SUB LONGINT MUIGetColorRed(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Coloradjust_Red, obj, VARPTR(result))
    MUIGetColorRed = result
END SUB

{ MUIGetColorGreen - Get green component from color object }
SUB LONGINT MUIGetColorGreen(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Coloradjust_Green, obj, VARPTR(result))
    MUIGetColorGreen = result
END SUB

{ MUIGetColorBlue - Get blue component from color object }
SUB LONGINT MUIGetColorBlue(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Coloradjust_Blue, obj, VARPTR(result))
    MUIGetColorBlue = result
END SUB

SUB ADDRESS MUIImage(LONGINT imageSpec) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Image_Spec
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = imageSpec
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIImage = MUI_NewObjectA(SADD("Image.mui"), VARPTR(_tags&(0)))
END SUB

{ Private helper - creates scale with orientation }
SUB ADDRESS _MUIScaleCreate(SHORTINT horiz)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Scale_Horiz
    _tagIndex = _tagIndex + 1
    IF horiz THEN
        _tags&(_tagIndex) = 1&
    ELSE
        _tags&(_tagIndex) = 0&
    END IF
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    _MUIScaleCreate = MUI_NewObjectA(SADD("Scale.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIScale EXTERNAL
    MUIScale = _MUIScaleCreate(-1)
END SUB

SUB ADDRESS MUIScaleV EXTERNAL
    MUIScaleV = _MUIScaleCreate(0)
END SUB

{ ============== Label Helpers ============== }

{ Private helper - creates label with optional right alignment }
SUB ADDRESS _MUILabelCreate(STRING label, SHORTINT rightAlign)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    IF rightAlign THEN
        _tags&(_tagIndex) = MUIA_Text_PreParse
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(CHR$(27) + "r")
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = MUIA_Text_Contents
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(label)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Weight
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 0&
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    _MUILabelCreate = MUI_NewObjectA(SADD("Text.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUILabel(STRING label) EXTERNAL
    MUILabel = _MUILabelCreate(label, 0)
END SUB

SUB ADDRESS MUILabelRight(STRING label) EXTERNAL
    MUILabelRight = _MUILabelCreate(label, -1)
END SUB

{ ============== Attribute Access ============== }

SUB MUISet(ADDRESS obj, LONGINT attr, LONGINT v) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = attr
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = v
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

SUB MUISetStr(ADDRESS obj, LONGINT attr, STRING s) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = attr
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(s)
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

SUB LONGINT MUIGet(ADDRESS obj, LONGINT attr) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(attr, obj, VARPTR(result))
    MUIGet = result
END SUB

{ Convenience functions for common attributes }

SUB MUISetText(ADDRESS obj, STRING txt) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Text_Contents
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(txt)
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIGetText(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Text_Contents, obj, VARPTR(result))
    MUIGetText = result
END SUB

SUB MUISetStringContents(ADDRESS obj, STRING txt) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_String_Contents
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(txt)
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIGetStringContents(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_String_Contents, obj, VARPTR(result))
    MUIGetStringContents = result
END SUB

SUB MUISetValue(ADDRESS obj, LONGINT v) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Numeric_Value
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = v
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

SUB LONGINT MUIGetValue(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Numeric_Value, obj, VARPTR(result))
    MUIGetValue = result
END SUB

SUB MUISetChecked(ADDRESS obj, LONGINT state) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Selected
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = state
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

SUB LONGINT MUIGetChecked(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Selected, obj, VARPTR(result))
    MUIGetChecked = result
END SUB

SUB LONGINT MUIGetActive(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Cycle_Active, obj, VARPTR(result))
    MUIGetActive = result
END SUB

SUB MUISetActive(ADDRESS obj, LONGINT idx) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Cycle_Active
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = idx
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

SUB LONGINT MUIGetInteger(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_String_Integer, obj, VARPTR(result))
    MUIGetInteger = result
END SUB

{ ============== Hook Support ============== }
{*
** Hook structure (defined in MUI.h as MUIHook):
**   ADDRESS h_MinNode_mln_Succ  (offset 0)
**   ADDRESS h_MinNode_mln_Pred  (offset 4)
**   ADDRESS h_Entry             (offset 8)
**   ADDRESS h_SubEntry          (offset 12)
**   ADDRESS h_Data              (offset 16)
**
** These functions help set up Amiga Hook structures for use with
** CALLBACK SUBs and MUI notifications.
*}

{ MUISetupHook - Initialize a hook structure }
SUB MUISetupHook(ADDRESS hook, ADDRESS hookFunc, ADDRESS userData) EXTERNAL
    { h_MinNode_mln_Succ at offset 0 }
    POKEL hook, 0&
    { h_MinNode_mln_Pred at offset 4 }
    POKEL hook + 4, 0&
    { h_Entry at offset 8 - the callback function address }
    POKEL hook + 8, hookFunc
    { h_SubEntry at offset 12 }
    POKEL hook + 12, 0&
    { h_Data at offset 16 - user data passed to callback }
    POKEL hook + 16, userData
END SUB

{ MUINotifyButtonHook - Set up hook notification on button press }
SUB MUINotifyButtonHook(ADDRESS btn, ADDRESS hook) EXTERNAL
    DIM msg&(10)

    msg&(0) = MUIM_Notify
    msg&(1) = MUIA_Pressed
    msg&(2) = 0&
    msg&(3) = btn
    msg&(4) = 2&
    msg&(5) = MUIM_CallHook
    msg&(6) = hook

    CALL DoMethodA(btn, VARPTR(msg&(0)))
END SUB

{ MUINotifyAttrHook - Set up hook notification on any attribute change }
SUB MUINotifyAttrHook(ADDRESS obj, LONGINT attr, ADDRESS hook) EXTERNAL
    DIM msg&(10)

    msg&(0) = MUIM_Notify
    msg&(1) = attr
    msg&(2) = MUIV_EveryTime
    msg&(3) = obj
    msg&(4) = 2&
    msg&(5) = MUIM_CallHook
    msg&(6) = hook

    CALL DoMethodA(obj, VARPTR(msg&(0)))
END SUB

{ ============== List Object Helpers ============== }

{ MUIList - Create a basic list object (for string entries) }
SUB ADDRESS MUIList EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    { Set up string copying hooks so MUI manages string memory }
    _tags&(_tagIndex) = MUIA_List_ConstructHook
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_List_ConstructHook_String
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_List_DestructHook
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_List_DestructHook_String
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIList = MUI_NewObjectA(SADD("List.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIListview - Create a scrollable listview wrapping a list object }
SUB ADDRESS MUIListview(ADDRESS listObj) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Listview_List
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = listObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIListview = MUI_NewObjectA(SADD("Listview.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIDirlist - Create a directory listing object }
SUB ADDRESS MUIDirlist(STRING directory) EXTERNAL
    SHARED _tags&, _tagIndex
    CONST MUIA_Dirlist_Directory = &H8042ea41

    _tagIndex = 0

    IF LEN(directory) > 0 THEN
        _tags&(_tagIndex) = MUIA_Dirlist_Directory
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(directory)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    MUIDirlist = MUI_NewObjectA(SADD("Dirlist.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIVolumelist - Create a volume/device listing object }
SUB ADDRESS MUIVolumelist EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = TAG_DONE

    MUIVolumelist = MUI_NewObjectA(SADD("Volumelist.mui"), VARPTR(_tags&(0)))
END SUB

{ ============== List Operation Functions ============== }

{ MUIListInsert - Add entry at end of list }
SUB MUIListInsert(ADDRESS listObj, STRING entry) EXTERNAL
    DIM msg&(10)
    DIM entries&(2)

    { Build array of string pointers (1 entry + NULL terminator) }
    entries&(0) = _CopyStr(entry)
    entries&(1) = 0&

    msg&(0) = MUIM_List_Insert
    msg&(1) = VARPTR(entries&(0))   { Pointer to string pointer array }
    msg&(2) = 1&                     { Count = 1 }
    msg&(3) = MUIV_List_Insert_Bottom

    CALL DoMethodA(listObj, VARPTR(msg&(0)))
END SUB

{ MUIListInsertAt - Insert entry at specific position }
SUB MUIListInsertAt(ADDRESS listObj, STRING entry, LONGINT position) EXTERNAL
    DIM msg&(10)
    DIM entries&(2)

    { Build array of string pointers (1 entry + NULL terminator) }
    entries&(0) = _CopyStr(entry)
    entries&(1) = 0&

    msg&(0) = MUIM_List_Insert
    msg&(1) = VARPTR(entries&(0))   { Pointer to string pointer array }
    msg&(2) = 1&                     { Count = 1 }
    msg&(3) = position

    CALL DoMethodA(listObj, VARPTR(msg&(0)))
END SUB

{ MUIListRemove - Remove entry at position }
SUB MUIListRemove(ADDRESS listObj, LONGINT position) EXTERNAL
    DIM msg&(5)

    msg&(0) = MUIM_List_Remove
    msg&(1) = position

    CALL DoMethodA(listObj, VARPTR(msg&(0)))
END SUB

{ MUIListClear - Clear all entries from list }
SUB MUIListClear(ADDRESS listObj) EXTERNAL
    DIM msg&(5)

    msg&(0) = MUIM_List_Clear

    CALL DoMethodA(listObj, VARPTR(msg&(0)))
END SUB

{ MUIListCount - Get number of entries in list }
SUB LONGINT MUIListCount(ADDRESS listObj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_List_Entries, listObj, VARPTR(result))
    MUIListCount = result
END SUB

{ MUIListActive - Get index of selected entry (-1 if none) }
SUB LONGINT MUIListActive(ADDRESS listObj) EXTERNAL
    LONGINT result
    result = -1&
    CALL GetAttr&(MUIA_List_Active, listObj, VARPTR(result))
    MUIListActive = result
END SUB

{ MUIListSetActive - Select entry at position }
SUB MUIListSetActive(ADDRESS listObj, LONGINT position) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_List_Active
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = position
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(listObj, VARPTR(_tags&(0)))
END SUB

{ MUIListGetEntry - Get pointer to entry string at position }
SUB ADDRESS MUIListGetEntry(ADDRESS listObj, LONGINT position) EXTERNAL
    DIM msg&(5)
    ADDRESS result

    result = 0&

    msg&(0) = MUIM_List_GetEntry
    msg&(1) = position
    msg&(2) = VARPTR(result)

    CALL DoMethodA(listObj, VARPTR(msg&(0)))

    MUIListGetEntry = result
END SUB

{ ============== Menu Builder ============== }
{*
** Stack-based menu builder for MUI menus.
** Usage:
**   MUIBeginMenustrip
**       MUIBeginMenu "File"
**           miNew = MUIMenuitem("New", "N")
**           MUIMenuSeparator
**           miQuit = MUIMenuitem("Quit", "Q")
**       MUIEndMenu
**   menustrip = MUIEndMenustrip
**   MUIWindowMenustrip win, menustrip
*}

{ MUIBeginMenustrip - Start building a menustrip }
SUB MUIBeginMenustrip EXTERNAL
    SHARED _menuLevel, _menuCount
    _menuLevel = 0
    _menuCount = 0
END SUB

{ MUIBeginMenu - Start a new menu with given title }
SUB MUIBeginMenu(STRING title) EXTERNAL
    SHARED _menuLevel, _menuCount, _menuItemCounts%, _menuTitles&

    _menuLevel = _menuCount + 1
    _menuItemCounts%(_menuCount) = 0
    _menuTitles&(_menuCount) = _CopyStr(title)
END SUB

{ MUIMenuitem - Add a menu item with keyboard shortcut }
SUB ADDRESS MUIMenuitem(STRING title, STRING shortcut) EXTERNAL
    SHARED _tags&, _tagIndex, _menuItems&, _menuItemCounts%, _menuCount
    SHORTINT idx, offs
    ADDRESS item

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Menuitem_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1

    IF LEN(shortcut) > 0 THEN
        _tags&(_tagIndex) = MUIA_Menuitem_Shortcut
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(shortcut)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    item = MUI_NewObjectA(SADD("Menuitem.mui"), VARPTR(_tags&(0)))

    { Store in menu items array }
    idx = _menuItemCounts%(_menuCount)
    offs = _menuCount * _MENU_MAX_ITEMS
    _menuItems&(offs + idx) = item
    _menuItemCounts%(_menuCount) = idx + 1

    MUIMenuitem = item
END SUB

{ MUIMenuitemNoKey - Add a menu item without keyboard shortcut }
SUB ADDRESS MUIMenuitemNoKey(STRING title) EXTERNAL
    SHARED _tags&, _tagIndex, _menuItems&, _menuItemCounts%, _menuCount
    SHORTINT idx, offs
    ADDRESS item

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Menuitem_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    item = MUI_NewObjectA(SADD("Menuitem.mui"), VARPTR(_tags&(0)))

    { Store in menu items array }
    idx = _menuItemCounts%(_menuCount)
    offs = _menuCount * _MENU_MAX_ITEMS
    _menuItems&(offs + idx) = item
    _menuItemCounts%(_menuCount) = idx + 1

    MUIMenuitemNoKey = item
END SUB

{ MUIMenuSeparator - Add a separator bar to the menu }
SUB MUIMenuSeparator EXTERNAL
    SHARED _tags&, _tagIndex, _menuItems&, _menuItemCounts%, _menuCount
    SHORTINT idx, offs
    ADDRESS item

    _tagIndex = 0

    { NM_BARLABEL = -1 for separator }
    _tags&(_tagIndex) = MUIA_Menuitem_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = NM_BARLABEL
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    item = MUI_NewObjectA(SADD("Menuitem.mui"), VARPTR(_tags&(0)))

    { Store in menu items array }
    idx = _menuItemCounts%(_menuCount)
    offs = _menuCount * _MENU_MAX_ITEMS
    _menuItems&(offs + idx) = item
    _menuItemCounts%(_menuCount) = idx + 1
END SUB

{ MUIMenuitemCheck - Add a checkable menu item }
SUB ADDRESS MUIMenuitemCheck(STRING title, STRING shortcut, LONGINT checked) EXTERNAL
    SHARED _tags&, _tagIndex, _menuItems&, _menuItemCounts%, _menuCount
    SHORTINT idx, offs
    ADDRESS item

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Menuitem_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _CopyStr(title)
    _tagIndex = _tagIndex + 1

    IF LEN(shortcut) > 0 THEN
        _tags&(_tagIndex) = MUIA_Menuitem_Shortcut
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(shortcut)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = MUIA_Menuitem_Checkit
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 1&
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Menuitem_Toggle
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 1&
    _tagIndex = _tagIndex + 1

    IF checked THEN
        _tags&(_tagIndex) = MUIA_Menuitem_Checked
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = 1&
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    item = MUI_NewObjectA(SADD("Menuitem.mui"), VARPTR(_tags&(0)))

    { Store in menu items array }
    idx = _menuItemCounts%(_menuCount)
    offs = _menuCount * _MENU_MAX_ITEMS
    _menuItems&(offs + idx) = item
    _menuItemCounts%(_menuCount) = idx + 1

    MUIMenuitemCheck = item
END SUB

{ MUIEndMenu - End current menu and build it }
SUB ADDRESS MUIEndMenu EXTERNAL
    SHARED _tags&, _tagIndex, _menuItems&, _menuItemCounts%, _menuTitles&
    SHARED _menus&, _menuCount, _menuLevel
    SHORTINT cnt, offs, idx
    ADDRESS theMenu

    cnt = _menuItemCounts%(_menuCount)
    offs = _menuCount * _MENU_MAX_ITEMS

    _tagIndex = 0

    { Menu title }
    _tags&(_tagIndex) = MUIA_Menu_Title
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = _menuTitles&(_menuCount)
    _tagIndex = _tagIndex + 1

    { Add all menu items as children }
    FOR idx = 0 TO cnt - 1
        _tags&(_tagIndex) = MUIA_Family_Child
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _menuItems&(offs + idx)
        _tagIndex = _tagIndex + 1
    NEXT idx

    _tags&(_tagIndex) = TAG_DONE

    theMenu = MUI_NewObjectA(SADD("Menu.mui"), VARPTR(_tags&(0)))

    { Store menu in menustrip array }
    _menus&(_menuCount) = theMenu
    _menuCount = _menuCount + 1
    _menuLevel = 0

    MUIEndMenu = theMenu
END SUB

{ MUIEndMenustrip - End menustrip and build it }
SUB ADDRESS MUIEndMenustrip EXTERNAL
    SHARED _tags&, _tagIndex, _menus&, _menuCount
    SHORTINT idx
    ADDRESS mstrip

    _tagIndex = 0

    { Add all menus as children }
    FOR idx = 0 TO _menuCount - 1
        _tags&(_tagIndex) = MUIA_Family_Child
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _menus&(idx)
        _tagIndex = _tagIndex + 1
    NEXT idx

    _tags&(_tagIndex) = TAG_DONE

    mstrip = MUI_NewObjectA(SADD("Menustrip.mui"), VARPTR(_tags&(0)))

    MUIEndMenustrip = mstrip
END SUB

{ MUIWindowMenustrip - Attach menustrip to window (call before opening) }
SUB MUIWindowMenustrip(ADDRESS win, ADDRESS menustrip) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Window_Menustrip
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = menustrip
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(win, VARPTR(_tags&(0)))
END SUB

{ MUINotifyMenu - Set up notification when menu item is triggered }
SUB MUINotifyMenu(ADDRESS menuitem, ADDRESS theApp, LONGINT menuID) EXTERNAL
    DIM msg&(10)

    msg&(0) = MUIM_Notify
    msg&(1) = MUIA_Menuitem_Trigger
    msg&(2) = MUIV_EveryTime
    msg&(3) = theApp
    msg&(4) = 2&
    msg&(5) = MUIM_Application_ReturnID
    msg&(6) = menuID

    CALL DoMethodA(menuitem, VARPTR(msg&(0)))
END SUB

{ MUIMenuEnable - Enable or disable a menu item }
SUB MUIMenuEnable(ADDRESS menuitem, LONGINT enabled) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Menuitem_Enabled
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = enabled
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(menuitem, VARPTR(_tags&(0)))
END SUB

{ MUIMenuSetChecked - Set checked state of a checkable menu item }
SUB MUIMenuSetChecked(ADDRESS menuitem, LONGINT checked) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Menuitem_Checked
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = checked
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(menuitem, VARPTR(_tags&(0)))
END SUB

{ MUIMenuGetChecked - Get checked state of a checkable menu item }
SUB LONGINT MUIMenuGetChecked(ADDRESS menuitem) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Menuitem_Checked, menuitem, VARPTR(result))
    MUIMenuGetChecked = result
END SUB

{ ============== Popup Objects (Phase 11) ============== }
{*
** Popup objects combine a string/text gadget with a popup button.
** When pressed, the button opens a popup window with various content
** (ASL requesters, lists, or custom objects).
**
** Popasl: Uses system ASL requesters (file, font, screenmode)
** Poplist: Simple dropdown list from a string array
** Popobject: Custom popup with any MUI object
** Popstring: Base class - string + button with custom hooks
*}

{ _MUIPopButton - Create a popup button with specified image }
SUB ADDRESS _MUIPopButton(LONGINT imageType)
    SHARED _tags&

    { Use MUI_MakeObjectA with MUIO_PopButton to create a proper popup button }
    _tags&(0) = imageType

    _MUIPopButton = MUI_MakeObjectA(MUIO_PopButton, VARPTR(_tags&(0)))
END SUB

{ MUIPopaslFile - Create a file requester popup }
SUB ADDRESS MUIPopaslFile(STRING title, STRING patt) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 256&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button with file icon }
    btnObj = _MUIPopButton(MUII_PopFile)

    { Create Popasl object }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popasl_Type
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = ASL_FileRequest
    _tagIndex = _tagIndex + 1

    IF LEN(title) > 0 THEN
        _tags&(_tagIndex) = ASLFR_TitleText
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(title)
        _tagIndex = _tagIndex + 1
    END IF

    IF LEN(patt) > 0 THEN
        _tags&(_tagIndex) = ASLFR_InitialPattern
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(patt)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    MUIPopaslFile = MUI_NewObjectA(SADD("Popasl.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPopaslDrawer - Create a drawer/directory requester popup }
SUB ADDRESS MUIPopaslDrawer(STRING title) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 256&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button with drawer icon }
    btnObj = _MUIPopButton(MUII_PopDrawer)

    { Create Popasl object }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popasl_Type
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = ASL_FileRequest
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = ASLFR_DrawersOnly
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 1&
    _tagIndex = _tagIndex + 1

    IF LEN(title) > 0 THEN
        _tags&(_tagIndex) = ASLFR_TitleText
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(title)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    MUIPopaslDrawer = MUI_NewObjectA(SADD("Popasl.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPopaslFont - Create a font requester popup }
SUB ADDRESS MUIPopaslFont(STRING title) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 80&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button }
    btnObj = _MUIPopButton(MUII_PopUp)

    { Create Popasl object }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popasl_Type
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = ASL_FontRequest
    _tagIndex = _tagIndex + 1

    IF LEN(title) > 0 THEN
        _tags&(_tagIndex) = ASLFO_TitleText
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(title)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    MUIPopaslFont = MUI_NewObjectA(SADD("Popasl.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPopaslFontFixed - Create a fixed-width font requester popup }
SUB ADDRESS MUIPopaslFontFixed(STRING title) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 80&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button }
    btnObj = _MUIPopButton(MUII_PopUp)

    { Create Popasl object }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popasl_Type
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = ASL_FontRequest
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = ASLFO_FixedWidthOnly
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 1&
    _tagIndex = _tagIndex + 1

    IF LEN(title) > 0 THEN
        _tags&(_tagIndex) = ASLFO_TitleText
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(title)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    MUIPopaslFontFixed = MUI_NewObjectA(SADD("Popasl.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPopaslScreen - Create a screen mode requester popup }
SUB ADDRESS MUIPopaslScreen(STRING title) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 80&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button }
    btnObj = _MUIPopButton(MUII_PopUp)

    { Create Popasl object }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popasl_Type
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = ASL_ScreenModeRequest
    _tagIndex = _tagIndex + 1

    IF LEN(title) > 0 THEN
        _tags&(_tagIndex) = ASLSM_TitleText
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(title)
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    MUIPopaslScreen = MUI_NewObjectA(SADD("Popasl.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPoplist - Create a simple list popup from a string array }
SUB ADDRESS MUIPoplist(ADDRESS entries) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 256&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button }
    btnObj = _MUIPopButton(MUII_PopUp)

    { Create Poplist object }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Poplist_Array
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = entries
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIPoplist = MUI_NewObjectA(SADD("Poplist.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPopobject - Create a popup with a custom object }
SUB ADDRESS MUIPopobject(ADDRESS popupObj) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 256&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button }
    btnObj = _MUIPopButton(MUII_PopUp)

    { Create Popobject }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popobject_Object
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = popupObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIPopobject = MUI_NewObjectA(SADD("Popobject.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPopobjectHooked - Create a popup with hooks for string/object sync }
SUB ADDRESS MUIPopobjectHooked(ADDRESS popupObj, ADDRESS strObjHook, ADDRESS objStrHook) EXTERNAL
    SHARED _tags&, _tagIndex
    ADDRESS strObj, btnObj

    { Create string gadget }
    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIA_String_MaxLen
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 256&
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE
    strObj = MUI_NewObjectA(SADD("String.mui"), VARPTR(_tags&(0)))

    { Create popup button }
    btnObj = _MUIPopButton(MUII_PopUp)

    { Create Popobject with hooks }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Popstring_String
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = strObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popstring_Button
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = btnObj
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Popobject_Object
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = popupObj
    _tagIndex = _tagIndex + 1

    IF strObjHook <> 0& THEN
        _tags&(_tagIndex) = MUIA_Popobject_StrObjHook
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = strObjHook
        _tagIndex = _tagIndex + 1
    END IF

    IF objStrHook <> 0& THEN
        _tags&(_tagIndex) = MUIA_Popobject_ObjStrHook
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = objStrHook
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    MUIPopobjectHooked = MUI_NewObjectA(SADD("Popobject.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIPopstringObj - Get the embedded string object from a popup }
SUB ADDRESS MUIPopstringObj(ADDRESS popup) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Popstring_String, popup, VARPTR(result))
    MUIPopstringObj = result
END SUB

{ MUIPopstringValue - Get the string contents from a popup }
SUB ADDRESS MUIPopstringValue(ADDRESS popup) EXTERNAL
    LONGINT strObj, result
    strObj = 0&
    result = 0&
    CALL GetAttr&(MUIA_Popstring_String, popup, VARPTR(strObj))
    IF strObj <> 0& THEN
        CALL GetAttr&(MUIA_String_Contents, strObj, VARPTR(result))
    END IF
    MUIPopstringValue = result
END SUB

{ MUIPopstringSetValue - Set the string contents of a popup }
SUB MUIPopstringSetValue(ADDRESS popup, STRING value) EXTERNAL
    SHARED _tags&, _tagIndex
    LONGINT strObj
    strObj = 0&
    CALL GetAttr&(MUIA_Popstring_String, popup, VARPTR(strObj))
    IF strObj <> 0& THEN
        _tagIndex = 0
        _tags&(_tagIndex) = MUIA_String_Contents
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = _CopyStr(value)
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = TAG_DONE
        CALL SetAttrsA(strObj, VARPTR(_tags&(0)))
    END IF
END SUB

{ MUIPopaslActive - Check if an ASL popup requester is currently open }
SUB LONGINT MUIPopaslActive(ADDRESS popup) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Popasl_Active, popup, VARPTR(result))
    MUIPopaslActive = result
END SUB

{ MUIPopstringClose - Close a popup programmatically }
SUB MUIPopstringClose(ADDRESS popup, LONGINT success) EXTERNAL
    DIM msg&(5)
    msg&(0) = MUIM_Popstring_Close
    msg&(1) = success
    CALL DoMethodA(popup, VARPTR(msg&(0)))
END SUB

{ MUIPopstringOpen - Open a popup programmatically }
SUB MUIPopstringOpen(ADDRESS popup) EXTERNAL
    DIM msg&(5)
    msg&(0) = MUIM_Popstring_Open
    CALL DoMethodA(popup, VARPTR(msg&(0)))
END SUB

{ ============== Register (Tabs) - Phase 12 ============== }
{*
** Register creates a tabbed interface where each tab shows a different page.
** Pages are groups that contain the content for each tab.
**
** Simple usage:
**   DIM titles&(3)
**   titles&(0) = SADD("General")
**   titles&(1) = SADD("Advanced")
**   titles&(2) = 0&  ' NULL terminator
**   reg = MUIRegister(VARPTR(titles&(0)), page1, page2)
**
** Builder pattern:
**   MUIBeginRegister "General|Advanced|Options"
**       MUIRegisterPage page1
**       MUIRegisterPage page2
**       MUIRegisterPage page3
**   reg = MUIEndRegister
*}

{ _ParseRegTitles - Parse pipe-separated title string into _regTitles array }
SUB _ParseRegTitles(STRING titles)
    SHARED _regTitles&
    SHORTINT i, start, idx, titleIdx, slen
    STRING t SIZE 82

    { Initialize all titles to NULL }
    FOR i = 0 TO _REG_MAX_TITLES - 1
        _regTitles&(i) = 0&
    NEXT i

    slen = LEN(titles)
    IF slen = 0 THEN EXIT SUB

    start = 1
    titleIdx = 0

    FOR idx = 1 TO slen
        IF MID$(titles, idx, 1) = "|" OR idx = slen THEN
            { Extract this title }
            IF idx = slen AND MID$(titles, idx, 1) <> "|" THEN
                t = MID$(titles, start, idx - start + 1)
            ELSE
                t = MID$(titles, start, idx - start)
            END IF

            IF LEN(t) > 0 AND titleIdx < _REG_MAX_PAGES THEN
                _regTitles&(titleIdx) = _CopyStr(t)
                titleIdx = titleIdx + 1
            END IF

            start = idx + 1
        END IF
    NEXT idx

    { Ensure NULL terminator }
    _regTitles&(titleIdx) = 0&
END SUB

{ MUIBeginRegister - Start building a register with pipe-separated titles }
SUB MUIBeginRegister(STRING titles) EXTERNAL
    SHARED _regPages&, _regTitles&, _regPageCount, _regBuilding
    SHORTINT i

    { Initialize register builder state }
    _regPageCount = 0
    _regBuilding = -1

    FOR i = 0 TO _REG_MAX_PAGES - 1
        _regPages&(i) = 0&
    NEXT i

    { Parse titles into array }
    CALL _ParseRegTitles(titles)
END SUB

{ MUIRegisterPage - Add a page (group) to the register being built }
SUB MUIRegisterPage(ADDRESS pageGroup) EXTERNAL
    SHARED _regPages&, _regPageCount, _regBuilding

    IF _regBuilding = 0 THEN EXIT SUB
    IF _regPageCount >= _REG_MAX_PAGES THEN EXIT SUB

    _regPages&(_regPageCount) = pageGroup
    _regPageCount = _regPageCount + 1
END SUB

{ MUIEndRegister - Finish building register and return the object }
SUB ADDRESS MUIEndRegister EXTERNAL
    SHARED _tags&, _tagIndex, _regPages&, _regTitles&, _regPageCount, _regBuilding
    SHORTINT i

    IF _regBuilding = 0 THEN
        MUIEndRegister = 0&
        EXIT SUB
    END IF

    _regBuilding = 0

    { Build register object }
    _tagIndex = 0

    { Set titles array }
    _tags&(_tagIndex) = MUIA_Register_Titles
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = VARPTR(_regTitles&(0))
    _tagIndex = _tagIndex + 1

    { Add page children }
    FOR i = 0 TO _regPageCount - 1
        IF _regPages&(i) <> 0& THEN
            _tags&(_tagIndex) = MUIA_Group_Child
            _tagIndex = _tagIndex + 1
            _tags&(_tagIndex) = _regPages&(i)
            _tagIndex = _tagIndex + 1
        END IF
    NEXT i

    _tags&(_tagIndex) = TAG_DONE

    MUIEndRegister = MUI_NewObjectA(SADD("Register.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIRegister2 - Create a register with 2 pages }
SUB ADDRESS MUIRegister2(STRING titles, ADDRESS page1, ADDRESS page2) EXTERNAL
    SHARED _tags&, _tagIndex, _regTitles&

    { Parse titles }
    CALL _ParseRegTitles(titles)

    { Build register }
    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Register_Titles
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = VARPTR(_regTitles&(0))
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = page1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = page2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIRegister2 = MUI_NewObjectA(SADD("Register.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIRegister3 - Create a register with 3 pages }
SUB ADDRESS MUIRegister3(STRING titles, ADDRESS page1, ADDRESS page2, ADDRESS page3) EXTERNAL
    SHARED _tags&, _tagIndex, _regTitles&

    CALL _ParseRegTitles(titles)

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Register_Titles
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = VARPTR(_regTitles&(0))
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = page1
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = page2
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = page3
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIRegister3 = MUI_NewObjectA(SADD("Register.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIRegisterActive - Get the currently active page index (0-based) }
SUB LONGINT MUIRegisterActive(ADDRESS reg) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Group_ActivePage, reg, VARPTR(result))
    MUIRegisterActive = result
END SUB

{ MUIRegisterSetActive - Set the active page (0-based index) }
SUB MUIRegisterSetActive(ADDRESS reg, LONGINT page) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Group_ActivePage
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = page
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(reg, VARPTR(_tags&(0)))
END SUB

{ ============== Scrollgroup & Virtgroup - Phase 12 ============== }
{*
** Scrollgroup provides a scrollable view of content.
** Virtgroup creates a virtual group that can be larger than the visible area.
**
** Usage:
**   virt = MUIVirtgroup(MUIVGroup2(MUIText("Line 1"), MUIText("Line 2")))
**   scroll = MUIScrollgroup(virt)
**
** Or use the builder pattern:
**   MUIBeginVGroup
**       ... many children ...
**   virt = MUIEndVirtgroup  ' Makes it virtual
**   scroll = MUIScrollgroup(virt)
*}

{ MUIVirtgroup - Create a virtual group (scrollable content) }
SUB ADDRESS MUIVirtgroup(ADDRESS contents) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_Virtual
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = contents
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIVirtgroup = MUI_NewObjectA(SADD("Virtgroup.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIVirtgroupH - Create a horizontal virtual group }
SUB ADDRESS MUIVirtgroupH(ADDRESS contents) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Frame
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = MUIV_Frame_Virtual
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Columns
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = 100&
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Group_Child
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = contents
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIVirtgroupH = MUI_NewObjectA(SADD("Virtgroup.mui"), VARPTR(_tags&(0)))
END SUB

{ Private helper - creates scrollgroup with specified scroll directions }
SUB ADDRESS _MUIScrollgroupCreate(ADDRESS virtgroup, SHORTINT freeH, SHORTINT freeV)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Scrollgroup_Contents
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = virtgroup
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Scrollgroup_FreeHoriz
    _tagIndex = _tagIndex + 1
    IF freeH THEN
        _tags&(_tagIndex) = -1&
    ELSE
        _tags&(_tagIndex) = 0&
    END IF
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Scrollgroup_FreeVert
    _tagIndex = _tagIndex + 1
    IF freeV THEN
        _tags&(_tagIndex) = -1&
    ELSE
        _tags&(_tagIndex) = 0&
    END IF
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    _MUIScrollgroupCreate = MUI_NewObjectA(SADD("Scrollgroup.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIScrollgroup(ADDRESS virtgroup) EXTERNAL
    MUIScrollgroup = _MUIScrollgroupCreate(virtgroup, -1, -1)
END SUB

SUB ADDRESS MUIScrollgroupHoriz(ADDRESS virtgroup) EXTERNAL
    MUIScrollgroupHoriz = _MUIScrollgroupCreate(virtgroup, -1, 0)
END SUB

SUB ADDRESS MUIScrollgroupVert(ADDRESS virtgroup) EXTERNAL
    MUIScrollgroupVert = _MUIScrollgroupCreate(virtgroup, 0, -1)
END SUB

{ ============== Balance - Phase 12 ============== }
{*
** Balance creates a resizable divider between groups.
** Use it in an HGroup to create horizontally resizable panes,
** or in a VGroup for vertically resizable panes.
**
** Usage:
**   MUIBeginHGroup
**       MUIChild leftPanel
**       MUIChild MUIBalance      ' Horizontal divider
**       MUIChild rightPanel
**   grp = MUIEndGroup
*}

{ Private helper - creates balance with optional quiet mode }
SUB ADDRESS _MUIBalanceCreate(SHORTINT quiet)
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    IF quiet THEN
        _tags&(_tagIndex) = MUIA_Balance_Quiet
        _tagIndex = _tagIndex + 1
        _tags&(_tagIndex) = -1&
        _tagIndex = _tagIndex + 1
    END IF

    _tags&(_tagIndex) = TAG_DONE

    _MUIBalanceCreate = MUI_NewObjectA(SADD("Balance.mui"), VARPTR(_tags&(0)))
END SUB

SUB ADDRESS MUIBalance EXTERNAL
    MUIBalance = _MUIBalanceCreate(0)
END SUB

SUB ADDRESS MUIBalanceQuiet EXTERNAL
    MUIBalanceQuiet = _MUIBalanceCreate(-1)
END SUB

{ ============== Additional Objects - Phase 13 ============== }
{*
** Numericbutton: A numeric input control with +/- buttons.
** The user can click buttons or type a value directly.
**
** Dtpic: Display an image file using datatypes. Supports
** any image format that has a datatype installed (IFF, PNG, etc).
*}

{ Numericbutton constants (same as Numeric base class) }
CONST MUIA_Numeric_Min            = &H8042e404
CONST MUIA_Numeric_Max            = &H8042d78a
CONST MUIA_Numeric_Default        = &H804263e8
CONST MUIA_Numeric_Format         = &H804263e9
CONST MUIA_Numeric_Reverse        = &H8042f2a0

{ Dtpic constants }
CONST MUIA_Dtpic_Name             = &H80423d72
CONST MUIA_Dtpic_Alpha            = &H8042b4db
CONST MUIA_Dtpic_DarkenSelState   = &H80423247
CONST MUIA_Dtpic_Fade             = &H80420f4a
CONST MUIA_Dtpic_LightenOnMouse   = &H8042966a

{ MUINumericbutton - Create a numeric input with +/- buttons }
SUB ADDRESS MUINumericbutton(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Numeric_Min
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = minVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Max
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = maxVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Value
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = initial
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUINumericbutton = MUI_NewObjectA(SADD("Numericbutton.mui"), VARPTR(_tags&(0)))
END SUB

{ MUINumericbuttonFormat - Create a numeric button with custom format string }
SUB ADDRESS MUINumericbuttonFormat(LONGINT minVal, LONGINT maxVal, LONGINT initial, STRING fmt) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Numeric_Min
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = minVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Max
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = maxVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Value
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = initial
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Format
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = SADD(fmt)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUINumericbuttonFormat = MUI_NewObjectA(SADD("Numericbutton.mui"), VARPTR(_tags&(0)))
END SUB

{ MUINumericbuttonValue - Get the current value of a numeric button }
SUB LONGINT MUINumericbuttonValue(ADDRESS obj) EXTERNAL
    LONGINT result
    result = 0&
    CALL GetAttr&(MUIA_Numeric_Value, obj, VARPTR(result))
    MUINumericbuttonValue = result
END SUB

{ MUINumericbuttonSetValue - Set the value of a numeric button }
SUB MUINumericbuttonSetValue(ADDRESS obj, LONGINT value) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Numeric_Value
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = value
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

{ MUIDtpic - Display an image file using datatypes }
SUB ADDRESS MUIDtpic(STRING filename) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Dtpic_Name
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = SADD(filename)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIDtpic = MUI_NewObjectA(SADD("Dtpic.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIDtpicAlpha - Display an image with alpha channel support }
SUB ADDRESS MUIDtpicAlpha(STRING filename, LONGINT alpha) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Dtpic_Name
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = SADD(filename)
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Dtpic_Alpha
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = alpha
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIDtpicAlpha = MUI_NewObjectA(SADD("Dtpic.mui"), VARPTR(_tags&(0)))
END SUB

{ MUIDtpicSetName - Change the displayed image }
SUB MUIDtpicSetName(ADDRESS obj, STRING filename) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0
    _tags&(_tagIndex) = MUIA_Dtpic_Name
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = SADD(filename)
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = TAG_DONE

    CALL SetAttrsA(obj, VARPTR(_tags&(0)))
END SUB

{ MUIKnob - Create a knob (rotary dial) numeric input }
SUB ADDRESS MUIKnob(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Numeric_Min
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = minVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Max
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = maxVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Value
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = initial
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUIKnob = MUI_NewObjectA(SADD("Knob.mui"), VARPTR(_tags&(0)))
END SUB

{ MUILevelmeter - Create a level meter (visual gauge with numeric display) }
SUB ADDRESS MUILevelmeter(LONGINT minVal, LONGINT maxVal, LONGINT initial) EXTERNAL
    SHARED _tags&, _tagIndex

    _tagIndex = 0

    _tags&(_tagIndex) = MUIA_Numeric_Min
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = minVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Max
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = maxVal
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = MUIA_Numeric_Value
    _tagIndex = _tagIndex + 1
    _tags&(_tagIndex) = initial
    _tagIndex = _tagIndex + 1

    _tags&(_tagIndex) = TAG_DONE

    MUILevelmeter = MUI_NewObjectA(SADD("Levelmeter.mui"), VARPTR(_tags&(0)))
END SUB
