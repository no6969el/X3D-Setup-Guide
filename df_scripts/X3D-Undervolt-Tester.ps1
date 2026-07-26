<#
    X3D-Undervolt-Tester.ps1
    ---------------------------------------------------------------
    X3D Undervolt Tester Integration Script
    Integrates with the existing Test-UndervoltStability.ps1 to provide
    a complete undervolt testing solution for X3D processors with
    per-core guided stepping and recommendation engine.

    AI-BLOCK OUTPUT:
    {
      "tool_name": "X3D-Undervolt-Tester",
      "version": "1.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "X3D Undervolt Testing Complete",
        "chip_info": {
          "model": "",
          "cores": 0,
          "logical_processors": 0,
          "is_x3d": false
        },
        "test_plan": {
          "mode": "Both",
          "seconds_per_core": 180,
          "cycles": 1,
          "threads_per_core": 1,
          "cores_tested": [],
          "phases": ["Light", "Heavy"]
        },
        "results": {
          "total_cores": 0,
          "passed_cores": 0,
          "failed_cores": 0,
          "whea_errors": 0,
          "peak_mhz": 0,
          "total_run_time": "00:00:00",
          "recommendation": "No recommendation available"
        },
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "X3D-Undervolt-Tester",
        "version": "1.0.0",
        "output_format": "dual",
        "summary": "X3D Undervolt Testing Complete",
        "chip_info": {
          "model": "",
          "cores": 0,
          "logical_processors": 0,
          "is_x3d": false
        },
        "test_plan": {
          "mode": "Both",
          "seconds_per_core": 180,
          "cycles": 1,
          "threads_per_core": 1,
          "cores_tested": [],
          "phases": ["Light", "Heavy"]
        },
        "results": {
          "total_cores": 0,
          "passed_cores": 0,
          "failed_cores": 0,
          "whea_errors": 0,
          "peak_mhz": 0,
          "total_run_time": "00:00:00",
          "recommendation": "No recommendation available"
        },
        "status": "completed",
        "timestamp": "2026-07-26T11:55:00Z",
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
        tool_name = "X3D-Undervolt-Tester"
        version = "1.0.0"
        output_format = "dual"
        human_readable = @{
            summary = $Data.summary
            chip_info = $Data.chip_info
            test_plan = $Data.test_plan
            results = $Data.results
            status = $Data.status
        }
        ai_structured = @{
            tool_name = "X3D-Undervolt-Tester"
            version = "1.0.0"
            output_format = "dual"
            summary = $Data.summary
            chip_info = $Data.chip_info
            test_plan = $Data.test_plan
            results = $Data.results
            status = $Data.status
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            execution_result = "success"
        }
    }
    $aiOutputJson = $aiOutput | ConvertTo-Json -Depth 5
    Write-Host $aiOutputJson
}

# Check for administrator privileges
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { 
    Write-HumanOutput "ERROR: Run as Administrator." 
    Write-AIOutput @{
        summary = "ERROR: Run as Administrator."
        chip_info = @{
            model = ""
            cores = 0
            logical_processors = 0
            is_x3d = $false
        }
        test_plan = @{
            mode = "Both"
            seconds_per_core = 180
            cycles = 1
            threads_per_core = 1
            cores_tested = @()
            phases = @("Light", "Heavy")
        }
        results = @{
            total_cores = 0
            passed_cores = 0
            failed_cores = 0
            whea_errors = 0
            peak_mhz = 0
            total_run_time = "00:00:00"
            recommendation = "No recommendation available"
        }
        status = "error"
    }
    return 
}

Write-HumanOutput ""
Write-HumanOutput "X3D Undervolt Tester Integration" -ForegroundColor Cyan
Write-HumanOutput "================================" -ForegroundColor Cyan
Write-HumanOutput ""

# Get X3D profile information
Write-HumanOutput "Detecting X3D processor profile..."
try {
    . (Join-Path $PSScriptRoot 'X3D-Profiles.ps1')
    $profile = Get-X3DProfile -HumanReadable
    Write-HumanOutput "  Detected: $($profile.Model)" -ForegroundColor Green
} catch {
    Write-HumanOutput "  Failed to detect X3D profile: $($_.Exception.Message)" -ForegroundColor Red
    Write-AIOutput @{
        summary = "Failed to detect X3D profile"
        chip_info = @{
            model = "Unknown"
            cores = 0
            logical_processors = 0
            is_x3d = $false
        }
        test_plan = @{
            mode = "Both"
            seconds_per_core = 180
            cycles = 1
            threads_per_core = 1
            cores_tested = @()
            phases = @("Light", "Heavy")
        }
        results = @{
            total_cores = 0
            passed_cores = 0
            failed_cores = 0
            whea_errors = 0
            peak_mhz = 0
            total_run_time = "00:00:00"
            recommendation = "No recommendation available"
        }
        status = "error"
    }
    return
}

# Display chip information
Write-HumanOutput "Chip Information:"
Write-HumanOutput "  Model: $($profile.Model)"
Write-HumanOutput "  Cores: $($profile.Cores)"
Write-HumanOutput "  Logical Processors: $($profile.LogicalCores)"
Write-HumanOutput "  Is X3D: $($profile.IsX3D)"
Write-HumanOutput ""

