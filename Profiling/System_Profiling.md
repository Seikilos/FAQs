# Windows Performance Bottleneck Analysis Guide

## Step 1: Quick Triage with typeperf

Run during the workload to classify the bottleneck (CPU, disk, or wait):

```powershell
typeperf `
    "\PhysicalDisk(*)\Avg. Disk sec/Read" `
    "\PhysicalDisk(*)\Avg. Disk sec/Write" `
    "\PhysicalDisk(*)\Disk Transfers/sec" `
    "\PhysicalDisk(*)\Current Disk Queue Length" `
    "\Processor(_Total)\% Processor Time" `
    "\System\Processes" `
    "\System\Context Switches/sec" `
    -si 2 -sc 45 -o C:\Temp\triage.csv
```

**Interpretation:**

- Disk read latency >10 ms or queue depth >4 → disk bottleneck
- CPU at 95–100% on a single core → CPU-bound
- Context switches >50,000/sec with fluctuating process count → process creation overhead
- All metrics moderate → blocking wait (network, license server, timer)

## Step 2: Capture ETW Trace

```powershell
New-Item -ItemType Directory -Path C:\Temp -Force | Out-Null

xperf -on PROC_THREAD+LOADER+PROFILE+CSWITCH+DISPATCHER+DISK_IO+DISK_IO_INIT+FILE_IO+FILE_IO_INIT+FILENAME+HARD_FAULTS+NETWORKTRACE `
    -stackwalk Profile+CSwitch+ReadyThread+ProcessCreate+ProcessDelete+DiskReadInit+FileCreate+FileRead+FileWrite `
    -BufferSize 1024 -MinBuffers 256 -MaxBuffers 512 `
    -f C:\Temp\kernel.etl
```

For long sessions (>10 min), add circular buffering:

```powershell
xperf -on PROC_THREAD+LOADER+PROFILE+CSWITCH+DISPATCHER+DISK_IO+DISK_IO_INIT+FILE_IO+FILE_IO_INIT+FILENAME+HARD_FAULTS+NETWORKTRACE `
    -stackwalk Profile+CSwitch+ReadyThread+ProcessCreate+ProcessDelete+DiskReadInit+FileCreate+FileRead+FileWrite `
    -BufferSize 1024 -MaxBuffers 1024 -MaxFile 2048 -FileMode Circular `
    -f C:\Temp\kernel.etl
```

## Step 3: Capture Network Events (Optional)

```powershell
logman create trace "NetworkTrace" -o C:\Temp\network.etl -bs 256 -nb 128 256 -ets
logman update trace "NetworkTrace" -p "Microsoft-Windows-TCPIP" 0xFFFFFFFF 4 -ets
logman update trace "NetworkTrace" -p "Microsoft-Windows-Winsock-AFD" 0xFFFFFFFF 4 -ets
logman update trace "NetworkTrace" -p "Microsoft-Windows-DNS-Client" 0xFFFFFFFF 4 -ets
```

## Step 4: Stop Traces

Let traces run for 2–3 minutes (enough to capture several process cycles), then:

```powershell
logman stop "NetworkTrace" -ets
xperf -d C:\Temp\merged.etl
```

The two ETL files are independent and can be analyzed separately.

## Step 5: Analyze in WPA

Open `merged.etl` in Windows Performance Analyzer.

**Configure symbols:** Trace → Configure Symbol Paths → `srv*C:\symbols*https://mssymbols.azureedge.net/download/symbols` → Trace → Load Symbols.

### 5a: Map the Process Lifetime Timeline

Open **System Activity → Processes**. Filter to the relevant process names. Look at process lifetimes and the gaps between child process exit and next child process creation.

### 5b: Wait Analysis

Open **Computation → CPU Usage (Precise)**. Configure columns:

- Grouping (left of gold bar): `New Process` → `New Thread Id` → `ReadyingProcess` → `ReadyThreadStack`
- Data (right of gold bar): `Wait (µs) [Sum]`, `Ready (µs) [Sum]`, `Count`, `CPU Usage (ms) [Sum]`

Sort by `Wait (µs) [Sum]` descending.

**Zoom into idle periods first** — select the flat/idle region in the CPU Usage line chart, right-click → Zoom To Selection. The table then only shows events within that window.

### 5c: Interpret ReadyingProcess and ReadyThreadStack

| ReadyingProcess | ReadyThreadStack contains | Meaning |
|---|---|---|
| `System` | `tcpip!` | Network I/O completed |
| `System` | `Ntfs!` or `storport!` | Disk I/O completed |
| `svchost.exe` (Dnscache) | `dnsapi.dll!` | DNS resolution completed |
| Same process | `ntoskrnl!KeSetEvent` | Internal thread synchronization |
| `(none)` | `ntoskrnl!KiTimerExpiration` | Sleep or timeout expired |

### 5d: Follow the Wait Chain

If a thread was woken by another thread in the same process, find that other thread and check *its* ReadyingProcess. Keep following until you reach `System` or an external process — that's the true root cause.

### 5e: Check Disk I/O (if indicated)

Open **Storage → Disk Usage**. Key columns: `Process`, `IO Type`, `Disk Service Time (Avg/Max)`, `QD/I (Avg)`.

- Premium SSD latency >10 ms → disk throttling
- Queue depth >4 → disk saturated

## Step 6: Validate Findings

Use targeted tools to confirm the bottleneck identified by ETW:

- **DNS issues:**

  ```powershell
  wevtutil sl Microsoft-Windows-DNS-Client/Operational /e:true
  ```

  Then inspect logs.

- **Network waits:** Process Monitor filtered to TCP traffic for the target process
- **Disk waits:** `diskspd` to benchmark raw disk performance
- **Process creation overhead:** Measure spawn cost with a loop test

## Notes

- Traces can be started while the workload is already running — no restart needed
- ETL files can be copied to another machine for analysis; symbols resolve via the public symbol server
- Write trace files to a fast local disk to avoid the trace competing for I/O with the workload
