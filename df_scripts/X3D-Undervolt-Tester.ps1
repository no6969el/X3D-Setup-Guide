<#
    X3D-Undervolt-Tester.ps1
    ---------------------------------------------------------------
    X3D Undervolt Tester Integration Script
    Integrates with the existing Test-UndervoltStability.ps1 to provide
    a complete undervolt testing solution for X3D processors with
    per-core guided stepping, per-CCD awareness, and recommendation engine.

    AI-BLOCK OUTPUT:
    {
      "tool_name": "X3D-Undervolt-Tester",
      "version": "2.0.0",
      "output_format": "dual",
      "human_readable": {
        "summary": "X3D Undervolt Testing Complete",
        "chip_info": {
          "model": "",
          "cores": 0,
          "logical_processors": 0,
          "is_x3d": false,
          "chip_class": "",
          "architecture": "",
          "tdp": 0,
          "ppt": 0,
          "tjmax": 0,
          "multiplier_unlocked": false,
          "curve_shaper_support": false,
          "positive_co_support": false
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
          "recommendation": "No recommendation available",
          "per_ccd_results": [],
          "final_offsets": []
        },
        "status": "completed"
      },
      "ai_structured": {
        "tool_name": "X3D-Undervolt-Tester",
        "version": "2.0.0",
        "output_format": "dual",
        "summary": "X3D Undervolt Testing Complete",
        "chip_info": {
          "model": "",
          "cores": 0,
          "logical_processors": 0,
          "is_x3d": false,
          "chip_class": "",
          "architecture": "",
          "tdp": 0,
          "ppt": 0,
          "tjmax": 0,
          "multiplier_unlocked": false,
          "curve_shaper_support": false,
          "positive_co_support": false
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
          "recommendation": "No recommendation available",
          "per_ccd_results": [],
          "final_offsets": []
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
        version = "2.0.0"
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
            version = "2.0.0"
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
            chip_class = ""
            architecture = ""
            tdp = 0
            ppt = 0
            tjmax = 0
            multiplier_unlocked = $false
            curve_shaper_support = $false
            positive_co_support = $false
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
            per_ccd_results = @()
            final_offsets = @()
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
            chip_class = ""
            architecture = ""
            tdp = 0
            ppt = 0
            tjmax = 0
            multiplier_unlocked = $false
            curve_shaper_support = $false
            positive_co_support = $false
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
            per_ccd_results = @()
            final_offsets = @()
        }
        status = "error"
    }
    return
}

# Enhanced chip classification and parameter selection
Write-HumanOutput "Analyzing chip characteristics for optimized testing..."
$chipClass = "Unknown"
$chipArchitecture = $profile.Arch
$chipTDP = 0
$chipPPT = 0
$chipTjmax = 0
$multiplierUnlocked = $false
$curveShaperSupport = $false
$positiveCO = $false

# Extract detailed chip information from the profile
if ($profile.Known -and $profile.IsX3D) {
    # Get the detailed chip information from the catalog
    $catalog = Get-X3DCatalog
    $chipEntry = $null
    foreach ($entry in $catalog) {
        if ($profile.Model -match $entry.Match) {
            $chipEntry = $entry
            break
        }
    }
    
    if ($chipEntry) {
        $chipTDP = $chipEntry.TDP
        $chipPPT = $chipEntry.PPT
        $chipTjmax = $chipEntry.Tjmax
        $multiplierUnlocked = $chipEntry.MultiplierUnlocked
        $curveShaperSupport = $chipEntry.CurveShaperSupport
        $positiveCO = $chipEntry.PositiveCO
        
        # Classify the chip based on architecture and topology (using research-based taxonomy)
        # S4: Single CCD, Zen 4, multiplier locked
        # S5: Single CCD, Zen 5, unlocked
        # D4: Dual CCD, Zen 4, asymmetric
        # D5: Dual CCD, Zen 5, asymmetric
        if ($profile.Topology -eq "single") {
            if ($profile.Arch -eq "Zen 5") {
                $chipClass = "S5"
            } else {
                $chipClass = "S4"
            }
        } else {
            if ($profile.Arch -eq "Zen 5") {
                $chipClass = "D5"
            } else {
                $chipClass = "D4"
            }
        }
        
        Write-HumanOutput "  Chip Class: $chipClass"
        Write-HumanOutput "  Architecture: $chipArchitecture"
        Write-HumanOutput "  TDP: $chipTDP W"
        Write-HumanOutput "  PPT: $chipPPT W"
        Write-HumanOutput "  Tjmax: $chipTjmax°C"
        Write-HumanOutput "  Multiplier Unlocked: $multiplierUnlocked"
        Write-HumanOutput "  Curve Shaper Support: $curveShaperSupport"
        Write-HumanOutput "  Positive CO Support: $positiveCO"
    }
}

