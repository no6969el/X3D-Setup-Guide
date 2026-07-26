<#
    Undo-NIC-USB-IRQ-Affinity.ps1
    ---------------------------------------------------------------
    Removes the interrupt-affinity overrides set by
    Set-NIC-USB-IRQ-Affinity.ps1, restoring default routing for the
    physical NIC(s) and USB host controllers.
    MUST run as Administrator. REBOOT after.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Undo-NIC-USB-IRQ-Affinity",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "NIC/USB IRQ affinity undone",
        "devices_processed": [],
        "reboot_required": true,
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Undo-NIC-USB-IRQ-Affinity",
        "version": "1.0.0",
        "output_format": "dual",
        "devices_processed": [],
        "reboot_required": true,
        "status": "completed",
        "timestamp": "2026-07-26T11:51:51Z",
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
        tool_name = "Undo-NIC-USB-IRQ-Affinity"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            devices_processed = $Data.devices_processed
            reboot_required = $Data.reboot_required
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Undo-NIC-USB-IRQ-Affinity"
            version = "1.0.0"
            output_format = "dual"
            devices_processed = $Data.devices_processed
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
        devices_processed = @()
        reboot_required = true
        status = "error"
    }
    return 
}

$devicesProcessed = @()
$nics = Get-PnpDevice -Class Net -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -like 'PCI\*' }
$usb  = Get-PnpDevice -Class USB -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -like 'PCI\*' }

$all = @()
foreach ($d in @($nics) + @($usb)) { $all += $d }

foreach ($d in $all) {
    $key = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($d.InstanceId)\Device Parameters\Interrupt Management\Affinity Policy"
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force
        Write-Host ("  reverted: {0}" -f $d.FriendlyName) -ForegroundColor Green
        $devicesProcessed += "$($d.FriendlyName) - Reverted IRQ affinity"
    }
}

Write-Host ""
Write-Host "Done. Reboot to return to default interrupt routing." -ForegroundColor Yellow

# --- AI Output ---
Write-AIOutput @{
    summary = "NIC/USB IRQ affinity undone"
    devices_processed = $devicesProcessed
    reboot_required = true
    status = "completed"
}