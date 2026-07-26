<#
    Enable-DiagnosticLogs.ps1
    ---------------------------------------------------------------
    Turns on the logs needed to catch periodic stutters:
      * TaskScheduler/Operational  - so we can see which task fired
      * Kernel-Processor-Power/... - power/parking state changes
    Read-mostly: only enables event logs, changes nothing else.
    RUN AS ADMINISTRATOR. No reboot needed.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Enable-DiagnosticLogs",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Enabled diagnostic logs for stutter detection",
        "logs_enabled": [],
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Enable-DiagnosticLogs",
        "version": "1.0.0",
        "output_format": "dual",
        "logs_enabled": [],
        "status": "completed",
        "timestamp": "2026-07-26T11:44:15Z",
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
        tool_name = "Enable-DiagnosticLogs"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            logs_enabled = $Data.logs_enabled
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Enable-DiagnosticLogs"
            version = "1.0.0"
            output_format = "dual"
            logs_enabled = $Data.logs_enabled
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
        logs_enabled = @()
        status = "error"
    }
    return 
}

$logs = @(
    'Microsoft-Windows-TaskScheduler/Operational',
    'Microsoft-Windows-Kernel-Processor-Power/Diagnostic'
)

$logsEnabled = @()

foreach ($log in $logs) {
    try {
        # /q:true auto-confirms the "analytic/debug logs will be cleared" prompt
        & wevtutil sl "$log" /enabled:true /q:true
        Write-HumanOutput "Enabled: $log" -ForegroundColor Green
        $logsEnabled += $log
    } catch {
        Write-HumanOutput "Could not enable $log : $_" -ForegroundColor Yellow
    }
}

Write-HumanOutput ""
Write-HumanOutput "Done. These now record - re-run your test session, then Scan-Stutter-Events.ps1." -ForegroundColor Cyan

# --- AI Output ---
Write-AIOutput @{
    summary = "Enabled diagnostic logs for stutter detection"
    logs_enabled = $logsEnabled
    status = "completed"
}