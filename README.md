# Firefox Privacy Configuration

A comprehensive setup for Firefox that enhances privacy, security, and performance using the Betterfox configuration and custom policies.

## Overview

This repository contains scripts and configuration files to set up Firefox with enhanced privacy settings, security hardening, and performance optimizations. It uses:

- Custom Firefox policies for organizational settings
- Betterfox user.js configuration
- PowerShell setup script for automated deployment
- Common overrides for fine-tuned customization

## Components

### 1. PowerShell Setup Script (`Setup-FirefoxPrivacy.ps1`)

Automates the Firefox profile setup process:

- Creates a new Firefox profile with privacy-focused settings
- Installs organization-wide policies
- Applies user preferences and common overrides
- Handles backup and restoration

#### Usage

```powershell
# Basic usage with default settings
.\Setup-FirefoxPrivacy.ps1

# Create a custom profile
.\Setup-FirefoxPrivacy.ps1 -ProfileName "CustomPrivacy"

# Force execution without prompts
.\Setup-FirefoxPrivacy.ps1 -Force

# Skip backup creation
.\Setup-FirefoxPrivacy.ps1 -NoBackup
```

### 2. Firefox Policies (`policies.json`)

Organization-wide policies that:

- Enable automatic updates
- Disable telemetry and studies
- Disable Pocket integration
- Install extensions:
  - uBlock Origin
  - Bitwarden Password Manager
  - LanguageTool
  - Linkding integration

### 3. User Preferences (`user.js`)

Based on the Betterfox project, includes optimizations for:

#### FastFox

- Improved content loading
- Optimized graphics performance
- Enhanced cache management
- Network connection optimizations

#### SecureFox

- Strict tracking protection
- Enhanced SSL/TLS security
- Privacy-focused browsing
- Telemetry disabled
- Crash reporting disabled

#### PeskyFox

- UI customizations
- Theme adjustments
- Cookie banner handling
- URL bar optimizations
- New tab page modifications

### 4. Common Overrides (`common-overrides.js`)

Additional customizations including:

- Startup behavior configuration
- Font rendering improvements
- Bookmarks toolbar settings
- Translation features
- Region-specific settings

## Installation

1. Clone this repository:

```bash
git clone [repository-url]
cd firefox-privacy-setup
```

2. Run the PowerShell script with administrator privileges:

```powershell
powershell -ExecutionPolicy Bypass -File .\Setup-FirefoxPrivacy.ps1
```

## Requirements

- Windows operating system
- Firefox browser installed
- PowerShell 5.1 or later
- Administrator privileges for policy installation

## Features

### Privacy Enhancements

- Disabled telemetry and data collection
- Enhanced tracking protection
- Secure DNS configuration
- Cookie and cache management
- Disabled potentially privacy-invasive features

### Security Features

- HTTPS-first policy
- Strict SSL/TLS configuration
- Enhanced password protection
- Mixed content blocking
- Safe browsing modifications

### Performance Optimizations

- Optimized content loading
- Enhanced graphics performance
- Improved cache management
- Network connection tweaks
- Memory usage optimizations

## Customization

### Modifying Policies

Edit `policies.json` to customize organizational policies:

```json
{
  "policies": {
    "DisableTelemetry": true,
    "DisablePocket": true
    // Add or modify policies here
  }
}
```

### Customizing User Preferences

Add personal overrides to `common-overrides.js`:

```javascript
// Custom preferences
user_pref("browser.startup.page", 3);
user_pref("browser.toolbars.bookmarks.visibility", "always");
```

## Troubleshooting

### Common Issues

1. **Script Execution Policy**

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   ```

2. **Profile Creation Fails**

   - Ensure Firefox is completely closed
   - Delete existing profiles if necessary
   - Run with administrator privileges

3. **Policy Installation Issues**
   - Verify administrator privileges
   - Check Firefox installation path
   - Ensure policies.json is valid

### Logs

The script creates detailed logs in the same directory:

- `FirefoxProfileSetup.log`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Betterfox Project](https://github.com/yokoffing/Betterfox)
- Mozilla Firefox Documentation
- Community contributors

## Security Notice

While this configuration enhances privacy and security, no system is completely secure. Regular updates and maintenance are essential for maintaining security.
