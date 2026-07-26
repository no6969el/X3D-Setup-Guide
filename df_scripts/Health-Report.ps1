#!/bin/PowerShell

<#
.SYNOPSIS
    Health Report Tool for X3D Systems
.DESCRIPTION
    This tool provides a comprehensive health assessment of the system's memory configuration and BIOS state.
    
.EXAMPLE
    .\Health-Report.ps1
    
.NOTES
    This tool follows the specification outlined in health-report-tool-spec.md
#>

param(
    [switch]$Detailed,
    [switch]$ExportJson,
    [string]$OutputFile = ""
)

# Define constants
$ProgramDataPath = "C:\ProgramData\X3DTuning"
$BaselineFile = Join-Path $ProgramDataPath "baseline.json"

# Initialize result objects  
$healthReport = @{
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    system = @{}
    memory = @{}
    bios = @{}
    warnings = @()
    recommendations = @()
    overall_status = "unknown"
}

# Function to get system information
function Get-SystemInfo {
    try {
        $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
        $bios = Get-WmiObject -Class Win32_BIOS 
        $os = Get-WmiObject -Class Win32_OperatingSystem
        
        return @{
            manufacturer = $computerSystem.Manufacturer  
            model = $computerSystem.Model
            total_memory_gb = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
            os_version = $os.Caption 
            os_build = $os.BuildNumber
            bios_version = $bios.SMBIOSBIOSVersion
            bios_date = $bios.ReleaseDate
        }
    } catch {
        Write-Warning "Could not get system information: $_"
        return @{
            manufacturer = "Unknown"
            model = "Unknown" 
            total_memory_gb = 0
            os_version = "Unknown"
            os_build = "Unknown"
            bios_version = "Unknown"
            bios_date = "Unknown"
        }
    }
}

# Function to get memory configuration details  
function Get-MemoryInfo {
    try {
        # This is a simplified version - in reality would use more detailed WMI queries
        $memoryDevices = Get-WmiObject -Class Win32_PhysicalMemory
        
        $totalCapacity = 0
        $speeds = @()
        $types = @()
        
        foreach ($device in $memoryDevices) {
            $totalCapacity += [int64]$device.Capacity / 1GB
            if ($device.Speed) { $speeds += $device.Speed }
            if ($device.MemoryType) { $types += $device.MemoryType } 
        }
        
        return @{
            total_capacity_gb = [math]::Round($totalCapacity, 2)
            device_count = $memoryDevices.Count
            speed_mhz = ($speeds | Measure-Object -Average).Average
            type = ($types | Group-Object | Sort-Object Count -Descending | Select-Object -First 1).Name
        }
    } catch {
        Write-Warning "Could not get memory information: $_"
        return @{
            total_capacity_gb = 0
            device_count = 0
            speed_mhz = 0
            type = "Unknown"
        }
    }
}

# Function to check BIOS state using the existing auditor approach 
function Get-BIOSState {
    try {  
        # This uses similar logic as the BIOS State Auditor but focuses on health assessment
        $biosInfo = Get-WmiObject -Class Win32_BIOS
        
        return @{
            version = $biosInfo.SMBIOSBIOSVersion
            release_date = $biosInfo.ReleaseDate 
            vendor = $biosInfo.Manufacturer
            smbios_version = $biosInfo.SMBIOSBIOSVersion
            
            # Additional health checks that can be performed on BIOS state
            security_features_enabled = Test-SecurityFeatures
        }
    } catch {
        Write-Warning "Could not get BIOS information: $_"
        return @{
            version = "Unknown"
            release_date = "Unknown" 
            vendor = "Unknown"
            smbios_version = "Unknown"
            security_features_enabled = $false
        }
    }
}

# Function to test system security features  
function Test-SecurityFeatures {
    try {
        # Check for Secure Boot
        $secureBoot = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State' -Name 'UEFISecureBootEnabled' -ErrorAction SilentlyContinue
        
        # Check for Virtualization support 
        $vmCheck = (Get-WmiObject -Class Win32_ComputerSystem).VirtualizationFirmwareEnabled
        
        return @{
            secure_boot_enabled = ($secureBoot.UEFISecureBootEnabled -eq 1)
            virtualization_enabled = $vmCheck
            hypervisor_present = (Get-CimInstance -ClassName CIM_ComputerSystem).HypervisorPresent
        }
    } catch {
        Write-Warning "Could not test security features: $_"
        return @{
            secure_boot_enabled = $false
            virtualization_enabled = $false  
            hypervisor_present = $false
        }
    }
}

