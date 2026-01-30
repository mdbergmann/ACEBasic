{*
** MUI_test_manyassign.b - Test many array assignments in SUB
** This tests Bug #3: Too many array assignments in EXTERNAL SUB crash
** Previously crashed with 5+ assignments, worked with 4
*}

DIM _tags&(20)
SHORTINT _count

SUB MUIInit EXTERNAL
    LIBRARY "muimaster.library"
END SUB

SUB MUICleanup EXTERNAL
    LIBRARY CLOSE "muimaster.library"
END SUB

SUB MUIBuildTags(LONGINT val1, LONGINT val2, LONGINT val3, LONGINT val4, LONGINT val5, LONGINT val6, LONGINT val7) EXTERNAL
    SHARED _tags&, _count

    { This SUB has 7 array assignments - previously crashed at 5+ }
    _tags&(0) = val1
    _tags&(1) = val2
    _tags&(2) = val3
    _tags&(3) = val4
    _tags&(4) = val5
    _tags&(5) = val6
    _tags&(6) = val7

    _count = 7
END SUB

SUB LONGINT MUIGetTag(SHORTINT idx) EXTERNAL
    SHARED _tags&
    MUIGetTag = _tags&(idx)
END SUB

SUB SHORTINT MUIGetCount EXTERNAL
    SHARED _count
    MUIGetCount = _count
END SUB
