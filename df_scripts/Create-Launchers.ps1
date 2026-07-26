<#
    Create-Launchers.ps1
    ---------------------------------------------------------------
    Makes a double-click .lnk shortcut next to every .ps1 in this
    folder tree. Loggers open with -NoExit (window stays up to read
    results). Every script that changes a setting is flagged
    "Run as administrator" so its shortcut elevates automatically.
    Safe to re-run any time; it just refreshes the shortcuts.
    
    AI-BLOCK OUTPUT:
    {
      "tool_name": "Create-Launchers",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Created/refreshed launcher shortcuts for PowerShell scripts",
        "shortcuts_created": 0,
        "scripts_processed": [],
        "admin_scripts_flagged": []
      },
      "ai_structured": {
        "tool_name": "Create-Launchers",
        "version": "1.0.0",
        "output_format": "dual",
        "shortcuts_created": 0,
        "scripts_processed": [],
        "admin_scripts_flagged": [],
        "timestamp": "2026-07-26T11:43:43Z",
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
        tool_name = "Create-Launchers"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            shortcuts_created = $Data.shortcuts_created
            scripts_processed = $Data.scripts_processed
            admin_scripts_flagged = $Data.admin_scripts_flagged
        }
        ai_structured = @{
            tool_name = "Create-Launchers"
            version = "1.0.0"
            output_format = "dual"
            shortcuts_created = $Data.shortcuts_created
            scripts_processed = $Data.scripts_processed
            admin_scripts_flagged = $Data.admin_scripts_flagged
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$adminScripts = @(
    'Set-GPU-IRQ-Affinity.ps1','Undo-GPU-IRQ-Affinity.ps1',
    'Set-NIC-USB-IRQ-Affinity.ps1','Undo-NIC-USB-IRQ-Affinity.ps1',
    'Pre-Race-Quiet.ps1','Post-Race-Restore.ps1',
    'Add-Defender-Exclusions.ps1','Apply-Guide-Extras.ps1','Undo-Guide-Extras.ps1',
    'Repair-PerfCounters.ps1','Enable-DiagnosticLogs.ps1',
    'Enable-GlobalTimerResolution.ps1','Undo-GlobalTimerResolution.ps1'
)
$wsh = New-Object -ComObject WScript.Shell
$made = 0
$scriptsProcessed = @()
$adminScriptsFlagged = @()

# Skip this script, the shared library (never run directly), and the dev tests.
$skipNames = @('Create-Launchers.ps1','X3D-Profiles.ps1')
Get-ChildItem -Path $root -Recurse -Filter *.ps1 |
    Where-Object { $skipNames -notcontains $_.Name -and $_.FullName -notmatch '\\tests\\' } |
    ForEach-Object {
    $ps1  = $_.FullName
    $dir  = $_.DirectoryName
    $lnk  = Join-Path $dir ($_.BaseName + '.lnk')

    $s = $wsh.CreateShortcut($lnk)
    $s.TargetPath       = 'powershell.exe'
    $s.Arguments        = '-NoExit -ExecutionPolicy Bypass -File "' + $ps1 + '"'
    $s.WorkingDirectory = $dir
    $s.IconLocation     = 'powershell.exe,0'
    $s.Description      = 'Launch ' + $_.Name
    $s.Save()

    # set "Run as administrator" bit for the scripts that need it
    if($adminScripts -contains $_.Name){
        $b = [System.IO.File]::ReadAllBytes($lnk)
        $b[0x15] = $b[0x15] -bor 0x20      # flag: run as admin
        [System.IO.File]::WriteAllBytes($lnk, $b)
        $adminScriptsFlagged += $_.Name
    }

    Write-HumanOutput ("shortcut -> {0}" -f $lnk) -ForegroundColor Green
    $made++
    $scriptsProcessed += $_.Name
}

Write-HumanOutput ""
Write-HumanOutput ("Done. Created/refreshed $made shortcut(s), one next to each script.") -ForegroundColor Cyan

# --- AI Output ---
Write-AIOutput @{
    summary = "Created/refreshed launcher shortcuts for PowerShell scripts"
    shortcuts_created = $made
    scripts_processed = $scriptsProcessed
    admin_scripts_flagged = $adminScriptsFlagged
}