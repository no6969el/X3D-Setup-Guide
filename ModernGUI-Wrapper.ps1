# X3D Setup Guide - Modern GUI Wrapper
# This script provides a basic modern interface for the X3D Setup Guide tools
# while maintaining all existing functionality

param(
    [switch]$ShowGUI
)

# Function to display a modern interface
function Show-ModernInterface {
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host "         X3D SETUP GUIDE - MODERN INTERFACE"    -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Available Tools:" -ForegroundColor Cyan
    Write-Host "1. Chip Profile Detection" -ForegroundColor Yellow
    Write-Host "2. BIOS State Audit" -ForegroundColor Yellow
    Write-Host "3. System Health Report" -ForegroundColor Yellow
    Write-Host "4. Undervolt Testing" -ForegroundColor Yellow
    Write-Host "5. Training Fingerprint Capture" -ForegroundColor Yellow
    Write-Host "6. Full System Setup" -ForegroundColor Yellow
    Write-Host "7. Exit" -ForegroundColor Yellow
    Write-Host ""
    
    $choice = Read-Host "Select an option (1-7)"
    
    switch ($choice) {
        1 { 
            Write-Host "Running Chip Profile Detection..." -ForegroundColor Green
            .\df_scripts\X3D-Profiles.ps1
            Write-Host "Chip Profile Detection completed." -ForegroundColor Green
        }
        2 { 
            Write-Host "Running BIOS State Audit..." -ForegroundColor Green
            .\df_scripts\BIOS-State-Auditor.ps1
        }
        3 { 
            Write-Host "Running System Health Report..." -ForegroundColor Green
            .\df_scripts\Health-Report.ps1
        }
        4 { 
            Write-Host "Running Undervolt Testing..." -ForegroundColor Green
            .\df_scripts\X3D-Undervolt-Tester.ps1
        }
        5 { 
            Write-Host "Running Training Fingerprint Capture..." -ForegroundColor Green
            .\df_scripts\Capture-TrainingFingerprint.ps1
        }
        6 { 
            Write-Host "Running Full System Setup..." -ForegroundColor Green
            Write-Host "Step 1: Pre-Race Quiet Mode" -ForegroundColor Yellow
            .\df_scripts\Pre-Race-Quiet.ps1
            Write-Host "Step 2: Preflight Check" -ForegroundColor Yellow
            .\df_scripts\Preflight-Check.ps1
            Write-Host "Step 3: Chip Profile Detection" -ForegroundColor Yellow
            .\df_scripts\X3D-Profiles.ps1
            Write-Host "Step 4: Health Report" -ForegroundColor Yellow
            .\df_scripts\Health-Report.ps1
            Write-Host "Setup complete!" -ForegroundColor Green
        }
        7 { 
            Write-Host "Goodbye!" -ForegroundColor Green
            return
        }
        default { 
            Write-Host "Invalid option. Please try again." -ForegroundColor Red
            Show-ModernInterface
        }
    }
    
    Write-Host ""
    $continue = Read-Host "Press Enter to continue..."
    Show-ModernInterface
}

# Main execution
if ($ShowGUI) {
    Show-ModernInterface
} else {
    Write-Host "Use -ShowGUI parameter to launch the modern interface" -ForegroundColor Yellow
    Write-Host "Example: .\ModernGUI-Wrapper.ps1 -ShowGUI" -ForegroundColor Yellow
}