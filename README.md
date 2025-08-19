# Firefox Privacy Configuration

A comprehensive, security-hardened setup for Firefox that maximizes privacy protection using the latest Betterfox configuration, enhanced security policies, and automated deployment tools.

## 🔒 Security Features

This repository provides **enterprise-grade privacy protection** with:

- **WebRTC leak protection** - Prevents IP address exposure through VPNs
- **Canvas fingerprinting resistance** - Blocks advanced tracking techniques
- **WebGL hardening** - Prevents system information leakage
- **Enhanced HTTPS enforcement** - Strict SSL/TLS security
- **DNS-over-HTTPS** - Encrypted DNS queries via Mozilla/Cloudflare
- **Media device privacy** - Blocks camera/microphone enumeration
- **Comprehensive telemetry blocking** - Zero data collection by Mozilla

## Overview

This repository contains scripts and configuration files to set up Firefox with **maximum privacy protection** and security hardening. It includes:

- **Enhanced Firefox policies** for organizational security settings
- **Hardened Betterfox user.js** configuration with additional privacy protections
- **Secure PowerShell setup script** with integrity validation
- **Security validation tools** for ongoing maintenance
- **Common overrides** for fine-tuned customization

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

```powershell
git clone https://github.com/cviorel/firefox-privacy-setup
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

## 🛡️ Security & Privacy Features

### **Critical Privacy Protections**

- **WebRTC Leak Prevention**: Blocks real IP address exposure even when using VPNs
- **Canvas Fingerprinting Resistance**: Advanced protection against browser fingerprinting
- **WebGL Hardening**: Prevents graphics API from exposing system information
- **Media Device Privacy**: Blocks enumeration of cameras, microphones, and other devices
- **Battery API Disabled**: Prevents battery-based device fingerprinting
- **Clipboard Protection**: Blocks malicious websites from accessing clipboard content

### **Enhanced Security Features**

- **HTTPS-First Policy**: Enforces encrypted connections with mixed content blocking
- **DNS-over-HTTPS**: Encrypted DNS queries via trusted Mozilla/Cloudflare provider
- **Strict SSL/TLS Configuration**: Enhanced certificate validation and security
- **Security Bypass Protection**: Prevents bypassing of certificate and safe browsing warnings
- **DRM Disabled**: Encrypted Media Extensions blocked for privacy
- **Enhanced Password Protection**: Built-in password manager disabled for security

### **Comprehensive Telemetry Blocking**

- Complete Mozilla telemetry and data collection disabled
- Crash reporting and studies blocked
- Firefox Accounts and Sync disabled
- Normandy experiments and Shield studies blocked
- Captive portal detection disabled

### **Performance Optimizations**

- Optimized content loading and caching
- Enhanced graphics performance (where security permits)
- Network connection optimizations
- Memory usage improvements
- Reduced DNS lookup times

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

### Security Validation

Run the security validation script to verify your configuration:

```powershell
# Basic security check
.\security-check.ps1

# Detailed analysis with report export
.\security-check.ps1 -Detailed -ExportReport
```

### Logs

The setup script creates detailed logs in the same directory:

- `FirefoxProfileSetup.log` - Setup process log
- `security-report-*.json` - Security validation reports (when using security-check.ps1)

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

## ⚠️ Security Notice & Compatibility

### **Security Considerations**

This configuration prioritizes **maximum privacy and security** over convenience. Some websites may not function correctly with these hardened settings.

### **Known Compatibility Issues**

- **Video Calling**: WebRTC disabled - Zoom, Teams, Google Meet may not work
- **3D Graphics**: WebGL disabled - Games and 3D applications will not function
- **Canvas Applications**: Some graphics-intensive sites may have display issues
- **Fingerprinting Protection**: Sites may display incorrectly due to spoofed browser characteristics

### **Recommended Workarounds**

1. **Separate Profile**: Use a different Firefox profile for work/video calling
2. **Temporary Disable**: Temporarily disable `privacy.resistFingerprinting` for specific sites
3. **Alternative Browser**: Use Chromium-based browser for WebGL-dependent applications
4. **Firefox Containers**: Use containers for site-specific relaxed settings

### **Maintenance Requirements**

- **Monthly Reviews**: Check for Betterfox updates and security advisories
- **Security Validation**: Run `security-check.ps1` regularly to verify configuration
- **Extension Updates**: Monitor and update security extensions
- **Policy Reviews**: Update policies based on new privacy threats

## 📋 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and security improvements.

## 🔧 Advanced Configuration

### Custom Security Levels

You can adjust security levels by modifying specific settings:

```javascript
// For less restrictive WebRTC (allow local IPs only)
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.enabled", true);

// For sites requiring WebGL (temporary)
user_pref("webgl.disabled", false);

// For reduced fingerprinting protection (if needed)
user_pref("privacy.resistFingerprinting", false);
```

### Security Validation

Regular security validation is recommended:

```powershell
# Weekly security check
.\security-check.ps1 -Detailed

# Monthly comprehensive report
.\security-check.ps1 -ExportReport
```