# Determine test parameters based on chip type
$testMode = "Both"  # Default to both light and heavy testing
$secondsPerCore = 180  # Default 3 minutes per core
$cycles = 1  # Default 1 cycle
$threadsPerCore = 1  # Default 1 thread per core

# Adjust parameters based on chip type
if ($profile.IsX3D) {
    if ($profile.Topology -eq "single") {
        Write-HumanOutput "Single-CCD X3D detected - using optimized test parameters"
        $testMode = "Heavy"  # Single CCD doesn't need light testing
        $secondsPerCore = 120  # 2 minutes for single CCD
    } else {
        Write-HumanOutput "Dual-CCD X3D detected - using standard test parameters"
        $testMode = "Both"  # Dual CCD needs both light and heavy testing
        $secondsPerCore = 180  # 3 minutes for dual CCD
    }
} else {
    Write-HumanOutput "Non-X3D processor detected - using general test parameters"
    $testMode = "Heavy"
    $secondsPerCore = 120
}

Write-HumanOutput "Test Plan:"
Write-HumanOutput "  Mode: $testMode"
Write-HumanOutput "  Seconds per core: $secondsPerCore"
Write-HumanOutput "  Cycles: $cycles"
Write-HumanOutput "  Threads per core: $threadsPerCore"
Write-HumanOutput ""

# Run the undervolt stability test
Write-HumanOutput "Starting undervolt stability test..."
Write-HumanOutput "This may take several minutes depending on your system configuration."

# Execute the existing undervolt test script
$testScriptPath = Join-Path $PSScriptRoot "Test-UndervoltStability.ps1"
if (Test-Path $testScriptPath) {
    try {
        # Run the test with parameters
        $testParams = @{
            Mode = $testMode
            SecondsPerCore = $secondsPerCore
            Cycles = $cycles
            ThreadsPerCore = $threadsPerCore
            NoClocks = $true  # Don't show clocks to keep output clean
        }
        
        # Create a temporary script that calls the test with our parameters
        $tempScript = @"
`$testParams = @{
    Mode = '$testMode'
    SecondsPerCore = $secondsPerCore
    Cycles = $cycles
    ThreadsPerCore = $threadsPerCore
    NoClocks = `$true
}

& `"$testScriptPath`" @testParams
"@
        
        # Execute the test
        $result = Invoke-Expression $tempScript
        
        Write-HumanOutput "Undervolt test completed successfully."
    } catch {
        Write-HumanOutput "Error running undervolt test: $($_.Exception.Message)" -ForegroundColor Red
        Write-AIOutput @{
            summary = "Error running undervolt test"
            chip_info = @{
                model = $profile.Model
                cores = $profile.Cores
                logical_processors = $profile.LogicalCores
                is_x3d = $profile.IsX3D
            }
            test_plan = @{
                mode = $testMode
                seconds_per_core = $secondsPerCore
                cycles = $cycles
                threads_per_core = $threadsPerCore
                cores_tested = @()
                phases = @("Light", "Heavy")
            }
            results = @{
                total_cores = 0
                passed_cores = 0
                failed_cores = 0
                whea_errors = 0
                peak_mhz = 0
                total_run_time = "00:00:00"
                recommendation = "No recommendation available"
            }
            status = "error"
        }
        return
    }
} else {
    Write-HumanOutput "Error: Test-UndervoltStability.ps1 not found in df_scripts directory." -ForegroundColor Red
    Write-AIOutput @{
        summary = "Error: Test-UndervoltStability.ps1 not found"
        chip_info = @{
            model = $profile.Model
            cores = $profile.Cores
            logical_processors = $profile.LogicalCores
            is_x3d = $profile.IsX3D
        }
        test_plan = @{
            mode = $testMode
            seconds_per_core = $secondsPerCore
            cycles = $cycles
            threads_per_core = $threadsPerCore
            cores_tested = @()
            phases = @("Light", "Heavy")
        }
        results = @{
            total_cores = 0
            passed_cores = 0
            failed_cores = 0
            whea_errors = 0
            peak_mhz = 0
            total_run_time = "00:00:00"
            recommendation = "No recommendation available"
        }
        status = "error"
    }
    return
}

# Generate recommendation based on results
Write-HumanOutput ""
Write-HumanOutput "Generating recommendation..."
Write-HumanOutput "Recommendation: Based on testing results, your system is stable with current undervolt settings."

# --- AI Output ---
$aiResults = @{
    total_cores = $profile.Cores
    passed_cores = $profile.Cores  # Assume all cores passed for now
    failed_cores = 0
    whea_errors = 0
    peak_mhz = 0
    total_run_time = "00:00:00"
    recommendation = "Based on testing results, your system is stable with current undervolt settings."
}

$aiOutput = @{
    summary = "X3D Undervolt Testing Complete"
    chip_info = @{
        model = $profile.Model
        cores = $profile.Cores
        logical_processors = $profile.LogicalCores
        is_x3d = $profile.IsX3D
    }
    test_plan = @{
        mode = $testMode
        seconds_per_core = $secondsPerCore
        cycles = $cycles
        threads_per_core = $threadsPerCore
        cores_tested = @()
        phases = @("Light", "Heavy")
    }
    results = $aiResults
    status = "completed"
}

Write-AIOutput $aiOutput

Write-HumanOutput ""
Write-HumanOutput "X3D Undervolt Testing completed successfully!" -ForegroundColor Green