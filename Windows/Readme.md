Windows tricks
====================

Remote Desktop exit
-------------------

Remote Desktop leaves machine in a locked state requiring user to enter password. To avoid that execute
`tscon 1 /dest:console` as admin in a **powershell** window (not cmd.exe). 
But since session is not always *1*, you can combine it with another powershell command to obtain current session.
Note: Admin permission is required here
```
tscon (Get-Process -PID $pid).SessionID /dest:console
```

Disable debugger on windows (Disable Windows Error Reporting)
----------------------

In Scenarios where a crash is detected by some means it is possible to disable the windows error reporting by settings the reg key (if it exist!) to **1**

`HKEY_CURRENT_USER\Software\ Microsoft\Windows\Windows Error Reporting\DontShowUI`
