Windows tricks
====================

Go to old Control setting
-------------------
<kbd>Win + R</kbd>, type `control`, <kbd>Enter</kbd>

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

Also add (as String or REG_SZ) or set the value of **Auto** to **0** in

`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug`

Tail Logfile
---------------------
`Get-Content ./log.log -Wait -Tail 10`

Detect heap corruption early
---------------------
See https://randomascii.wordpress.com/2011/12/07/increased-reliability-through-more-crashes/

The gist: Enable Pageheap via App Verifier, where each allocation gets own 4kb page and next page will be unmapped causing an access violation. Various issues can be detected (e.g. _buffer overrun_ on writing next page, etc.).


RDP issues or dns record not propertly resolved
------------------
When RDP to a hostname does not work, or `nslookup The_name` does not resolve the name. Try this on the **destination** machine (second command needs elevation):

```
ipconfig /flushdns
ipconfig /registerdns
```
The first command might be necessary on both sides but `/registerdns` updates or creates the DNS record on the active directory to which it is connected which should cause all other machines to be able to reach it.

## Windows user groups
----------------------------
Display all user groups available:

```ps
# Console
gcim Win32_Account | ft Name, SID # ft = FeatureTable

# DataGrid
gcim Win32_Account | select Name, SID | ogv # ogv= Out-GridView
```

See https://docs.microsoft.com/en-us/windows/win32/secauthz/well-known-sids

Windows paths longer than 260 chars
-------------------

Prefix `\\?\` to switch to unicode, this allows for much longer path names (does not support `.`, `..` or `/`)

See [StackOverflow](https://stackoverflow.com/a/21194605) and [Microsoft](https://docs.microsoft.com/en-US/windows/win32/fileio/naming-a-file?redirectedfrom=MSDN)


# Windows terminates RDP session after certain time
Check registry path `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\MaxDisconnectionTime`. 
Also see [admx.help](https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_SESSIONS_Disconnected_Timeout_2&Language=de-de)


Measure Performance (built-in)
---------------------------
See [Measure-Performance](Measure-Performance.ps1) Script. However `winsat` does not work with terminal services like RDP sessions.

Disable combining of task bar items
---------------------------
Especially useful if windows is not yet activated, so no UI is available

Powersehll admin
```ps1
New-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name "TaskbarGlomLevel" -value "2" -PropertyType DWORD
```
Go to `taskmgr`, select `explorer.exe` and execute `restart` command to apply.

Install .net Framework 3.5 from ISO via DISM
===================================
`DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:d:\sources\sxs`

Check if Domain Account is locked (no admin permissions)
=====================================
Open a powershell on a domain attached machine and type

```ps1
Import-Module ActiveDirectory
Get-aduser -identity THE_USER -properties * | select accountexpirationdate, accountexpires, accountlockouttime, badlogoncount, padpwdcount, lastbadpasswordattempt, lastlogondate, lockedout, passwordexpired, passwordlastset, pwdlastset | format-list
```

