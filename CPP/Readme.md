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

Symbol not found during linker step
======================

If proper .lib was included, perform `dumpbin` step as above, search for method: If not available, it is not exported, if it is avaialble check the `Machine` entry whether the architecture matches (x64 or x86)

Display layout of a class
==============
Undocumented compiler switches displaying the layout and offset of a class:

```
/d1reportAllClassLayout
/d1reportSingleClassLayout<name>
```
See http://ofekshilon.com/2010/11/07/d1reportallclasslayout-dumping-object-memory-layout/

```
class A
{
    int m_a, m_b;
    virtual void cookie() {}
    virtual void monster() {}
};
  
class B : public A
{
    double m_c;
    virtual void cookie() {}
};
```

will be
```
class A    size(16):
    +---
 0  | {vfptr}
 8  | m_a
12  | m_b
    +---
A::$vftable@:
    | &A_meta
    |  0
 0  | &A::cookie
 1  | &A::monster
A::cookie this adjustor: 0
A::monster this adjustor: 0
 
class B    size(24):
    +---
    | +--- (base class A)
 0  | | {vfptr}
 8  | | m_a
12  | | m_b
    | +---
16  | m_c
    +---
B::$vftable@:
    | &B_meta
    |  0
 0  | &B::cookie
 1  | &A::monster
B::cookie this adjustor: 0
```

Debugging difference between WinDbg and Visual Studio
=========

When looking at dlls with missing pdb files, WinDbg's callstack may differe from Visual Studio's one. WinDbg may display function names whereas Visual Studio shows only addresses not able to resolve the name.

The source of that is the dll export table, WinDbg reads the export definition of Dlls and resolve the names (of course only for exported symbols). To have a similar behaviour in Visual Studio, go to `Tools > Options > Debugging > General and select "Load dll exports"`

Debugging Deadlocks (User-Mode Deadlocks)
=========

Reference: https://msdn.microsoft.com/en-us/library/windows/hardware/ff540592%28v=vs.85%29.aspx

* Call `!locks` to obtain all locks, may take a while. Returns all critical sections with lock count
* Count of 0 means not locked
* Run `~` to see current threads
* On thread with nummber X run `~X kb` to obtain call stack
* Check for `WaitForCriticalSection` which means it has a lock (referenced in !locks) and is also waiting
* First address in **Args to Child** is address of the critical section.
* Check thread for the CritSec of this address and see whether it has a lock to another section to verify the deadlock
