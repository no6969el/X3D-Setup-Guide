# X3D First-Time Setup & Optimization Guide

[!IMPORTANT] This project is now in the beta testing phase! 
Please see the "Beta Testing & Chip-Specific Testing" section below for detailed instructions on how to contribute to our validation testing.

This repository contains the first-time setup guide for AMD Ryzen 9 X3D processors. The guide takes users from a completely new PC build (or "never touched BIOS") to a verified, stable, repeatable X3D tune.

## Project Name
X3D Foundation: A First-Time Setup & Tuning Guide for AMD Ryzen 9 X3D Processors

This project is the foundation of an ecosystem that will eventually include:
- The first-time setup guide (this repository)
- The iRacing X3D Tuning kit 
- The X3D Undervolt Tester

## Project Status
Currently in development phase: Phase 2 - Testing & Validation Kit (Complete)
Phase 3 - Tool Enhancement (Complete)

## Development Status
This is a work in progress. Current development phase: Phase 2 - Testing & Validation Kit (Complete).
Phase 3 - Tool Enhancement (Complete)

## Purpose
This document is the master plan for building a first-time setup guide that takes a user from "just built the PC" (or "never touched BIOS") to a verified, stable, repeatable X3D tune — ending exactly where the iRacing X3D Tuning kit picks up.

## Framework Overview

The guide branches on three architectural dimensions:
- **Class A**: Single-CCD X3D (5800X3D, 7800X3D, 9800X3D) - Simplest path
- **Class B**: Dual-CCD, single-cache (7900X3D, 7950X3D, 9900X3D, 9950X3D) - The hard case 
- **Class C**: Dual-CCD, dual-cache (9950X3D2) - Most complex

## Enhanced Chip Classification

Building on the original Class A/B/C taxonomy, the X3D Tuning Kit now implements a more precise chip classification system based on research findings:

- **S4**: Single CCD, Zen 4, multiplier locked (e.g., 7800X3D, 7600X3D)
- **S5**: Single CCD, Zen 5, unlocked (e.g., 9800X3D, 9850X3D)
- **D4**: Dual CCD, Zen 4, asymmetric (e.g., 7950X3D, 7900X3D)
- **D5**: Dual CCD, Zen 5, asymmetric (e.g., 9950X3D, 9900X3D)

This research-based classification system enables more precise tuning parameters and testing approaches for each chip architecture.

## Development Status
This is a work in progress. Current development phase: Phase 0 - BIOS Foundation (Complete).

## Structure
1. [Phase 0 - BIOS Foundation](phase0-bios-foundation-final.md)
2. [Phase 1 - Windows Install & Baseline](phase1-windows-baseline.md) 
3. [Phase 2 - Testing & Validation Kit](phase2-testing-validation.md)

## Project Principles
1. **Verify, don't assume** - Every setting change gets a verification step (script or manual readout)
2. **Repeatability over peak numbers** - A tune that trains identically every boot beats a fragile record run
3. **Auto-detect, then branch** - Chip detection drives which instructions apply 
4. **Tested or sourced** - Every claim is either validated through our own troubleshooting history, cited from known-good community/vendor sources, or explicitly marked [VERIFY]

## Target Hardware
Primary target: AMD Ryzen 9 9950X3D (dual-CCD, single V-Cache die)

## X3D Tuning Kit - Dual-Format Optimization

The X3D Tuning Kit includes scripts that support both human-readable output and AI-readable structured output. This dual-format approach allows for:

1. **Human-Readable Output**: Traditional console output with clear status messages and guidance
2. **AI-Readable Output**: Structured JSON output that can be parsed by AI systems for automated analysis and decision-making

