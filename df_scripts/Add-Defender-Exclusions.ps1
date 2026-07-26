<#
    Add-Defender-Exclusions.ps1
    ---------------------------------------------------------------
    Stops Windows Defender from scanning iRacing's files, a source of
    continuous hard-pagefault micro-stalls mid-race (Defender scanning
    every texture/asset read). Auto-detects your iRacing
    install + Documents folder and excludes them, plus the sim
    processes. Keeps Defender fully active everywhere else.

    RUN AS ADMINISTRATOR. No reboot needed. Persists.
    (To undo later: Remove-MpPreference -ExclusionPath "<path>")

    AI-BLOCK OUTPUT:
    {
      "tool_name": "Add-Defender-Exclusions",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "Added Windows Defender exclusions for iRacing folders and processes",
        "folders_excluded": [],
        "processes_excluded": [],
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "Add-Defender-Exclusions",
        "version": "1.0.0",
        "output_format": "dual",
        "folders_excluded": [],
        "processes_excluded": [],
        "status": "completed",
        "timestamp": "2026-07-26T11:41:01Z",
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
        tool_name = "Add-Defender-Exclusions"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            folders_excluded = $Data.folders_excluded
            processes_excluded = $Data.processes_excluded
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "Add-Defender-Exclusions"
            version = "1.0.0"
            output_format = "dual"
            folders_excluded = $Data.folders_excluded
            processes_excluded = $Data.processes_excluded
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
    Write-HumanOutput "ERROR: right-click PowerShell -> Run as Administrator, then re-run."
    Write-AIOutput @{
        summary = "ERROR: right-click PowerShell -> Run as Administrator, then re-run."
        folders_excluded = @()
        processes_excluded = @()
        status = "error"
    }
    return 
}

if (-not (Get-Command Add-MpPreference -ErrorAction SilentlyContinue)) {
    Write-HumanOutput "ERROR: Windows Defender cmdlets not available (third-party AV?). Add exclusions in that product instead."
    Write-AIOutput @{
        summary = "ERROR: Windows Defender cmdlets not available (third-party AV?). Add exclusions in that product instead."
        folders_excluded = @()
        processes_excluded = @()
        status = "error"
    }
    return 
}

Write-HumanOutput ""
Write-HumanOutput "Locating iRacing folders..." -ForegroundColor Cyan

$paths = New-Object System.Collections.Generic.List[string]

# 1) Documents\iRacing (setups, replays, telemetry, caches) - almost always exists
$docs = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'iRacing'
if (Test-Path $docs) { $paths.Add($docs) }

# 2) install dir from a running iRacing process, if any
$proc = Get-Process iRacingSim64DX11, iRacingUI, iRacingService64 -ErrorAction SilentlyContinue | Where-Object { $_.Path } | Select-Object -First 1
if ($proc) { $paths.Add((Split-Path $proc.Path)) }

# 3) scan drives for common install locations
$subs = @(
    'SteamLibrary\steamapps\common\iRacing',
    'Steam\steamapps\common\iRacing',
    'Program Files (x86)\Steam\steamapps\common\iRacing',
    'Program Files (x86)\iRacing',
    'Program Files\iRacing'
)
foreach ($root in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue).Root) {
    foreach ($sub in $subs) {
        $c = Join-Path $root $sub
        if (Test-Path $c) { $paths.Add($c) }
    }
}

$paths = $paths | Sort-Object -Unique

if (-not $paths) {
    Write-HumanOutput "Could not auto-find the iRacing install folder." -ForegroundColor Yellow
    Write-HumanOutput "Edit this script and add your install path to the \$subs list above, then re-run." -ForegroundColor Yellow
    Write-AIOutput @{
        summary = "Could not auto-find the iRacing install folder."
        folders_excluded = @()
        processes_excluded = @()
        status = "warning"
    }
    return
}

# --- add folder exclusions ---
Write-HumanOutput ""
Write-HumanOutput "Adding folder exclusions:" -ForegroundColor Cyan
$foldersAdded = @()
foreach ($p in $paths) {
    try { Add-MpPreference -ExclusionPath $p -ErrorAction Stop; Write-HumanOutput "  + $p" -ForegroundColor Green; $foldersAdded += $p }
    catch { Write-HumanOutput "  ! failed: $p ($($_.Exception.Message))" -ForegroundColor Yellow }
}

# --- add process exclusions ---
Write-HumanOutput ""
Write-HumanOutput "Adding process exclusions:" -ForegroundColor Cyan
$processesAdded = @()
foreach ($ex in 'iRacingSim64DX11.exe','iRacingUI.exe','iRacingService64.exe') {
    try { Add-MpPreference -ExclusionProcess $ex -ErrorAction Stop; Write-HumanOutput "  + $ex" -ForegroundColor Green; $processesAdded += $ex }
    catch { Write-HumanOutput "  ! failed: $ex" -ForegroundColor Yellow }
}

# --- confirm ---
Write-HumanOutput ""
Write-HumanOutput "Current Defender exclusions now set:" -ForegroundColor Cyan
$prefs = Get-MpPreference
Write-HumanOutput "  Paths:" -ForegroundColor Gray
$prefs.ExclusionPath | ForEach-Object { Write-HumanOutput "    $_" }
Write-HumanOutput "  Processes:" -ForegroundColor Gray
$prefs.ExclusionProcess | ForEach-Object { Write-HumanOutput "    $_" }

Write-HumanOutput ""
Write-HumanOutput "Done. Defender still protects everything else - it just won't scan iRacing's files now." -ForegroundColor Green

# --- AI Output ---
Write-AIOutput @{
    summary = "Added Windows Defender exclusions for iRacing folders and processes"
    folders_excluded = $foldersAdded
    processes_excluded = $processesAdded
    status = "completed"
}