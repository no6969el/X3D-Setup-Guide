<#
    Preflight-Check.ps1
    ---------------------------------------------------------------
    Read-only. Run before a session to confirm every fix is live
    after a reboot. Prints a checklist + READY / NOT READY.
    No admin required (run as admin only if a registry line says
    "access denied").

    Topology comes from X3D-Profiles.ps1, so this now adapts to the
    chip it finds instead of assuming the example rig: 6/8-core
    single-CCD, 12/16-core dual-CCD, the dual-cached 9950X3D2, mobile
    HX3D parts, and non-X3D CPUs (where the core-pinning and interrupt
    checks are skipped rather than failed).
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Preflight-Check",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Preflight check completed",
        "cpu_topology": {
          "logical_processors": 0,
          "status": "unknown"
        },
        "power_plan": {
          "active_plan": "",
          "status": "unknown"
        },
        "gpu_interrupt_affinity": {
          "status": "unknown",
          "issues": []
        },
        "global_timer_resolution": {
          "status": "unknown"
        },
        "process_lasso": {
          "status": "unknown",
          "issues": []
        },
        "park_control": {
          "status": "unknown"
        },
        "gpu_driver": {
          "status": "unknown"
        },
        "overall_status": "unknown",
        "issues_count": 0
      },
      "ai_structured": {
        "tool_name": "Preflight-Check",
        "version": "1.0.0",
        "output_format": "dual",
        "cpu_topology": {
          "logical_processors": 0,
          "status": "unknown"
        },
        "power_plan": {
          "active_plan": "",
          "status": "unknown"
        },
        "gpu_interrupt_affinity": {
          "status": "unknown",
          "issues": []
        },
        "global_timer_resolution": {
          "status": "unknown"
        },
        "process_lasso": {
          "status": "unknown",
          "issues": []
        },
        "park_control": {
          "status": "unknown"
        },
        "gpu_driver": {
          "status": "unknown"
        },
        "overall_status": "unknown",
        "issues_count": 0,
        "timestamp": "2026-07-26T11:48:26Z",
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
        tool_name = "Preflight-Check"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            cpu_topology = $Data.cpu_topology
            power_plan = $Data.power_plan
            gpu_interrupt_affinity = $Data.gpu_interrupt_affinity
            global_timer_resolution = $Data.global_timer_resolution
            process_lasso = $Data.process_lasso
            park_control = $Data.park_control
            gpu_driver = $Data.gpu_driver
            overall_status = $Data.overall_status
            issues_count = $Data.issues_count
        }
        ai_structured = @{
            tool_name = "Preflight-Check"
            version = "1.0.0"
            output_format = "dual"
            cpu_topology = $Data.cpu_topology
            power_plan = $Data.power_plan
            gpu_interrupt_affinity = $Data.gpu_interrupt_affinity
            global_timer_resolution = $Data.global_timer_resolution
            process_lasso = $Data.process_lasso
            park_control = $Data.park_control
            gpu_driver = $Data.gpu_driver
            overall_status = $Data.overall_status
            issues_count = $Data.issues_count
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

function Show-OK   { param($m) Write-Host "  [OK]   $m" -ForegroundColor Green }
function Show-WARN { param($m) Write-Host "  [WARN] $m" -ForegroundColor Yellow }
function Show-INFO { param($m) Write-Host "  [ .. ] $m" -ForegroundColor Gray }
function Show-SKIP { param($m) Write-Host "  [ -- ] $m" -ForegroundColor DarkGray }

$issues = 0
$aiData = @{
    summary = "Preflight check completed"
    cpu_topology = @{
        logical_processors = 0
        status = "unknown"
    }
    power_plan = @{
        active_plan = ""
        status = "unknown"
    }
    gpu_interrupt_affinity = @{
        status = "unknown"
        issues = @()
    }
    global_timer_resolution = @{
        status = "unknown"
    }
    process_lasso = @{
        status = "unknown"
        issues = @()
    }
    park_control = @{
        status = "unknown"
    }
    gpu_driver = @{
        status = "unknown"
    }
    overall_status = "unknown"
    issues_count = 0
}

# --- resolve the profile -----------------------------------------
$mod = Join-Path $PSScriptRoot 'X3D-Profiles.ps1'
if (-not (Test-Path $mod)) {
    Write-Host ""
    Write-Host "  X3D-Profiles.ps1 is missing from the scripts folder - re-unzip the kit." -ForegroundColor Red
    Write-Host ""
    Write-AIOutput $aiData
    return
}
. $mod
$P = Get-X3DProfile

$ncpu        = [int]$P.ActualLogical
$FreqFirst   = [int]$P.FreqFirst
$IsSingle    = ($P.Topology -eq 'single')
$VCacheRange = $P.VCacheRange
$CanSteer    = ($P.TopologyKnown -and $P.IsX3D -and $FreqFirst -ge 1 -and $FreqFirst -lt $ncpu)
$NeedsPin    = ($P.IsX3D -and -not $IsSingle)

Write-Host ""
Write-Host "=================  iRACING PREFLIGHT  =================" -ForegroundColor Cyan
Write-Host ("  {0}  ({1})" -f $P.Model, $P.Profile) -ForegroundColor Gray
Write-Host ("  " + (Get-X3DTopologySummary $P)) -ForegroundColor DarkGray
if ($P.Simulated) { Write-Host "  SIMULATED PROFILE ACTIVE - readings below are from the real machine." -ForegroundColor Magenta }

# 1. CPU visible to Windows
Write-Host ""
Write-Host "1. CPU topology"
$expected = 0
if ($P.Known) { $expected = $P.Cores * $P.SmtFactor }
if (-not $P.IsX3D) {
    Show-SKIP "$ncpu logical processors - no 3D V-Cache detected, topology checks skipped"
    $aiData.cpu_topology.status = "skipped"
} elseif ($P.Known -and $ncpu -eq $expected) {
    if ($IsSingle) { 
        Show-OK "$ncpu logical processors - single-CCD, all cores share the V-Cache"
        $aiData.cpu_topology.status = "ok"
    }
    else { 
        Show-OK "$ncpu logical processors - both CCDs active"
        $aiData.cpu_topology.status = "ok"
    }
} elseif ($P.Known -and $ncpu -lt $expected) {
    Show-WARN "only $ncpu of the expected $expected logical processors - cores are being limited. Check msconfig > Boot > Advanced ('Number of processors' should be UNCHECKED) and your BIOS CCD/SMT settings, then reboot."
    $issues++
    $aiData.cpu_topology.status = "warning"
} elseif ($IsSingle) {
    Show-OK "$ncpu logical processors - single-CCD"
    $aiData.cpu_topology.status = "ok"
} else {
    Show-OK "$ncpu logical processors - $($P.CcdCount) CCDs detected"
    $aiData.cpu_topology.status = "ok"
}
$aiData.cpu_topology.logical_processors = $ncpu
if ($P.VCacheScope -eq 'both') {
    Show-INFO "both CCDs carry V-Cache on this chip - there is no 'bad' CCD, but keeping the sim on one die still avoids cross-CCD latency"
}

# 2. Active power plan
Write-Host ""
Write-Host "2. Power plan"
$scheme = (powercfg /getactivescheme) -join ' '
$planName = '?'
if ($scheme -match '\(([^)]+)\)') { $planName = $Matches[1] }
$aiData.power_plan.active_plan = $planName
if ($P.Form -eq 'mobile') {
    Show-INFO "active plan = $planName - on a laptop your OEM power software may override this. Confirm the machine is on mains power and in its performance profile."
    $aiData.power_plan.status = "info"
} elseif ($IsSingle) {
    # single-CCD: any plan is fine; Balanced is actually AMD's recommendation
    Show-OK "active plan = $planName (single-CCD - power plan isn't critical; Balanced is fine)"
    $aiData.power_plan.status = "ok"
} elseif (-not $P.IsX3D) {
    Show-INFO "active plan = $planName - make sure core parking is OFF (100% cores unparked)"
    $aiData.power_plan.status = "info"
} elseif ($scheme.ToLower().Contains('a4342cf1') -or $planName -like '*Bitsum*') {
    Show-OK "active plan = $planName (all cores unparked)"
    $aiData.power_plan.status = "ok"
} elseif ($scheme.ToLower().Contains('8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c')) {
    Show-OK "active plan = $planName (High Performance - cores unparked)"
    $aiData.power_plan.status = "ok"
} elseif ($scheme.ToLower().Contains('381b4222-f694-41f0-9685-ff5bb260df2e')) {
    Show-WARN "active plan = Balanced - on a dual-CCD chip its core parking can starve the VR compositor. Switch to Bitsum Highest Performance or High Performance."
    $issues++
    $aiData.power_plan.status = "warning"
} else {
    Show-INFO "active plan = $planName - make sure core parking is OFF (100% cores unparked)"
    $aiData.power_plan.status = "info"
}

# 3. GPU interrupt affinity (registry)
Write-Host ""
Write-Host "3. GPU interrupt affinity"
if (-not $CanSteer) {
    Show-SKIP "interrupt steering not applicable on this CPU - skipped"
    $aiData.gpu_interrupt_affinity.status = "skipped"
} else {
    Write-Host "   (target CPU $FreqFirst)" -ForegroundColor DarkGray
    $gpus = Get-PnpDevice -Class Display -Status OK -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -like '*VEN_10DE*' }
    if (-not $gpus) {
        Show-WARN "no active NVIDIA display device found"
        $issues++
        $aiData.gpu_interrupt_affinity.status = "warning"
        $aiData.gpu_interrupt_affinity.issues += "no active NVIDIA display device found"
    }
    foreach ($g in $gpus) {
        $key = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($g.InstanceId)\Device Parameters\Interrupt Management\Affinity Policy"
        try {
            if (Test-Path $key) {
                $p   = Get-ItemProperty -Path $key -ErrorAction Stop
                $pol = $p.DevicePolicy
                $ov  = $p.AssignmentSetOverride
                if ($pol -eq 4 -and $ov) {
                    $mask = [uint64]0
                    for ($i = 0; $i -lt $ov.Length; $i++) {
                        $mask = $mask -bor ([uint64]$ov[$i] -shl (8 * $i))
                    }
                    $cores = @()
                    for ($b = 0; $b -lt 64; $b++) {
                        if ((($mask -shr $b) -band [uint64]1) -eq 1) { $cores += $b }
                    }
                    $coreList = $cores -join ','
                    if ($cores -contains $FreqFirst) {
                        Show-OK "GPU interrupts steered to CPU $coreList (override active)"
                        $aiData.gpu_interrupt_affinity.status = "ok"
                    } else {
                        Show-WARN "GPU IRQ override present but targets CPU $coreList (not $FreqFirst) - re-run Set-GPU-IRQ-Affinity, or reset the saved profile from the Tuning-Menu if you changed CPU"
                        $issues++
                        $aiData.gpu_interrupt_affinity.status = "warning"
                        $aiData.gpu_interrupt_affinity.issues += "GPU IRQ override targets CPU $coreList (not $FreqFirst)"
                    }
                } else {
                    Show-WARN "policy present but not SpecifiedProcessors(4) - re-run Set-GPU-IRQ-Affinity"
                    $issues++
                    $aiData.gpu_interrupt_affinity.status = "warning"
                    $aiData.gpu_interrupt_affinity.issues += "policy present but not SpecifiedProcessors(4)"
                }
            } else {
                Show-WARN "no interrupt override on $($g.FriendlyName) - reverted (MSI quirk). Re-run Set-GPU-IRQ-Affinity as admin."
                $issues++
                $aiData.gpu_interrupt_affinity.status = "warning"
                $aiData.gpu_interrupt_affinity.issues += "no interrupt override on $($g.FriendlyName)"
            }
        } catch {
            Show-WARN "could not read IRQ registry (try running as admin)"
            $issues++
            $aiData.gpu_interrupt_affinity.status = "warning"
            $aiData.gpu_interrupt_affinity.issues += "could not read IRQ registry"
        }
    }
}

