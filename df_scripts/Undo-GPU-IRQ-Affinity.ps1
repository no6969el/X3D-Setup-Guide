<#
    Undo GPU interrupt steering — restores default (machine-chosen) IRQ routing.
    MUST run as Administrator. Reboot afterward.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Undo-GPU-IRQ-Affinity",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "GPU IRQ affinity undone",
        "gpus_processed": [],
        "reboot_required": true,
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Undo-GPU-IRQ-Affinity",
        "version": "1.0.0",
        "output_format": "dual",
        "gpus_processed": [],
        "reboot_required": true,
        "status": "completed",
        "timestamp": "2026-07-26T11:51:38Z",
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
        tool_name = "Undo-GPU-IRQ-Affinity"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            gpus_processed = $Data.gpus_processed
            reboot_required = $Data.reboot_required
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Undo-GPU-IRQ-Affinity"
            version = "1.0.0"
            output_format = "dual"
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

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if(-not $admin){ 
    Write-HumanOutput "ERROR: Run as Administrator." 
    Write-AIOutput @{
        summary = "ERROR: Run as Administrator."
        gpus_processed = @()
        reboot_required = true
        status = "error"
    }
    return 
}

$gpusProcessed = @()
$gpus = Get-PnpDevice -Class Display -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -match 'VEN_10DE' }
foreach($g in $gpus){
    $key = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($g.InstanceId)\Device Parameters\Interrupt Management\Affinity Policy"
    if(Test-Path $key){
        Remove-Item -Path $key -Recurse -Force
        Write-Host "Removed IRQ affinity override for: $($g.FriendlyName)" -ForegroundColor Green
        $gpusProcessed += "$($g.FriendlyName) - Removed IRQ affinity override"
    } else {
        Write-Host "No override present for: $($g.FriendlyName)" -ForegroundColor DarkGray
        $gpusProcessed += "$($g.FriendlyName) - No override present"
    }
}
Write-Host "Done. Reboot to return to default interrupt routing." -ForegroundColor Yellow

# --- AI Output ---
Write-AIOutput @{
    summary = "GPU IRQ affinity undone"
    gpus_processed = $gpusProcessed
    reboot_required = true
    status = "completed"
}