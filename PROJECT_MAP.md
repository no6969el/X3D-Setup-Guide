# X3D Setup Guide Project Map

## Overview
This project contains a collection of PowerShell scripts and documentation for setting up and optimizing Windows systems for gaming and performance-critical applications, particularly focused on X3D (Xtreme 3D) performance tuning.

## Scripts Directory Structure
- `df_scripts/` - Contains dual-format PowerShell scripts for system configuration and optimization (human-readable + AI-block structured output)
  - `BIOS-State-Auditor.ps1` - Audits BIOS settings for X3D systems
  - `Capture-TrainingFingerprint.ps1` - Captures and compares memory training fingerprints
  - `Health-Report.ps1` - Provides system health assessment with dual-format output
  - `X3D-Profiles.ps1` - Manages X3D profiles with dual-format output
  - `X3D-Undervolt-Tester.ps1` - Integrates undervolt testing with X3D tuning framework
  - All scripts in this directory now support dual-format output
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

## Documentation Files
- `README.md` - Main project documentation
- `PROJECT_PLAN.md` - Complete development plan and roadmap
- `phase0-bios-foundation.md` - BIOS foundation setup
- `phase0-bios-foundation-final.md` - Final BIOS foundation
- `phase1-windows-baseline.md` - Windows baseline configuration
- `phase2-testing-validation.md` - Testing and validation procedures
- `phase2-tool-enhancement-plan.md` - Tool enhancement plan
- `x3d-first-time-setup-plan.pdf` - First-time setup plan (PDF)
- `FUTURE.pdf` - Future development plans (PDF)

## PowerShell Script Purpose Summary
- **Preparation Scripts**: `Pre-Race-Quiet.ps1`, `Preflight-Check.ps1`
- **Configuration Scripts**: `Set-GPU-IRQ-Affinity.ps1`, `Set-NIC-USB-IRQ-Affinity.ps1`, `Enable-GlobalTimerResolution.ps1`
- **Monitoring Scripts**: `Check-Quiet-Status.ps1`, `Watch-TimerResolution.ps1`, `Scan-Stutter-Events.ps1`
- **Reversion Scripts**: `Post-Race-Restore.ps1`, `Undo-GPU-IRQ-Affinity.ps1`, `Undo-NIC-USB-IRQ-Affinity.ps1`, `Undo-GlobalTimerResolution.ps1`
- **Diagnostic Scripts**: `Enable-DiagnosticLogs.ps1`, `FullTrace.ps1`, `Trace-QuietReverts.ps1`
- **Stability Scripts**: `Test-UndervoltStability.ps1`, `Repair-PerfCounters.ps1`
- **Utility Scripts**: `Create-Launchers.ps1`, `Apply-Guide-Extras.ps1`, `Undo-Guide-Extras.ps1`, `Add-Defender-Exclusions.ps1`

## Script Categories
1. **Pre-Race Setup**: Scripts run before performance testing
2. **During-Race Monitoring**: Scripts for real-time system monitoring
3. **Post-Race Cleanup**: Scripts to restore system after testing
4. **Diagnostic Tools**: Scripts for system diagnostics and troubleshooting
5. **Optimization Tools**: Scripts for system performance optimization