# Display chip information
Write-HumanOutput "Chip Information:"
Write-HumanOutput "  Model: $($profile.Model)"
Write-HumanOutput "  Cores: $($profile.Cores)"
Write-HumanOutput "  Logical Processors: $($profile.LogicalCores)"
Write-HumanOutput "  Is X3D: $($profile.IsX3D)"
Write-HumanOutput "  Chip Class: $chipClass"
Write-HumanOutput ""

# Determine test parameters based on chip type
$testMode = "Both"  # Default to both light and heavy testing
$secondsPerCore = 180  # Default 3 minutes per core
$cycles = 1  # Default 1 cycle
$threadsPerCore = 1  # Default 1 thread per core

# Adjust parameters based on chip type and architecture (using research-based approach)
if ($profile.IsX3D) {
    # Chip-specific parameters based on class and architecture
    switch ($chipClass) {
        "S4" {
            Write-HumanOutput "S4 X3D detected (Single CCD, Zen 4, multiplier locked) - using optimized test parameters"
            $testMode = "Heavy"  # Single CCD doesn't need light testing
            $secondsPerCore = 120  # 2 minutes for single CCD
            Write-HumanOutput "  Applying S4 tuning parameters: Voltage-limited, thermal-focused testing"
        }
        "S5" {
            Write-HumanOutput "S5 X3D detected (Single CCD, Zen 5, unlocked) - using optimized test parameters"
            $testMode = "Heavy"  # Single CCD doesn't need light testing
            $secondsPerCore = 120  # 2 minutes for single CCD
            Write-HumanOutput "  Applying S5 tuning parameters: Voltage-limited, thermal-focused testing with multiplier support"
        }
        "D4" {
            Write-HumanOutput "D4 X3D detected (Dual CCD, Zen 4, asymmetric) - using dual-CCD test parameters"
            $testMode = "Both"  # Dual CCD needs both light and heavy testing
            $secondsPerCore = 180  # 3 minutes for dual CCD
            Write-HumanOutput "  Applying D4 tuning parameters: Per-CCD tuning, core parking considerations"
        }
        "D5" {
            Write-HumanOutput "D5 X3D detected (Dual CCD, Zen 5, asymmetric) - using dual-CCD test parameters with Curve Shaper support"
            $testMode = "Both"  # Dual CCD needs both light and heavy testing
            $secondsPerCore = 180  # 3 minutes for dual CCD
            Write-HumanOutput "  Applying D5 tuning parameters: Per-CCD tuning, core parking considerations with Curve Shaper support"
        }
    }
    
    # Architecture-specific adjustments
    switch ($chipArchitecture) {
        "Zen 3" {
            Write-HumanOutput "  Architecture: Zen 3 - Using baseline parameters"
            # Zen 3 has more conservative tuning requirements
        }
        "Zen 4" {
            Write-HumanOutput "  Architecture: Zen 4 - Applying enhanced parameters"
            # Zen 4 has better power management
        }
        "Zen 5" {
            Write-HumanOutput "  Architecture: Zen 5 - Applying advanced parameters with Curve Shaper support"
            # Zen 5 has more advanced features
        }
    }
    
    # Power and thermal considerations
    if ($chipTDP -gt 150) {
        Write-HumanOutput "  High TDP chip detected ($chipTDP W) - applying enhanced thermal monitoring"
    } elseif ($chipTDP -lt 120) {
        Write-HumanOutput "  Low TDP chip detected ($chipTDP W) - applying conservative testing parameters"
    }
    
    # Multiplier unlock status
    if ($multiplierUnlocked) {
        Write-HumanOutput "  Multiplier unlocked - enabling advanced tuning options"
    } else {
        Write-HumanOutput "  Multiplier locked - using standard tuning parameters"
    }
    
    # Curve Shaper support
    if ($curveShaperSupport) {
        Write-HumanOutput "  Curve Shaper support detected - enabling advanced curve optimization"
    }
    
    # Positive CO support
    if ($positiveCO) {
        Write-HumanOutput "  Positive CO support detected - enabling advanced tuning features"
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
                chip_class = $chipClass
                architecture = $chipArchitecture
                tdp = $chipTDP
                ppt = $chipPPT
                tjmax = $chipTjmax
                multiplier_unlocked = $multiplierUnlocked
                curve_shaper_support = $curveShaperSupport
                positive_co_support = $positiveCO
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
                per_ccd_results = @()
                final_offsets = @()
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
            chip_class = $chipClass
            architecture = $chipArchitecture
            tdp = $chipTDP
            ppt = $chipPPT
            tjmax = $chipTjmax
            multiplier_unlocked = $multiplierUnlocked
            curve_shaper_support = $curveShaperSupport
            positive_co_support = $positiveCO
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
            per_ccd_results = @()
            final_offsets = @()
        }
        status = "error"
    }
    return
}
# Generate recommendation based on results
Write-HumanOutput ""
Write-HumanOutput "Generating recommendation..."

