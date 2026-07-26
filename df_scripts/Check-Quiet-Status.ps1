<#
    Check-Quiet-Status.ps1                                    v3.0.0
    ---------------------------------------------------------------
    READ-ONLY. Shows whether "race quiet" is active right now.
    No admin needed. Changes nothing.

    Since v3.0.0 Pre-Race-Quiet DISABLES the services rather than just
    stopping them, so this now reports the startup type as well as the
    running state - a stopped-but-Manual service is the exact condition
    that let Windows restart it mid-race.

    It also tells you whether an un-restored snapshot is sitting in
    C:\ProgramData\RaceQuiet, which is the definitive answer to
    "am I still quieted?"

    AI-BLOCK OUTPUT:
    {
      "tool_name": "Check-Quiet-Status",
      "version": "3.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Checked race quiet status",
        "snapshot_present": false,
        "services_status": [],
        "tasks_status": [],
        "defender_status": "unknown",
        "overall_status": "unknown"
      },
      "ai_structured": {
        "tool_name": "Check-Quiet-Status",
        "version": "3.0.0",
        "output_format": "dual",
        "snapshot_present": false,
        "services_status": [],
        "tasks_status": [],
        "defender_status": "unknown",
        "overall_status": "unknown",
        "timestamp": "2026-07-26T11:43:08Z",
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
        tool_name = "Check-Quiet-Status"
        version = "3.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            snapshot_present = $Data.snapshot_present
            services_status = $Data.services_status
            tasks_status = $Data.tasks_status
            defender_status = $Data.defender_status
            overall_status = $Data.overall_status
        }
        ai_structured = @{
            tool_name = "Check-Quiet-Status"
            version = "3.0.0"
            output_format = "dual"
            snapshot_present = $Data.snapshot_present
            services_status = $Data.services_status
            tasks_status = $Data.tasks_status
            defender_status = $Data.defender_status
            overall_status = $Data.overall_status
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

function State($label,$good,$goodText,$badText){
    if($good){ 
        Write-HumanOutput ("  [quiet]  {0}: {1}" -f $label,$goodText) -ForegroundColor Green 
        return $true
    }
    else { 
        Write-HumanOutput ("  [ on  ]  {0}: {1}" -f $label,$badText) -ForegroundColor Yellow 
        return $false
    }
}

$StateFile = Join-Path $env:ProgramData 'RaceQuiet\state.json'
$SvcRoot   = 'HKLM:\SYSTEM\CurrentControlSet\Services'
$StartName = @{ 0='Boot'; 1='System'; 2='Automatic'; 3='Manual'; 4='Disabled' }

Write-HumanOutput ""
Write-HumanOutput "  ================  RACE-QUIET STATUS  ================" -ForegroundColor Cyan
Write-HumanOutput ""

# --- is there an un-restored session? ---
$snap = $null
if (Test-Path $StateFile) {
    try { $snap = Get-Content $StateFile -Raw | ConvertFrom-Json } catch { }
}
$snapshotPresent = $false
if ($snap) {
    Write-HumanOutput ("  Snapshot present - quieted at {0} UTC and NOT yet restored." -f $snap.CreatedUtc) -ForegroundColor Green
    $snapshotPresent = $true
} else {
    Write-HumanOutput "  No snapshot - this PC is not currently quieted by the kit." -ForegroundColor DarkGray
}
Write-HumanOutput ""

# --- services: running state AND startup type ---
Write-HumanOutput "  Services:" -ForegroundColor Gray
$svcQuiet = $true
$anyManual = $false
$servicesStatus = @()
foreach($s in 'WaaSMedicSvc','UsoSvc','wuauserv','bits','DoSvc','WSearch'){
    $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
    if(-not $svc){ 
        Write-HumanOutput "           $s not present on this build" -ForegroundColor DarkGray
        continue 
    }

    $start = $null
    try { $start = [int](Get-ItemProperty -Path (Join-Path $SvcRoot $s) -Name 'Start' -ErrorAction Stop).Start } catch { }
    $startTxt = '?'
    if ($null -ne $start -and $StartName.ContainsKey($start)) { $startTxt = $StartName[$start] }

    $stopped  = ($svc.Status -eq 'Stopped')
    $disabled = ($start -eq 4)
    if(-not $stopped){ $svcQuiet = $false }
    if($stopped -and -not $disabled){ $anyManual = $true }

    $serviceStatus = @{
        name = $s
        status = if ($stopped -and $disabled) { "stopped + Disabled (cannot come back)" }
                 elseif ($stopped) { "stopped, but startup type is {0} - Windows can restart it" -f $startTxt }
                 else { "running (startup type {0})" -f $startTxt }
        is_quiet = if ($stopped -and $disabled) { $true } else { $false }
    }
    $servicesStatus += $serviceStatus

    if ($stopped -and $disabled) {
        State $s $true "stopped + Disabled (cannot come back)" ""
    } elseif ($stopped) {
        Write-HumanOutput ("  [ ~~  ]  {0}: stopped, but startup type is {1} - Windows can restart it" -f $s,$startTxt) -ForegroundColor Yellow
    } else {
        State $s $false "" ("running (startup type " + $startTxt + ")")
    }
}

# --- scheduled tasks ---
Write-HumanOutput ""
Write-HumanOutput "  Scheduled tasks:" -ForegroundColor Gray
$tasks = @(
    @{ Path='\Microsoft\Windows\WaaSMedic\';                   Name='PerformRemediation' },
    @{ Path='\Microsoft\Windows\UpdateOrchestrator\';          Name='Schedule Scan' },
    @{ Path='\Microsoft\Windows\UpdateOrchestrator\';          Name='Schedule Scan Static Task' },
    @{ Path='\Microsoft\Windows\UpdateOrchestrator\';          Name='Universal Orchestrator Start' },
    @{ Path='\Microsoft\Windows\UpdateOrchestrator\';          Name='Report policies' },
    @{ Path='\Microsoft\Windows\InstallService\';              Name='ScanForUpdates' },
    @{ Path='\Microsoft\Windows\PushToInstall\';               Name='LoginCheck' },
    @{ Path='\Microsoft\Windows\LanguageComponentsInstaller\'; Name='ReconcileLanguageResources' }
)
$tasksDisabled = 0; $tasksSeen = 0; $medicOn = $false
$tasksStatus = @()
foreach($t in $tasks){
    $obj = Get-ScheduledTask -TaskPath $t.Path -TaskName $t.Name -ErrorAction SilentlyContinue
    if(-not $obj){ continue }
    $tasksSeen++
    $disabled = ($obj.State -eq 'Disabled')
    if($disabled){ $tasksDisabled++ }
    elseif($t.Name -eq 'PerformRemediation'){ $medicOn = $true }
    
    $taskStatus = @{
        name = $t.Name
        disabled = $disabled
        state = $obj.State
    }
    $tasksStatus += $taskStatus
    
    State $t.Name $disabled "disabled" ("enabled (" + $obj.State + ")")
}
if ($tasksSeen -eq 0) {
    Write-HumanOutput "           none visible - run this from an ELEVATED prompt;" -ForegroundColor DarkGray
    Write-HumanOutput "           the WaaSMedic tasks are hidden from a normal user." -ForegroundColor DarkGray
}

# --- Defender ---
Write-HumanOutput ""
Write-HumanOutput "  Defender:" -ForegroundColor Gray
$rt = $null
try { $rt = (Get-MpComputerStatus -ErrorAction Stop).RealTimeProtectionEnabled } catch {}
$defenderStatus = "unknown"
if($rt -eq $false){ 
    Write-HumanOutput "  [quiet]  Real-time protection: OFF" -ForegroundColor Green 
    $defenderStatus = "OFF"
}
elseif($rt -eq $true){ 
    Write-HumanOutput "  [ on  ]  Real-time protection: ON" -ForegroundColor Yellow 
    $defenderStatus = "ON"
}
else { 
    Write-HumanOutput "           Real-time protection: unknown" -ForegroundColor DarkGray 
    $defenderStatus = "unknown"
}

# --- verdict ---
Write-HumanOutput ""
Write-HumanOutput "  ====================================================" -ForegroundColor Cyan
$overallStatus = "unknown"
if($svcQuiet -and $tasksSeen -gt 0 -and $tasksDisabled -ge 1){
    if ($anyManual) {
        Write-HumanOutput "  QUIET, BUT NOT LOCKED DOWN." -ForegroundColor Yellow
        Write-HumanOutput "  Some services are stopped yet still set to Manual/Automatic," -ForegroundColor Yellow
        Write-HumanOutput "  so Windows can restart them mid-race. Re-run Pre-Race-Quiet" -ForegroundColor Yellow
        Write-HumanOutput "  (v3.0.0 or later) to disable them properly." -ForegroundColor Yellow
        $overallStatus = "quiet_but_not_locked_down"
    } else {
        Write-HumanOutput "  RACE-QUIET is ACTIVE - the scans are paused. Good to race." -ForegroundColor Green
        $overallStatus = "active"
    }
    if ($medicOn) {
        Write-HumanOutput ""
        Write-HumanOutput "  ! WaaSMedic\PerformRemediation is still ENABLED. That is the" -ForegroundColor Yellow
        Write-HumanOutput "    task that re-enables Windows Update about 10 minutes after" -ForegroundColor Yellow
        Write-HumanOutput "    you quiet it. Re-run Pre-Race-Quiet as admin." -ForegroundColor Yellow
    }
} else {
    Write-HumanOutput "  NOT quieted - background scans can fire during a race." -ForegroundColor Yellow
    Write-HumanOutput "  Run Pre-Race-Quiet before you drive (then Post-Race-Restore after)." -ForegroundColor Yellow
    $overallStatus = "not_quieted"
}
if ($snap) {
    Write-HumanOutput ""
    Write-HumanOutput "  Remember: Post-Race-Restore is required. Until it runs, this PC" -ForegroundColor Yellow
    Write-HumanOutput "  has no Windows Update and no fresh Defender definitions." -ForegroundColor Yellow
}
Write-HumanOutput "  ====================================================" -ForegroundColor Cyan
Write-HumanOutput ""
Read-Host "  Press Enter to close" | Out-Null

# --- AI Output ---
Write-AIOutput @{
    summary = "Checked race quiet status"
    snapshot_present = $snapshotPresent
    services_status = $servicesStatus
    tasks_status = $tasksStatus
    defender_status = $defenderStatus
    overall_status = $overallStatus
}