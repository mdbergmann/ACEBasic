REM Test TYPECASE type narrowing

CLASS Animal
    LONGINT legs
END CLASS

CLASS Dog EXTENDS Animal
    LONGINT goodboy
END CLASS

SUB LONGINT CheckDog(Animal a)
  LONGINT result
  result = 0
  TYPECASE a
    CASE Dog
      result = a->goodboy
    CASE ELSE
      result = a->legs
  END TYPECASE
  CheckDog = result
END SUB

DECLARE CLASS Dog d
d->legs = 4
d->goodboy = 1

DECLARE CLASS Animal a
a->legs = 99

ASSERT CheckDog(d) = 1, "Dog narrowed: should read goodboy=1"
ASSERT CheckDog(a) = 99, "Animal ELSE: should read legs=99"

PRINT "typecase_narrow: ALL PASSED"
