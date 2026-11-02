# Enhanced Automated Test Framework for X3D Tuning Kit
# This script implements Phase 6 enhancements for automated testing and optimization

param(
    [switch]$RunAllTests,
    [switch]$RunChipDetection,
    [switch]$RunStabilityTest,
    [switch]$RunUndervoltTest,
    [switch]$RunHealthReport,
    [switch]$GenerateReport,
    [string]$OutputFormat = "dual",  # "human", "ai", "dual"
    [string]$TestProfile = "auto",   # "auto", "classA", "classB", "classC", "custom"
    [int]$TestDuration = 180,        # Default test duration in seconds per core
    [switch]$Verbose,
    [switch]$NoCache
)

# Import the core X3D profiles module
try {
    . (Join-Path $PSScriptRoot 'X3D-Profiles.ps1')
} catch {
    Write-Error "Failed to import X3D-Profiles.ps1: $($_.Exception.Message)"
    exit 1
}

# Enhanced AI output function
function Write-AIOutput {
    param(
        [string]$ToolName,
        [string]$Summary,
        [hashtable]$Data,
        [string]$Status = "completed"
    )
    
    $output = @{
        tool_name = $ToolName
        version = "1.0.0"
        output_format = $OutputFormat
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        summary = $Summary
        data = $Data
        status = $Status
        execution_result = $Status
    }
    
    if ($OutputFormat -eq "ai" -or $OutputFormat -eq "dual") {
        Write-Output (ConvertTo-Json $output -Depth 10)
    }
}

# Enhanced human output function
function Write-HumanOutput {
    param([string]$Message)
    if ($OutputFormat -eq "human" -or $OutputFormat -eq "dual") {
        Write-Host $Message
    }
}

# Enhanced error handling function
function Write-ErrorOutput {
    param([string]$Message)
    if ($OutputFormat -eq "human" -or $OutputFormat -eq "dual") {
        Write-Host $Message -ForegroundColor Red
    }
    Write-AIOutput -ToolName "Enhanced-Automated-Test-Framework" -Summary "Error occurred" -Data @{error = $Message} -Status "error"
}

