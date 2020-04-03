UWP apps cannot be uninstalled from other user
=======================
See http://techgenix.com/sysprep-problems-app-x-packages/ and use the provided script.

There is sometimes an issue that prevents devs to uninstall apps installed by other users. 
Restoring the app registry is therefore a possible solution to messing with `Get-AppxPackage -AllUsers | Remove-AppPackage -AllUsers` combinations which fail in certain scenarios

Download Fix-Sysprep.ps1 to C:\Powershell\Fix-Sysprep.ps1
and execute this line *as admin*

```bat
schtasks /create /RU "SYSTEM" /NP /SC ONSTART /TN Reset-AppX /TR "powershell C:\Powershell\Fix-Sysprep.ps1" /F
```

NetNative compiling ILC issues
===============================

32 bit nutc compiler sometimes fails, without looking at diagnostic output of msbuild there is no really helpful error. Force it to 64 bit

```xml
<Use64BitCompiler>true</Use64BitCompiler>

<!-- Unverified -->
<ShortcutGenericAnalysis>true</ShortcutGenericAnalysis>
<SingleThreadNUTC>true</SingleThreadNUTC> <!-- This might slow things down a lot -->

```
