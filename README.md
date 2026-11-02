# X3D tuner

A local scan for an AMD Ryzen X3D PC. It reads the Windows settings the scripts in `df_scripts` can change, applies a fixer when a check fails, and writes a report an LM or cloud agent can read.

The scan has to run on this PC. A cloud agent cannot see the machine until that report exists.

## Run

`X3D-Setup-Guide-Launcher.bat` asks for administrator and opens the window. **Scan and fix** applies changes. **Dry run** only prints what it would change.

From a prompt:

```powershell
.\df_scripts\Invoke-X3DScan.ps1 -DryRun
.\df_scripts\Invoke-X3DScan.ps1
```

`Preflight-Check.ps1` is the dry run.

## What it will change

- USB selective suspend off, and Game Mode, Game Bar, and Game DVR off. No reboot. Undo: `Undo-Guide-Extras.ps1`.
- `GlobalTimerResolutionRequests = 1`. Reboot, then scan again. Undo: `Undo-GlobalTimerResolution.ps1`.
- NVIDIA GPU interrupts off CPU 0, using the chip profile. Reboot. Undo: `Undo-GPU-IRQ-Affinity.ps1`.
- PCI NIC and USB host interrupts onto background CPUs. Reboot. Undo: `Undo-NIC-USB-IRQ-Affinity.ps1`.
- Performance counters, only when a processor counter query comes back empty. Reboot. `Repair-PerfCounters.ps1` has no undo; it rebuilds Windows counters.

Interrupt steering stays off when the CPU is not an X3D part or the topology is not known.

## What it will not change

EXPO, memory context restore, SoC voltage, and Curve Optimizer. Windows cannot read or write them. The report marks each `not_fixable_from_windows`.

`Test-UndervoltStability.ps1` can test cores and write a CSV next to itself. The scan includes the latest CSV and any core a previous run died on. It does not start that test, and it does not write an offset. `X3D-Undervolt-Tester.ps1` only repeats the numbers in that CSV.

`BIOS-State-Auditor.ps1`, `Capture-TrainingFingerprint.ps1`, and `Health-Report.ps1` report fields Windows actually returns. They do not fill in demo voltages or a pass. `Enhanced-Automated-Test-Framework.ps1` will not invent a stability or health pass.

## Report

After a real scan:

- `%ProgramData%\X3DTuner\latest-report.json`
- `%ProgramData%\X3DTuner\history.jsonl` (one JSON object per line)

Each item is `fixed`, `already_ok`, `failed`, or `not_fixable_from_windows`, with the value before, the value after, the script used, and whether a reboot is still required. A dry run does not write these files.

The chip profile cache, when a real scan saves one, is `%APPDATA%\X3DTuner\config.json`.
