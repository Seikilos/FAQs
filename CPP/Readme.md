LoadLibrary returned 127 The specified procedure could not be found.
===============
Explanation: http://stackoverflow.com/a/2603386/2416394

Debugging LoadLibrary issues: http://blogs.msdn.com/b/junfeng/archive/2006/11/20/debugging-loadlibrary-failures.aspx

Gist out of it:

* Call gflags with +sls: `gflags.exe -i your-app-without-path.exe +sls`
* Star application with attached debugger. DevEnv or WinDBG
* Look for string "failed" in loader snaps
* Remember to call gflags with -sls

Dump contents of LIB file / detect mismatching lib<=>dll
==========================

See http://stackoverflow.com/questions/488809/tools-for-inspecting-lib-files
* `dumpbin.exe -headers File.lib > file.headers`
* Locate function
* Load dll in Dependency Walker
* Enable/Disable Function decoration
* Search for function
* => If not in DLL but in lib, most likey mismatch between lib and dll
