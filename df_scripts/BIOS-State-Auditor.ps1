#!/bin/PowerShell

<#
.SYNOPSIS
    BIOS State Auditor for X3D Systems
.DESCRIPTION
    Reports the BIOS version string and the memory modules Windows can see.
    EXPO, memory context restore, SoC voltage, and Curve Optimizer are not
    readable here. This script does not invent those values and does not
    report a pass.
    
.EXAMPLE
    .\BIOS-State-Auditor.ps1
    
.NOTES
    This tool is designed to be run in a Windows environment with appropriate permissions
    to access system information and BIOS settings. It outputs both human-readable 
    reports and structured AI-block formatted output for troubleshooting.
#>

param(
    [string]$OutputFormat = "both"  # "human", "ai", or "both"
)

# Initialize result objects
$auditResults = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    SystemInfo = @{}
    MemorySettings = @{}
    VoltageSettings = @{}
    PBOSettings = @{}
    SchedulingSettings = @{}
    OverallStatus = "Unknown"
    Issues = @()
}

# Helper function to write human-readable output
function Write-HumanOutput {
    param([hashtable]$Data)
    
    Write-Host "`n=== BIOS STATE AUDITOR REPORT ===" -ForegroundColor Green
    Write-Host "Timestamp: $($Data.Timestamp)" 
    Write-Host ""
    
    Write-Host "SYSTEM INFORMATION:" -ForegroundColor Yellow
    foreach ($key in $Data.SystemInfo.Keys) {
    Write-Host "  ${key}: $($Data.SystemInfo[$key])"
    }
    
    Write-Host "`nMEMORY SETTINGS:" -ForegroundColor Yellow
    foreach ($key in $Data.MemorySettings.Keys) {
    Write-Host "  ${key}: $($Data.MemorySettings[$key])"
    }
    
    Write-Host "`nVOLTAGE SETTINGS:" -ForegroundColor Yellow  
    foreach ($key in $Data.VoltageSettings.Keys) {
    Write-Host "  ${key}: $($Data.VoltageSettings[$key])"
    }
    
    Write-Host "`nPBO SETTINGS:" -ForegroundColor Yellow
    foreach ($key in $Data.PBOSettings.Keys) {
    Write-Host "  ${key}: $($Data.PBOSettings[$key])"
    }
    
    Write-Host "`nSCHEDULING SETTINGS:" -ForegroundColor Yellow
    foreach ($key in $Data.SchedulingSettings.Keys) {
    Write-Host "  ${key}: $($Data.SchedulingSettings[$key])"
    }
    
    $statusColor = switch ($Data.OverallStatus) { 'PASS' { 'Green' } 'not_measured' { 'Yellow' } default { 'Red' } }
    Write-Host "`nOVERALL STATUS: $($Data.OverallStatus)" -ForegroundColor $statusColor
    
    if ($Data.Issues.Count -gt 0) {
        Write-Host "`nISSUES DETECTED:" -ForegroundColor Red
        foreach ($issue in $Data.Issues) {
            Write-Host "  - $issue"
        }
    }
}

# Helper function to write AI-block formatted output
function Write-AIOutput {
    param([hashtable]$Data)
    
    Write-Host "`n=== AI-BLOCK OUTPUT ===" -ForegroundColor Cyan
    
    # System information block
    Write-Host "[SYSTEM_INFO]"
    foreach ($key in $Data.SystemInfo.Keys) {
        Write-Host "$key=$($Data.SystemInfo[$key])"
    }
    
    # Memory settings block  
    Write-Host "`n[MEMORY_SETTINGS]"
    foreach ($key in $Data.MemorySettings.Keys) {
        Write-Host "$key=$($Data.MemorySettings[$key])"
    }
    
    # Voltage settings block
    Write-Host "`n[VOLTAGE_SETTINGS]" 
    foreach ($key in $Data.VoltageSettings.Keys) {
        Write-Host "$key=$($Data.VoltageSettings[$key])"
    }
    
    # PBO settings block
    Write-Host "`n[PBO_SETTINGS]"
    foreach ($key in $Data.PBOSettings.Keys) {
        Write-Host "$key=$($Data.PBOSettings[$key])"
    }
    
    # Scheduling settings block  
    Write-Host "`n[SCHEDULING_SETTINGS]"
    foreach ($key in $Data.SchedulingSettings.Keys) {
        Write-Host "$key=$($Data.SchedulingSettings[$key])"
    }
    
    # Overall status and issues
    Write-Host "`n[OVERALL_STATUS]"
    Write-Host "status=$($Data.OverallStatus)"
    
    if ($Data.Issues.Count -gt 0) {
        Write-Host "`n[ISSUES]"
        foreach ($issue in $Data.Issues) {
            Write-Host "issue=$issue"
        }
    }
}

