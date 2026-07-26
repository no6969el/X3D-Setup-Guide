<#
    Steer NVIDIA GPU interrupts away from the sim's core
    ---------------------------------------------------------------
    iRacing's sim thread favors CPU 0, and NVIDIA's GPU interrupts
    (nvlddmkm) also default toward CPU 0 - they collide and cause DPC
    spikes. This steers the GPU's interrupt handling elsewhere:

      * Dual-CCD  -> the first CPU of the SECOND CCD, off the die the
                     sim is pinned to (16 on a 16-core, 12 on a 12-core).
      * Single-CCD-> a core well away from CPU 0 (half the thread count:
                     8 on an 8-core, 6 on a 6-core).

    The target comes from X3D-Profiles.ps1, which knows every X3D SKU
    and validates the answer against the CPUs Windows actually reports.
    It can never point at a processor that does not exist.

    MUST run as Administrator. Reboot afterward, then verify with LatencyMon.
    Reversible with Undo-GPU-IRQ-Affinity.ps1.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Set-GPU-IRQ-Affinity",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "GPU IRQ affinity set",
        "target_core": 0,
        "gpus_processed": [],
        "reboot_required": true,
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Set-GPU-IRQ-Affinity",
        "version": "1.0.0",
        "output_format": "dual",
        "target_core": 0,
        "gpus_processed": [],
        "reboot_required": true,
        "status": "completed",
        "timestamp": "2026-07-26T11:50:31Z",
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
        tool_name = "Set-GPU-IRQ-Affinity"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            target_core = $Data.target_core
            gpus_processed = $Data.gpus_processed
            reboot_required = $Data.reboot_required
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Set-GPU-IRQ-Affinity"
            version = "1.0.0"
            output_format = "dual"
            target_core = $Data.target_core
            gpus_processed = $Data.gpus_processed
            reboot_required = $Data.reboot_required
            status = $Data.status
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

# ---- resolve the target core ------------------------------------
$mod = Join-Path $PSScriptRoot 'X3D-Profiles.ps1'
$Simulated = $false
$Valid     = $true

if (Test-Path $mod) {
    . $mod
    $r = Resolve-X3DTarget
    $TargetCore = $r.FreqFirst
    $Limit      = $r.Limit
    $Simulated  = $r.Simulated
    $Valid      = $r.Valid
} else {
    Write-Host "  ! X3D-Profiles.ps1 not found next to this script - using a safe fallback." -ForegroundColor Yellow
    $Limit      = [int][Environment]::ProcessorCount
    $TargetCore = [int]($Limit / 2)
}

if ($TargetCore -lt 1 -or $TargetCore -ge $Limit) {
    Write-Host ""
    Write-Host "ABORTED: CPU $TargetCore is not a usable target on this machine ($Limit logical processors)." -ForegroundColor Red
    Write-Host "Nothing was changed. Run the Tuning-Menu once so it can save a correct core profile." -ForegroundColor DarkGray
    Write-AIOutput @{
        summary = "ABORTED: CPU $TargetCore is not a usable target on this machine ($Limit logical processors)."
        target_core = $TargetCore
        gpus_processed = @()
        reboot_required = $true
        status = "error"
    }
    return
}
if (-not $Valid) {
    Write-Host ""
    Write-Host "ABORTED: this CPU's topology could not be identified, so interrupt steering is disabled." -ForegroundColor Red
    Write-Host "The rest of the kit still works. Nothing was changed." -ForegroundColor DarkGray
    Write-AIOutput @{
        summary = "ABORTED: this CPU's topology could not be identified, so interrupt steering is disabled."
        target_core = $TargetCore
        gpus_processed = @()
        reboot_required = $true
        status = "error"
    }
    return
}

# --- require admin ---
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { 
    Write-HumanOutput "ERROR: right-click PowerShell and Run as Administrator, then re-run." 
    Write-AIOutput @{
        summary = "ERROR: right-click PowerShell and Run as Administrator, then re-run."
        target_core = $TargetCore
        gpus_processed = @()
        reboot_required = $true
        status = "error"
    }
    return 
}

$gpusProcessed = @()

# --- build the processor affinity mask (little-endian 8 bytes) ---
$mask  = ([uint64]1) -shl $TargetCore
$bytes = [System.BitConverter]::GetBytes($mask)      # KAFFINITY, group 0

# --- find NVIDIA display device(s) ---
$gpus = Get-PnpDevice -Class Display -Status OK -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -match 'VEN_10DE' }
if (-not $gpus) { 
    Write-Host "ERROR: no active NVIDIA display device found." -ForegroundColor Red
    Write-AIOutput @{
        summary = "ERROR: no active NVIDIA display device found."
        target_core = $TargetCore
        gpus_processed = @()
        reboot_required = $true
        status = "error"
    }
    return 
}

if ($Simulated) {
    Write-Host ""
    Write-Host "  DRY RUN - X3D_FORCE_PROFILE is set, so nothing will be written." -ForegroundColor Magenta
}

foreach ($g in $gpus) {
    Write-Host ""
    Write-Host "GPU : $($g.FriendlyName)" -ForegroundColor Cyan
    Write-Host "  Instance: $($g.InstanceId)"
    $key = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($g.InstanceId)\Device Parameters\Interrupt Management\Affinity Policy"

    if ($Simulated) {
        Write-Host ("  -> WOULD pin GPU interrupts to CPU {0} (mask 0x{1:X})" -f $TargetCore, $mask) -ForegroundColor Magenta
        $gpusProcessed += "$($g.FriendlyName) - Would pin to CPU $TargetCore"
        continue
    }
    try {
        New-Item -Path $key -Force | Out-Null
        # DevicePolicy = 4  (IrqPolicySpecifiedProcessors)
        New-ItemProperty -Path $key -Name 'DevicePolicy' -PropertyType DWord -Value 4 -Force | Out-Null
        # AssignmentSetOverride = processor mask
        New-ItemProperty -Path $key -Name 'AssignmentSetOverride' -PropertyType Binary -Value $bytes -Force | Out-Null
        Write-Host ("  -> GPU interrupts pinned to CPU {0} (mask 0x{1:X})" -f $TargetCore, $mask) -ForegroundColor Green
        $gpusProcessed += "$($g.FriendlyName) - Pinned to CPU $TargetCore"
    } catch {
        Write-Host "  ERROR writing registry (permissions?): $_" -ForegroundColor Red
        $gpusProcessed += "$($g.FriendlyName) - ERROR writing registry"
    }
}

Write-Host ""
if ($Simulated) {
    Write-Host "Dry run complete - no changes were made." -ForegroundColor Magenta
    Write-AIOutput @{
        summary = "Dry run complete - no changes were made."
        target_core = $TargetCore
        gpus_processed = $gpusProcessed
        reboot_required = $true
        status = "completed"
    }
} else {
    Write-Host "Done. REBOOT for it to take effect, then run LatencyMon and confirm" -ForegroundColor Yellow
    Write-Host "nvlddmkm ISRs/DPCs now land on CPU $TargetCore instead of CPU 0." -ForegroundColor Yellow
    Write-Host "If it reverts after reboot (MSI-mode quirk), re-run this each session." -ForegroundColor DarkGray
    Write-AIOutput @{
        summary = "GPU IRQ affinity set"
        target_core = $TargetCore
        gpus_processed = $gpusProcessed
        reboot_required = $true
        status = "completed"
    }
}