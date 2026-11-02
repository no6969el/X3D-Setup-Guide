<#
    Preflight-Check.ps1
    Read-only checklist for the settings Invoke-X3DScan.ps1 can fix.
    Does not change Windows. Does not write the agent report.
#>
& (Join-Path $PSScriptRoot 'Invoke-X3DScan.ps1') -DryRun
