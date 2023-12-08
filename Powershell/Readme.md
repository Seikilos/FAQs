Windows Credential-Manager without CredentialManager Module
=========================

```powershell
# List all credential stores
. vaultcmd /list

# List logins in specific credential store
. vaultcmd.exe /listcreds:"Windows-Anmeldeinformationen"

# find required credential types 
.  vaultcmd.exe /listschema

# register a new domain login for server
. vaultcmd.exe /addcreds:"Windows-Anmeldeinformationen" /credtype:"{3E0E35BE-1B77-43E7-B873-AED901B6275B}" /identity:TestCred /authenticator:Test /resource:Server /savedBy:Test
```

Life-Hack to use vaultcmd.exe with powershells secure strings from `Get-Credential`

```powershell
$pwd = (Get-Credential).GetNetworkCredential().Password
```

Use PSGallery behind Authenticating Proxy
======================
```ps1
[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('http://<address>:<port>')
[system.net.webrequest]::defaultwebproxy.credentials = (Get-Credential)
[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true

# Then install ...
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name CredentialManager -Force
```


Exit code not working with Parameter-Attribute
========
Currently no explanation why PS breaks when using parameters in the file header to define script parameters.

This code returns an exit code of **0** (e.g. `echo %ERRORLEVEL%`)

```powershell
Param(
  [Parameter()]$a
)
exit 9999
```

