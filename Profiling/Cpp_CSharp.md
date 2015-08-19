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

Fallback
=========
WinDbg and MemComparer (https://github.com/Seikilos/MemComparer) for Managed Leaks
