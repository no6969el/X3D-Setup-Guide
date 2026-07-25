# Phase 0 - BIOS Foundation

Everything in this phase happens before Windows matters. Order matters.

## 2.1 BIOS/AGESA Baseline

### Update to a Current, Known-Stable BIOS
Update your motherboard's BIOS to a current, known-stable version. Record the AGESA version — memory training behavior and CO behavior change across AGESA releases.

**Minimum recommended AGESA for the guide: ComboAM5 PI 1.3.0.0a.**
This is a *floor*, not a target, and not a guarantee. Reasoning below.

### Load Optimized Defaults
After flashing, load optimized defaults (clears stale training data).

## 2.2 Memory: EXPO + Guaranteed Training Integrity

This is a core pillar of the guide per the brain dump: the memory tune must be trained, and must STAY trained, so the state is guaranteed identical at every boot.

### Enable EXPO Profile
Enable the EXPO profile (or manual timings for advanced path).

### Memory Context Restore (MCR): DISABLED
With MCR enabled, the board skips full DRAM training on boot and restores cached training data — faster boots, but training state can drift or restore stale/marginal data, producing "it was stable yesterday" instability. Disabling MCR forces a full retrain every boot: slower POST, guaranteed consistent training.

### Power Down Enable: DISABLED
Paired with MCR on most AM5 boards — both off for training consistency. [VERIFY pairing behavior per vendor]

### Record Trained Values
Record trained values after first successful boot (tRFC, actual UCLK/MCLK/FCLK) — these become the reference fingerprint the testing kit checks against.

**Guidance:**
- FCLK/UCLK/MCLK ratio guidance: 1:1 UCLK=MCLK for ≤6000 MT/s sweet spot; FCLK 2000–2133 typical
- SoC voltage guardrail: ≤1.30V hard cap (post-burnout AGESA-enforced, but verify the board respects it and don't manually exceed)

### Optional Advanced Section 
Manual subtimings, tRFC tightening, bank group swap — explicitly out of scope for "first-time setup," linked as a follow-on.

## 2.3 PBO & Curve Optimizer (Negative Offsets)

Start philosophy: every chip's silicon is different — start low, validate, step down.

### Two-Path Structure

**Path 1 (Default, Everyone):**
All-core conservative negative offset (−10 to −15 starting range), validated with the standard testing tiers. Done.
Most users stop here with a meaningful gain.

**Path 2 (Opt-in "Tuning Path"):**
A software suite of tuning options + recommendations with full logging — this is where the X3D Undervolt Tester project gets absorbed/extended. Per-core refinement, guided stepping, per-CCD awareness, and the dual-format output spec so every result is both human-readable and AI consumable.

### Dual-CCD Asymmetry (Class B/C)
Cache CCD and frequency CCD tolerate different offsets. Cache CCD typically runs lower voltage/frequency ceilings; frequency CCD cores often take deeper offsets.
Guide must present per-CCD guidance, not one number.

### PBO Limits (PPT/TDC/EDC)
Motherboard vs manual — first-time setup keeps these at defaults or motherboard-enforced; document what they are and how to read them.

### Boost Clock Override (+MHz)
Optional, later-stage. Key teaching point: an unstable CO offset often doesn't crash under load — it crashes at IDLE or light load (low-voltage boost states). Testing section must reflect this (Core Cycler-style single-core boosting tests, idle soak).

## 2.4 Scheduling-Relevant BIOS Settings (Class B/C)

### CPPC / CPPC Preferred Cores: Enabled
The driver stack depends on it.

### Global C-States: Enabled 
Parking depends on it [VERIFY current best practice — some guides disable, we should test]

### SMT: On by Default
Note X3D Turbo Mode (ASUS) / equivalent "game mode" toggles that disable SMT + CCD1 — document as a benchmark curiosity, not the recommended path. [DECISION NEEDED]

### iGPU: Disable If Discrete GPU Present
Removes a device from the interrupt/scheduling picture; we saw the iGPU cause confusion in community troubleshooting.

## 2.5 Boot Integrity Checklist (End of Phase 0)

- [ ] AGESA version recorded
- [ ] EXPO active, MCR off, Power Down off
- [ ] Trained memory fingerprint recorded
- [ ] SoC voltage confirmed ≤1.30V
- [ ] CO offsets recorded per core/CCD
- [ ] Three consecutive cold boots train to identical values [tooling opportunity: fingerprint-compare script]

## Vendor Translation Table

This guide is written in generic setting names, backed by a BIOS Translation Table covering the top 5 board vendors:
1. ASUS
2. MSI  
3. Gigabyte
4. ASRock
5. Biostar [CONFIRM 5th vendor choice]

User selects their board vendor once (or auto-detected via baseboard WMI query) and all instructions render/adjust with that vendor's exact wording and menu paths. Every setting also gets an expandable "other names for this setting" dropdown as the fallback for unlisted boards/BIOS revisions.

### Menu Paths
- ASUS: Ai Tweaker
- MSI: OC 
- Gigabyte: Tweaker

## Research Resolution (Appendix)

This section contains details of research that resolved issues in Phase 0.

### AGESA Version
* **Minimum recommended AGESA version**: ComboAM5 PI 1.3.0.0a.
* This is a *floor*, not a target, and not a guarantee.
* The minimum was chosen based on the following factors:
   - No known memory training issues with this or newer versions 
   - AGESA 1.3.0.0a introduced important fixes for X3D memory training
   - The community has successfully used this version for stable tuning

### MCR/Power Down Behavior
* **MCR and Power Down must be set consistently** (both off or both on).
* For the X3D Foundation Guide, setting both to OFF is recommended.
* This ensures that all systems go through full memory training every boot, maintaining consistent results.

### Memory Training Details
* EXPO profile + MCR disabled = optimal for first-time setup.
* Full retraining on each boot guarantees stability and prevents drift.
* The performance trade-off (slower POST) is acceptable as it ensures long-term system consistency over peak performance gains.

### SoC Voltage Enforcement
* Maximum SoC voltage should be ≤1.30V post-burnout AGESA-enforced.
* While most boards respect this, verify with the specific board manufacturer's documentation or tools if possible.
* This is a safety measure to prevent damage or instability.

### FCLK Guidance Update (Phase 0 v0.4 Resolution)
* **FCLK guidance has been refined**: 
   * Baseline recommendation: Keep FCLK at 2000 MHz
   * Rationale: Higher values can cause WHEA errors that are misattributed to CO instability
   * Path 2 of the guide will cover climbing FCLK for users who want to go beyond baseline