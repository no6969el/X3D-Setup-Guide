<#
    Invoke-X3DScan.ps1
    Reads the Windows settings the fixer scripts can actually change.
    When a check fails, runs that fixer, then reads the value again.
    Writes one JSON report and appends it to history. DryRun changes nothing
    and writes no report.

    BIOS, EXPO, SoC voltage, and Curve Optimizer are reported as
    not_fixable_from_windows. This script does not call a model and does
    not write a voltage.
#>
param(
    [switch]$DryRun,
    [switch]$PassThru
)

$ErrorActionPreference = 'Continue'

$reportDir = Join-Path $env:ProgramData 'X3DTuner'
$reportFile = Join-Path $reportDir 'latest-report.json'
$historyFile = Join-Path $reportDir 'history.jsonl'
$pendingFile = Join-Path $reportDir 'pending-reboot.json'

function New-ItemResult {
    param(
        [string]$Id,
        [string]$Status,
        $Before,
        $After,
        [string]$Script,
        [bool]$RebootRequired,
        [string]$Detail
    )
    return @{
        id = $Id
        status = $Status
        before = "$Before"
        after = "$After"
        script = $Script
        reboot_required = $RebootRequired
        detail = $Detail
    }
}

function Get-DwordValue {
    param([string]$Path, [string]$Name)
    try {
        if (-not (Test-Path -LiteralPath $Path)) { return $null }
        $item = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction Stop
        return $item.$Name
    } catch { return $null }
}

function Get-UsbSuspend {
    $text = & powercfg /q SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 2>&1 | Out-String
    $acMatch = [regex]::Match($text, 'Current AC Power Setting Index:\s*0x([0-9a-fA-F]+)')
    $dcMatch = [regex]::Match($text, 'Current DC Power Setting Index:\s*0x([0-9a-fA-F]+)')
    $ac = $null
    $dc = $null
    if ($acMatch.Success) { $ac = [Convert]::ToInt32($acMatch.Groups[1].Value, 16) }
    if ($dcMatch.Success) { $dc = [Convert]::ToInt32($dcMatch.Groups[1].Value, 16) }
    $off = ($ac -eq 0 -and $dc -eq 0)
    return @{ Off = $off; Text = "ac=$ac dc=$dc" }
}

function Get-GameModeState {
    $dvr = Get-DwordValue 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled'
    $mode = Get-DwordValue 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled'
    $allow = Get-DwordValue 'HKCU:\Software\Microsoft\GameBar' 'AllowAutoGameMode'
    $policy = Get-DwordValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR'
    $off = ($dvr -eq 0 -and $mode -eq 0 -and $allow -eq 0 -and $policy -eq 0)
    return @{ Off = $off; Text = "dvr=$dvr mode=$mode allow=$allow policy=$policy" }
}

function Get-TimerState {
    $value = Get-DwordValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'GlobalTimerResolutionRequests'
    return @{ Set = ($value -eq 1); Text = "GlobalTimerResolutionRequests=$value" }
}

function Get-AffinityCores {
    param([string]$Key)
    if (-not (Test-Path -LiteralPath $Key)) { return $null }
    $item = Get-ItemProperty -LiteralPath $Key -ErrorAction SilentlyContinue
    if (-not $item -or $item.DevicePolicy -ne 4 -or -not $item.AssignmentSetOverride) { return @() }
    $bytes = $item.AssignmentSetOverride
    $mask = [uint64]0
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        $mask = $mask -bor ([uint64]$bytes[$i] -shl (8 * $i))
    }
    $cores = @()
    for ($bit = 0; $bit -lt 64; $bit++) {
        if ((($mask -shr $bit) -band [uint64]1) -eq 1) { $cores += $bit }
    }
    return $cores
}

