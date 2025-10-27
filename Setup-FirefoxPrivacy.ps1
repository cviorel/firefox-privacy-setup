<#
.SYNOPSIS
Sets up a privacy-focused Firefox profile by removing existing profiles, creating a new profile, and applying custom configurations and policies.

.DESCRIPTION
This script automates the setup of a privacy-focused Firefox profile. It performs the following tasks:
1. Stops any running Firefox processes.
2. Backs up existing Firefox profiles (unless the -NoBackup switch is specified).
3. Removes existing Firefox profiles and related files.
4. Creates a new Firefox profile with a specified name and applies custom configurations from user.js and common-overrides.js files.
5. Installs Firefox policies from a specified policies.json file.
6. Launches Firefox with the new profile.

.PARAMETER ProfileName
The name of the new Firefox profile to be created. Default is "Privacy".

.PARAMETER FirefoxPath
The path to the Firefox executable. Default is "${env:ProgramFiles}\Mozilla Firefox\firefox.exe".

.PARAMETER DefaultProfilesPath
The path to the default Firefox profiles directory. Default is the 'Profiles' directory under the user's ApplicationData\Mozilla\Firefox folder.

.PARAMETER MozillaPath
The path to the Mozilla Firefox directory. Default is the 'Firefox' directory under the user's ApplicationData\Mozilla folder.

.PARAMETER LocalAppDataMozillaPath
The path to the local application data Mozilla Firefox directory. Default is the 'Firefox' directory under the user's LocalApplicationData\Mozilla folder.

.PARAMETER UserJsPath
The path to the user.js file containing custom configurations. Default is "user.js" in the script's directory.

.PARAMETER OverridesPath
The path to the common-overrides.js file containing additional configurations. Default is "common-overrides.js" in the script's directory.

.PARAMETER Force
If specified, forces the script to proceed without prompting for confirmation and ignores certain errors.

.PARAMETER NoBackup
If specified, skips the backup of existing Firefox profiles.

.EXAMPLE
.\Setup-FirefoxPrivacy.ps1 -ProfileName "MyPrivacyProfile" -FirefoxPath "C:\Program Files\Mozilla Firefox\firefox.exe" -Force

.EXAMPLE
.\Setup-FirefoxPrivacy.ps1 -NoBackup

.NOTES
- Requires PowerShell 5.1 or higher.
- Must be run as Administrator.
- Logs are written to "FirefoxProfileSetup.log" in the script's directory.

#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('^[a-zA-Z0-9_-]+$')]
    [ValidateLength(1,50)]
    [string]$ProfileName = "Privacy",

    [Parameter(Position = 1)]
    [ValidateScript({
            if (-not (Test-Path $_)) {
                throw "Firefox executable not found at: $_"
            }
            return $true
        })]
    [string]$FirefoxPath = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe",

    [Parameter(Position = 2)]
    [string]$DefaultProfilesPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('ApplicationData'), 'Mozilla', 'Firefox', 'Profiles'),

    [Parameter(Position = 3)]
    [string]$MozillaPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('ApplicationData'), 'Mozilla', 'Firefox'),

    [Parameter(Position = 4)]
    [string]$LocalAppDataMozillaPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('LocalApplicationData'), 'Mozilla', 'Firefox'),

    [Parameter(Position = 5)]
    [ValidateScript({
            if (-not (Test-Path $_)) {
                throw "user.js file not found at: $_"
            }
            return $true
        })]
    [string]$UserJsPath = (Join-Path $PSScriptRoot "user.js"),

    [Parameter(Position = 6)]
    [ValidateScript({
            if (-not (Test-Path $_)) {
                throw "common-overrides.js file not found at: $_"
            }
            return $true
        })]
    [string]$OverridesPath = (Join-Path $PSScriptRoot "common-overrides.js"),

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$NoBackup
)

# Set strict mode and error action preference
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Initialize script-wide variables
$script:LogPath = Join-Path $PSScriptRoot "FirefoxProfileSetup.log"
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
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp][$Level] $Message"

    # Console output with color
    switch ($Level) {
        'ERROR' { Write-Host $logMessage -ForegroundColor Red }
        'WARNING' { Write-Host $logMessage -ForegroundColor Yellow }
        default { Write-Host $logMessage }
    }

    # File output
    Add-Content -Path $script:LogPath -Value $logMessage
}

function Backup-FirefoxProfile {
    [CmdletBinding()]
    param([string]$ProfilePath)

    try {
        if ($NoBackup) {
            Write-Log -Message "Skipping backup as -NoBackup switch was specified" -Level WARNING
            return
        }

        $backupPath = Join-Path $PSScriptRoot "FirefoxBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Log -Message "Creating backup at: $backupPath"

        if (Test-Path $ProfilePath) {
            $null = Copy-Item -Path $ProfilePath -Destination $backupPath -Recurse -Force
            Write-Log -Message "Backup completed successfully"
        }
    }
    catch {
        Write-Log -Message "Failed to create backup: $_" -Level ERROR
        if (-not $Force) { throw }
    }
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

            # Double-check all processes are stopped
            if (Get-Process -Name "firefox" -ErrorAction SilentlyContinue) {
                throw "Failed to stop all Firefox processes"
            }
        }
    }
    catch {
        Write-Log -Message "Error stopping Firefox processes: $($_.Exception.Message)" -Level ERROR
        if (-not $Force) { throw }
    }
}

