Concurrency Visualizer
===========
* For Threads Waits and visualization
* Separate Installation

Markers:

````c#
// Assembly: Microsoft.ConcurrencyVisualizer.Markers.dll
using Microsoft.ConcurrencyVisualizer.Instrumentation;

var cs = Markers.EnterSpan("Span A");
// Code 
cs.Leave();

```

Visual Studio Profiling
===========
```c#
// Assembly: Microsoft.VisualStudio.Profiler

using Microsoft.VisualStudio.Profiler;
DataCollection.CommentMarkProfile(100, "Some Marker"); // Provide IDs
```

Visual Studio Heap Profiling (VS 2015)
==========
VS 2015 can take memory screenshot and profile heap when debugger is attached using the diagnostic tools.

Update: While snapshots do display allocs and growth, opening such a snapshot results in a black window for large heaps. Those snapshots require massive amount of disk space. A fix to this behaviour was to move User/temp, temp and pagefile to separate disk with enough space.
However 2015 now has a **Memory Profiling** option in the performance profiler view, which seems to handle large snapshots. [Article on MSDN](https://blogs.msdn.microsoft.com/visualstudioalm/2014/04/02/diagnosing-memory-issues-with-the-new-memory-usage-tool-in-visual-studio/)

For external solution see below ETW analysis.

Event Tracing for Windows (ETW) and Windows Performance Analyzer
==========
See https://randomascii.wordpress.com/2015/04/27/etw-heap-tracingevery-allocation-recorded/

Traces native memory usage.

Important: If UI looks outdated, this might be xperf. Ensure you start `"C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\wpa.exe"` (both, xperf and WPA have the same "Windows Performance Analyzer" title)

Digested command line used by UIforETW. Use UIforETW at least to add and remove the proper `Image File Execution Option`

* Begin Tracing: `xperf.exe -start "NT Kernel Logger" -on Latency+POWER+DISPATCHER+DISK_IO_INIT+FILE_IO+FILE_IO_INIT+VIRT_ALLOC+MEMINFO -stackwalk VirtualAlloc -buffersize 1024 -minbuffers 900 -maxbuffers 900 -f "e:\kernel.etl" -start UIforETWSession -on Microsoft-Windows-Win32k:0xfdffffffefffffff+Multi-MAIN+Multi-FrameRate+Multi-Input+Multi-Worker+Microsoft-Windows-Kernel-Memory:0xE0+Microsoft-Windows-Kernel-Power -buffersize 1024 -minbuffers 150 -maxbuffers 150 -f "e:\user.etl" -start xperfHeapSession -heap -Pids 0 -stackwalk HeapCreate+HeapDestroy+HeapAlloc+HeapRealloc -buffersize 1024 -minbuffers 1500 -maxBuffers 1500 -f "e:\heap.etl"`

* Take snapshot and stop tracing:
  * `xperf.exe -capturestate UIforETWSession Microsoft-Windows-Win32k:0xfdffffffefffffff+Multi-MAIN+Multi-FrameRate+Multi-Input+Multi-Worker+Microsoft-Windows-Kernel-Memory:0xE0+Microsoft-Windows-Kernel-Power`
  * `xperf.exe -stop xperfHeapSession -stop UIforETWSession -stop "NT Kernel Logger"`
  * `xperf.exe -merge "e:\kernel.etl" "e:\user.etl" "e:\heap.etl" "e:\Result.etl"`


**Warning:** Windows Performance Analyzer (wpa.exe) as of version 10.0.10586.15 crashes when adding "Stacks" to the *Heap Allocations* view for large etl files (tested with ~9GB).

dotMemory + dotCover
==========

dotMemory does currently not require a license and can be used with any R# version.

TBC

Manual leak detection in native processes
==========
Partial information at http://www.codeproject.com/Articles/31382/Memory-Leak-Detection-Using-Windbg

However `!heap -s` displayed only empty virtual blocks. VMMap displayed heaps with leaks but `!heap -stat –h ADDRESS` failed.

Working alternative -> Set gflags to `gflags.exe /i app.exe +ust` (enables user mode stack trace database) and use umdh.exe (http://stackoverflow.com/a/5255439/2416394) from WindDBG, dump stacks (mode 1) and let umdh create a diff (mode 2) which provide stack traces!

***Important: Remember to reset gflags  to -ust***

Common native heap issues like large memory
=========
Use WinDBG with `!address -summary` and `!heap`, see references:

https://blogs.msdn.microsoft.com/sudeepg/2009/05/22/manually-debugging-native-memory-leaks/

https://www.codeproject.com/articles/31382/memory-leak-detection-using-windbg

*Hint*: WinDBG 10.0.10240.9 has a broken !heap -s, which returns a truncated list, see [SO](http://stackoverflow.com/questions/40931572/why-does-heap-s-heap-not-work-the-way-intended) thread.

Application crashes only when debugger is not attached
=========
See http://stackoverflow.com/questions/811951/mt-and-md-builds-crashing-but-only-when-debugger-isnt-attached-how-to-debug and http://stackoverflow.com/questions/1060337/why-does-my-stl-code-run-so-slowly-when-i-have-the-debugger-ide-attached/1060929#1060929

Probably the debugger heap causes different behaviour
Add `_NO_DEBUG_HEAP=1` to project's properties environment (See Heap corruption for more)

When debugger is attached from the beginning, the heap layout of the debug heap is different. Debug heap introduces padding and heap extra space (see article below) in which checks do not occur. So with debug heap a previous crash (heap corruption in a heap header) might be now in padding of a heap which is not checked by the heap manager.

Heap corruption in native processes
=========
See http://stackoverflow.com/questions/1010106/how-to-debug-heap-corruption-errors

Especially http://stackoverflow.com/questions/1010106/how-to-debug-heap-corruption-errors AppVerifier with DebugDiag

Also: Enable Page Heap for application in gflags and attach debugger.

**Explanation of Windows Heap Management** http://blogs.msdn.com/b/jiangyue/archive/2010/03/16/windows-heap-overrun-monitoring.aspx

*Additionally* https://blogs.msdn.microsoft.com/carlos/2008/12/10/heap-corruption-a-case-study/ 


Hint: Debug with WinDbg for deeper analysis

Normal Heap
---------
Has CRC checks when block is freed. Heap corruption only detected in heap headers, not user data.

Debug Heap
--------
Has trailing checking pattern *ab*. Also detects only on freeing blocks but may detect corruption of user data (when in trailing checking pattern. Misses corruption of heap extra area. Debug Heap might hide a crash occuring with normal heap due to offsets in address space)

Page Heap
--------
Most detailed debugging with access monitoring during execution.

Enabled via gflags.exe or application verifier. Increases heap massively. Provides inaccessible areas where access to it causes an instant **access violation 0xc0000005!**. Those inaccessible address areas are displayed as **??**. Suffix area overrun still detected only on release (suffix area validation is done on release) and causes a *VERIFIER STOP corrupted suffix pattern* message .

Implicitly enables Heap Stack Trace for heaps

Normal Page Heap
--------
Slimmed down version of Page Heap without non-accessible pages. Checks executed only on freeing blocks

Fallback
=========
WinDbg and MemComparer (https://github.com/Seikilos/MemComparer) for Managed Leaks

