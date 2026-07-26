# X3D First-Time Setup & Optimization Guide - Development Plan

## Project Overview

The X3D First-Time Setup & Optimization Guide is a comprehensive project that builds a foundation for tuning AMD Ryzen 9 X3D processors. The project follows a structured roadmap with clear phases, from BIOS foundation to advanced tuning.

## Current Status

The project has successfully implemented dual-format output capabilities for scripts, with enhanced scripts in the `df_scripts/` directory and original scripts in the `scripts/` directory. All scripts in the df_scripts directory now support dual-format output as specified in the project requirements.

## Prioritized Development Plan

### Phase 1: Foundation Completion (v0.3 - v0.5)
**Priority: High**

#### Asset Intake and Research (v0.3)
- [ ] Intake all supplied assets (detect script, X3D Undervolt Tester, iRacing kit scripts, troubleshooting notes)
- [ ] Convert all [VERIFY]/[VALIDATED-DIRECTION] tags to confirmed claims
- [ ] Complete research items 1-8
- [ ] Resolve open decisions 5-12
- [ ] Audit detect script and establish claim-provenance convention

#### Foundation Content (v0.4)
- [ ] Write Phase 0 BIOS chapter for 9950X3D
- [ ] Build BIOS Translation Table for 5 vendors
- [ ] Create memory training integrity chapter
- [ ] Document CO Path 1 (all-core conservative)
- [ ] Finalize boot integrity checklist

#### Tooling Foundation (v0.5)
- [ ] Build dual-format output engine
- [ ] Implement history log schema
- [ ] Develop chip detection tool
- [ ] Create BIOS state auditor
- [ ] Build training fingerprint capture/compare tool
- [ ] Develop health report tool

### Phase 2: Windows Integration and Scheduling (v0.6)
**Priority: High**

#### Windows Baseline Chapter
- [ ] Document chipset driver stack and V-Cache Optimizer
- [ ] Address Game Bar warnings for Class B
- [ ] Explain Balanced power plan rationale
- [ ] Document NVIDIA driver hygiene

#### Scheduling Verification
- [ ] Create scheduling verifier tool
- [ ] Implement backup/restore integration
- [ ] Write handoff chapter to iRacing kit

### Phase 3: Advanced Tuning Path (v0.7)
**Priority: Medium**

#### Absorb X3D Undervolt Tester
- [x] Integrate into suite
- [x] Implement per-core guided stepping
- [x] Create recommendation engine
- [x] Implement testing protocol tiers

#### Advanced Features
- [ ] CoreCycler + idle-soak integration
- [ ] Every result routed through dual-format engine

### Phase 4: Chip Expansion (v0.8)
**Priority: Medium**

#### Class Expansion
- [x] Add Class A chips (single-CCD)
- [x] Add Class C chips (9950X3D2 dual-cache)
- [x] Add remaining Class B chips
- [x] Document Zen 4 vs Zen 5 divergences
- [x] Chip catalog enhancement completed
- [x] Enhanced testing protocols for different chip architectures

### Phase 5: Integration and Validation (v0.9)
**Priority: High**

#### Integration and Validation
- [ ] Test integration between all enhanced tools
- [ ] Validate chip detection accuracy across all chip families
- [ ] Perform stability testing with enhanced protocols
- [ ] Generate comprehensive validation reports
- [ ] Document performance differences between chip classes

#### Deliverables
1. Integrated toolset with enhanced chip support
2. Validation reports for all chip families
3. Performance comparison documentation
4. User guides for enhanced functionality

### Phase 6: Tool Enhancement and Optimization (v1.0)
**Priority: High**

#### Enhancement and Optimization
- [ ] Implement automated testing framework
- [ ] Enhance AI output with more detailed recommendations
- [ ] Improve error handling and edge case management
- [ ] Optimize testing protocols for faster execution
- [ ] Strengthen documentation and user guides

#### Deliverables
1. Automated testing framework
2. Enhanced AI output capabilities
3. Improved error handling
4. Optimized performance protocols
5. Updated documentation

## Key Features

### Dual-Format Output
- **Human-readable report**: Clean summary with pass/fail, key numbers, and plain-language interpretation
- **AI troubleshooting block**: Fenced, copy-paste-ready block with embedded prompt header, structured state dump, and explicit ask
- **History logging**: Append-only log writer for iterative AI tuning sessions

### Core Components
1. **Chip Detection**: Reuse existing auto-detection script from iRacing X3D tuner
2. **BIOS State Auditor**: Reads live memory config, SoC voltage, and other readable states
3. **Training Fingerprint Compare**: Captures trained memory state and diffs across boots
4. **Scheduling Verifier**: Confirms V-Cache driver, Game Mode, and preferred core rankings
5. **One-shot Health Report**: Runs all checks and outputs single pass/fail report

## Redundant Information Analysis

### Files That May Be Redundant:
1. **phase2-tool-development-plan.md** vs **FUTURE.pdf** - Both contain development plans but with different focus
2. **STATUS.md** vs **PROJECT_MAP.md** - Both contain status information but in different formats

### Recommended Merging:
- **phase2-tool-development-plan.md** and **FUTURE.pdf** should be merged into a single comprehensive roadmap document
- **STATUS.md** should be consolidated with **PROJECT_MAP.md** to avoid duplication

### Suggested Consolidated Structure:
1. **PROJECT_ROADMAP.md** - Complete roadmap with phases and milestones
2. **PROJECT_STATUS.md** - Current status tracking with implementation progress
3. **PROJECT_STRUCTURE.md** - Directory structure and file organization

## Implementation Notes

- All new tools should follow the established dual-format output pattern
- Tooling should integrate seamlessly with the iRacing X3D Tuning kit
- The project maintains a "verify, don't assume" philosophy throughout
- Repeatability over peak numbers is a core principle
- Auto-detection drives which instructions apply