<#
    Undo-GlobalTimerResolution.ps1
    ---------------------------------------------------------------
    Reverts Enable-GlobalTimerResolution.ps1: removes the
    GlobalTimerResolutionRequests value so Windows 11 goes back to its
    default focus-dependent timer behavior.
    RUN AS ADMINISTRATOR. REBOOT for it to take effect.

    AI-BLOCK OUTPUT:
    {
      "tool_name": "Undo-GlobalTimerResolution",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Global timer resolution reverted",
        "action": "removed",
        "key": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel",
        "property": "GlobalTimerResolutionRequests",
        "reboot_required": true,
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Undo-GlobalTimerResolution",
        "version": "1.0.0",
        "output_format": "dual",
        "summary": "Global timer resolution reverted",
        "action": "removed",
        "key": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel",
        "property": "GlobalTimerResolutionRequests",
        "reboot_required": true,
        "status": "completed",
        "timestamp": "2026-07-26T11:55:00Z",
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
        tool_name = "Undo-GlobalTimerResolution"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            action = $Data.action
            key = $Data.key
            property = $Data.property
            reboot_required = $Data.reboot_required
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Undo-GlobalTimerResolution"
            version = "1.0.0"
            output_format = "dual"
            summary = $Data.summary
            action = $Data.action
            key = $Data.key
            property = $Data.property
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
        action = "none"
        key = ""
        property = ""
        reboot_required = false
        status = "error"
    }
    return 
}

$key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'

if (Get-ItemProperty -Path $key -Name 'GlobalTimerResolutionRequests' -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path $key -Name 'GlobalTimerResolutionRequests' -Force
    Write-HumanOutput "Removed GlobalTimerResolutionRequests - default behavior restored." -ForegroundColor Green
    Write-AIOutput @{
        summary = "Global timer resolution reverted"
        action = "removed"
        key = $key
        property = "GlobalTimerResolutionRequests"
        reboot_required = true
        status = "completed"
    }
} else {
    Write-HumanOutput "GlobalTimerResolutionRequests not set - nothing to undo." -ForegroundColor DarkGray
    Write-AIOutput @{
        summary = "Global timer resolution reverted"
        action = "none"
        key = $key
        property = "GlobalTimerResolutionRequests"
        reboot_required = false
        status = "completed"
    }
}

Write-HumanOutput "Done. Reboot for it to take effect." -ForegroundColor Yellow