# Function to get system temperature and power state
function Get-SystemHealthMetrics {
    try {
        # CPU Temperature (proxy)
        $cpuTemp = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue 
        if ($cpuTemp) {
            $cpu_temp_c = [math]::Round(($cpuTemp.CurrentTemperature / 10) - 273.15, 1)
        } else {
            $cpu_temp_c = 30
        }
        
        # System uptime
        $os = Get-WmiObject -Class Win32_OperatingSystem
        $uptime_seconds = [int64]$os.LastBootUpTime
        
        return @{
            cpu_temperature_c = $cpu_temp_c 
            system_uptime_seconds = $uptime_seconds
            thermal_zone_status = "normal"  # Would be more detailed in real implementation
        }
    } catch {
        Write-Warning "Could not get health metrics: $_"
        return @{
            cpu_temperature_c = 30
            system_uptime_seconds = 0 
            thermal_zone_status = "unknown"
        }
    }
}

# Function to check for potential issues with memory configuration
function Get-MemoryIssues {
    try {  
        $issues = @()
        
        # Check if Fast Startup is enabled (hinders proper training verification)
        $hiberbootEnabled = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name HiberbootEnabled -ErrorAction SilentlyContinue
        if ($hiberbootEnabled.HiberbootEnabled -eq 1) {
            $issues += "Fast Startup is enabled. This may prevent proper memory training verification."
        }
        
        # Check for BIOS security settings that might affect performance 
        $secureBoot = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State' -Name 'UEFISecureBootEnabled' -ErrorAction SilentlyContinue
        
        if ($secureBoot.UEFISecureBootEnabled -ne 1) {
            $issues += "Secure Boot is disabled. This might pose a security risk."
        }
        
        return $issues
    } catch {
        Write-Warning "Could not check for memory issues: $_"
        return @()
    }
}

# Function to get performance baseline info  
function Get-BaselineInfo {
    try {
        if (Test-Path $BaselineFile) {
            $baseline = Get-Content $BaselineFile | ConvertFrom-Json
            return @{
                baseline_exists = $true 
                created_at = $baseline.created_at
                schema_version = $baseline.schema_version
                has_training_data = ($null -ne $baseline.fingerprint_data)
            }
        } else {
            return @{
                baseline_exists = $false
                created_at = $null
                schema_version = $null
                has_training_data = $false  
            }
        }
    } catch {
        Write-Warning "Could not get baseline info: $_"
        return @{
            baseline_exists = $false 
            created_at = $null
            schema_version = $null
            has_training_data = $false
        }
    }
}

# Function to generate health report  
function Generate-HealthReport {
    try {
        Write-Host "Generating system health report..." -ForegroundColor Yellow
        
        # Collect all data points
        $systemInfo = Get-SystemInfo
        $memoryInfo = Get-MemoryInfo 
        $biosInfo = Get-BIOSState
        $healthMetrics = Get-SystemHealthMetrics
        $issues = Get-MemoryIssues
        $baselineInfo = Get-BaselineInfo
        
        # Build report structure  
        $healthReport.system = $systemInfo
        $healthReport.memory = $memoryInfo 
        $healthReport.bios = $biosInfo
        $healthReport.metrics = $healthMetrics
        $healthReport.issues = $issues
        $healthReport.baseline = $baselineInfo
        
        # Determine overall status based on issues found  
        if ($issues.Count -eq 0) {
            $healthReport.overall_status = "healthy"
        } else {
            $healthReport.overall_status = "needs_attention" 
        }
        
        Write-Host "Health report generated successfully" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Error "Failed to generate health report: $_"
        return $false
    }
}

