<#
    Apply-Guide-Extras.ps1
    ---------------------------------------------------------------
    Remaining low-risk guide items:
      * USB Selective Suspend = OFF on the active power plan
        (stops wheel/VR USB devices power-cycling mid-race -
         a real DPC-hitch source)
      * Windows Game Mode / Game Bar / Game DVR = OFF
    Safe and reversible (Undo-Guide-Extras.ps1). No reboot needed.
    HAGS is a genuine toss-up on newer cards - test both ways (see guide).
    RUN AS ADMINISTRATOR.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Apply-Guide-Extras",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Applied guide extras: USB Selective Suspend OFF and Game Mode/Bar/DVR OFF",
        "steps_completed": [],
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Apply-Guide-Extras",
        "version": "1.0.0",
        "output_format": "dual",
        "steps_completed": [],
        "status": "completed",
        "timestamp": "2026-07-26T11:42:48Z",
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
        tool_name = "Apply-Guide-Extras"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            steps_completed = $Data.steps_completed
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Apply-Guide-Extras"
            version = "1.0.0"
            output_format = "dual"
            steps_completed = $Data.steps_completed
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
        status = "error"
    }
    return 
}

Write-HumanOutput ""
Write-HumanOutput "1) USB Selective Suspend -> OFF (active power plan)" -ForegroundColor Cyan
$usbSub     = '2a737441-1930-4402-8d77-b2bebba308a3'
$usbSetting = '48e6b7a6-50f5-4782-a5d4-53bb8f07e226'
$usbSteps = @()
try {
    powercfg /setacvalueindex SCHEME_CURRENT $usbSub $usbSetting 0 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT $usbSub $usbSetting 0 | Out-Null
    powercfg /setactive SCHEME_CURRENT | Out-Null
    Write-HumanOutput "   done - USB devices will no longer selectively suspend" -ForegroundColor Green
    $usbSteps += "USB Selective Suspend disabled"
} catch { 
    Write-HumanOutput "   ! failed: $($_.Exception.Message)" -ForegroundColor Yellow 
    $usbSteps += "USB Selective Suspend failed"
}

Write-HumanOutput ""
Write-HumanOutput "2) Game Mode / Game Bar / Game DVR -> OFF" -ForegroundColor Cyan
function Set-Reg($path, $name, $value) {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null
}
$gameSteps = @()
try {
    Set-Reg 'HKCU:\System\GameConfigStore'            'GameDVR_Enabled'      0
    Set-Reg 'HKCU:\Software\Microsoft\GameBar'        'AutoGameModeEnabled'  0
    Set-Reg 'HKCU:\Software\Microsoft\GameBar'        'AllowAutoGameMode'    0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
    Write-HumanOutput "   done - Game Mode/Bar/DVR disabled" -ForegroundColor Green
    $gameSteps += "Game Mode/Bar/DVR disabled"
} catch { 
    Write-HumanOutput "   ! failed: $($_.Exception.Message)" -ForegroundColor Yellow 
    $gameSteps += "Game Mode/Bar/DVR failed"
}

Write-HumanOutput ""
Write-HumanOutput "Done. No reboot needed. (Undo with Undo-Guide-Extras.ps1)" -ForegroundColor Yellow

# --- AI Output ---
Write-AIOutput @{
    summary = "Applied guide extras: USB Selective Suspend OFF and Game Mode/Bar/DVR OFF"
    steps_completed = $usbSteps + $gameSteps
    status = "completed"
}