' Assert.b - Demonstrates the ASSERT statement for debugging and validation
'
' ASSERT checks a condition and halts the program if it's false.
' This is useful for catching bugs early and validating assumptions.

' ============================================================================
' Stack data structure with ASSERT-based validation
' ============================================================================

CONST STACK_SIZE = 10

DIM stackData(STACK_SIZE)
stackTop = 0

' Push a value onto the stack
SUB StackPush(SHORTINT value)
  SHARED stackData(), stackTop

  ' Validate: stack must not be full
  ASSERT stackTop < STACK_SIZE, "Stack overflow - cannot push"

  stackData(stackTop) = value
  stackTop = stackTop + 1
END SUB

' Pop a value from the stack
FUNCTION StackPop
  SHARED stackData(), stackTop

  ' Validate: stack must not be empty
  ASSERT stackTop > 0, "Stack underflow - cannot pop from empty stack"

  stackTop = stackTop - 1
  StackPop = stackData(stackTop)
END FUNCTION

' Return the current stack size
FUNCTION StackSize
  SHARED stackTop
  StackSize = stackTop
END FUNCTION

' ============================================================================
' Mathematical functions with precondition checking
' ============================================================================

' Calculate factorial (n must be non-negative)
FUNCTION Factorial(SHORTINT n)
  ASSERT n >= 0, "Factorial requires non-negative input"

  IF n <= 1 THEN
    Factorial = 1
  ELSE
    result& = 1
    FOR i = 2 TO n
      result& = result& * i
    NEXT i
    Factorial = result&
  END IF
END FUNCTION

' Integer division (divisor must not be zero)
FUNCTION SafeDivide(SHORTINT dividend, SHORTINT divisor)
  ASSERT divisor <> 0, "Division by zero"
  SafeDivide = dividend / divisor
END FUNCTION

' ============================================================================
' Main program - demonstrate ASSERT usage
' ============================================================================

PRINT "ASSERT Statement Demonstration"
PRINT "=============================="
PRINT

' Test 1: Stack operations with validation
PRINT "Test 1: Stack operations"
PRINT "------------------------"

StackPush(10)
StackPush(20)
StackPush(30)

PRINT "Pushed 10, 20, 30 onto stack"
PRINT "Stack size:"; StackSize

value = StackPop
PRINT "Popped:"; value
ASSERT value = 30, "Expected 30 from stack"

value = StackPop
PRINT "Popped:"; value
ASSERT value = 20, "Expected 20 from stack"

PRINT "Stack operations validated successfully"
PRINT

' Test 2: Mathematical functions
PRINT "Test 2: Mathematical functions"
PRINT "------------------------------"

result = Factorial(5)
PRINT "Factorial(5) ="; result
ASSERT result = 120, "Factorial calculation error"

result = Factorial(0)
PRINT "Factorial(0) ="; result
ASSERT result = 1, "Factorial(0) should be 1"

result = SafeDivide(100, 5)
PRINT "100 / 5 ="; result
ASSERT result = 20, "Division result incorrect"

PRINT "Mathematical functions validated successfully"
PRINT

' Test 3: Postcondition checking
PRINT "Test 3: Postcondition validation"
PRINT "--------------------------------"

' Simulate some computation
x = 10
y = 20
sum = x + y

' Verify the result is what we expect
ASSERT sum = 30, "Sum calculation failed"
ASSERT sum > 0, "Sum should be positive"

PRINT "x ="; x; ", y ="; y; ", sum ="; sum
PRINT "Postconditions verified"
PRINT

' Test 4: Loop invariant checking
PRINT "Test 4: Loop invariant checking"
PRINT "-------------------------------"

total = 0
FOR i = 1 TO 5
  oldTotal = total
  total = total + i

  ' Invariant: total should always increase
  ASSERT total > oldTotal, "Loop invariant violated"
NEXT i

PRINT "Sum of 1..5 ="; total
ASSERT total = 15, "Expected sum to be 15"
PRINT "Loop invariant held throughout execution"
PRINT

' All tests passed
PRINT "=============================="
PRINT "All assertions passed!"
PRINT "Program completed successfully."

END
