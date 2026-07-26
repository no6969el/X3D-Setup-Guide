<#
    Enable-GlobalTimerResolution.ps1
    ---------------------------------------------------------------
    Fixes the "it stutters until I click the iRacing window" problem.

    Windows 11 only honors a game's high-resolution timer request while
    that game owns FOREGROUND focus. In VR, the compositor constantly
    steals focus from the sim window, so Windows drops the system timer
    from ~1 ms to its 15.625 ms default mid-race -> periodic frame-pacing
    hitches that stop the moment you click the sim window (focus returns,
    the timer snaps back). That click-to-fix pattern is the signature.
    (Confirm it first with Watch-TimerResolution.ps1 if you like.)

    This restores the pre-Windows-11 behavior: high-resolution timer
    requests are honored globally, whether or not the requester has focus.

    RUN AS ADMINISTRATOR. REBOOT for it to take effect.
    Reversible with Undo-GlobalTimerResolution.ps1.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Enable-GlobalTimerResolution",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Enabled global high-resolution timer requests",
        "registry_setting": "GlobalTimerResolutionRequests",
        "setting_value": 1,
        "status": "completed",
        "reboot_required": true
      },
      "ai_structured": {
        "tool_name": "Enable-GlobalTimerResolution",
        "version": "1.0.0",
        "output_format": "dual",
        "registry_setting": "GlobalTimerResolutionRequests",
        "setting_value": 1,
        "status": "completed",
        "reboot_required": true,
        "timestamp": "2026-07-26T11:44:29Z",
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
        tool_name = "Enable-GlobalTimerResolution"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            registry_setting = $Data.registry_setting
            setting_value = $Data.setting_value
            status = $Data.status
            reboot_required = $Data.reboot_required
        }
        ai_structured = @{
            tool_name = "Enable-GlobalTimerResolution"
            version = "1.0.0"
            output_format = "dual"
            registry_setting = $Data.registry_setting
            setting_value = $Data.setting_value
            status = $Data.status
            reboot_required = $Data.reboot_required
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { 
    Write-HumanOutput "ERROR: right-click PowerShell -> Run as Administrator, then re-run." 
    Write-AIOutput @{
        summary = "ERROR: right-click PowerShell -> Run as Administrator, then re-run."
        registry_setting = "GlobalTimerResolutionRequests"
        setting_value = 1
        status = "error"
        reboot_required = $true
    }
    return 
}

$key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'

Write-HumanOutput ""
Write-HumanOutput "Enabling global high-resolution timer requests..." -ForegroundColor Cyan
$settingApplied = $false
try {
    if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    New-ItemProperty -Path $key -Name 'GlobalTimerResolutionRequests' -PropertyType DWord -Value 1 -Force | Out-Null
    $v = (Get-ItemProperty -Path $key -Name 'GlobalTimerResolutionRequests').GlobalTimerResolutionRequests
    if ($v -eq 1) {
        Write-HumanOutput "  GlobalTimerResolutionRequests = 1  (set)" -ForegroundColor Green
        $settingApplied = $true
    } else {
        Write-HumanOutput "  ! value reads back as $v - expected 1" -ForegroundColor Yellow
    }
} catch {
    Write-HumanOutput "  ERROR writing registry: $($_.Exception.Message)" -ForegroundColor Red
    Write-AIOutput @{
        summary = "ERROR writing registry: $($_.Exception.Message)"
        registry_setting = "GlobalTimerResolutionRequests"
        setting_value = 1
        status = "error"
        reboot_required = $true
    }
    return
}

Write-HumanOutput ""
Write-HumanOutput "Done. REBOOT for it to take effect." -ForegroundColor Yellow
Write-HumanOutput "After the reboot, Watch-TimerResolution.ps1 should show ~1 ms or better" -ForegroundColor DarkGray
Write-HumanOutput "while the sim runs, even when the sim window doesn't have focus." -ForegroundColor DarkGray

# --- AI Output ---
Write-AIOutput @{
    summary = "Enabled global high-resolution timer requests"
    registry_setting = "GlobalTimerResolutionRequests"
    setting_value = 1
    status = "completed"
    reboot_required = $true
}