# Function to get system information
function Get-SystemInfo {
    try {
        $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
        $bios = Get-WmiObject -Class Win32_BIOS
        
        $auditResults.SystemInfo = @{
            "Manufacturer" = $computerSystem.Manufacturer
            "Model" = $computerSystem.Model  
            "TotalPhysicalMemoryGB" = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
            "BIOSVersion" = $bios.SMBIOSBIOSVersion
            "BIOSReleaseDate" = $bios.ReleaseDate
        }
    } catch {
        Write-Warning "Could not retrieve system information: $_"
        $auditResults.SystemInfo = @{
            "Manufacturer" = "Unknown"
            "Model" = "Unknown"
            "TotalPhysicalMemoryGB" = 0  
            "BIOSVersion" = "Unknown"
            "BIOSReleaseDate" = "Unknown"
        }
    }
}

function Get-MemorySettings {
    $notMeasured = 'not_measured'
    $settings = @{
        "EXPOProfileActive" = $notMeasured
        "MCRStatus" = $notMeasured
        "PowerDownStatus" = $notMeasured
        "FCLKValue" = $notMeasured
        "UCLKValue" = $notMeasured
        "MCLKValue" = $notMeasured
        "MemorySpeedMHz" = $notMeasured
        "DeviceCount" = 0
        "PartNumbers" = @()
    }
    try {
        $modules = @(Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop)
        $speeds = @($modules | ForEach-Object { $_.ConfiguredClockSpeed } | Where-Object { $_ })
        if ($speeds.Count -gt 0) { $settings["MemorySpeedMHz"] = ($speeds | Select-Object -First 1) }
        $settings["DeviceCount"] = $modules.Count
        $settings["PartNumbers"] = @($modules | ForEach-Object { $_.PartNumber.Trim() })
    } catch {
        Write-Warning "Could not read Win32_PhysicalMemory: $_"
    }
    $auditResults.MemorySettings = $settings
}

function Get-VoltageSettings {
    $auditResults.VoltageSettings = @{
        "SoCVoltage" = "not_measured"
        "Status" = "not_measured"
    }
}

function Get-PBOSettings {
    $auditResults.PBOSettings = @{
        "PBOEnabled" = "not_measured"
        "CurveOptimizerOffsets" = "not_measured"
        "PPTLimit" = "not_measured"
        "TDCLimit" = "not_measured"
        "EDCValue" = "not_measured"
    }
}

function Get-SchedulingSettings {
    $smt = "not_measured"
    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        if ($cpu.NumberOfLogicalProcessors -gt $cpu.NumberOfCores) { $smt = "enabled" }
        elseif ($cpu.NumberOfLogicalProcessors -eq $cpu.NumberOfCores) { $smt = "disabled" }
    } catch { }
    $auditResults.SchedulingSettings = @{
        "CPPCEnabled" = "not_measured"
        "GlobalCStates" = "not_measured"
        "SMTStatus" = $smt
        "iGPUStatus" = "not_measured"
    }
}

function Test-Phase0Requirements {
    return @(
        "EXPO, memory context restore, power-down, SoC voltage, and Curve Optimizer are not readable from Windows. No pass or fail is reported for them."
    )
}

# Main execution logic
Write-Host "Starting BIOS State Auditor..." -ForegroundColor Yellow

# Get all system information
Get-SystemInfo
Get-MemorySettings  
Get-VoltageSettings
Get-PBOSettings
Get-SchedulingSettings

# Validate against requirements
$auditResults.Issues = Test-Phase0Requirements

$auditResults.OverallStatus = "not_measured"

# Output results based on requested format
if ($OutputFormat -eq "human" -or $OutputFormat -eq "both") {
    Write-HumanOutput -Data $auditResults
}

if ($OutputFormat -eq "ai" -or $OutputFormat -eq "both") {
    Write-AIOutput -Data $auditResults
}

Write-Host "`nBIOS State Audit Complete." -ForegroundColor Green

# Return results for potential further processing
return $auditResults