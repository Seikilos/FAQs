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

Optional
* http://stackoverflow.com/questions/28163009/how-can-i-find-the-reason-of-hang-with-windbg-c
* `!analyze -v -hang`
* `!runaway`
* Also very useful: Load Dump in DebugDiag (Advanced Analysis) to get a nice html report of a dump

WinDBG: Set breakpoints on kernel functions, etc
========

Sometimes it is necessary to break on functions in WinDBG before they are know (e.g. visited) or unreachable otherwise.
WinDBG allows to set breakpoints on matching functions:

`bm /a Kernel32.dll!MapViewOfFile*` sets breakpoints on all variants of `MapViewOfFile` in Kernel32.dll

`bm /a *!MapViewOfFile*` sets breakpoints on all variants in **ALL** modules. Allows to find same names in different modules aswell

For all `b*` commands it is possible to append dbg command, like `bm /a *!MapViewOfFile* "k"` setting breakpoint on all found locations and executes command `k` on hit.

**Important**: When watching the callstacks in WinDBG callstack window, click on **MORE**, you might miss relevant parts otherwise. Alternatively use explicit k command (works on explicit breakpoints only :/):
`bp kernel32!MapViewOfFile "k"`

**Hint**: Check `$spat` in conditional breakpoints (https://msdn.microsoft.com/en-us/library/windows/hardware/ff556853%28v=vs.85%29.aspx) to break into them when a condition like match in callstack has been met.

Release with Debug 
========
Important flags under Linker > Optimization, which should be set:
* References: `No (/OPT:NOREF)`
* Enable COMDAT Folding: `No (/OPT:NOICF)` 


Name Mangling or what does ??0Visit@Master@@QEAA@AEBV01@@Z actually mean
========

If you run a programm that cannot find some obscure methode like ??0Visit@Master@@QEAA@AEBV01@@Z in a message box it indicates that a binary expects a signature not available in some other part (typically another DLL).

The Event Viewer in the System log contains this name as text so you can copy that. The name you see is "mangled". For more information on name mangling (here for Visual C++) see https://en.wikiversity.org/wiki/Visual_C%2B%2B_name_mangling

Go to https://demangler.com/ and enter the mangled name, you will see that
```
??0Visit@Master@@QEAA@AEBV01@@Z
```
actually resolves to a signature 
```
public: __cdecl Master::Visit::Visit(class Master::Visit const & __ptr64) __ptr64
```

The original message typically also contains the binary in which the issue was located. 
If this binary is under your control, check whether it is compiled with a signature that matches the one in the error. It might be something like a missing or added `const`, the difference of x86 or x64, etc.
If the binary is not yours, you need to find an update (or a matching version to be exactly) or contact the developer on that issue.
