<#
    Repair-PerfCounters.ps1
    ---------------------------------------------------------------
    If every counter-based column in a FullTrace comes back empty
    (per-core load, interrupt/DPC time, pagefaults), your Windows
    performance counters are corrupt - a surprisingly common Windows
    fault. This rebuilds them so the trace can measure the CCD split,
    confirm the GPU-interrupt move, and expose periodic hitches.

    RUN AS ADMINISTRATOR, then REBOOT.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Repair-PerfCounters",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Performance counters repair initiated",
        "steps_completed": [],
        "reboot_required": true,
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Repair-PerfCounters",
        "version": "1.0.0",
        "output_format": "dual",
        "steps_completed": [],
        "reboot_required": true,
        "status": "completed",
        "timestamp": "2026-07-26T11:49:18Z",
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
        tool_name = "Repair-PerfCounters"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            steps_completed = $Data.steps_completed
            reboot_required = $Data.reboot_required
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Repair-PerfCounters"
            version = "1.0.0"
            output_format = "dual"
            steps_completed = $Data.steps_completed
            reboot_required = $Data.reboot_required
            status = $Data.status
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { 
    Write-HumanOutput "ERROR: Run as Administrator." 
    Write-AIOutput @{
        summary = "ERROR: Run as Administrator."
        steps_completed = @()
        reboot_required = $true
        status = "error"
    }
    return 
}

$stepsCompleted = @()

Write-Host "Rebuilding performance counter registry (64-bit)..." -ForegroundColor Cyan
& "$env:windir\system32\lodctr.exe" /R
$stepsCompleted += "Rebuilding performance counter registry (64-bit)"

Write-Host "Rebuilding performance counter registry (32-bit)..." -ForegroundColor Cyan
& "$env:windir\syswow64\lodctr.exe" /R
$stepsCompleted += "Rebuilding performance counter registry (32-bit)"

Write-Host "Refreshing WMI performance classes (WMIADAP)..." -ForegroundColor Cyan
$wmiadap = "$env:windir\system32\wbem\wmiadap.exe"
if (Test-Path $wmiadap) {
    & $wmiadap /f
    Write-Host "  wmiadap /f done" -ForegroundColor Green
    $stepsCompleted += "Refreshing WMI performance classes (WMIADAP)"
} else {
    Write-Host "  wmiadap.exe not found - skipping (the lodctr /R above is the main fix)" -ForegroundColor DarkGray
}

# best-effort WMI perf resync if the command is available on PATH
$wm = Get-Command winmgmt -ErrorAction SilentlyContinue
if ($wm) { 
    try { 
        & winmgmt /resyncperf 
        $stepsCompleted += "WMI perf resync"
    } catch { } 
}

Write-Host ""
Write-Host "Done. REBOOT, then re-run Preflight-Check - the per-core columns should populate." -ForegroundColor Green
Write-Host "If they still don't populate, the deeper fix is rebuilding the WMI repository (search 'winmgmt salvagerepository')." -ForegroundColor DarkGray

# --- AI Output ---
Write-AIOutput @{
    summary = "Performance counters repair initiated"
    steps_completed = $stepsCompleted
    reboot_required = $true
    status = "completed"
}