### Key Scripts with Dual-Format Support:
- **X3D-Profiles.ps1**: Core CPU detection script that provides both human-readable profile information and structured JSON output for AI systems
- **Pre-Race-Quiet.ps1**: System quieting script with both status reporting and structured data for AI analysis
- **Post-Race-Restore.ps1**: System restoration script with dual-format output capabilities
- **X3D-Undervolt-Tester.ps1**: Undervolt testing script that integrates with the X3D tuning framework and provides both human-readable results and AI-structured output
- **All scripts in df_scripts directory**: All scripts in the dedicated df_scripts directory now support dual-format output

### Enhanced X3D-Undervolt-Tester Capabilities

The enhanced X3D-Undervolt-Tester.ps1 now implements:

- **Research-based Chip Classification**: Uses S4/S5/D4/D5 taxonomy for precise chip detection
- **Per-CCD Testing**: Implements proper per-CCD baseline testing before per-core refinement
- **Multi-Phase Algorithm**: Follows the research-based approach with coarse screening, refinement, and confirmation stages
- **Curve Shaper Support**: Leverages Curve Shaper features for Zen 5 processors
- **Idle/Load Failure Detection**: Enhanced stability testing that catches instability at idle/load transitions

### Usage Examples:

For human users:
```powershell
.\X3D-Profiles.ps1
```

For AI systems:
```powershell
.\X3D-Profiles.ps1 -AIOnly
```

This dual-format approach ensures that the X3D tuning process can be effectively used by both human operators and automated systems, providing flexibility in how the tuning information is consumed and processed.

## Documentation Update Protocol

All changes to the X3D Tuning Kit are immediately documented to maintain consistency and quality. When modifications are made:

- **STATUS.md** is updated with current progress and task completion
- **PROJECT_MAP.md** is updated with new tools and capabilities
- **PROJECT_PLAN.md** is updated with completed milestones
- **README.md** is updated with new features and capabilities
- **Chip_Expansion_Request_Sheet.md** is maintained for future expansion planning

This "verify, don't assume" philosophy ensures that documentation always reflects the current state of the project.

## Beta Testing & Chip-Specific Testing

We are now preparing for a beta testing phase to validate our enhanced chip detection and tuning capabilities across all supported X3D processor families. 

### Supported Chip Classes
- **S4**: Single CCD, Zen 4, multiplier locked (e.g., 7800X3D, 7600X3D)
- **S5**: Single CCD, Zen 5, unlocked (e.g., 9800X3D, 9850X3D)
- **D4**: Dual CCD, Zen 4, asymmetric (e.g., 7950X3D, 7900X3D)
- **D5**: Dual CCD, Zen 5, asymmetric (e.g., 9950X3D, 9900X3D)

### Beta Tester Guidelines
Beta testers can contribute valuable data by running the following tests on their specific hardware:

1. **Chip Detection Test**: Run `X3D-Profiles.ps1` to verify accurate chip class detection
2. **Undervolt Testing**: Execute `X3D-Undervolt-Tester.ps1` with appropriate parameters for their chip class
3. **Stability Verification**: Run stability tests across all workload stages
4. **Performance Benchmarking**: Compare results against baseline performance metrics

### Data Collection Requirements
When contributing to the beta testing program, please provide:
- Chip identification and class (S4/S5/D4/D5)
- Environmental fingerprint (AGESA, BIOS, drivers, etc.)
- Test parameters used
- Stability test results
- Performance benchmarking data
- Clock stretching measurements
- Any error logs or failure analysis

### Test Results Format
All test results should follow the standardized validation report format found in the `temp/` directory. This ensures consistent data collection and analysis across all beta testers.

### Download Beta Testing Package
All beta testing materials are now available in a downloadable package:
- **Download**: [X3D-Beta-Testing-Package.zip](X3D-Beta-Testing-Package.zip)
- This package contains all necessary tools and documentation for beta testing

### How to Contribute
1. Download and extract the beta testing package
2. Run the `X3D-Beta-Test.bat` script to perform automated testing
3. Document your findings using the validation report template
4. Submit your results to the development team
5. Provide feedback on usability and documentation clarity

This beta testing phase will help us validate our enhanced chip detection and tuning capabilities across the full range of supported X3D processors.
