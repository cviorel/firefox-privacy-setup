<#
.SYNOPSIS
Resets Firefox to factory defaults by removing enterprise policies and profile customizations created by this project.

.DESCRIPTION
This script removes organization policies, profile locks, and custom preference files so Firefox starts as if freshly installed.
It can perform either a hard reset (delete all profiles and config so Firefox recreates a clean default on next launch),
or a soft reset (preserve existing profiles but remove user.js and unlock profiles.ini).

.PARAMETER FirefoxPath
Path to firefox.exe. Defaults to "${env:ProgramFiles}\Mozilla Firefox\firefox.exe".

.PARAMETER DefaultProfilesPath
Path to the Firefox 'Profiles' directory under AppData\Roaming\Mozilla\Firefox.

.PARAMETER MozillaPath
Path to the AppData\Roaming\Mozilla\Firefox directory.

.PARAMETER LocalAppDataMozillaPath
Path to the AppData\Local\Mozilla\Firefox directory.

.PARAMETER Force
Proceed without prompt and continue on recoverable errors.

.PARAMETER NoBackup
Skip backup of existing data.

.PARAMETER PreserveProfiles
Perform a soft reset: keep existing profiles, remove user.js in each profile, and remove 'Locked=' from profiles.ini.

.PARAMETER Launch
Launch Firefox once after reset to initialize defaults.

.EXAMPLE
.\Reset-FirefoxDefaults.ps1

.EXAMPLE
.\Reset-FirefoxDefaults.ps1 -PreserveProfiles -Launch

.NOTES
- Requires PowerShell 5.1 or higher.
- Must be run as Administrator to remove policies from Program Files.
- Logs are written to "FirefoxReset.log" in the script's directory.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateScript({
        if (-not (Test-Path $_)) {
            throw "Firefox executable not found at: $_"
        }
        return $true
    })]
    [string]$FirefoxPath = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe",

    [Parameter(Position = 1)]
    [string]$DefaultProfilesPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('ApplicationData'), 'Mozilla', 'Firefox', 'Profiles'),

    [Parameter(Position = 2)]
    [string]$MozillaPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('ApplicationData'), 'Mozilla', 'Firefox'),

    [Parameter(Position = 3)]
    [string]$LocalAppDataMozillaPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('LocalApplicationData'), 'Mozilla', 'Firefox'),

    [Parameter()]
    [switch]$Force,

    [Parameter()]
   [switch]$NoBackup,

    [Parameter()]
    [switch]$PreserveProfiles,

    [Parameter()]
    [switch]$Launch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Initialize logging
$script:LogPath = Join-Path $PSScriptRoot "FirefoxReset.log"
$logDir = Split-Path -Parent $script:LogPath
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('INFO','WARNING','ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp][$Level] $Message"

    switch ($Level) {
        'ERROR' { Write-Host $logMessage -ForegroundColor Red }
        'WARNING' { Write-Host $logMessage -ForegroundColor Yellow }
        default { Write-Host $logMessage }
    }

    Add-Content -Path $script:LogPath -Value $logMessage
}

function Stop-FirefoxProcesses {
    [CmdletBinding()]
    param()
    try {
        $processes = Get-Process -Name "firefox" -ErrorAction SilentlyContinue
        if ($processes) {
            Write-Log -Message "Stopping Firefox processes..."
            $processes | ForEach-Object {
                try {
                    $_ | Stop-Process -Force
                    $null = $_.WaitForExit(5000)
                }
                catch {
                    Write-Log -Message "Failed to stop process $($_.Id): $_" -Level WARNING
                }
            }
            if (Get-Process -Name "firefox" -ErrorAction SilentlyContinue) {
                throw "Failed to stop all Firefox processes"
            }
        }
    }
    catch {
        Write-Log -Message "Error stopping Firefox: $($_.Exception.Message)" -Level ERROR
        if (-not $Force) { throw }
    }
}