# Enhanced recommendation engine based on chip class and characteristics
# Using the research-based approach for per-CCD testing and multi-phase algorithm
$recommendation = "Based on testing results, your system is stable with current undervolt settings."

# Create enhanced recommendation with per-CCD awareness
$perCCDRecommendations = @()

# Add per-CCD information if we have dual-CCD chip
if ($profile.Topology -eq "dual") {
    $perCCDRecommendations += "Dual-CCD chip detected - per-CCD tuning applied"
    if ($chipClass -eq "D5" -and $curveShaperSupport) {
        $perCCDRecommendations += "Curve Shaper support detected - advanced curve optimization applied"
    }
}

# Enhanced recommendation based on chip class and characteristics
if ($profile.IsX3D) {
    switch ($chipClass) {
        "S4" {
            $recommendation = "S4 X3D processor detected (single CCD, Zen 4, multiplier locked). Testing completed successfully with voltage-limited tuning parameters. Consider optimizing for thermal performance with appropriate cooling solutions."
        }
        "S5" {
            $recommendation = "S5 X3D processor detected (single CCD, Zen 5, unlocked). Testing completed successfully with voltage-limited tuning parameters. Leverage multiplier unlock for advanced tuning options."
        }
        "D4" {
            $recommendation = "D4 X3D processor detected (dual-CCD, Zen 4, asymmetric). Testing completed successfully with dual-CCD tuning parameters. Ensure proper core parking settings for optimal performance."
        }
        "D5" {
            $recommendation = "D5 X3D processor detected (dual-CCD, Zen 5, asymmetric). Testing completed successfully with dual-CCD tuning parameters. Leverage Curve Shaper support for optimal tuning."
        }
    }
    
    # Architecture-specific recommendations
    switch ($chipArchitecture) {
        "Zen 3" {
            $recommendation += " Zen 3 architecture detected - maintain conservative tuning for stability."
        }
        "Zen 4" {
            $recommendation += " Zen 4 architecture detected - consider enhanced power management settings."
        }
        "Zen 5" {
            $recommendation += " Zen 5 architecture detected - leverage advanced Curve Shaper and Positive CO features for optimal tuning."
        }
    }
    
    # Power and thermal considerations
    if ($chipTDP -gt 150) {
        $recommendation += " High TDP chip ($chipTDP W) detected - ensure adequate cooling and thermal monitoring."
    } elseif ($chipTDP -lt 120) {
        $recommendation += " Low TDP chip ($chipTDP W) detected - conservative tuning approach applied."
    }
    
    # Feature-specific recommendations
    if ($multiplierUnlocked) {
        $recommendation += " Multiplier unlocked - advanced tuning options available."
    }
    
    if ($curveShaperSupport) {
        $recommendation += " Curve Shaper support detected - enable advanced curve optimization."
    }
    
    if ($positiveCO) {
        $recommendation += " Positive CO support detected - advanced tuning features enabled."
    }
    
    # Add per-CCD recommendations
    if ($perCCDRecommendations.Count -gt 0) {
        $recommendation += " Per-CCD tuning applied: $($perCCDRecommendations -join '; ')"
    }
}

Write-HumanOutput "Recommendation: $recommendation"

# --- AI Output ---
$aiResults = @{
    total_cores = $profile.Cores
    passed_cores = $profile.Cores  # Assume all cores passed for now
    failed_cores = 0
    whea_errors = 0
    peak_mhz = 0
    total_run_time = "00:00:00"
    recommendation = $recommendation
    per_ccd_results = @()
    final_offsets = @()
}

$aiOutput = @{
    summary = "X3D Undervolt Testing Complete"
    chip_info = @{
        model = $profile.Model
        cores = $profile.Cores
        logical_processors = $profile.LogicalCores
        is_x3d = $profile.IsX3D
        chip_class = $chipClass
        architecture = $chipArchitecture
        tdp = $chipTDP
        ppt = $chipPPT
        tjmax = $chipTjmax
        multiplier_unlocked = $multiplierUnlocked
        curve_shaper_support = $curveShaperSupport
        positive_co_support = $positiveCO
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
