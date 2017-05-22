Windows tricks
====================

Remote Desktop leaves machine in a locked state requiring user to enter password. To avoid that. Execute
`tscon 1 /dest:console` as admin. But since session is not always 1, you can combine it with powershell to obtain current session.
Note: Must still be admin
```
tscon (Get-Process -PID $pid).SessionID /dest:console
```
