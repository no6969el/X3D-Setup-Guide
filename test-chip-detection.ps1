# Test script to debug chip detection
Write-Host "Testing chip detection..."
try {
    . (Join-Path $PSScriptRoot 'df_scripts\X3D-Profiles.ps1')
    Write-Host "Script loaded successfully"
    $profile = Get-X3DProfile -HumanReadable
    Write-Host "Profile retrieved: $profile"
    if ($profile) {
        Write-Host "Profile details:"
        $profile | Format-List
    } else {
        Write-Host "No profile returned"
    }
} catch {
    Write-Host "Error occurred: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.Exception.StackTrace)"
}