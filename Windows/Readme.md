Windows tricks
====================

Remote Desktop leaves machine in a locked state requiring user to enter password. To avoid that execute
`tscon 1 /dest:console` as admin in a **powershell** window (not cmd.exe). 
But since session is not always *1*, you can combine it with another powershell command to obtain current session.
Note: Admin permission is required here
```
tscon (Get-Process -PID $pid).SessionID /dest:console
```
