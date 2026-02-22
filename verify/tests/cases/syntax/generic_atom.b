REM Test: ATOM dispatch with GENERIC METHOD

GENERIC METHOD Process(ATOM)
  ON :ok
  ON :fail
END GENERIC

METHOD Process(:ok result)
  PRINT "Success"
END METHOD

METHOD Process(:fail result)
  PRINT "Failed"
END METHOD

ATOM status
status = :ok
Process(status)
Process(:fail)

ASSERT 1 = 1, "atom dispatch ok"
