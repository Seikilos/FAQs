LoadLibrary returned 127 The specified procedure could not be found.
===============
Explanation: http://stackoverflow.com/a/2603386/2416394

Debugging LoadLibrary issues: http://blogs.msdn.com/b/junfeng/archive/2006/11/20/debugging-loadlibrary-failures.aspx

Gist out of it:

* Call gflags with +sls: `gflags.exe -i your-app-without-path.exe +sls`
* Star application with attached debugger. DevEnv or WinDBG
* Look for string "failed" in loader snaps
* Remember to call gflags with -sls
