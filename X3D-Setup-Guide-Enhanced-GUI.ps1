# X3D Setup Guide - Enhanced GUI Version
# This script provides an enhanced graphical interface for the X3D Setup Guide tools
# with a dedicated panel for displaying chip information

# Track PowerShell processes launched by this GUI
$psProcesses = @()

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "X3D Setup Guide - Enhanced Interface"
$form.Size = New-Object System.Drawing.Size(900, 600)
$form.StartPosition = "CenterScreen"
$form.Icon = [System.Drawing.SystemIcons]::Information

# Main panel for menu
$menuPanel = New-Object System.Windows.Forms.Panel
$menuPanel.Size = New-Object System.Drawing.Size(250, 550)
$menuPanel.Location = New-Object System.Drawing.Point(10, 10)
$menuPanel.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$menuPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

# Results panel for chip information
$resultsPanel = New-Object System.Windows.Forms.Panel
$resultsPanel.Size = New-Object System.Drawing.Size(620, 550)
$resultsPanel.Location = New-Object System.Drawing.Point(270, 10)
$resultsPanel.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 250)
$resultsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

# Label for results panel title
$resultsLabel = New-Object System.Windows.Forms.Label
$resultsLabel.Text = "Chip Detection Results"
$resultsLabel.Location = New-Object System.Drawing.Point(10, 10)
$resultsLabel.Size = New-Object System.Drawing.Size(300, 20)
$resultsLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$resultsLabel.ForeColor = [System.Drawing.Color]::DarkBlue

# RichTextBox for displaying chip information
$resultsBox = New-Object System.Windows.Forms.RichTextBox
$resultsBox.Location = New-Object System.Drawing.Point(10, 40)
$resultsBox.Size = New-Object System.Drawing.Size(600, 500)
$resultsBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$resultsBox.ReadOnly = $true
$resultsBox.BackColor = [System.Drawing.Color]::White
$resultsBox.ScrollBars = "Vertical"

# Menu items
$menuItems = @(
    @{ Text = "1. Chip Profile Detection"; Command = "ChipProfile" },
    @{ Text = "2. BIOS State Audit"; Command = "BIOSAudit" },
    @{ Text = "3. System Health Report"; Command = "HealthReport" },
    @{ Text = "4. Undervolt Testing"; Command = "UndervoltTest" },
    @{ Text = "5. Training Fingerprint Capture"; Command = "FingerprintCapture" },
    @{ Text = "6. Full System Setup"; Command = "FullSetup" },
    @{ Text = "7. Exit"; Command = "Exit" }
)

# Create menu buttons
$buttonHeight = 40
$buttonSpacing = 10
$buttonTop = 20

$buttons = @()
foreach ($item in $menuItems) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $item.Text
    $button.Size = New-Object System.Drawing.Size(230, $buttonHeight)
    $button.Location = New-Object System.Drawing.Point(10, $buttonTop)
    $button.Font = New-Object System.Drawing.Font("Arial", 9)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
    $button.Tag = $item.Command
    
    # Add click event
    $button.Add_Click({
        $command = $this.Tag
        Execute-Command $command
    })
    
    $menuPanel.Controls.Add($button)
    $buttons += $button
    $buttonTop += $buttonHeight + $buttonSpacing
}

# Add controls to panels
$resultsPanel.Controls.Add($resultsLabel)
$resultsPanel.Controls.Add($resultsBox)

# Add panels to form
$form.Controls.Add($menuPanel)
$form.Controls.Add($resultsPanel)

