# Phase 2 - Tool Development Plan

This document outlines the development requirements for Phase 2 Testing & Validation Kit based on our analysis of existing tools and documentation.

## Tools That Can Be Carried Over From iRacing Tuner Program

The following tools from the existing iRacing tuning kit can be leveraged or enhanced:

1. **Preflight-Check.ps1** - Pre-session sanity check
2. **FullTrace.ps1** - Main logger for performance monitoring  
3. **Scan-Stutter-Events.ps1** - Auto-reads FullTrace CSV to find stutters
4. **Test-UndervoltStability.ps1** - Tests undervolt stability (directly related to Phase 0 work)
5. **Check-Quiet-Status.ps1** - Checks the quiet status 
6. **Pre-Race-Quiet.ps1** and **Post-Race-Restore.ps1** - For session management
7. **Repair-PerfCounters.ps1**, **Enable-DiagnosticLogs.ps1** - Diagnostic tools

## New Tools That Need to be Developed for Phase 2

Based on the Phase 2 documentation requirements, these specific verification tools need to be built:

### 1. BIOS State Auditor 
- Reads live memory config, SoC voltage, whatever else research proved readable
- This tool doesn't exist in current iRacing tuning kit but is needed to verify BIOS settings from Phase 0
- [COMPLETED - Already developed and moved to final location]

### 2. Training Fingerprint Capture + Compare  
- Drift alarm across boots
- Currently not implemented in the existing project
- [COMPLETED - Development finished and tools deployed]

### 3. Health Report Tool
- Single pass/fail artifact (with detailed logs)
- Should produce both human-readable and AI-block structured formats for troubleshooting
- [COMPLETED - Development finished and tools deployed]

## Implementation Requirements

### 4.1 Dual-Format Output Engine
Every claim in this guide has a corresponding tool that confirms it - every tool should emit both formats:
1. Human-readable report (in the guide)
2. AI block with structured format for troubleshooting 

### 4.3 History Log Schema
Append-only log writer (so "what's been tried" is always available to the AI block)
Each entry should include:
- Timestamp
- Setting changed 
- Tool used for verification
- Result/Status
- Notes

## Development Approach

1. **Enhance Existing Tools**: Modify current scripts to support dual-format output as specified in section 4.1
2. **Develop New Tools**: Create the three new tools identified above (BIOS State Auditor, Training Fingerprint Capture + Compare, Health Report Tool)
3. **Integration**: Ensure all tools integrate with existing X3D-Profiles.ps1 for chip detection and consistent behavior

## Temporary Working Directory

As per project instructions:
```
mkdir temp
mkdir temp\Projects
mkdir temp\Projects\X3D-Setup-Guide
```

This will allow development work without affecting the main project until everything is tested and approved.

## Current Status 

All completed tools have been moved from the temporary directory to the main Projects/X3D-Setup-Guide location, including:
- BIOS-State-Auditor.ps1 (already present)
- Capture-TrainingFingerprint.ps1 (moved from temp directory)  
- Health-Report.ps1 (moved from temp directory)
- X3D-Profiles.ps1 (enhanced for dual-format output)

The temporary directory structure is now: 
```
temp/
└── Projects/
    └── X3D-Setup-Guide/
        ├── Capture-TrainingFingerprint.ps1  # [COMPLETED]
        └── Health-Report.ps1                # [COMPLETED]
```
