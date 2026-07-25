# Phase 1 - Windows Install & Baseline

Assumes fresh Windows 11 install (24H2+). 

## 3.1 The Driver Stack (Class B/C Critical Path)

The dual-CCD X3D scheduling story lives in software:

### 1. AMD Chipset Drivers
Installs the 3D V-Cache Performance Optimizer driver + PPM provisioning.
Without this, cache-CCD preference doesn't work.
Version matters; record it.

### 2. Windows Game Mode + Xbox Game Bar
Game detection is what triggers cache-CCD preference and frequency-CCD parking. 
Counter-intuitive for optimizers who instinctively strip Game Bar out. The guide must explicitly warn: do not debloat away Game Bar on Class B chips (unless going the manual-affinity route from the iRacing kit).

### 3. Power Plan
Balanced is the AMD-intended plan for parking behavior (not Ultimate/High Performance).
[VALIDATED-DIRECTION — align with what we proved in the iRacing kit testing]

### Verification Step
Confirm amd3dvcache service/driver present and running; confirm preferred-core rankings visible (e.g., via provisioning package readout). [tooling opportunity]

## 3.2 Windows Baseline Settings

### HAGS (Hardware-Accelerated GPU Scheduling)
Document current recommendation + how to test both states. [RESEARCH]
* **Current Recommendation**: Enable HAGS for optimal X3D performance
* **Rationale**: Improves scheduling efficiency and reduces latency on multi-CCD systems

### Core Isolation / VBS / Memory Integrity
Measurable overhead on some systems; document tradeoff honestly (security vs latency) rather than blanket "disable."
* **For X3D Systems**: Minimal overhead, recommend keeping enabled for security benefits

### Timer Resolution
Reference the existing iRacing kit — that's its territory. Link, don't duplicate.

### Background/Debloat
Minimal, reversible changes only. No registry-hack soup. Everything scripted = everything reversible.

### NVIDIA Driver Install
Clean install, no bloat. Note our documented MEMORY_MANAGEMENT 0x61941 BSOD history with iRacing/NVIDIA drivers — driver version hygiene section. [Pull from our forum PSA]

## 3.3 Handoff Point

Phase 1 ends where the iRacing X3D Tuning kit begins: 
per-application CPU Sets, GPU interrupt affinity, Process Lasso config. 
The first-time-setup guide links out; no duplication.

## 3.4 Integration with Phase 0 Findings

Based on the research resolution from Phase 0 v0.4, several key recommendations should be incorporated into this baseline:

### FCLK Guidance Update
The current BIOS foundation guidance has been refined:
* **Baseline recommendation**: Keep FCLK at 2000 MHz (as established in Phase 0)
* **Rationale**: Higher values can cause WHEA errors that are misattributed to CO instability
* **Impact on Windows baseline**: This stability-focused approach should be maintained through the Windows setup phase

### Memory Training Integrity 
The memory training consistency achieved in BIOS must carry forward:
* The EXPO profile with MCR disabled ensures consistent memory training
* Any Windows-level configuration should not disrupt this established foundation

### SoC Voltage Enforcement
Maintain the ≤1.30V SoC voltage guardrail established in Phase 0:
* This safety measure should be documented and validated during Windows baseline setup
* The driver stack relies on these voltage parameters for stability