# 4. Global timer resolution (the VR focus/timer fix)
Write-Host ""
Write-Host "4. Global timer resolution"
$tk = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'
$tv = (Get-ItemProperty -Path $tk -Name 'GlobalTimerResolutionRequests' -ErrorAction SilentlyContinue).GlobalTimerResolutionRequests
if ($tv -eq 1) {
    Show-OK "GlobalTimerResolutionRequests = 1 - high-res timer honored even when the sim loses focus"
    $aiData.global_timer_resolution.status = "ok"
} else {
    Show-INFO "not set - if you get hitches that stop when you CLICK the sim window (common in VR), run Enable-GlobalTimerResolution (admin) + reboot"
    $aiData.global_timer_resolution.status = "info"
}

# 5. Process Lasso config + engine (dual-CCD only)
Write-Host ""
Write-Host "5. Process Lasso (core pinning)"
if (-not $P.IsX3D) {
    Show-SKIP "no V-Cache to pin to on this CPU - skipped"
    $aiData.process_lasso.status = "skipped"
} elseif ($IsSingle) {
    Show-OK "single-CCD - no core pinning needed (all cores are V-Cache)"
    $aiData.process_lasso.status = "ok"
} else {
    if (Get-Process ProcessGovernor -ErrorAction SilentlyContinue) {
        Show-OK "governor running (ProcessGovernor.exe)"
        $aiData.process_lasso.status = "ok"
    } else {
        Show-WARN "ProcessGovernor.exe not running - Process Lasso rules won't apply"
        $issues++
        $aiData.process_lasso.status = "warning"
        $aiData.process_lasso.issues += "ProcessGovernor.exe not running"
    }
    $cfg = 'C:\ProgramData\ProcessLasso\config\prolasso.ini'
    if (Test-Path $cfg) {
        try {
            $t = [System.IO.File]::ReadAllText($cfg, [System.Text.Encoding]::Unicode).ToLower()
            if ($t.Contains("iracingsim64dx11.exe,($VCacheRange)")) { 
                Show-OK "iRacing soft CPU Set $VCacheRange present"
                $aiData.process_lasso.status = "ok"
            }
            else { 
                Show-WARN "iRacing CPU Set $VCacheRange missing - add it (CPU Sets, not affinity)"
                $issues++
                $aiData.process_lasso.status = "warning"
                $aiData.process_lasso.issues += "iRacing CPU Set $VCacheRange missing"
            }
            if (-not $t.Contains("iracingsim64dx11.exe,0,$VCacheRange")) { 
                Show-OK "no hard-affinity rule (EAC would reject it)"
                $aiData.process_lasso.status = "ok"
            }
            else { 
                Show-WARN "hard-affinity rule still present - remove it (EAC reverts it and it fights the CPU Set)"
                $issues++
                $aiData.process_lasso.status = "warning"
                $aiData.process_lasso.issues += "hard-affinity rule still present"
            }
        } catch {
            Show-WARN "could not parse prolasso.ini"
            $aiData.process_lasso.status = "warning"
            $aiData.process_lasso.issues += "could not parse prolasso.ini"
        }
    } else {
        Show-INFO "prolasso.ini not found at default path (check your install location)"
        $aiData.process_lasso.status = "info"
    }
}

