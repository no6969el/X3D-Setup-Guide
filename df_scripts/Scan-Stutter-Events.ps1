<#
    Scan-Stutter-Events.ps1
    ---------------------------------------------------------------
    Finds the cause of stutters - with ZERO manual editing.
    It automatically reads your most recent FullTrace CSV from the
    Desktop, finds the moments you stuttered (gaps in the timestamps),
    then lists the scheduled tasks and Windows events around each one.

    Prereqs: run a FullTrace race first (so there's a CSV to read), and
    run Enable-DiagnosticLogs BEFORE that race (so the task log has data).
    Read-only. Writes stutter-events.txt to your Desktop.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Scan-Stutter-Events",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Stutter event scan completed",
        "trace_file": "",
        "session_duration": {
          "start": "",
          "end": ""
        },
        "stutter_count": 0,
        "stutter_timestamps": [],
        "scheduled_tasks": [],
        "system_events": [],
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Scan-Stutter-Events",
        "version": "1.0.0",
        "output_format": "dual",
        "trace_file": "",
        "session_duration": {
          "start": "",
          "end": ""
        },
        "stutter_count": 0,
        "stutter_timestamps": [],
        "scheduled_tasks": [],
        "system_events": [],
        "status": "completed",
        "timestamp": "2026-07-26T11:50:00Z",
        "execution_result": "success"
      }
    }
#>

function Write-HumanOutput {
    param([string]$Message)
    Write-Host $Message
}

