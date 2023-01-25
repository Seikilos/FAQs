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

```
net user USER_NAME /domain
```

or

```ps1
Import-Module ActiveDirectory
Get-aduser -identity THE_USER -properties * | select accountexpirationdate, accountexpires, accountlockouttime, badlogoncount, padpwdcount, lastbadpasswordattempt, lastlogondate, lockedout, passwordexpired, passwordlastset, pwdlastset | format-list
```

Find Environment Variables a program access
========================
If you don't know which `env` variables a process access, you need to use `WinDBG` in order to debug on them. AFAIK ProcessMonitor does not have events for accessing environment variables. If you need to know what the values for certain environment variables are, you can easily use `Process Explorer` and `Process Monitor`.

*Hint*: You need to know the C/C++ low level function that is called. For environment variables it is `Kernel32.dll!GetEnvironmentVariable*`. Check [MSDN](https://learn.microsoft.com/en-US/windows/win32/api/winbase/nf-winbase-getenvironmentvariable) for this. Gotcha: The implementation is actually in KERNELBASE but we don't know this yet.

If you are unsure, create a c++ console application that is using the code in question and use WinDBG to dig into it.

* Run WinDBG
* Select `Open Executable`
* Hit <kbd>F5</kbd> or type `g` untill `No runnable debuggees error in 'g'` occurs. This means the programm is fully executed. All modules should have been loaded
* Type `lm` to see which modules are loaded. For `GetEnvironmentVariable` you see that `KERNEL32` is deferred loaded but `KERNELBASE` is directly loaded.
* Search for the function you wan't to break on. We assumed `KERNEL32`:
    ```
    x /D /f KERNEL32!GetEnvironmentVariable*
    00000000`75dd8990 KERNEL32!GetEnvironmentVariableAStub (_GetEnvironmentVariableAStub@12)
    00000000`75de0f30 KERNEL32!GetEnvironmentVariableWStub (_GetEnvironmentVariableWStub@12)
    ```
    * These are only stubs and not the functions we look for
* Search for the function name in all modules:
    ```
    x /D /f *!GetEnvironmentVariable*
    00000000`75dd8990 KERNEL32!GetEnvironmentVariableAStub (_GetEnvironmentVariableAStub@12)
    00000000`75de0f30 KERNEL32!GetEnvironmentVariableWStub (_GetEnvironmentVariableWStub@12)
    00000000`76bfaef0 KERNELBASE!GetEnvironmentVariableA (void)
    00000000`76be2580 KERNELBASE!GetEnvironmentVariableW (_GetEnvironmentVariableW@12)
    ```
    * `KERNELBASE` appears to be the relevant module
* We need to set the break point for this function but when starting up the program but we need an unresolved breakpoint because the module is not yet loaded
* `Debug > Restart` the application and wait for the first automatic break point. (WinDBG might hang here sometimes)
* `lm` does not show `KERNELBASE`
* Set a break point (no wildcards) for the functions via
  * `bu KERNELBASE!GetEnvironmentVariableA`
  * `bu KERNELBASE!GetEnvironmentVariableW`
* Hit <kdb>F5</kdb> and keep pressing it untill the command window shows the breakpoint of interest: 
    ```
    Breakpoint 1 hit
    KERNELBASE!GetEnvironmentVariableW:
    76be2580 8bff            mov     edi,edi
    ```
* From the [documentation page](https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-getenvironmentvariablew) we know that the first parameter points to the name of the environment variable (of provided)
   ```cpp
   DWORD GetEnvironmentVariable(
    [in, optional]  LPCTSTR lpName,
    [out, optional] LPTSTR  lpBuffer,
    [in]            DWORD   nSize
    );
   ```
* When breakpoint hit, type `kb` to show the call stack and the passed arguments:
   ```
    0:000:x86> kb
    # ChildEBP RetAddr      Args to Child              
    00 0113f9dc 003012c3     00303248 012a1e40 0000ffff KERNELBASE!GetEnvironmentVariableW
    01 0113fa1c 00302228     00000001 01297f98 0129d6f0 ConsoleCpp!main+0xa3 [...\ConsoleCpp.cpp @ 20] 
   ```
* The first argument is the name and it points to `0x00303248`
* Display this address using unicode characters via `du 303248`
    ```
    0:000:x86> du 303248
    00303248  "Foobar"
    ```
* *The quick and automated way* is using the offset of the stack pointer: `du poi(@esp+4)`. Or if this fails `du rbx`. (**Important**: For the new debugger model you need the WinDBG from App Store)
* If the string is from CLR, execute `!dso` command and look in the stack to see strings used.

Now you have the string