function Backup-FirefoxData {
    [CmdletBinding()]
    param()
    try {
        if ($NoBackup) {
            Write-Log -Message "Skipping backup as -NoBackup was specified" -Level WARNING
            return
        }

        $backupRoot = Join-Path $PSScriptRoot "FirefoxResetBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Log -Message "Creating backup at: $backupRoot"
        $null = New-Item -ItemType Directory -Path $backupRoot -Force

        $items = @(
            @{ Path = $MozillaPath; Dest = Join-Path $backupRoot "Roaming\Mozilla\Firefox" },
            @{ Path = $LocalAppDataMozillaPath; Dest = Join-Path $backupRoot "Local\Mozilla\Firefox" },
            @{ Path = (Join-Path $env:ProgramFiles "Mozilla Firefox\distribution"); Dest = Join-Path $backupRoot "ProgramFiles\Mozilla Firefox\distribution" }
        )

        foreach ($item in $items) {
            if (Test-Path $item.Path) {
                $destDir = Split-Path -Parent $item.Dest
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }
                Copy-Item -Path $item.Path -Destination $item.Dest -Recurse -Force -ErrorAction Stop
                Write-Log -Message "Backed up: $($item.Path)"
            }
        }
        Write-Log -Message "Backup completed successfully"
    }
    catch {
        Write-Log -Message "Failed to create backup: $_" -Level ERROR
        if (-not $Force) { throw }
    }
}

function Remove-Policies {
    [CmdletBinding()]
    param()
    try {
        $policiesDir = Join-Path $env:ProgramFiles "Mozilla Firefox\distribution"
        $policiesFile = Join-Path $policiesDir "policies.json"
        if (Test-Path $policiesFile) {
            Write-Log -Message "Removing enterprise policy file: $policiesFile"
            Remove-Item -Path $policiesFile -Force -ErrorAction Stop
        }
        if (Test-Path $policiesDir) {
            $hasItems = Get-ChildItem -Path $policiesDir -Force | Measure-Object | Select-Object -ExpandProperty Count
            if ($hasItems -eq 0) {
                Write-Log -Message "Removing empty distribution directory: $policiesDir"
                Remove-Item -Path $policiesDir -Force
            }
        }
    }
    catch {
        Write-Log -Message "Failed to remove policies: $_" -Level ERROR
        if (-not $Force) { throw }
    }
}

function Reset-Profiles {
    [CmdletBinding()]
    param()
    try {
        if ($PreserveProfiles) {
            Write-Log -Message "Soft reset: preserving profiles; removing user.js and unlocking profiles.ini"
            if (Test-Path $DefaultProfilesPath) {
                Get-ChildItem -Path $DefaultProfilesPath -Filter "user.js" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        Remove-Item -Path $_.FullName -Force
                        Write-Log -Message "Removed: $($_.FullName)"
                    }
                    catch {
                        Write-Log -Message "Failed to remove $($_.FullName): $_" -Level WARNING
                    }
                }
            }
            $profilesIniPath = Join-Path $MozillaPath "profiles.ini"
            if (Test-Path $profilesIniPath) {
                $content = Get-Content -Path $profilesIniPath -ErrorAction Stop
                $newContent = $content | Where-Object { $_ -notmatch '^\s*Locked\s*=' }
                if ($newContent -ne $content) {
                    Set-Content -Path $profilesIniPath -Value $newContent -Encoding ASCII
                    Write-Log -Message "Removed Locked= entries from profiles.ini"
                }
            }
        }
        else {
            Write-Log -Message "Hard reset: removing profiles and configuration"
            @($DefaultProfilesPath, $LocalAppDataMozillaPath) | ForEach-Object {
                if (Test-Path $_) {
                    Write-Log -Message "Removing directory: $_"
                    Remove-Item -Path $_ -Recurse -Force -ErrorAction Stop
                    $null = New-Item -ItemType Directory -Path $_ -Force
                }
            }
            @(
                (Join-Path $MozillaPath "profiles.ini"),
                (Join-Path $MozillaPath "times.json"),
                (Join-Path $MozillaPath "installs.ini")
            ) | Where-Object { Test-Path $_ } | ForEach-Object {
                Write-Log -Message "Removing file: $_"
                Remove-Item -Path $_ -Force -ErrorAction Stop
            }
        }
        Write-Log -Message "Profile reset completed"
    }
    catch {
        Write-Log -Message "Failed to reset profiles: $_" -Level ERROR
        throw
    }
}

# Main
try {
    if (-not $Force) {
        Write-Log -Message "WARNING: This will remove Firefox enterprise policies and reset profiles to defaults" -Level WARNING
        Write-Log -Message "Press Ctrl+C within 5 seconds to cancel..."
        Start-Sleep -Seconds 5
    }

    Stop-FirefoxProcesses
    Backup-FirefoxData
    Remove-Policies
    Reset-Profiles

    if ($Launch) {
        Write-Log -Message "Launching Firefox to initialize default profile..."
        Start-Process -FilePath $FirefoxPath
    }

    Write-Log -Message "Reset completed successfully!"
}
catch {
    Write-Log -Message $_.Exception.Message -Level ERROR
    Write-Log -Message $_.ScriptStackTrace -Level ERROR
    exit 1
}