function Remove-ExistingProfiles {
    [CmdletBinding()]
    param([switch]$SkipBackup)

    Write-Log -Message "Removing existing Firefox profiles..."

    try {
        if (-not $SkipBackup) {
            Backup-FirefoxProfile -ProfilePath $DefaultProfilesPath
        }

        # Remove directories and recreate them
        @($DefaultProfilesPath, $LocalAppDataMozillaPath) | ForEach-Object {
            if (Test-Path $_) {
                Remove-Item -Path $_ -Recurse -Force -ErrorAction Stop
                $null = New-Item -ItemType Directory -Path $_ -Force
            }
        }

        # Remove specific files
        @(
            (Join-Path $MozillaPath "profiles.ini"),
            (Join-Path $MozillaPath "times.json")
        ) | Where-Object { Test-Path $_ } | Remove-Item -Force

        Write-Log -Message "Successfully removed existing profiles"
    }
    catch {
        Write-Log -Message "Failed to remove existing profiles: $_" -Level ERROR
        throw
    }
}

function New-FirefoxProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ProfileName,
        [string]$UserJsContent
    )

    try {
        Write-Log -Message "Creating new Firefox profile: $ProfileName"

        # Create profile directory
        $profileDir = Join-Path $DefaultProfilesPath $ProfileName
        $null = New-Item -ItemType Directory -Path $profileDir -Force

        # Create profile using Firefox
        $createProfileArg = "-CreateProfile `"$ProfileName $profileDir`""
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processStartInfo.FileName = $FirefoxPath
        $processStartInfo.Arguments = $createProfileArg
        $processStartInfo.UseShellExecute = $false
        $processStartInfo.RedirectStandardOutput = $true
        $processStartInfo.RedirectStandardError = $true
        $processStartInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processStartInfo
        $null = $process.Start()
        $process.WaitForExit(30000) # 30-second timeout

        if ($process.ExitCode -ne 0) {
            throw "Firefox profile creation failed with exit code: $($process.ExitCode)"
        }

        # Write user.js content if provided
        if ($UserJsContent) {
            [System.IO.File]::WriteAllText(
                (Join-Path $profileDir "user.js"),
                $UserJsContent,
                [System.Text.UTF8Encoding]::new($false)
            )
        }

        Write-Log -Message "Profile created successfully: $profileDir"
        return $profileDir
    }
    catch {
        Write-Log -Message "Failed to create Firefox profile: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Install-FirefoxPolicies {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PoliciesJsonPath
    )

    try {
        Write-Log -Message "Installing Firefox policies..."

        # Validate policy file
        if (-not (Test-Path $PoliciesJsonPath)) {
            throw "Policies JSON file not found: $PoliciesJsonPath"
        }

        # Validate JSON content and structure
        try {
            $jsonContent = Get-Content $PoliciesJsonPath -Raw | ConvertFrom-Json
            if (-not $jsonContent.policies) {
                throw "Invalid policy structure: missing 'policies' key"
            }
        }
        catch {
            throw "Invalid JSON content in policies file: $_"
        }

        # Validate file integrity (basic size check)
        $fileInfo = Get-Item $PoliciesJsonPath
        if ($fileInfo.Length -lt 100 -or $fileInfo.Length -gt 50KB) {
            Write-Log -Message "Warning: Policy file size seems unusual ($($fileInfo.Length) bytes)" -Level WARNING
        }

        $policiesDir = Join-Path $env:ProgramFiles "Mozilla Firefox\distribution"
        $policiesFile = Join-Path $policiesDir "policies.json"

        # Create directory if needed
        if (-not (Test-Path $policiesDir)) {
            $null = New-Item -ItemType Directory -Path $policiesDir -Force
            Write-Log -Message "Created directory: $policiesDir"
        }

        # Copy policy file
        Copy-Item -Path $PoliciesJsonPath -Destination $policiesFile -Force

        # Set permissions using .NET for better performance
        $acl = Get-Acl $policiesFile
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "BUILTIN\Users",
            "Read",
            "Allow"
        )
        $acl.SetAccessRule($rule)
        Set-Acl $policiesFile $acl

        Write-Log -Message "Firefox policies installed successfully"
    }
    catch {
        Write-Log -Message "Failed to install Firefox policies: $_" -Level ERROR
        throw
    }
}


# Main execution block
try {
    if (-not $Force) {
        Write-Log -Message "WARNING: This script will remove all existing Firefox profiles!" -Level WARNING
        Write-Log -Message "Press Ctrl+C within 5 seconds to cancel..."
        Start-Sleep -Seconds 5
    }

    # Read and merge configuration files
    $mergedUserJs = @(Get-Content -Path $UserJsPath -Raw
        Get-Content -Path $OverridesPath -Raw) -join "`n"

    # Execute main tasks
    Stop-FirefoxProcesses
    Remove-ExistingProfiles -SkipBackup:$NoBackup
    New-FirefoxProfile -ProfileName $ProfileName -UserJsContent $mergedUserJs

    # Create profiles.ini using .NET for better performance
    $profilesIniPath = Join-Path $MozillaPath "profiles.ini"
    $profilesIniContent = @"
[Install4F96D1932A9F858E]
Default=$ProfileName
Locked=1

[Profile0]
Name=$ProfileName
IsRelative=1
Path=Profiles/$ProfileName
Default=1
"@
    [System.IO.File]::WriteAllText($profilesIniPath, $profilesIniContent)

    # Install policies
    Install-FirefoxPolicies -PoliciesJsonPath (Join-Path $PSScriptRoot "policies.json")

    # Launch Firefox
    Write-Log -Message "Starting Firefox with new profile..."
    Start-Process $FirefoxPath -ArgumentList "-P `"$ProfileName`""

    Write-Log -Message "Setup completed successfully!"
}
catch {
    Write-Log -Message $_.Exception.Message -Level ERROR
    Write-Log -Message $_.ScriptStackTrace -Level ERROR
    exit 1
}
