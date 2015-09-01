NSIS Hints
==============

* Calling xcopy from NSIS 3.0b2 currently always fails, use robocopy instead.

Obtain return value from !system call
----------------

```
!system 'exit /B 1' RESULT

!if ${RESULT} == 1
	!error "RESULT was ${RESULT}"
!endif
```

Check if a path exist during compile time (windows)
---------------------

This relies on operating system calls but does not create temp files etc

````
!system 'IF EXIST "${SOURCE}" (exit /b 0) ELSE (exit /b 1)' RESULT

!if ${RESULT} == 1
	!error "${SOURCE} not valid, make sure it is a valid directory"
!endif```
