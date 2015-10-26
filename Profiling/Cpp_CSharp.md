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

dotMemory + dotCover
==========
TBC

Manual leak detection in native processes
==========
Partial information at http://www.codeproject.com/Articles/31382/Memory-Leak-Detection-Using-Windbg

However `!heap -s` displayed only empty virtual blocks. VMMap displayed heaps with leaks but `!heap -stat –h ADDRESS` failed.

Working alternative -> Set gflags to `gflags.exe /i app.exe +ust` (enables user mode stack trace database) and use umdh.exe (http://stackoverflow.com/a/5255439/2416394) from WindDBG, dump stacks (mode 1) and let umdh create a diff (mode 2) which provide stack traces!

***Important: Remember to reset gflags  to -ust***

Application crashes only when debugger is not attached
=========
See http://stackoverflow.com/questions/811951/mt-and-md-builds-crashing-but-only-when-debugger-isnt-attached-how-to-debug and http://stackoverflow.com/questions/1060337/why-does-my-stl-code-run-so-slowly-when-i-have-the-debugger-ide-attached/1060929#1060929
Probably the debugger heap causes different behaviour
Add `_NO_DEBUG_HEAP=1` to project's properties environment

Fallback
=========
WinDbg and MemComparer (https://github.com/Seikilos/MemComparer) for Managed Leaks