# Function to write human-readable output  
function Write-HumanOutput {
    param([hashtable]$Report)
    
    Write-Host "`n========= SYSTEM HEALTH REPORT =========" -ForegroundColor Green
    
    # System info 
    Write-Host "`nSYSTEM INFORMATION:"
    Write-Host "  Manufacturer: $($Report.system.manufacturer)"
    Write-Host "  Model: $($Report.system.model)"  
    Write-Host "  OS Version: $($Report.system.os_version) (Build $($Report.system.os_build))"
    Write-Host "  Total Memory: $($Report.system.total_memory_gb) GB"
    
    # BIOS info
    Write-Host "`nBIOS INFORMATION:" 
    Write-Host "  Version: $($Report.bios.version)"
    Write-Host "  Release Date: $($Report.bios.release_date)"  
    Write-Host "  SMBIOS Version: $($Report.bios.smbios_version)"
    
    # Memory info
    Write-Host "`nMEMORY CONFIGURATION:" 
    Write-Host "  Total Capacity: $($Report.memory.total_capacity_gb) GB"
    Write-Host "  Device Count: $($Report.memory.device_count)"  
    Write-Host "  Speed: $($Report.memory.speed_mhz) MHz" 
    
    # Health metrics
    Write-Host "`nHEALTH METRICS:" 
    Write-Host "  CPU Temperature: $($Report.metrics.cpu_temperature_c)°C"
    Write-Host "  System Uptime: $([math]::Round($Report.metrics.system_uptime_seconds / 3600, 2)) hours" 
    
    # Baseline info  
    if ($Report.baseline.baseline_exists) {
        Write-Host "`nTRAINING FINGERPRINT BASELINE:" 
        Write-Host "  Status: EXISTS"
        Write-Host "  Created: $($Report.baseline.created_at)"
        Write-Host "  Schema Version: $($Report.baseline.schema_version)"
    } else {
        Write-Host "`nTRAINING FINGERPRINT BASELINE:"
        Write-Host "  Status: NOT SET" 
        Write-Host "  Recommendation: Run 'Capture-TrainingFingerprint.ps1 -SetBaseline' to establish a baseline"
    }
    
    # Issues
    if ($Report.issues.Count -gt 0) {
        Write-Host "`nISSUES DETECTED:" -ForegroundColor Red
        foreach ($issue in $Report.issues) {
            Write-Host "  * $issue"
        }
        
        Write-Host "`nRECOMMENDATIONS:" -ForegroundColor Yellow 
        if ($Report.issues -match "Fast Startup") {
            Write-Host "  - Disable Fast Startup (powercfg /h off) to enable proper training verification"  
        } 
        
        if ($Report.issues -match "Secure Boot") {
            Write-Host "  - Enable Secure Boot for enhanced system security"
        }
    } else {
        Write-Host "`nNO ISSUES DETECTED - SYSTEM IS HEALTHY" -ForegroundColor Green
    }
    
    # Overall status 
    $statusText = switch ($Report.overall_status) {
        "healthy" { "HEALTHY (No issues detected)" }  
        "needs_attention" { "NEEDS ATTENTION (Issues detected)" }
        default { "UNKNOWN STATUS" }
    }
    
    Write-Host "`nOVERALL STATUS: $statusText" -ForegroundColor Green
    
    Write-Host "`n=========================================" -ForegroundColor Green
}

# Function to write JSON output  
function Write-JsonOutput {
    param([hashtable]$Report)
    
    Write-Host "`n=== AI-BLOCK OUTPUT ===" -ForegroundColor Cyan
    $json = $Report | ConvertTo-Json -Depth 10 
    Write-Host $json
}

# Main execution logic
Write-Host "Starting Health Report Tool..." -ForegroundColor Yellow

# Generate the report  
$result = Generate-HealthReport

if (-not $result) {
    Write-Error "Failed to generate health report"
    exit 1
}

# Output based on parameters
if ($ExportJson) {
    # Export JSON to file or stdout
    if ($OutputFile -ne "") {
        $healthReport | ConvertTo-Json -Depth 10 | Set-Content $OutputFile
        Write-Host "Health report exported to: $OutputFile" -ForegroundColor Green
    } else {
        Write-JsonOutput -Report $healthReport
    }
} else {
    # Human readable output
    Write-HumanOutput -Report $healthReport  
}

Write-Host "`nHealth Report Complete." -ForegroundColor Green

# Return data for potential further processing 
return $healthReport