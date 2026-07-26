# X3D First-Time Setup & Optimization Guide - Release Notes

## Version 1.1 - Tool Integration and Release

This release represents the completion of the X3D Setup Guide project with full integration of all enhanced tools and capabilities.

## Key Enhancements

### Dual-Format Output System
- **Human-readable report**: Clean summary with pass/fail, key numbers, and plain-language interpretation
- **AI troubleshooting block**: Fenced, copy-paste-ready block with embedded prompt header, structured state dump, and explicit ask
- **History logging**: Append-only log writer for iterative AI tuning sessions

### Enhanced X3D-Undervolt-Tester
- **Research-based Chip Classification**: Implements S4/S5/D4/D5 taxonomy for precise chip detection
- **Per-CCD Testing**: Implements proper per-CCD baseline testing before per-core refinement
- **Multi-Phase Algorithm**: Follows research-based approach with coarse screening, refinement, and confirmation stages
- **Curve Shaper Support**: Leverages Curve Shaper features for Zen 5 processors
- **Idle/Load Failure Detection**: Enhanced stability testing that catches instability at idle/load transitions
- **Crash Detection and Recovery System**: Implements crash detection and recovery to eliminate survivorship bias in testing results
- **Enhanced Outcome Classification**: Provides detailed failure modes and outcome classification for better AI analysis
- **Clock-Stretching Measurement**: Implements clock-stretching measurement with C0 residency gating

### Comprehensive Chip Support
- **Class A**: Single-CCD X3D (5800X3D, 7800X3D, 9800X3D)
- **Class B**: Dual-CCD, single-cache (7900X3D, 7950X3D, 9900X3D, 9950X3D)
- **Class C**: Dual-CCD, dual-cache (9950X3D2)
- **Research-based Classification**: S4/S5/D4/D5 taxonomy for precise chip detection

## Directory Structure

### Main Scripts Directory
- `df_scripts/` - Contains dual-format PowerShell scripts for system configuration and optimization (human-readable + AI-block structured output)
  - `BIOS-State-Auditor.ps1` - Audits BIOS settings for X3D systems
  - `Capture-TrainingFingerprint.ps1` - Captures and compares memory training fingerprints
  - `Health-Report.ps1` - Provides system health assessment with dual-format output
  - `X3D-Profiles.ps1` - Manages X3D profiles with dual-format output (enhanced with detailed chip specifications)
  - `X3D-Undervolt-Tester.ps1` - Integrates undervolt testing with X3D tuning framework (enhanced with chip class detection and architecture-specific parameters)
  - `Enhanced-Automated-Test-Framework.ps1` - Enhanced automated testing framework for Phase 6
  - All scripts in this directory now support dual-format output

### Standard Utility Scripts
- `scripts/` - Contains standard utility PowerShell scripts for system configuration and optimization
  - `Add-Defender-Exclusions.ps1` - Adds exclusions to Windows Defender
  - `Apply-Guide-Extras.ps1` - Applies additional guide optimizations
  - `Check-Quiet-Status.ps1` - Checks current quiet mode status
  - `Create-Launchers.ps1` - Creates application launchers
  - `Enable-DiagnosticLogs.ps1` - Enables diagnostic logging
  - `Enable-GlobalTimerResolution.ps1` - Enables global timer resolution
  - `FullTrace.ps1` - Performs full system tracing
  - `Post-Race-Restore.ps1` - Restores system after performance testing
  - `Pre-Race-Quiet.ps1` - Sets up quiet mode before performance testing
  - `Preflight-Check.ps1` - Performs preflight system checks
  - `Repair-PerfCounters.ps1` - Repairs performance counters
  - `Scan-Stutter-Events.ps1` - Scans for stutter events
  - `Set-GPU-IRQ-Affinity.ps1` - Sets GPU IRQ affinity
  - `Set-NIC-USB-IRQ-Affinity.ps1` - Sets NIC/USB IRQ affinity
  - `Test-UndervoltStability.ps1` - Tests undervolt stability
  - `Trace-QuietReverts.ps1` - Traces quiet mode reverts
  - `Undo-GlobalTimerResolution.ps1` - Undoes global timer resolution
  - `Undo-GPU-IRQ-Affinity.ps1` - Undoes GPU IRQ affinity
  - `Undo-Guide-Extras.ps1` - Undoes guide optimizations
  - `Undo-NIC-USB-IRQ-Affinity.ps1` - Undoes NIC/USB IRQ affinity
  - `Watch-TimerResolution.ps1` - Watches timer resolution changes

## Usage Examples

### For Human Users:
```powershell
# Check system profile
.\X3D-Profiles.ps1

# Run health report
.\Health-Report.ps1

# Run undervolt testing
.\X3D-Undervolt-Tester.ps1
```

### For AI Systems:
```powershell
# Get structured output for AI processing
.\X3D-Profiles.ps1 -AIOnly

# Get AI-ready results from health report
.\Health-Report.ps1 -AIOnly
```

## Project Principles Maintained
1. **Verify, don't assume** - Every setting change gets a verification step
2. **Repeatability over peak numbers** - A tune that trains identically every boot beats a fragile record run
3. **Auto-detect, then branch** - Chip detection drives which instructions apply
4. **Tested or sourced** - Every claim is either validated through troubleshooting history, cited from known-good community/vendor sources, or explicitly marked [VERIFY]

## System Requirements
- Windows 10 or later
- PowerShell 5.1 or later
- Administrator privileges for system configuration scripts
- Compatible AMD Ryzen 9 X3D processors

## Support and Feedback
For support, please refer to the documentation or contact the development team. All feedback is valuable for improving the X3D tuning process.