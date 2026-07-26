# X3D First-Time Setup & Optimization Guide

This repository contains the first-time setup guide for AMD Ryzen 9 X3D processors. The guide takes users from a completely new PC build (or "never touched BIOS") to a verified, stable, repeatable X3D tune.

## Project Name
X3D Foundation: A First-Time Setup & Tuning Guide for AMD Ryzen 9 X3D Processors

This project is the foundation of an ecosystem that will eventually include:
- The first-time setup guide (this repository)
- The iRacing X3D Tuning kit 
- The X3D Undervolt Tester

## Project Status
Currently in development phase: Phase 0 - BIOS Foundation (Complete)

## Development Status
This is a work in progress. Current development phase: Phase 0 - BIOS Foundation (Complete).

## Purpose
This document is the master plan for building a first-time setup guide that takes a user from "just built the PC" (or "never touched BIOS") to a verified, stable, repeatable X3D tune — ending exactly where the iRacing X3D Tuning kit picks up.

## Framework Overview

The guide branches on three architectural dimensions:
- **Class A**: Single-CCD X3D (5800X3D, 7800X3D, 9800X3D) - Simplest path
- **Class B**: Dual-CCD, single-cache (7900X3D, 7950X3D, 9900X3D, 9950X3D) - The hard case 
- **Class C**: Dual-CCD, dual-cache (9950X3D2) - Most complex

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