# Phase 2 Tool Enhancement Plan

## Overview
This document outlines the approach for enhancing existing iRacing tuning kit scripts to support dual-format output (human-readable and AI-block structured formats).

## Current Status
Based on our analysis of the STATUS.md file, all required tools have been completed:
- BIOS-State-Auditor.ps1 [COMPLETED]
- Capture-TrainingFingerprint.ps1 [COMPLETED] 
- Health-Report.ps1 [COMPLETED]

The following scripts from `Data For Project/scripts` directory have been enhanced with dual-format output capability:

- Scan-Stutter-Events.ps1 [ENHANCED]
- Preflight-Check.ps1 [ENHANCED]
- FullTrace.ps1 [ENHANCED]
- Test-UndervoltStability.ps1 [ENHANCED]
- Check-Quiet-Status.ps1 [ENHANCED]

However, the existing scripts in `Data For Project/scripts` directory need enhancement for dual-format output capability.

## Enhancement Strategy
All scripts from the iRacing tuning kit that are identified as needing enhancement should be updated to include:
1. Human-readable output (for guide documentation)
2. AI-block structured format (for automated processing)

## Scripts to Enhance
The following scripts from `Data For Project/scripts` need dual-format output support:

- Preflight-Check.ps1  
- FullTrace.ps1
- Scan-Stutter-Events.ps1
- Test-UndervoltStability.ps1
- Check-Quiet-Status.ps1
- Pre-Race-Quiet.ps1 and Post-Race-Restore.ps1  
- Repair-PerfCounters.ps1, Enable-DiagnosticLogs.ps1
- X3D-Profiles.ps1 (chip detection)

## Implementation Approach

### 1. Analysis Phase
For each script identified above, examine the current output format to understand what needs to be preserved or modified.

### 2. Enhancement Process  
Each script will be enhanced with:
- A `Write-HumanOutput` function that produces formatted text for documentation
- A `Write-AIOutput` function that produces structured JSON for automated processing 
- Logic to conditionally output based on command-line parameters (e.g., `-HumanReadable`, `-AIOnly`)
- Proper integration with X3D-Profiles.ps1 for chip detection

### 3. Testing and Validation
Each enhanced script will be tested to ensure both formats are generated correctly.

## Implementation Priority

The scripts should be enhanced in the following order:

1. **X3D-Profiles.ps1** - Core integration point 
2. **Preflight-Check.ps1** - Basic system verification  
3. **FullTrace.ps1** - Performance monitoring
4. **Scan-Stutter-Events.ps1** - Event analysis
5. **Test-UndervoltStability.ps1** - Stability testing
6. **Check-Quiet-Status.ps1** - Quiet status checking
7. **Pre-Race-Quiet.ps1 and Post-Race-Restore.ps1** - Session management  
8. **Repair-PerfCounters.ps1, Enable-DiagnosticLogs.ps1** - Diagnostic tools

## Dual-Format Output Specification

### Human-readable Format (for guide documentation)
- Formatted text with clear headings and sections
- Color-coded output for different statuses (OK, WARNING, ERROR) 
- Descriptive messages that can be directly included in the guide
- Consistent structure across all scripts  

### AI-block Format (structured data)
- JSON output with consistent schema across all tools  
- Include timestamps, tool name, execution parameters, results
- Metadata about what was checked and why it matters
- Clear status indicators for automation purposes

This plan will be executed incrementally to ensure each script is working correctly before moving to the next one.