# Function to execute commands
function Execute-Command {
    param([string]$command)
    
    # Clear results box
    $resultsBox.Clear()
    
    # Add timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $resultsBox.AppendText("[$timestamp] Executing: $command`r`n")
    $resultsBox.AppendText("=" * 50 + "`r`n")
    
    try {
        switch ($command) {
            "ChipProfile" {
                $resultsBox.AppendText("Running Chip Profile Detection...`r`n")
                $resultsBox.AppendText("-" * 30 + "`r`n")
                
                # Execute the chip profile detection and capture output properly
                try {
                    # Load the script and get profile directly
                    . (Join-Path $PSScriptRoot 'df_scripts\X3D-Profiles.ps1')
                    $profile = Get-X3DProfile -HumanReadable
                    
                    if ($profile) {
                        # Display the chip profile information in a structured way
                        $resultsBox.AppendText("Chip Profile Information:`r`n")
                        $resultsBox.AppendText("=" * 40 + "`r`n")
                        $resultsBox.AppendText("Model: $($profile.Model)`r`n")
                        $resultsBox.AppendText("Cores: $($profile.Cores)`r`n")
                        $resultsBox.AppendText("Logical Cores: $($profile.LogicalCores)`r`n")
                        $resultsBox.AppendText("Topology: $($profile.Topology)`r`n")
                        $resultsBox.AppendText("V-Cache Scope: $($profile.VCacheScope)`r`n")
                        $resultsBox.AppendText("Is X3D Processor: $($profile.IsX3D)`r`n")
                        $resultsBox.AppendText("Form Factor: $($profile.Form)`r`n")
                        $resultsBox.AppendText("Architecture: $($profile.Arch)`r`n")
                        $resultsBox.AppendText("Platform: $($profile.Platform)`r`n")
                        $resultsBox.AppendText("TDP: $($profile.TDP)`r`n")
                        $resultsBox.AppendText("PPT: $($profile.PPT)`r`n")
                        $resultsBox.AppendText("Tjmax: $($profile.Tjmax)`r`n")
                        $resultsBox.AppendText("Multiplier Unlocked: $($profile.MultiplierUnlocked)`r`n")
                        $resultsBox.AppendText("Curve Shaper Support: $($profile.CurveShaperSupport)`r`n")
                        $resultsBox.AppendText("Positive CO Support: $($profile.PositiveCO)`r`n")
                        $resultsBox.AppendText("Chip Class: $($profile.Profile)`r`n")
                        $resultsBox.AppendText("CCD Count: $($profile.CcdCount)`r`n")
                        $resultsBox.AppendText("CCD0 Logical Cores: $($profile.Ccd0Logical)`r`n")
                        $resultsBox.AppendText("VCache Range: $($profile.VCacheRange)`r`n")
                        $resultsBox.AppendText("Background Range: $($profile.BackgroundRange)`r`n")
                        $resultsBox.AppendText("Frequency First Core: $($profile.FreqFirst)`r`n")
                        $resultsBox.AppendText("=" * 40 + "`r`n")
                        $resultsBox.AppendText("Detection Source: $($profile.DetectSource)`r`n")
                        $resultsBox.AppendText("Detection Date: $($profile.DetectedOn)`r`n")
                    } else {
                        $resultsBox.AppendText("Chip Profile Detection completed but no profile information was returned.`r`n")
                    }
                } catch {
                    $resultsBox.AppendText("Error during chip profile detection: $($_.Exception.Message)`r`n")
                    $resultsBox.AppendText("Stack trace: $($_.Exception.StackTrace)`r`n")
                }
            }
            "BIOSAudit" {
                $resultsBox.AppendText("Running BIOS State Audit...`r`n")
                $resultsBox.AppendText("-" * 30 + "`r`n")
                
                # Execute BIOS audit and capture output
                try {
                    $output = & "$PSScriptRoot\df_scripts\BIOS-State-Auditor.ps1" 2>&1
                    if ($output) {
                        # Format the BIOS audit output for better readability
                        $resultsBox.AppendText("BIOS State Audit Results:`r`n")
                        $resultsBox.AppendText("=" * 40 + "`r`n")
                        $resultsBox.AppendText($output)
                    } else {
                        $resultsBox.AppendText("BIOS State Audit completed with no output.`r`n")
                    }
                } catch {
                    $resultsBox.AppendText("Error during BIOS audit: $($_.Exception.Message)`r`n")
                }
            }
            "HealthReport" {
                $resultsBox.AppendText("Running System Health Report...`r`n")
                $resultsBox.AppendText("-" * 30 + "`r`n")
                
                # Execute health report and capture output
                try {
                    $output = & "$PSScriptRoot\df_scripts\Health-Report.ps1" 2>&1
                    if ($output) {
                        # Format the health report output for better readability
                        $resultsBox.AppendText("System Health Report Results:`r`n")
                        $resultsBox.AppendText("=" * 40 + "`r`n")
                        $resultsBox.AppendText($output)
                    } else {
                        $resultsBox.AppendText("System Health Report completed with no output.`r`n")
                    }
                } catch {
                    $resultsBox.AppendText("Error during health report: $($_.Exception.Message)`r`n")
                }
            }
            "UndervoltTest" {
                $resultsBox.AppendText("Running Undervolt Testing...`r`n")
                $resultsBox.AppendText("-" * 30 + "`r`n")
                
                # Check if running as administrator
                $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                if (-not $admin) { 
                    $resultsBox.AppendText("ERROR: Undervolt testing requires administrator privileges.`r`n")
                    $resultsBox.AppendText("Please run the launcher as Administrator.`r`n")
                    return 
                }
                
                # Execute undervolt test and capture output
                try {
                    $output = & "$PSScriptRoot\df_scripts\X3D-Undervolt-Tester.ps1" 2>&1
                    if ($output) {
                        $resultsBox.AppendText($output)
                    } else {
                        $resultsBox.AppendText("Undervolt Testing completed with no output.`r`n")
                    }
                } catch {
                    $resultsBox.AppendText("Error running undervolt test: $($_.Exception.Message)`r`n")
                    $resultsBox.AppendText("This may be due to insufficient privileges or execution context.`r`n")
                }
            }
            "FingerprintCapture" {
                $resultsBox.AppendText("Running Training Fingerprint Capture...`r`n")
                $resultsBox.AppendText("-" * 30 + "`r`n")
                
                # Execute fingerprint capture and capture output
                try {
                    $output = & "$PSScriptRoot\df_scripts\Capture-TrainingFingerprint.ps1" 2>&1
                    if ($output) {
                        # Format the fingerprint capture output for better readability
                        $resultsBox.AppendText("Training Fingerprint Capture Results:`r`n")
                        $resultsBox.AppendText("=" * 40 + "`r`n")
                        $resultsBox.AppendText($output)
                    } else {
                        $resultsBox.AppendText("Training Fingerprint Capture completed with no output.`r`n")
                    }
                } catch {
                    $resultsBox.AppendText("Error during fingerprint capture: $($_.Exception.Message)`r`n")
                }
            }
            "FullSetup" {
                $resultsBox.AppendText("Running Full System Setup...`r`n")
                $resultsBox.AppendText("-" * 30 + "`r`n")
                $resultsBox.AppendText("Step 1: Pre-Race Quiet Mode`r`n")
                $output1 = & "$PSScriptRoot\df_scripts\Pre-Race-Quiet.ps1" 2>&1
                if ($output1) { $resultsBox.AppendText($output1) }
                $resultsBox.AppendText("Step 2: Preflight Check`r`n")
                $output2 = & "$PSScriptRoot\df_scripts\Preflight-Check.ps1" 2>&1
                if ($output2) { $resultsBox.AppendText($output2) }
                $resultsBox.AppendText("Step 3: Chip Profile Detection`r`n")
                $output3 = & "$PSScriptRoot\df_scripts\X3D-Profiles.ps1" -HumanReadable 2>&1
                if ($output3) { $resultsBox.AppendText($output3) }
                $resultsBox.AppendText("Step 4: Health Report`r`n")
                $output4 = & "$PSScriptRoot\df_scripts\Health-Report.ps1" 2>&1
                if ($output4) { $resultsBox.AppendText($output4) }
                $resultsBox.AppendText("Setup complete!`r`n")
            }
            "Exit" {
                $form.Close()
                return
            }
        }
        
        $resultsBox.AppendText("`r`nOperation completed successfully.`r`n")
    }
    catch {
        $resultsBox.AppendText("Error occurred: $($_.Exception.Message)`r`n")
        $resultsBox.AppendText("Stack trace: $($_.Exception.StackTrace)`r`n")
    }
    
    # Scroll to bottom
    $resultsBox.ScrollToCaret()
}

# Set initial focus
$form.Add_Shown({$form.Activate()})

# Form closing event to clean up PowerShell processes
$form.add_FormClosing({
    param($sender, $e)
    
    # Kill any PowerShell processes launched by this GUI
    foreach ($process in $psProcesses) {
        try {
            if ($process -and !$process.HasExited) {
                $process.Kill()
            }
        } catch {
            # Ignore errors when trying to kill processes
        }
    }
    
    # Clear the process list
    $psProcesses.Clear()
})

# Show the form
$form.ShowDialog() | Out-Null