function Write-AIOutput {
    param([hashtable]$Data)
    $aiOutput = @{
        tool_name = "Scan-Stutter-Events"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            trace_file = $Data.trace_file
            session_duration = $Data.session_duration
            stutter_count = $Data.stutter_count
            stutter_timestamps = $Data.stutter_timestamps
            scheduled_tasks = $Data.scheduled_tasks
            system_events = $Data.system_events
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Scan-Stutter-Events"
            version = "1.0.0"
            output_format = "dual"
            trace_file = $Data.trace_file
            session_duration = $Data.session_duration
            stutter_count = $Data.stutter_count
            stutter_timestamps = $Data.stutter_timestamps
            scheduled_tasks = $Data.scheduled_tasks
            system_events = $Data.system_events
            status = $Data.status
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

$desktop = [Environment]::GetFolderPath('Desktop')

# --- find the newest FullTrace CSV on the Desktop ---
$csv = Get-ChildItem -Path $desktop -Filter 'iRacing-FullTrace-*.csv' -ErrorAction SilentlyContinue |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $csv) {
    Write-Host ""
    Write-Host "  No FullTrace CSV found on your Desktop." -ForegroundColor Yellow
    Write-Host "  Run 'Log a race (FullTrace)' first, then run this again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to close" | Out-Null
    Write-AIOutput @{
        summary = "No FullTrace CSV found on your Desktop"
        trace_file = ""
        session_duration = @{
            start = ""
            end = ""
        }
        stutter_count = 0
        stutter_timestamps = @()
        scheduled_tasks = @()
        system_events = @()
        status = "error"
    }
    return
}

Write-Host ""
Write-Host "  Using latest trace: $($csv.Name)" -ForegroundColor Cyan
$day = $csv.LastWriteTime.Date

# --- parse timestamps, find gaps (>1s between rows = a stall) ---
$times = @()
foreach ($line in (Get-Content $csv.FullName | Select-Object -Skip 1)) {
    $t = ($line -split ',')[0].Trim()
    if ($t -match '^\d{1,2}:\d{2}:\d{2}$') { $times += $t }
}
if ($times.Count -lt 2) {
    Write-Host "  That trace has no usable timestamps." -ForegroundColor Yellow
    Read-Host "  Press Enter to close" | Out-Null
    Write-AIOutput @{
        summary = "That trace has no usable timestamps"
        trace_file = $csv.Name
        session_duration = @{
            start = ""
            end = ""
        }
        stutter_count = 0
        stutter_timestamps = @()
        scheduled_tasks = @()
        system_events = @()
        status = "error"
    }
    return
}

function DT([string]$hms) { $day + [TimeSpan]::Parse($hms) }

$incidents = @()
$prev = $null
foreach ($t in $times) {
    $cur = [TimeSpan]::Parse($t).TotalSeconds
    if ($prev -ne $null -and ($cur - $prev) -gt 1) { $incidents += $t }
    $prev = $cur
}
$Start = DT $times[0]
$End   = DT $times[-1]

Write-Host ("  Session {0} -> {1}   |   auto-detected {2} stutter(s)" -f $Start.ToString('HH:mm:ss'), $End.ToString('HH:mm:ss'), $incidents.Count) -ForegroundColor Cyan

# --- write report ---
$out = Join-Path $desktop 'stutter-events.txt'
"STUTTER EVENT SCAN"                                   | Out-File $out -Encoding utf8
"Trace  : $($csv.Name)"                                | Out-File $out -Append -Encoding utf8
"Window : $Start  ->  $End"                            | Out-File $out -Append -Encoding utf8
"Auto-detected stutters (timestamp gaps): $($incidents.Count)" | Out-File $out -Append -Encoding utf8
if ($incidents.Count) { "  at: $($incidents -join ', ')" | Out-File $out -Append -Encoding utf8 }

# 1) scheduled tasks that fired during the whole session (a repeating cadence is the prime suspect)
"" | Out-File $out -Append -Encoding utf8
"=== SCHEDULED TASKS THAT RAN THIS SESSION (Id 100/200) ===" | Out-File $out -Append -Encoding utf8
$scheduledTasks = @()
try {
    $t = Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-TaskScheduler/Operational'; Id=100,200; StartTime=$Start; EndTime=$End } -ErrorAction Stop | Sort-Object TimeCreated
    if (-not $t) { "(none)" | Out-File $out -Append -Encoding utf8 }
    foreach ($e in $t) { 
        $m=($e.Message -replace '\s+',' '); 
        "{0:HH:mm:ss}  {1}" -f $e.TimeCreated, $m.Substring(0,[Math]::Min(150,$m.Length)) | Out-File $out -Append -Encoding utf8 
        $scheduledTasks += "{0:HH:mm:ss}  {1}" -f $e.TimeCreated, $m.Substring(0,[Math]::Min(150,$m.Length))
    }
} catch {
    "(TaskScheduler Operational log is off - run Enable-DiagnosticLogs BEFORE your next race to capture this.)" | Out-File $out -Append -Encoding utf8
    $scheduledTasks += "(TaskScheduler Operational log is off - run Enable-DiagnosticLogs BEFORE your next race to capture this.)"
}

# 2) System events within +/-20s of each detected stutter
"" | Out-File $out -Append -Encoding utf8
"=== SYSTEM EVENTS NEAR EACH STUTTER (+/-20s) ===" | Out-File $out -Append -Encoding utf8
$systemEvents = @()
if (-not $incidents.Count) {
    "(No stutters detected in this trace - nice and smooth!)" | Out-File $out -Append -Encoding utf8
    $systemEvents += "(No stutters detected in this trace - nice and smooth!)"
}
foreach ($ts in $incidents) {
    $c = DT $ts
    "" | Out-File $out -Append -Encoding utf8
    "--- $ts ---" | Out-File $out -Append -Encoding utf8
    try {
        $ev = Get-WinEvent -FilterHashtable @{ LogName='System'; StartTime=$c.AddSeconds(-20); EndTime=$c.AddSeconds(20); Level=1,2,3 } -ErrorAction Stop | Sort-Object TimeCreated
        if (-not $ev) { "  (no warnings/errors logged - typical for a pure DPC/scheduler blip)" | Out-File $out -Append -Encoding utf8 }
        foreach ($e in $ev) { 
            $m=($e.Message -replace '\s+',' '); 
            "  [{0:HH:mm:ss}] Id={1} {2}: {3}" -f $e.TimeCreated,$e.Id,$e.ProviderName,$m.Substring(0,[Math]::Min(150,$m.Length)) | Out-File $out -Append -Encoding utf8 
            $systemEvents += "  [{0:HH:mm:ss}] Id={1} {2}: {3}" -f $e.TimeCreated,$e.Id,$e.ProviderName,$m.Substring(0,[Math]::Min(150,$m.Length))
        }
    } catch {
        "  (no matching System events)" | Out-File $out -Append -Encoding utf8
        $systemEvents += "  (no matching System events)"
    }
}

Write-Host "  Done -> $out" -ForegroundColor Green
Start-Process notepad.exe $out

# --- AI Output ---
Write-AIOutput @{
    summary = "Stutter event scan completed"
    trace_file = $csv.Name
    session_duration = @{
        start = $Start.ToString('HH:mm:ss')
        end = $End.ToString('HH:mm:ss')
    }
    stutter_count = $incidents.Count
    stutter_timestamps = $incidents
    scheduled_tasks = $scheduledTasks
    system_events = $systemEvents
    status = "completed"
}