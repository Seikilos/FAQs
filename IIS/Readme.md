# Enable better error output in the browser (e.g. for HTTP 500)
* Go to IIS Manager
* Select the site
* Select Error Pages
* On the right `Edit Feature Settings`
* Set to `Detailed errors`


# Executing Word on a server impersonating another user
* Most important: Don't do it. Microsoft says don't do it, it is a not supported use case
* You won't get all error messages
* You will get permission issues
* You will get all sorts of quirky behaviour
* You will never see the UI to see if it failed because impersonate execution from say svhost has no UI session, where you actually could see it

## I understand and ignore this
If you chose to ignore this. Ok. See [SO](https://stackoverflow.com/a/1680214/2416394) 

1. Be admin
Impersonating user **must** be part of Admin group. Otherwise automation objects will return null

2. Make your Desktop
Create Desktop user vor the service account, you are running. This is done via
```
mkdir C:\Windows\System32\config\systemprofile\Desktop
mkdir C:\Windows\SysWOW64\config\systemprofile\Desktop
```
