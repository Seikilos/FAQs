Error handling 
========

Use trap command to catch all exceptions (https://technet.microsoft.com/en-us/library/hh847742.aspx)

Example: (Place anywhere):

```powershell
$ErrorActionPreference = "stop"
trap [Exception] {
    echo "Trap encountered. Exiting with 1. See errors below"
    echo $_
    exit 1
}
```

Read below for explanation of ```$ErrorActionPreference```

**Important on Syntax Errors and Invalid Arguments**

Syntax errors, invalid arguments etc will all cause powershell to exit with code **0**!

See https://social.technet.microsoft.com/Forums/windowsserver/en-US/dd56862f-a0c4-4398-a2e8-689facdb31a2/trycatch-block-not-catching-error-from-addadgroupmember-cmdlet and https://technet.microsoft.com/en-us/library/hh847796.aspx

Set ```$ErrorActionPreference = "stop"``` to ensure errors do not continue and can actually be trapped with ```trap``` statement above exiting with 1