function Get-GpuIrqState {
    param([int]$TargetCore)
    $gpus = @(Get-PnpDevice -Class Display -Status OK -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -match 'VEN_10DE' })
    if ($gpus.Count -eq 0) {
        return @{ Ok = $false; MissingDevice = $true; Text = 'no active NVIDIA display device' }
    }
    $parts = @()
    $ok = $true
    foreach ($gpu in $gpus) {
        $key = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($gpu.InstanceId)\Device Parameters\Interrupt Management\Affinity Policy"
        $cores = @(Get-AffinityCores $key)
        $hit = ($cores -contains $TargetCore)
        if (-not $hit) { $ok = $false }
        $shown = if ($cores.Count -eq 0) { 'unset' } else { ($cores -join ',') }
        $parts += "$($gpu.FriendlyName)=$shown"
    }
    return @{ Ok = $ok; MissingDevice = $false; Text = ($parts -join '; ') }
}

function Get-NicUsbTargets {
    $found = @()
    $nics = @(Get-PnpDevice -Class Net -Status OK -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -like 'PCI\*' })
    $usb = @(Get-PnpDevice -Class USB -Status OK -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -like 'PCI\*' })
    foreach ($device in ($nics + $usb)) {
        $found += [pscustomobject]@{ Name = $device.FriendlyName; Id = $device.InstanceId }
    }
    return $found
}

function Get-NicUsbIrqState {
    param([int[]]$AllowedCores)
    $devices = @(Get-NicUsbTargets)
    if ($devices.Count -eq 0) {
        return @{ Ok = $true; Empty = $true; Text = 'no PCI NIC or USB host controller' }
    }
    $parts = @()
    $ok = $true
    foreach ($device in $devices) {
        $key = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($device.Id)\Device Parameters\Interrupt Management\Affinity Policy"
        $cores = @(Get-AffinityCores $key)
        $hit = $false
        foreach ($core in $cores) {
            if ($AllowedCores -contains $core) { $hit = $true }
        }
        if (-not $hit) { $ok = $false }
        $shown = if ($cores.Count -eq 0) { 'unset' } else { ($cores -join ',') }
        $parts += "$($device.Name)=$shown"
    }
    return @{ Ok = $ok; Empty = $false; Text = ($parts -join '; ') }
}

function Test-PerfCounters {
    try {
        $sample = @(Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor -ErrorAction Stop | Select-Object -First 1)
        return @{ Ok = ($sample.Count -gt 0); Text = $(if ($sample.Count -gt 0) { 'processor counter responded' } else { 'processor counter returned no samples' }) }
    } catch {
        return @{ Ok = $false; Text = "counter query failed: $($_.Exception.Message)" }
    }
}

function Read-Pending {
    if (-not (Test-Path -LiteralPath $pendingFile)) { return @{} }
    try {
        $parsed = Get-Content -LiteralPath $pendingFile -Raw | ConvertFrom-Json
        $map = @{}
        foreach ($property in $parsed.PSObject.Properties) { $map[$property.Name] = [string]$property.Value }
        return $map
    } catch { return @{} }
}