# 6. ParkControl (Dynamic Boost can't be read programmatically - remind)
Write-Host ""
Write-Host "6. ParkControl"
if (Get-Process ParkControl -ErrorAction SilentlyContinue) {
    Show-INFO "ParkControl running - confirm 'Bitsum Dynamic Boost' is UNCHECKED (it can flip the power plan mid-race)"
    $aiData.park_control.status = "info"
} else {
    Show-OK "ParkControl not running (can't flip the plan)"
    $aiData.park_control.status = "ok"
}

# 7. NVIDIA driver
Write-Host ""
Write-Host "7. GPU driver"
$vc = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -like '*NVIDIA*' } | Select-Object -First 1
if ($vc) { 
    Show-INFO "$($vc.Name)  driver $($vc.DriverVersion)  ($($vc.DriverDate))"
    $aiData.gpu_driver.status = "info"
}

# profile notes
if ($P.Warnings -and $P.Warnings.Count) {
    Write-Host ""
    Write-Host "Notes about this CPU"
    Write-X3DWarnings $P '  '
}

# verdict
Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
if ($issues -eq 0) {
    Write-Host "  READY - all applicable checks passed. Launch FullTrace, then race." -ForegroundColor Green
    $aiData.overall_status = "ready"
} else {
    Write-Host "  NOT READY - $issues item(s) need attention above." -ForegroundColor Yellow
    $aiData.overall_status = "not_ready"
}
$aiData.issues_count = $issues
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# --- AI Output ---
Write-AIOutput $aiData