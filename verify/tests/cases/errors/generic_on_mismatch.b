REM Error test: wrong ON clause arity (error 96)

CLASS Foo
    LONGINT x
END CLASS

GENERIC METHOD BadGen(CLASS, CLASS)
    ON Foo
END GENERIC
