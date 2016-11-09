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
	Get-PSCallStack # This dumps callstack of caller, Callstack of exception in $_ not always usable
	Write-Output $_ # will be red
	$host.ui.RawUI.ForegroundColor = $t
   
	
	# Exit should only be called on topmost scripts (not sub scripts) and never in ISE
	if( $host.name -notmatch 'ISE' -and $MyInvocation.ScriptName -eq "" )
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

Set ```$ErrorActionPreference = "stop"``` to ensure errors do not continue and can actually be trapped with ```trap``` statement above exiting with 1

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

