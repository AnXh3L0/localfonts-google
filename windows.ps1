# This script downloads and installs new Google Fonts on Windows 10/11
# Requires Git and administrative privileges
# https://github.com/AnXh3L0

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script needs to be run as Administrator. Please re-run the script as Administrator."
    Exit
}

$FONTS_FOLDER = "$PSScriptRoot\google-fonts"
$REPO_FOLDER = "$PSScriptRoot\repository"
$TRACKER_FILE = "$PSScriptRoot\installed_fonts.txt"
$CHECK_INTERVAL_DAYS = 7

# Ensure the fonts folder exists
if (-not (Test-Path -Path $FONTS_FOLDER)) {
    New-Item -Path $FONTS_FOLDER -ItemType Directory
}

# Clone or update the Google Fonts repository
if (-not (Test-Path -Path $REPO_FOLDER)) {
    Write-Host "Cloning Google Fonts repository..."
    git clone --depth=1 https://github.com/google/fonts $REPO_FOLDER
} else {
    Write-Host "Updating Google Fonts repository..."
    Set-Location -Path $REPO_FOLDER
    git pull --ff-only
    Set-Location -Path $PSScriptRoot
}

# Initialize the tracker file if it doesn't exist
if (-not (Test-Path -Path $TRACKER_FILE)) {
    New-Item -Path $TRACKER_FILE -ItemType File
}

# Function to install new fonts
function Install-NewFonts {
    Get-ChildItem -Path "$REPO_FOLDER" -Recurse -Filter "*.ttf" | ForEach-Object {
        $fontPath = $_.FullName
        $baseFontFile = $_.Name

        if (-not (Select-String -Path $TRACKER_FILE -Pattern $baseFontFile -Quiet)) {
            Write-Host "Processing new font: $baseFontFile"
            Copy-Item -Path $fontPath -Destination $FONTS_FOLDER
            Add-Content -Path $TRACKER_FILE -Value $baseFontFile
        } else {
            Write-Host "Font $baseFontFile already installed. Skipping..."
        }
    }
}

# Install new fonts
Install-NewFonts

# Move fonts to the Windows system fonts folder
$SystemFontsFolder = "$env:WINDIR\Fonts"
Write-Host "Moving all new fonts to the system fonts folder..."
Copy-Item -Path "$FONTS_FOLDER\*" -Destination $SystemFontsFolder -Force

# Clean up the temporary fonts folder
Remove-Item -Path $FONTS_FOLDER -Recurse

Write-Host "`n========== Fonts copied, you can now start using them! ==========`n"

# Set up Task Scheduler for automatic updates every 7 days
$taskName = "GoogleFontsUpdate"
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$PSScriptRoot\$(Split-Path -Leaf $PSCommandPath)`"
$taskTrigger = New-ScheduledTaskTrigger -At 12:00AM -Daily -RepetitionInterval (New-TimeSpan -Days $CHECK_INTERVAL_DAYS)
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopOnIdleEnd -StartWhenAvailable

# Register the task if it doesn't already exist
if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings
    Write-Host "Task scheduled to check for new fonts every $CHECK_INTERVAL_DAYS days."
} else {
    Write-Host "Task already exists."
}
