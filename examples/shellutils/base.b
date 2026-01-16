deflng x

SUB usage
  print "usage: base <decimal number>"
  stop
END SUB

if argcount<>1 then
  usage
else
  if arg$(1)="?" then 
    usage
  else
    x=val(arg$(1))
    print "    Decimal:";x
    print "Hexadecimal: ";hex$(x)
    print "      Octal: ";oct$(x)
    print "     Binary: ";bin$(x)
  end if
end if
