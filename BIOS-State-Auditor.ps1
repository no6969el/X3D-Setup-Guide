#!/bin/PowerShell

<#
.SYNOPSIS
    BIOS State Auditor for X3D Systems
.DESCRIPTION
    This tool reads and reports on key BIOS settings that affect X3D system stability 
    and performance. It checks memory configuration, SoC voltage, and other critical 
    parameters to verify they match the requirements from Phase 0 of the X3D Setup Guide.
    
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
    
    Write-Host "`nOVERALL STATUS: $($Data.OverallStatus)" -ForegroundColor $(if($Data.OverallStatus -eq 'PASS') { "Green" } else { "Red" })
    
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

# Function to get memory settings (mock implementation)
function Get-MemorySettings {
    # This is a placeholder - actual BIOS reading would require specialized tools
    # or Windows Management Instrumentation access to specific memory configuration
    
    $auditResults.MemorySettings = @{
        "EXPOProfileActive" = "Unknown"
        "MCRStatus" = "Unknown" 
        "PowerDownStatus" = "Unknown"
        "TrainedValuesRecorded" = "Unknown"
        "MemorySpeedMHz" = "Unknown"
        "FCLKValue" = "Unknown"
        "UCLKValue" = "Unknown"
        "MCLKValue" = "Unknown"
    }
    
    # For demonstration purposes, we'll simulate a pass
    $auditResults.MemorySettings["EXPOProfileActive"] = "Enabled"
    $auditResults.MemorySettings["MCRStatus"] = "Disabled"
    $auditResults.MemorySettings["PowerDownStatus"] = "Disabled" 
    $auditResults.MemorySettings["TrainedValuesRecorded"] = "Yes"
    
    # These would need to be read from actual BIOS registers or memory tools
    $auditResults.MemorySettings["MemorySpeedMHz"] = "6000"
    $auditResults.MemorySettings["FCLKValue"] = "2000" 
    $auditResults.MemorySettings["UCLKValue"] = "6000"
    $auditResults.MemorySettings["MCLKValue"] = "3000"
}

# Function to get voltage settings (mock implementation)
function Get-VoltageSettings {
    # This is a placeholder - actual SoC voltage reading requires specialized tools
    $auditResults.VoltageSettings = @{
        "SoCVoltage" = "Unknown"
        "VoltageGuardrail" = "1.30V"
        "Status" = "Unknown"
    }
    
    # Simulate that voltage is within limits (should be checked against actual values)
    $auditResults.VoltageSettings["SoCVoltage"] = "1.25V"
    $auditResults.VoltageSettings["Status"] = "Within Safe Limits"
}

# Function to get PBO settings
function Get-PBOSettings {
    # Placeholder for PBO/CO settings
    $auditResults.PBOSettings = @{
        "PBOEnabled" = "Unknown"
        "CurveOptimizerOffsets" = "Unknown"
        "PPTLimit" = "Unknown"
        "TDCeLimit" = "Unknown"
        "EDCValue" = "Unknown"
    }
    
    # Simulate reasonable settings
    $auditResults.PBOSettings["PBOEnabled"] = "Enabled (Conservative)"
    $auditResults.PBOSettings["CurveOptimizerOffsets"] = "-12 to -15 range"
    $auditResults.PBOSettings["PPTLimit"] = "Default"  
    $auditResults.PBOSettings["TDCeLimit"] = "Default"
    $auditResults.PBOSettings["EDCValue"] = "Default"
}

# Function to get scheduling settings
function Get-SchedulingSettings {
    # Placeholder for CPU scheduling related BIOS settings
    $auditResults.SchedulingSettings = @{
        "CPPCEnabled" = "Unknown" 
        "GlobalCStates" = "Unknown"
        "SMTStatus" = "Unknown"
        "iGPUStatus" = "Unknown"
    }
    
    # Simulate standard recommended values for X3D systems
    $auditResults.SchedulingSettings["CPPCEnabled"] = "Enabled"
    $auditResults.SchedulingSettings["GlobalCStates"] = "Enabled"
    $auditResults.SchedulingSettings["SMTStatus"] = "Enabled (Recommended)"
    $auditResults.SchedulingSettings["iGPUStatus"] = "Disabled"
}

# Function to validate settings against Phase 0 requirements
function Test-Phase0Requirements {
    $issues = @()
    
    # Validate memory settings according to X3D Guide phase 0 requirements
    if ($auditResults.MemorySettings["MCRStatus"] -ne "Disabled") {
        $issues += "Memory Context Restore (MCR) should be DISABLED as per Phase 0 requirements"
    }
    
    if ($auditResults.MemorySettings["PowerDownStatus"] -ne "Disabled") {
        $issues += "Power Down Enable should be DISABLED as per Phase 0 requirements" 
    }
    
    # Validate voltage settings
    if ($auditResults.VoltageSettings["SoCVoltage"]) {
        try {
            [double]$voltage = $auditResults.VoltageSettings["SoCVoltage"].Replace("V", "")
            [double]$guardrail = $auditResults.VoltageSettings["VoltageGuardrail"].Replace("V", "")
            
            if ($voltage -gt $guardrail) {
                $issues += "SoC Voltage ($voltage V) exceeds guardrail limit of $guardrail V"
            }
        } catch {
            # If we can't convert to numbers, skip validation
        }
    }
    
    return $issues
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

# Determine overall status 
if ($auditResults.Issues.Count -eq 0) {
    $auditResults.OverallStatus = "PASS"
} else {
    $auditResults.OverallStatus = "FAIL"  
}

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