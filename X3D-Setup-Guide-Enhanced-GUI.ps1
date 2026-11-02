# X3D tuner. One action: scan this PC and apply the reversible Windows fixes.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scanPath = Join-Path $PSScriptRoot 'df_scripts\Invoke-X3DScan.ps1'
$reportDir = Join-Path $env:ProgramData 'X3DTuner'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'X3D tuner'
$form.Size = New-Object System.Drawing.Size(920, 640)
$form.StartPosition = 'CenterScreen'

$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Size = New-Object System.Drawing.Size(200, 580)
$buttonPanel.Location = New-Object System.Drawing.Point(10, 10)

$resultsBox = New-Object System.Windows.Forms.RichTextBox
$resultsBox.Location = New-Object System.Drawing.Point(220, 10)
$resultsBox.Size = New-Object System.Drawing.Size(670, 580)
$resultsBox.Font = New-Object System.Drawing.Font('Consolas', 10)
$resultsBox.ReadOnly = $true

function New-ScanButton {
    param([string]$Text, [int]$Top, [bool]$AsDryRun)
    $box = $resultsBox
    $window = $form
    $path = $scanPath
    $dir = $reportDir
    $dry = $AsDryRun
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size(180, 40)
    $button.Location = New-Object System.Drawing.Point(10, $Top)
    $button.Add_Click({
        $box.Clear()
        $box.AppendText("Scanning...`r`n")
        $window.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
        try {
            if ($dry) { $report = & $path -DryRun -PassThru }
            else { $report = & $path -PassThru }
            $box.Clear()
            if (-not $report) {
                $box.AppendText("The scan did not return a report.`r`n")
                return
            }
            $box.AppendText("X3D tuner`r`n")
            $box.AppendText("$($report.chip.model)`r`n")
            $box.AppendText("$($report.chip.advice)`r`n")
            $box.AppendText("BIOS $($report.measured.bios_version)  |  $($report.measured.memory_modules) memory module(s)")
            if ($report.measured.memory_speed_mhz) { $box.AppendText(" at $($report.measured.memory_speed_mhz) MHz") }
            $box.AppendText("`r`n")
            if ($report.dry_run) { $box.AppendText("Dry run. Nothing was written.`r`n") }
            $box.AppendText("`r`n")
            foreach ($item in @($report.items)) {
                $reboot = if ($item.reboot_required) { '  reboot required' } else { '' }
                $box.AppendText("$($item.id): $($item.status)$reboot`r`n")
                $box.AppendText("  before: $($item.before)`r`n")
                $box.AppendText("  after:  $($item.after)`r`n")
                if ($item.script) { $box.AppendText("  script: $($item.script)`r`n") }
                if ($item.detail) { $box.AppendText("  $($item.detail)`r`n") }
                $box.AppendText("`r`n")
            }
            if (-not $report.dry_run) {
                $box.AppendText("Report: $dir\latest-report.json`r`n")
                $box.AppendText("History: $dir\history.jsonl`r`n")
            }
            $box.SelectionStart = 0
            $box.ScrollToCaret()
        } catch {
            $box.AppendText("Scan failed: $($_.Exception.Message)`r`n")
        } finally {
            $window.Cursor = [System.Windows.Forms.Cursors]::Default
        }
    }.GetNewClosure())
    $buttonPanel.Controls.Add($button)
}

New-ScanButton -Text 'Scan and fix' -Top 20 -AsDryRun $false
New-ScanButton -Text 'Dry run' -Top 70 -AsDryRun $true

$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = 'Exit'
$exitButton.Size = New-Object System.Drawing.Size(180, 40)
$exitButton.Location = New-Object System.Drawing.Point(10, 130)
$exitButton.Add_Click({ $form.Close() }.GetNewClosure())
$buttonPanel.Controls.Add($exitButton)

$form.Controls.Add($buttonPanel)
$form.Controls.Add($resultsBox)
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
