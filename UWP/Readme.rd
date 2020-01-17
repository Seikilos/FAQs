UWP apps cannot be uninstalled from other user
=======================
See http://techgenix.com/sysprep-problems-app-x-packages/ and use the two provided scripts. (Execute as admin)

There is sometimes an issue that prevents devs to uninstall apps installed by other users. 
Restoring the app registry is therefore a possible alternative

Store the Fix-Sysprep.ps1 as C:\Powershell\Fix-Sysprep.ps1
and execute this line

```bat
schtasks /create /RU "SYSTEM" /NP /SC ONSTART /TN Reset-AppX /TR "powershell C:\Powershell\Fix-Sysprep.ps1" /F
```
