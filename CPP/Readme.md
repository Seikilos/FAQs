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

