Sharepoint issues
===============

WSS_Logging consumes a lot of space
--------------------------------
* Go to the sql server, visit the WSS_Logging Database
* Right click, select Reports > Disk Usage by Top Tables

Check which Table consumes a lot of memory. Visit this table read events and see if it is clear what causes it. If unclear, you can issue a clear of the table which has a task group
equivalent.
By this you only purge the logs. If there was a hickup this will be ok, if the source still misbehaves, you will have to properly fix it

Go to sharepoint server, open **sharepoint** powershell
* Execute `Get-SPUsageDefinition` and look for names similar to a table
* Disable the entry by e.g. `Set-SPUsageDefinition -Identity "Task Use" -Enable:0`
* Check again a report to see if WSS_Logging is smaller now
* Re-Enable the identity
* Monitor regularly whether the size increases again. If yes, fix the source.

Powershell addins not loaded
-------------------------------------
If you cannot execute sharepoint related commands, load the sharepoint powershell integration

Call 
```ps1
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil /LogToConsole=true C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Microsoft.SharePoint.PowerShell\v4.0_15.0.0.0__71e9bce111e9429c\Microsoft.SharePoint.Powershell.dll
```
