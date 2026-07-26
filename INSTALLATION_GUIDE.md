# X3D First-Time Setup & Optimization Guide - Installation Guide

## Overview
This guide provides step-by-step instructions for installing and setting up the X3D Setup Guide toolset on your Windows system.

## System Requirements
- Windows 10 or later
- PowerShell 5.1 or later
- Administrator privileges for system configuration scripts
- Compatible AMD Ryzen 9 X3D processors

## Installation Steps

### 1. Download the Toolset
- Download the complete X3D Setup Guide package from the official repository
- Extract the contents to a desired directory (e.g., `C:\X3D-Setup-Guide`)

### 2. Verify Directory Structure
After extraction, your directory should contain:
```
X3D-Setup-Guide/
├── df_scripts/
│   ├── BIOS-State-Auditor.ps1
│   ├── Capture-TrainingFingerprint.ps1
│   ├── Health-Report.ps1
│   ├── X3D-Profiles.ps1
│   ├── X3D-Undervolt-Tester.ps1
│   └── Enhanced-Automated-Test-Framework.ps1
├── scripts/
│   ├── Add-Defender-Exclusions.ps1
│   ├── Apply-Guide-Extras.ps1
│   ├── Check-Quiet-Status.ps1
│   ├── Create-Launchers.ps1
│   ├── Enable-DiagnosticLogs.ps1
│   ├── Enable-GlobalTimerResolution.ps1
│   ├── FullTrace.ps1
│   ├── Post-Race-Restore.ps1
│   ├── Pre-Race-Quiet.ps1
│   ├── Preflight-Check.ps1
│   ├── Repair-PerfCounters.ps1
│   ├── Scan-Stutter-Events.ps1
│   ├── Set-GPU-IRQ-Affinity.ps1
│   ├── Set-NIC-USB-IRQ-Affinity.ps1
│   ├── Test-UndervoltStability.ps1
│   ├── Trace-QuietReverts.ps1
│   ├── Undo-GlobalTimerResolution.ps1
│   ├── Undo-GPU-IRQ-Affinity.ps1
│   ├── Undo-Guide-Extras.ps1
│   ├── Undo-NIC-USB-IRQ-Affinity.ps1
│   └── Watch-TimerResolution.ps1
├── README.md
├── RELEASE_NOTES.md
└── INSTALLATION_GUIDE.md
```

### 3. Enable Script Execution
Before running any scripts, you may need to enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Run Initial Setup
1. Open PowerShell as Administrator
2. Navigate to your X3D-Setup-Guide directory
3. Run the initial setup scripts in order:
   ```powershell
   .\Pre-Race-Quiet.ps1
   .\Preflight-Check.ps1
   .\X3D-Profiles.ps1
   ```

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

## Script Categories

### Pre-Race Setup Scripts
- `Pre-Race-Quiet.ps1` - Sets up quiet mode before performance testing
- `Preflight-Check.ps1` - Performs preflight system checks

### Configuration Scripts
- `Set-GPU-IRQ-Affinity.ps1` - Sets GPU IRQ affinity
- `Set-NIC-USB-IRQ-Affinity.ps1` - Sets NIC/USB IRQ affinity
- `Enable-GlobalTimerResolution.ps1` - Enables global timer resolution

### Monitoring Scripts
- `Check-Quiet-Status.ps1` - Checks current quiet mode status
- `Watch-TimerResolution.ps1` - Watches timer resolution changes
- `Scan-Stutter-Events.ps1` - Scans for stutter events

### Reversion Scripts
- `Post-Race-Restore.ps1` - Restores system after performance testing
- `Undo-GPU-IRQ-Affinity.ps1` - Undoes GPU IRQ affinity
- `Undo-NIC-USB-IRQ-Affinity.ps1` - Undoes NIC/USB IRQ affinity
- `Undo-GlobalTimerResolution.ps1` - Undoes global timer resolution

### Diagnostic Scripts
- `Enable-DiagnosticLogs.ps1` - Enables diagnostic logging
- `FullTrace.ps1` - Performs full system tracing
- `Trace-QuietReverts.ps1` - Traces quiet mode reverts

### Stability Scripts
- `Test-UndervoltStability.ps1` - Tests undervolt stability
- `Repair-PerfCounters.ps1` - Repairs performance counters

### Utility Scripts
- `Create-Launchers.ps1` - Creates application launchers
- `Apply-Guide-Extras.ps1` - Applies additional guide optimizations
- `Undo-Guide-Extras.ps1` - Undoes guide optimizations
- `Add-Defender-Exclusions.ps1` - Adds exclusions to Windows Defender

## Security Considerations
- Run scripts with appropriate privileges as needed
- Review script contents before execution
- The toolset requires administrator privileges for system configuration changes
- All scripts are designed to be safe and non-destructive when used properly

## Troubleshooting
If you encounter issues:
1. Ensure PowerShell execution policy allows script execution
2. Verify you're running scripts with appropriate privileges
3. Check that your system meets the minimum requirements
4. Consult the RELEASE_NOTES.md for any known issues or limitations

## Support
For support, please refer to the documentation or contact the development team. All feedback is valuable for improving the X3D tuning process.