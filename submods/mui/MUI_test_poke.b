{*
** MUI_test_poke.b - Test POKE in module
** This tests Bug #2: POKE statement crashes in EXTERNAL module
*}

DIM _buffer%(100)
SHORTINT _index

SUB MUIInit EXTERNAL
    SHARED _buffer%, _index
    ADDRESS addr

    _index = 0

    { Get address of buffer and POKE into it }
    addr = VARPTR(_buffer%(0))
    POKE addr, 65      { Write 'A' to first byte }
    POKE addr+1, 66    { Write 'B' to second byte }
    POKE addr+2, 0     { Null terminator }

    LIBRARY "muimaster.library"
END SUB

SUB MUICleanup EXTERNAL
    LIBRARY CLOSE "muimaster.library"
END SUB

SUB ADDRESS MUIGetBuffer EXTERNAL
    SHARED _buffer%
    MUIGetBuffer = VARPTR(_buffer%(0))
END SUB