function Write-Pending {
    param($Map)
    if ($DryRun) { return }
    if (-not (Test-Path -LiteralPath $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    $json = $Map | ConvertTo-Json
    [System.IO.File]::WriteAllText($pendingFile, $json)
}

function Invoke-FixerScript {
    param([string]$Name, [switch]$GuideExtras)
    $path = Join-Path $PSScriptRoot $Name
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing $Name" }
    if ($GuideExtras) {
        & $path -OutputFormat human *>&1 | Out-Host
    } else {
        & $path *>&1 | Out-Host
    }
}

function Get-UndervoltEvidence {
    $csv = Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'undervolt_results_*.csv' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    $logPath = Join-Path $PSScriptRoot 'undervolt_test_log.txt'
    $crashCore = $null
    if (Test-Path -LiteralPath $logPath) {
        try {
            $tail = @(Get-Content -LiteralPath $logPath -Tail 100)
            $suspect = $null
            $index = -1
            for ($i = $tail.Count - 1; $i -ge 0; $i--) {
                if ($tail[$i] -match 'begin core (\d+)') { $suspect = $Matches[1]; $index = $i; break }
            }
            if ($null -ne $suspect) {
                $after = $tail[$index..($tail.Count - 1)]
                $resolved = ($after -match ("core {0}\b.*(PASS|FAIL|WHEA)" -f $suspect)) -or ($after -match 'RUN END')
                if (-not $resolved) { $crashCore = $suspect }
            }
        } catch { }
    }

    $detail = 'Windows cannot read or write Curve Optimizer. No voltage was changed.'
    $before = 'no_run'
    if ($null -ne $crashCore) {
        $detail = "A stability run stopped while testing core $crashCore and never recorded that core. $detail"
        $before = "unresolved_core=$crashCore"
    }
    if ($csv) {
        $rows = @(Import-Csv -LiteralPath $csv.FullName)
        $pass = @($rows | Where-Object { $_.Status -eq 'pass' }).Count
        $failRows = @($rows | Where-Object { $_.Status -eq 'FAIL' -or $_.Status -eq 'WHEA' -or ([int]$_.Whea) -gt 0 })
        $whea = 0
        foreach ($row in $rows) { try { $whea += [int]$row.Whea } catch { } }
        $failIds = @($failRows | ForEach-Object { $_.Core })
        $before = "$($csv.Name) pass=$pass fail=$($failRows.Count) whea=$whea"
        $detail = "Latest stability CSV $($csv.Name): $pass passed, $($failRows.Count) failed, $whea WHEA."
        if ($failIds.Count -gt 0) { $detail += " Failed cores: $($failIds -join ', ')." }
        if ($null -ne $crashCore) { $detail += " Unresolved crash core: $crashCore." }
        $detail += ' Curve Optimizer was not changed.'
    } elseif ($null -eq $crashCore) {
        $detail = "No stability CSV is on disk. $detail"
    }
    return (New-ItemResult -Id 'curve_optimizer' -Status 'not_fixable_from_windows' -Before $before -After 'not_changed' -Script '' -RebootRequired $false -Detail $detail)
}

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$canWrite = ($admin -and -not $DryRun)

. (Join-Path $PSScriptRoot 'X3D-Profiles.ps1')
if ($DryRun) { $profile = Get-X3DProfile -NoCache -NoSave } else { $profile = Get-X3DProfile -NoCache }
$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$pending = Read-Pending
foreach ($key in @($pending.Keys)) {
    try {
        $applied = [datetime]::Parse($pending[$key])
        if ($boot -ge $applied) { [void]$pending.Remove($key) }
    } catch {
        [void]$pending.Remove($key)
    }
}

$items = @()
$simulated = [bool]$profile.Simulated
$canSteer = ([bool]$profile.TopologyKnown -and [bool]$profile.IsX3D -and [int]$profile.FreqFirst -ge 1 -and [int]$profile.FreqFirst -lt [int]$profile.ActualLogical)

function Add-FixItem {
    param(
        [string]$Id,
        [scriptblock]$Read,
        [string]$ScriptName,
        [bool]$Reboot,
        [switch]$GuideExtras,
        [string]$SkipDetail
    )
    $before = & $Read
    $rebootStill = [bool]$pending.ContainsKey($Id)
    if ($SkipDetail) {
        $script:items += New-ItemResult -Id $Id -Status 'already_ok' -Before $before.Text -After $before.Text -Script '' -RebootRequired $false -Detail $SkipDetail
        return
    }
    if ($before.Ok) {
        $detail = if ($rebootStill) { 'Value is set. Windows has not rebooted since it was applied.' } else { '' }
        $script:items += New-ItemResult -Id $Id -Status 'already_ok' -Before $before.Text -After $before.Text -Script '' -RebootRequired $rebootStill -Detail $detail
        return
    }
    if (-not $canWrite -or $simulated) {
        $why = if ($DryRun) { 'Dry run. Nothing was written.' } elseif ($simulated) { 'X3D_FORCE_PROFILE is set. Nothing was written.' } else { 'Administrator is required. Nothing was written.' }
        $needsReboot = $Reboot -and -not $DryRun -and -not $simulated -and $canWrite
        $script:items += New-ItemResult -Id $Id -Status $(if ($DryRun -or $simulated) { 'would_fix' } else { 'failed' }) -Before $before.Text -After $before.Text -Script $ScriptName -RebootRequired $needsReboot -Detail $why
        return
    }
    try {
        if ($GuideExtras) { Invoke-FixerScript -Name $ScriptName -GuideExtras } else { Invoke-FixerScript -Name $ScriptName }
    } catch {
        $script:items += New-ItemResult -Id $Id -Status 'failed' -Before $before.Text -After $before.Text -Script $ScriptName -RebootRequired $false -Detail $_.Exception.Message
        return
    }
    $after = & $Read
    if ($Reboot) { $pending[$Id] = (Get-Date).ToString('o') }
    if ($after.Ok) {
        $script:items += New-ItemResult -Id $Id -Status 'fixed' -Before $before.Text -After $after.Text -Script $ScriptName -RebootRequired $Reboot -Detail $(if ($Reboot) { 'Reboot, then run the scan again.' } else { '' })
    } else {
        $script:items += New-ItemResult -Id $Id -Status 'failed' -Before $before.Text -After $after.Text -Script $ScriptName -RebootRequired $false -Detail 'The fixer ran and the check is still wrong.'
    }
}

Add-FixItem -Id 'guide_extras' -ScriptName 'Apply-Guide-Extras.ps1' -GuideExtras -Reboot $false -Read {
    $u = Get-UsbSuspend
    $g = Get-GameModeState
    return @{ Ok = ($u.Off -and $g.Off); Text = "$($u.Text); $($g.Text)" }
}

Add-FixItem -Id 'global_timer' -ScriptName 'Enable-GlobalTimerResolution.ps1' -Reboot $true -Read {
    $t = Get-TimerState
    return @{ Ok = $t.Set; Text = $t.Text }
}

if (-not $canSteer) {
    $reason = if (-not $profile.IsX3D) { 'Not an X3D CPU. Interrupt steering was left off.' } else { 'CPU topology is not known. Interrupt steering was left off.' }
    Add-FixItem -Id 'gpu_irq' -ScriptName '' -Reboot $false -SkipDetail $reason -Read { return @{ Ok = $true; Text = 'not_applicable' } }
    Add-FixItem -Id 'nic_usb_irq' -ScriptName '' -Reboot $false -SkipDetail $reason -Read { return @{ Ok = $true; Text = 'not_applicable' } }
} else {
    $gpuNow = Get-GpuIrqState -TargetCore ([int]$profile.FreqFirst)
    if ($gpuNow.MissingDevice) {
        $items += New-ItemResult -Id 'gpu_irq' -Status 'failed' -Before $gpuNow.Text -After $gpuNow.Text -Script '' -RebootRequired $false -Detail 'No NVIDIA GPU was found, so Set-GPU-IRQ-Affinity.ps1 was not run.'
    } else {
        Add-FixItem -Id 'gpu_irq' -ScriptName 'Set-GPU-IRQ-Affinity.ps1' -Reboot $true -Read {
            $g = Get-GpuIrqState -TargetCore ([int]$profile.FreqFirst)
            return @{ Ok = $g.Ok; Text = $g.Text }
        }
    }
    $allowed = @($profile.IrqTargets | ForEach-Object { [int]$_ })
    $nicNow = Get-NicUsbIrqState -AllowedCores $allowed
    if ($nicNow.Empty) {
        $items += New-ItemResult -Id 'nic_usb_irq' -Status 'already_ok' -Before $nicNow.Text -After $nicNow.Text -Script '' -RebootRequired $false -Detail ''
    } elseif ($allowed.Count -eq 0) {
        $items += New-ItemResult -Id 'nic_usb_irq' -Status 'failed' -Before $nicNow.Text -After $nicNow.Text -Script '' -RebootRequired $false -Detail 'No background CPU is available for NIC and USB interrupts.'
    } else {
        Add-FixItem -Id 'nic_usb_irq' -ScriptName 'Set-NIC-USB-IRQ-Affinity.ps1' -Reboot $true -Read {
            $cores = @($profile.IrqTargets | ForEach-Object { [int]$_ })
            $n = Get-NicUsbIrqState -AllowedCores $cores
            return @{ Ok = $n.Ok; Text = $n.Text }
        }
    }
}

Add-FixItem -Id 'perf_counters' -ScriptName 'Repair-PerfCounters.ps1' -Reboot $true -Read {
    $p = Test-PerfCounters
    return @{ Ok = $p.Ok; Text = $p.Text }
}

$items += New-ItemResult -Id 'expo' -Status 'not_fixable_from_windows' -Before 'not_measured' -After 'not_changed' -Script '' -RebootRequired $false -Detail 'EXPO is a BIOS setting. Windows cannot read or write it.'
$items += New-ItemResult -Id 'memory_context_restore' -Status 'not_fixable_from_windows' -Before 'not_measured' -After 'not_changed' -Script '' -RebootRequired $false -Detail 'Memory Context Restore is a BIOS setting. Windows cannot read or write it.'
$items += New-ItemResult -Id 'soc_voltage' -Status 'not_fixable_from_windows' -Before 'not_measured' -After 'not_changed' -Script '' -RebootRequired $false -Detail 'SoC voltage is a BIOS setting. Windows cannot read or write it.'
$items += Get-UndervoltEvidence

$os = Get-CimInstance Win32_OperatingSystem
$board = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$modules = @(Get-CimInstance Win32_PhysicalMemory)
$speed = $null
if ($modules.Count -gt 0) { $speed = $modules[0].ConfiguredClockSpeed }

$report = @{
    timestamp = (Get-Date).ToString('o')
    dry_run = [bool]$DryRun
    admin = [bool]$admin
    chip = @{
        model = [string]$profile.Model
        cpu_name = [string]$profile.CpuName
        cores = $profile.Cores
        logical_cores = $profile.LogicalCores
        topology = [string]$profile.Topology
        is_x3d = [bool]$profile.IsX3D
        vcache_range = [string]$profile.VCacheRange
        background_range = [string]$profile.BackgroundRange
        freq_first = $profile.FreqFirst
        irq_targets = @($profile.IrqTargets)
        topology_known = [bool]$profile.TopologyKnown
        simulated = $simulated
        advice = [string](Get-X3DPinningAdvice $profile)
        warnings = @($profile.Warnings)
    }
    measured = @{
        manufacturer = [string]$board.Manufacturer
        model = [string]$board.Model
        bios_version = [string]$bios.SMBIOSBIOSVersion
        os = [string]$os.Caption
        os_build = [string]$os.BuildNumber
        memory_modules = $modules.Count
        memory_speed_mhz = $speed
        last_boot = $boot.ToString('o')
    }
    items = @($items)
}

Write-Host ''
Write-Host 'X3D scan' -ForegroundColor Cyan
Write-Host ("  {0}" -f $report.chip.model)
Write-Host ("  {0}" -f $report.chip.advice)
if ($DryRun) { Write-Host '  Dry run. No settings and no report file were written.' -ForegroundColor Yellow }
foreach ($item in $items) {
    $rebootNote = if ($item.reboot_required) { ' reboot_required' } else { '' }
    Write-Host ("  {0,-24} {1}{2}" -f $item.id, $item.status, $rebootNote)
    if ($item.detail) { Write-Host ("    {0}" -f $item.detail) -ForegroundColor DarkGray }
}

if (-not $DryRun) {
    if (-not (Test-Path -LiteralPath $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    Write-Pending -Map $pending
    $json = $report | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($reportFile, $json)
    [System.IO.File]::AppendAllText($historyFile, (($report | ConvertTo-Json -Depth 8 -Compress) + [Environment]::NewLine))
    Write-Host ''
    Write-Host "Report: $reportFile"
    Write-Host "History: $historyFile"
}

if ($PassThru) { return $report }