# Function to run chip detection test
function Test-ChipDetection {
    Write-HumanOutput "Running Chip Detection Test..."
    
    try {
        $profile = Get-X3DProfile -NoCache:$NoCache
        $testResult = @{
            detected = $profile.Known
            model = $profile.Model
            is_x3d = $profile.IsX3D
            cores = $profile.Cores
            logical_processors = $profile.LogicalCores
            topology = $profile.Topology
            vcache_scope = $profile.VCacheScope
            detect_source = $profile.DetectSource
            warnings = $profile.Warnings
        }
        
        Write-HumanOutput "Chip Detection: $($profile.Model) - $($profile.Topology) topology"
        
        if ($profile.Warnings.Count -gt 0) {
            Write-HumanOutput "Warnings detected:"
            foreach ($warning in $profile.Warnings) {
                Write-HumanOutput "  - $warning"
            }
        }
        
        Write-AIOutput -ToolName "Chip-Detection" -Summary "Chip detection completed successfully" -Data $testResult
        return $true
    } catch {
        Write-ErrorOutput "Chip detection failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-NotMeasured {
    param([string]$Name, [string]$Reason)
    Write-HumanOutput "$Name was not measured. $Reason"
    Write-AIOutput -ToolName $Name -Summary $Reason -Data @{ measured = $false; reason = $Reason } -Status "not_measured"
    return $false
}

function Test-Stability {
    return Test-NotMeasured -Name "Stability-Test" -Reason "This framework does not run a stability test and will not report a pass. Run Test-UndervoltStability.ps1."
}

function Test-Undervolt {
    return Test-NotMeasured -Name "Undervolt-Test" -Reason "This framework does not run an undervolt test and will not report a pass. Run X3D-Undervolt-Tester.ps1."
}

function Test-HealthReport {
    return Test-NotMeasured -Name "Health-Report" -Reason "This framework does not invent a health result. Run Health-Report.ps1 for the fields Windows can read."
}

# Function to generate comprehensive report
function Generate-Comprehensive-Report {
    Write-HumanOutput "Generating Comprehensive Test Report..."
    
    try {
        # Get current profile
        $profile = Get-X3DProfile -NoCache:$NoCache
        
        $report = @{
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            system_info = @{
                cpu_name = $profile.CpuName
                gpu_name = $profile.GpuName
                model = $profile.Model
                is_x3d = $profile.IsX3D
                cores = $profile.Cores
                logical_processors = $profile.LogicalCores
                topology = $profile.Topology
                vcache_scope = $profile.VCacheScope
            }
            test_results = @{
                chip_detection = @{ status = "see_chip_detection_result" }
                stability = @{ status = "not_measured" }
                undervolt = @{ status = "not_measured" }
                health = @{ status = "not_measured" }
            }
            recommendations = @()
            warnings = $profile.Warnings
        }
        
        # Add chip-specific recommendations
        if ($profile.IsX3D) {
            $recommendations = @()
            if ($profile.Topology -eq "single") {
                $recommendations += "Single-CCD processor detected. No core pinning needed."
            } elseif ($profile.VCacheScope -eq "both") {
                $recommendations += "Dual-CCD with both caches. Optimize for cross-CCD latency."
            } else {
                $recommendations += "Dual-CCD processor with asymmetric cache. Optimize for V-Cache CCD."
            }
            
            $report.recommendations = $recommendations
        }
        
        Write-HumanOutput "Chip profile recorded. Stability, undervolt, and health were not measured by this framework."
        Write-AIOutput -ToolName "Comprehensive-Report" -Summary "Chip profile only. Stability, undervolt, and health were not measured." -Data $report -Status "not_measured"
        return $true
    } catch {
        Write-ErrorOutput "Report generation failed: $($_.Exception.Message)"
        return $false
    }
}

# Main execution logic
Write-HumanOutput "Starting Enhanced Automated Test Framework"
Write-HumanOutput "=========================================="

# Run tests based on parameters
$success = $true

if ($RunAllTests -or $RunChipDetection) {
    $success = $success -and (Test-ChipDetection)
}

if ($RunAllTests -or $RunStabilityTest) {
    $success = $success -and (Test-Stability)
}

if ($RunAllTests -or $RunUndervoltTest) {
    $success = $success -and (Test-Undervolt)
}

if ($RunAllTests -or $RunHealthReport) {
    $success = $success -and (Test-HealthReport)
}

if ($RunAllTests -or $GenerateReport) {
    $success = $success -and (Generate-Comprehensive-Report)
}

if ($RunAllTests -or $RunStabilityTest -or $RunUndervoltTest -or $RunHealthReport -or $GenerateReport) {
    Write-HumanOutput "Finished. Requested stability, undervolt, or health results were not measured. No pass was invented."
    Write-AIOutput -ToolName "Enhanced-Automated-Test-Framework" -Summary "No invented pass. Unmeasured tests stay not_measured." -Data @{ status = "not_measured" } -Status "not_measured"
} elseif ($RunChipDetection -and $success) {
    Write-HumanOutput "Chip detection finished."
    Write-AIOutput -ToolName "Enhanced-Automated-Test-Framework" -Summary "Chip detection finished" -Data @{ status = "completed" } -Status "completed"
} elseif ($RunChipDetection) {
    Write-HumanOutput "Chip detection failed."
    Write-AIOutput -ToolName "Enhanced-Automated-Test-Framework" -Summary "Chip detection failed" -Data @{ status = "failed" } -Status "error"
} else {
    Write-HumanOutput "Nothing was run. Use -RunChipDetection to detect the CPU. This framework does not measure stability, undervolt, or health."
    Write-AIOutput -ToolName "Enhanced-Automated-Test-Framework" -Summary "Nothing was run." -Data @{ status = "not_measured" } -Status "not_measured"
}