If you remove the `[Parameter...]` block you will get the proper exit code.
To workaround this behaviour replace **exit** with [[Environment]::Exit(...)](https://msdn.microsoft.com/de-de/library/system.environment.exit(v=vs.110).aspx)

```powershell
Param(
  [Parameter()]$a
)
[Environment]::Exit(9999)
```

Parameters
========

Ask for values
-------------
```powershell
param (
    [Parameter(Mandatory=$true)][string] $Name,
    [Parameter(Mandatory=$true)][int] $Number
)

echo ("Name {0}, Number {1}" -f $Name, $Number)
```


Throw on missing parameters
-------------------
```powershell
param (
    [Parameter()][string] $Name = $(throw "Name missing"),
    [Parameter()][int] $Number = $(throw "Number missing")
)

echo ("Name {0}, Number {1}" -f $Name, $Number)
```


Error handling 
========

Edit: As of now the entire handling errors is a mess in ps. A trap does properly work, even if calling a script from within a script. But if the result of the script is stored in a variable, all output is redirected to it. You will get an exit code 1 but not the message causing the problem.

Use trap command to catch all exceptions (https://technet.microsoft.com/en-us/library/hh847742.aspx)

**Important**: The following code does **not** work for Win 7 and PS Version 3 when dealing with syntax errors. However it seems to [work](http://stackoverflow.com/questions/40507389/cannot-catch-or-trap-syntax-error?noredirect=1#comment68266103_40507389) on Win 10 PS 5.1 

Example: (Place on top):

```powershell
$ErrorActionPreference = "stop"
trap [Exception] {
	echo "Trap encountered. Exiting with 1. See errors below"
	$t = $host.ui.RawUI.ForegroundColor
	$host.ui.RawUI.ForegroundColor = "Red"
	Write-Host(Get-PSCallStack) # This dumps callstack of caller, Callstack of exception in $_ not always usable
	Write-Output $_ # will be red
	$host.ui.RawUI.ForegroundColor = $t
   
	
	# Exit should only be called on topmost scripts (not sub scripts) and never in ISE or VS Code
	if( $host.name -notmatch 'ISE' -and $MyInvocation.ScriptName -eq ""  -and $host.name -notmatch 'Visual Studio Code')
	{ 
		[Environment]::Exit(1)
	}
}

```

Read below for explanation of ```$ErrorActionPreference```

*Note*: The trap command can be placed anywhere but ```$ErrorActionPreference``` should be placed as early as possible.

**Important on Syntax Errors and Invalid Arguments**

Syntax errors, invalid arguments etc will all cause powershell to exit with code **0**!

See https://social.technet.microsoft.com/Forums/windowsserver/en-US/dd56862f-a0c4-4398-a2e8-689facdb31a2/trycatch-block-not-catching-error-from-addadgroupmember-cmdlet and https://technet.microsoft.com/en-us/library/hh847796.aspx

Set ```$ErrorActionPreference = "stop"``` to ensure errors do not continue and can actually be trapped with ```trap``` statement above exiting with 1. Be aware that calling missing functions will trigger the trap but malformed code (e.g. missing braces) will exit powershell without trapping and returning _0_ in older powershell versions.

*Why using `Write-Output` with overhead instead of `Write-Error`?*

Prior versions had `Write-Error` but `$ErrorActionPreference = "stop"` makes it a terminating error therefore ignoring the next exit code and returning with **0**, which again breaks behaviour of exit codes on errors.


Starting scripts with *&* throws errors
=========

Calling script slike 

```powershell
& script.ps1 --dosomething
```


may throw messages like positional parameter `--dosomething` not found (even if it is defined in a `params` block), usually with an `PositionalParameterNotFound` exception. Calling this via `powershell -F` does work but is **massively** slower than `&`. 

To fix the `&` version, use *one* dash for `-dosomething` instead of two.


Starting scripts with *&* and redirecting error fails on first output
=========


Using 
```powershell
& program 2>d:\error.txt | Out-Null
```
will wait for application to complete but will directly abort execution when anything is written to error stream. This is bad when multiple lines are expected because although multiple lines might be written to the stream, powershell aborts execution apparently when it detects a new-line.

Use `Start-Process` for that: 
```powershell
$proc = Start-Process -FilePath "program" -ArgumentList @("a", "b") -NoNewWindow -Wait -RedirectStandardError $strErrFile -PassThru
echo ("Last exit code: "+$proc.ExitCode)
```
PassThru returns the process object and `ExitCode` can be used to examine result.



Param with string array [string[]] not working properly
=========

If a script param block defines something like `[string[]]$var` it might not properly work when calling powershell via -file argument:

`powershell -f file.ps1 "a", "b", 1` won't really have $var as an array rather emit an error that "b" cannot be bind, etc. This might be solved when using 
`powershell -command 'file.ps1 "a", "b", 1'` but this also has drawbacks: Escaping must be done properly because the entire command is a string and a different behaviour in exit codes for the command version (see https://stackoverflow.com/questions/18410956/powershell-commands-exit-code-is-not-the-same-as-a-scripts-exit-code)

A possible workaround is using the remaining values from arguments by adding `[Parameter(ValueFromRemainingArguments=$true)]` to the parameter, then this would work:

```powershell
powershell -f file.ps1 a b c
```

**Note:** The array arguments are now separated by whitespace and has a negative side-effect: Named arguments do no longer work and positional arguments must be used.


Starting script with powershell -f is slow (Use NoProfile)
=========

See http://www.powertheshell.com/bp_noprofile/

Always start powershell without scripts loaded in the current profile!
```powershell
powershell.exe –NoProfile –File script.ps1
```


Quickly inspect members of objects
=======
Use `Get-Member` on an object:
```powershell
echo $obj | gm # or Get-Member
```


Find double entries in files via powershell
=======
```powershell
Get-Content <FILE> | Group-Object | Where-Object { $_.Count -gt 1 } | Select -ExpandProperty Name
```

Creating new objects in Pipe
===============
`Select-Object` can create objects easily.

Note: `n` and `e` are shortcuts for `Name` and `Expression` for each property.

```powershell
Get-Content -Encoding "UTF8" $file | Select-Object @{ n='line';e={$_}}, @{n='match'; e={$_ -replace "(.*_)(\d+)\.mp4", '$2'} }
```

Select statement similar to LINQ Select
================
Use `Select-Object` with `-ExpandProperty` to remove the Property name.

```powershell
$list | Select-Object Fullname # Creates a list, when dumped to string, having a leading "Fullname" in the output

$list | Select-Object -ExpandProperty Fullname # fixes this
```

Credentials
===========
Asking for credentials
----------------
```powershell
$creds = Get-Credential

$user = $creds.UserName
$password = $creds.Password

$myCreds=New-Object System.Management.Automation.PSCredential -ArgumentList $user,$password
# Now use this cred object like
Invoke-WebRequest $url  -Proxy 'http://proxy:port' -ProxyCredential $myCreds
```
Store credentials in code (not secure)
------------------
Sometimes useful.
*Important: Delete powershell history afterwards*

Open new powershell console
```powershell
# Store the output string of this:
"Password" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString

# Then clear history (and close console)
del (Get-PSReadlineOption).HistorySavePath
```

The copied secure string (not that secure) can be used as
```powershell
$password = "634cead364368c6a40a20..."  | ConvertTo-SecureString
```

WebRequest for TLS resources
==========
Two things must be used when calling `Invoke-WebRequest` for SSL/TLS resources, the TLS1.2 mode and `-UseBasicParsing`:
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest "url" -UseBasicParsing
```

Find version numbers for a given assembly
==============

```powershell
 Get-ChildItem .\file.dll | Select-Object Name,@{n='FileVersion';e={$_.VersionInfo.FileVersion}},@{n='AssemblyVersion';e={[Reflection.AssemblyName]::GetAssemblyName($_.FullName).Version}}
```


UNC Path not available after it was available a moment ago
=================
For some reasons UNC paths may be inaccessible after they were accessed a moment ago.
Await the path to become ready

```powershell
function Wait-For-Path-Ready($path) {
    echo "Waiting for '$path' be ready"
    $tries = 100
    $waitInMs = 100
    $success = $false

    for ($i = 0; $i -le $tries; ++$i) {
        try {

            Get-ChildItem $path -ErrorAction Stop | Out-Null
            $success = $true
            break;

        }
        catch {
            echo "Path not ready, retrying"
            Start-Sleep -Milliseconds $waitInMs
        }
    }
 
    if( $success )
    {
        echo "Path is ready"
    }
    else {
        throw "$path failed to become ready after $($tries*$waitInMs / 1000) seconds"
    }

}

```

xpath query without namespaces
====================
Somtimes you want query an xpath without qualifying namespaces.

```powershell
# Namespace aware, won't return nodes, when some parent uses xmlns="..."
([xml]Get-Content some.xml -Raw).SelectNodes("//ProjectReference/PrivateAssets");

# Namespace agnostic
([xml]Get-Content some.xml -Raw).SelectNodes("//*[local-name() = 'ProjectReference']/*[local-name() = 'PrivateAssets']");

```

Group Files by date and display grouped size of them
=============================
```powershell
get-Childitem PATH | Group {$_.LastWriteTime.ToString("yyyy-MM-dd")} | Sort Name | Foreach-Object {Write-Host ("Date: {0}, Count: {1}, Size in GB: {2}" -f $_.Name, $_.Count, (($_.Group | Measure-Object -Sum Length).Sum /1GB))}
```

Result looks like
```
Date: 2022-01-08, Count: 648, Size in GB: 53,5989532470703
Date: 2022-01-09, Count: 464, Size in GB: 1299,17489814758
Date: 2022-01-10, Count: 747, Size in GB: 88,04141664505
Date: 2022-01-11, Count: 741, Size in GB: 140,498733043671
Date: 2022-01-12, Count: 768, Size in GB: 179,834815979004
Date: 2022-01-13, Count: 760, Size in GB: 173,782751083374
Date: 2022-01-14, Count: 328, Size in GB: 191,552196502686
```

Get size of folders
=========================
```ps1
 Get-Childitem . | ForEach-Object { Write-Host( "{0,-30}`tSize {1:0.##} GB" -f $_, (( Get-ChildItem $_ -Recurse | Measure-Object -Sum Length).Sum /1GB)) }

```

Reload PATH Variable inside script
======================================
```ps1
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
# Here new path variable is available to find new binaries
```

Zipping fast with 7zip
======================================
`Compress-Archive` has very poor performance storing large data into zip. This is a faster wrapper

```ps1
function Compress-7Zip(
    [Parameter(Mandatory = $true, HelpMessage="Base folder of source. Up to this directory will not be included in the zip. See https://sevenzip.osdn.jp/chm/cmdline/commands/add.htm")]
    [string]
    $RootSourceDir,
    [Parameter(Mandatory = $true, HelpMessage="See https://sevenzip.osdn.jp/chm/cmdline/switches/include.htm")]
    [string]
    $IncludePattern,
    [Parameter(Mandatory = $false, HelpMessage="See https://sevenzip.osdn.jp/chm/cmdline/switches/exclude.htm")]
    [string]
    $ExcludePattern,
    [Parameter(Mandatory = $true)]
    [string]
    $OutFile
)
{
    # Set this part correctly
    $7zip = "$PSScriptRoot\3rdParty\7Zip\7z.exe"

    if(!(Test-Path $7zip))
    {
        throw "Did not find 7zip at '$7zip'"
    }

    if(!(Test-Path $RootSourceDir))
    {
        throw "Source directory '$RootSourceDir' does not exist."
    }

    if(Test-Path $OutFile)
    {
        Remove-Item -Force $OutFile | Out-Null
    }

    Push-Location $RootSourceDir
    
    try
    {
        $argString = "a `"$OutFile`" $includePattern"

        if($ExcludePattern)
        {
            $argString += " -x!$ExcludePattern"
        }

        $processOptions = @{
            FilePath = $7zip
            NoNewWindow = $true
            UseNewEnvironment = $true
            PassThru = $true
            Wait = $true
            ArgumentList = $argString
        }

        Write-Warning("Aborting powershell does NOT stop 7zip. You have to kill the 7zip process instead.")
        $process = Start-Process @processOptions
        if ($process.ExitCode -ne 0)
        {
            Remove-Item -Force $OutFile | Out-Null
            throw "7zip failed with exit code '$($process.ExitCode)'."
        }

    } finally {
        Pop-Location
    }

}
```

Aliases in powershell
============================
* Open Powershell, type `notepad $PROFILE`
* Add a function (New-Alias) won't work for parameters
```ps1
function kubectl { 
  minikube kubectl -- @args
}
```
* Note: @args splats the arguments, do not declare them in the parameter list, as this will introduces issues.
* Restart powershell session.


Run powershell code in scheduled task that deletes itself
============================
*Hint*: Use `-noexit` Parameter during tests to prevent closing the powershell window

*Hint 2*: The Script Block after `-Command` must use the ampersand `&`!

```powershell
$jobName = "Reboot"
$pathToPowershell = "$PSHome\powershell.exe"

$run = (Get-Date).AddMinutes(1)
Register-ScheduledTask -TaskName "$jobName" -InputObject (
  (
	New-ScheduledTask -Action (
	  New-ScheduledTaskAction -Execute "$pathToPowershell" -Argument (
		"-Command &{" + 
		". shutdown /g /t 10 /f /c \""'Reboot pending' detected\"" /d p:2:3"+
		"}"
	  )
	) -Trigger (
	  New-ScheduledTaskTrigger -Once -At ($run.TimeOfDay.ToString("hh\:mm")) # As a "TimeOfDay" to get 24Hr format
	) -Settings (
	  New-ScheduledTaskSettingsSet  -DeleteExpiredTaskAfter 00:00:01 # Delete one second after trigger expires
	) 
  ) | %{ $_.Triggers[0].EndBoundary = $run.AddMinutes(2).ToString('s') ; $_ } # Run through a pipe to set the end boundary of the trigger
)

Get-ScheduledTask | Where {$_.TaskName.Contains($jobName)}
```


Encoding, Umlauts, etc
================================
If your powershell file does not use proper encoding, this will break:
```ps1
Write-Host("öäü");
# > Ã¶Ã¤Ã¼
```

Solution: Ensure the ps1 file has `UTF8 with BOM` encoding.
